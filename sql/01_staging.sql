-- =========================================================
-- Creating a cleaned team_key_stats table with numeric values columns, removing "contest" rows
    -- and splitting values that are in "total (completed)" format
-- =========================================================
CREATE OR REPLACE TABLE team_key_stats_numeric AS
SELECT 
    *,
    TRY_CAST(
        REGEXP_EXTRACT(value, '^ *([0-9.]+)', 1) 
        AS DOUBLE
    ) AS num_value,
    TRY_CAST(
        REGEXP_EXTRACT(value, '\( *([0-9.]+) *\)', 1) 
        AS DOUBLE
    ) AS num_completed
FROM team_key_stats
WHERE team != 'contest';

-- =========================================================
-- Cross-checking if fifa_ranking uses the same naming conventions for team names
-- =========================================================
SELECT 
    COALESCE(r.team, f.team) AS team,
    r.team AS raw_dominance_team,
    f.team AS fifa_ranking_team,
    CASE 
        WHEN r.team = f.team THEN 'Match'
        WHEN r.team IS NULL THEN 'Only found in fifa_ranking'
        WHEN f.team IS NULL THEN 'Only found in raw_dominance'
        ELSE 'Different'
    END AS status
FROM (SELECT DISTINCT team FROM team_raw_dominance) r
FULL OUTER JOIN (SELECT DISTINCT team FROM fifa_ranking) f
    ON r.team = f.team
ORDER BY status, team;

-- =========================================================
-- Mapping the mismatched team names
-- =========================================================
CREATE OR REPLACE TABLE team_name_mapping AS
    SELECT 'Cape Verde' AS fifa_name, 'Cabo Verde' AS dominance_name
    UNION ALL
    SELECT 'Czech Republic', 'Czechia'
    UNION ALL
    SELECT 'DR Congo', 'Congo DR'
    UNION ALL
    SELECT 'Iran', 'IR Iran'
    UNION ALL
    SELECT 'Ivory Coast', 'Côte d''Ivoire'
    UNION ALL
    SELECT 'South Korea', 'Korea Republic'
    UNION ALL
    SELECT 'Turkey', 'Türkiye'
    UNION ALL
    SELECT 'United States', 'USA';

-- =========================================================
-- Uniting team names based on team_raw_dominance to keep initial data integrity
    -- keeping needed fields only: team, fifa_points
    -- calculating average opponent rating
-- =========================================================
CREATE OR REPLACE TABLE fifa_points_adjusted AS
WITH base AS (
    SELECT 
        COALESCE(m.dominance_name, f.team) AS team,
        f.fifa_points AS fifa_points
    FROM fifa_ranking f
    LEFT JOIN team_name_mapping m ON f.team = m.fifa_name
)
SELECT team, fifa_points FROM base
UNION ALL
SELECT 'AVG_OPPONENT_REFERENCE', AVG(fifa_points) FROM base;

-- =========================================================
-- All opponents faced by each team
-- =========================================================
CREATE OR REPLACE TABLE team_opponents AS
WITH all_opponents AS (
    SELECT home_team AS team, away_team AS opponent FROM matches
    UNION
    SELECT away_team AS team, home_team AS opponent FROM matches
),
opponents_distinct AS (
    SELECT DISTINCT team, opponent FROM all_opponents
),
numbered AS (
    SELECT 
        team,
        opponent,
        ROW_NUMBER() OVER (PARTITION BY team ORDER BY opponent) AS rn
    FROM opponents_distinct
)
SELECT 
    team,
    MAX(CASE WHEN rn = 1 THEN opponent END) AS opponent_1,
    MAX(CASE WHEN rn = 2 THEN opponent END) AS opponent_2,
    MAX(CASE WHEN rn = 3 THEN opponent END) AS opponent_3,
    MAX(CASE WHEN rn = 4 THEN opponent END) AS opponent_4,
    MAX(CASE WHEN rn = 5 THEN opponent END) AS opponent_5,
    MAX(CASE WHEN rn = 6 THEN opponent END) AS opponent_6,
    MAX(CASE WHEN rn = 7 THEN opponent END) AS opponent_7,
    MAX(CASE WHEN rn = 8 THEN opponent END) AS opponent_8
FROM numbered
GROUP BY team;
