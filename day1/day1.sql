DROP TABLE IF EXISTS calibration_values;

CREATE TABLE calibration_values (calibration_value TEXT);

COPY calibration_values FROM '/db_input/day1.txt';

-- Part 1

WITH trimed AS (
        SELECT
            TRIM(
                'abcdefghijklmnopqrstuvwxyz'
                FROM
                    cV.calibration_value
            ) AS trimed_value
        FROM
            calibration_values AS cV
    )
SELECT
    sum( (
            "left"(trimed.trimed_value, 1) || "right"(trimed.trimed_value, 1)
        ) :: numeric
    )
FROM trimed;

-- Part 2

With corrected_values AS (
        SELECT
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(
                            REPLACE(
                                REPLACE(
                                    REPLACE(
                                        REPLACE(
                                            calibration_value,
                                            'twone',
                                            'twoone'
                                        ),
                                        'threeight',
                                        'threeeight'
                                    ),
                                    'fiveight',
                                    'fiveeight'
                                ),
                                'sevenine',
                                'sevennine'
                            ),
                            'eighthree',
                            'eightthree'
                        ),
                        'eightwo',
                        'eighttwo'
                    ),
                    'nineight',
                    'nineeight'
                ),
                'oneight',
                'oneeight'
            ) AS corrected_calibration_value
        FROM
            calibration_values
    )
SELECT
    sum( (
            regExp_result.agg_val [1] || regExp_result.agg_val [array_length(regExp_result.agg_val, 1)]
        ) :: numeric
    )
FROM
    corrected_values AS cV,
    LATERAL (
        SELECT
            array_agg(
                CASE
                    WHEN value [1] = 'one' then '1'
                    WHEN value [1] = 'two' then '2'
                    WHEN value [1] = 'three' then '3'
                    WHEN value [1] = 'four' THEN '4'
                    WHEN value [1] = 'five' THEN '5'
                    WHEN value [1] = 'six' then '6'
                    WHEN value [1] = 'seven' then '7'
                    WHEN value [1] = 'eight' then '8'
                    WHEN value [1] = 'nine' then '9'
                    ELSE value [1]
                END
            ) AS agg_val
        FROM (
                SELECT
                    regexp_matches(
                        cV.corrected_calibration_value,
                        '([1-9]|one|two|three|four|five|six|seven|eight|nine)',
                        'g'
                    ) AS value
            ) subquery
    ) AS regExp_result;