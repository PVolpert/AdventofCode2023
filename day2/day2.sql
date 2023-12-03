DROP TABLE IF EXISTS game_values;

CREATE TABLE game_values (game TEXT, id SERIAL)

COPY game_values(game) FROM '/db_input/day2.txt';

-- Part 1

WITH draws AS (
        SELECT
            id,
            string_to_table(
                string_to_table(
                    regexp_replace(game, 'Game \d+: ', ''),
                    ';'
                ),
                ','
            ) AS draw
        FROM
            game_values AS gV
    ),
    single_draws AS (
        SELECT
            id AS gameId, (regexp_match(draw, '\d+')) [1] :: numeric AS amount, (
                regexp_match(draw, 'red|green|blue')
            ) [1] AS colour
        FROM
            draws
    ),
    valid_games AS (
        SELECT gameId
        FROM single_draws
        GROUP BY gameId
        HAVING
            every(
                colour = 'red'
                AND amount <= 12
                OR colour = 'blue'
                AND amount <= 14
                OR colour = 'green'
                AND amount <= 13
            )
    )
SELECT sum(gameId)
FROM valid_games;

-- Part 2

WITH draws AS (
        SELECT
            id,
            string_to_table(
                string_to_table(
                    regexp_replace(game, 'Game \d+: ', ''),
                    ';'
                ),
                ','
            ) AS draw
        FROM
            game_values AS gV
    ),
    single_draws AS (
        SELECT
            id AS gameId, (regexp_match(draw, '\d+')) [1] :: numeric AS amount, (
                regexp_match(draw, 'red|green|blue')
            ) [1] AS colour
        FROM
            draws
    ),
    min_valid_amounts AS (
        SELECT
            gameId,
            colour,
            max(amount) AS min_valid_amount
        FROM single_draws
        GROUP BY
            gameId,
            colour
    ),
    product AS (
        SELECT
            exp(sum(ln(min_valid_amount))) AS product
        FROM
            min_valid_amounts
        GROUP BY gameId
    )
SELECT
    sum(product.product) :: integer
FROM product