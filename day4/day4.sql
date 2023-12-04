DROP TABLE IF EXISTS scratch_ticket

CREATE TABLE scratch_ticket (ticket TEXT, id SERIAL)

COPY scratch_ticket(ticket) FROM '/db_input/day4.txt';

-- Part 1

WITH cards AS (
        SELECT
            id,
            string_to_array(
                regexp_replace(ticket, 'Card\s+\d+: ', ''),
                '|'
            ) as cap
        FROM
            scratch_ticket as sT
    ),
    draws as (
        SELECT
            id,
            draw:: numeric
        FROM
            cards,
            string_to_table(cap [1], ' ') as d(draw)
        WHERE
            draw != ''
    ),
    wants as (
        SELECT
            id,
            want:: numeric
        FROM
            cards,
            string_to_table(cap [2], ' ') as d(want)
        WHERE
            want != ''
    ),
    matchings_draws as (
        SELECT wants.id, draw
        FROM draws, wants
        WHERE
            wants.id = draws.id
            AND want = draw
    ),
    ticket_value as (
        SELECT
            pow(2, count(*) -1) as ticket_value
        FROM matchings_draws
        GROUP BY id
    )
SELECT sum(ticket_value)
FROM ticket_value;

-- Part 2 partial

WITH cards AS (
        SELECT
            id,
            string_to_array(
                regexp_replace(ticket, 'Card\s+\d+: ', ''),
                '|'
            ) as cap
        FROM
            scratch_ticket as sT
    ),
    draws as (
        SELECT
            id,
            draw:: numeric
        FROM
            cards,
            string_to_table(cap [1], ' ') as d(draw)
        WHERE
            draw != ''
    ),
    wants as (
        SELECT
            id,
            want:: numeric
        FROM
            cards,
            string_to_table(cap [2], ' ') as d(want)
        WHERE
            want != ''
    ),
    matchings_draws as (
        SELECT wants.id, draw
        FROM draws, wants
        WHERE
            wants.id = draws.id
            AND want = draw
    ),
    ticket_matches as (
        SELECT
            id,
            count(*) as matches,
            1 as count
        FROM matchings_draws
        GROUP BY id
    )
SELECT id, matches, count
FROM ticket_matches
UNION
SELECT id, 0, 1 as count
FROM cards
WHERE cards.id NOT IN (
        SELECT id
        FROM ticket_matches
    )
ORDER BY id;

-- exported to json for further processing ＼（〇_ｏ）／