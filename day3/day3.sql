DROP TABLE IF EXISTS engine_parts

CREATE TABLE engine_parts (entry TEXT, id SERIAL)

COPY engine_parts(entry) FROM '/db_input/day3.txt';

-- Part 1

WITH tabled_engine AS (
        SELECT
            id AS row,
            col,
            value
        FROM
            engine_parts,
            string_to_table(
                regexp_replace(
                    entry,
                    '\*|\+|&|-|%|=|#|\$|\\|/',
                    '@',
                    'g'
                ),
                NULL
            )
        WITH
            ORDINALITY AS c(value, col)
    ),
    markers AS (
        SELECT row, col
        FROM tabled_engine
        WHERE
            value = '@'
    ),
    unpaired_numbers AS (
        SELECT
            row,
            lag(col, 2) OVER (
                ORDER BY
                    row,
                    col
            ) AS two_prior_col,
            lag(col) OVER (
                ORDER BY
                    row,
                    col
            ) AS prior_col,
            col,
            lead(col) OVER (
                ORDER BY
                    row,
                    col
            ) As next_col,
            lag(value) OVER (
                ORDER BY
                    row,
                    col
            ) AS prior_val,
            value,
            lead(value) OVER (
                ORDER BY
                    row,
                    col
            ) As next_val
        FROM tabled_engine
        WHERE
            value != '@'
            AND value != '.'
    ),
    numbers AS (
        SELECT
            row,
            prior_col AS left_edge,
            next_col AS right_edge,
            prior_val || value || next_val AS value
        FROM unpaired_numbers
        WHERE
            prior_col = next_col - 2
        UNION
        SELECT
            row,
            prior_col AS left_edge,
            col AS right_edge,
            prior_val || value AS value
        FROM unpaired_numbers
        WHERE
            prior_col = col - 1
            AND prior_col != next_col - 2
            AND two_prior_col != col - 2
        UNION
        SELECT
            row,
            col AS left_edge,
            col AS right_edge,
            value AS value
        FROM unpaired_numbers
        WHERE
            prior_col != col - 1
            AND col != next_col - 1
    ),
    relevant_numbers AS (
        SELECT
            DISTINCT numbers.row,
            numbers.left_edge,
            numbers.right_edge,
            value
        FROM numbers, markers
        WHERE (
                markers.row = numbers.row
                AND (
                    markers.col = numbers.left_edge - 1
                    or markers.col = numbers.right_edge + 1
                )
            )
            OR (
                markers.row = numbers.row - 1
                AND (
                    markers.col BETWEEN numbers.left_edge - 1
                    AND numbers.right_edge + 1
                )
            )
            OR (
                markers.row = numbers.row + 1
                AND (
                    markers.col BETWEEN numbers.left_edge - 1
                    AND numbers.right_edge + 1
                )
            )
    )
SELECT sum(value :: numeric)
FROM relevant_numbers;

-- Part 2

WITH tabled_engine AS (
        SELECT
            id AS row,
            col,
            value
        FROM
            engine_parts,
            string_to_table(
                regexp_replace(
                    entry,
                    '@|\+|&|-|%|=|#|\$|\\|/',
                    '.',
                    'g'
                ),
                NULL
            )
        WITH
            ORDINALITY AS c(value, col)
    ),
    gears AS (
        SELECT row, col
        FROM tabled_engine
        WHERE
            value = '*'
    ),
    unpaired_numbers AS (
        SELECT
            row,
            lag(col, 2) OVER (
                ORDER BY
                    row,
                    col
            ) AS two_prior_col,
            lag(col) OVER (
                ORDER BY
                    row,
                    col
            ) AS prior_col,
            col,
            lead(col) OVER (
                ORDER BY
                    row,
                    col
            ) As next_col,
            lag(value) OVER (
                ORDER BY
                    row,
                    col
            ) AS prior_val,
            value,
            lead(value) OVER (
                ORDER BY
                    row,
                    col
            ) As next_val
        FROM tabled_engine
        WHERE
            value != '*'
            AND value != '.'
    ),
    numbers AS (
        SELECT
            row,
            prior_col AS left_edge,
            next_col AS right_edge,
            prior_val || value || next_val AS value
        FROM unpaired_numbers
        WHERE
            prior_col = next_col - 2
        UNION
        SELECT
            row,
            prior_col AS left_edge,
            col AS right_edge,
            prior_val || value AS value
        FROM unpaired_numbers
        WHERE
            prior_col = col - 1
            AND prior_col != next_col - 2
            AND two_prior_col != col - 2
        UNION
        SELECT
            row,
            col AS left_edge,
            col AS right_edge,
            value AS value
        FROM unpaired_numbers
        WHERE
            prior_col != col - 1
            AND col != next_col - 1
    ),
    relevant_gears AS (
        SELECT
            gears.row,
            gears.col,
            exp(sum(ln(value :: numeric))) AS product
        FROM numbers, gears
        WHERE (
                gears.row = numbers.row
                AND (
                    gears.col = numbers.left_edge - 1
                    or gears.col = numbers.right_edge + 1
                )
            )
            OR (
                gears.row = numbers.row - 1
                AND (
                    gears.col BETWEEN numbers.left_edge - 1
                    AND numbers.right_edge + 1
                )
            )
            OR (
                gears.row = numbers.row + 1
                AND (
                    gears.col BETWEEN numbers.left_edge - 1
                    AND numbers.right_edge + 1
                )
            )
        GROUP BY
            gears.row,
            gears.col
        HAVING count(*) = 2
    )
SELECT sum(product) :: integer
FROM relevant_gears;