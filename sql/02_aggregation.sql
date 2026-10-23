-- =========================================================
-- Creating raw dominance table
-- =========================================================
CREATE OR REPLACE TABLE team_raw_dominance AS
SELECT 
    t.team,
    AVG(t.num_value) FILTER (WHERE t.metric = 'Possession') AS possession_pct,
    AVG(
        CASE 
            WHEN t.metric = 'Total Passes (Complete)' 
                 AND t.num_value > 0 
            THEN (t.num_completed / t.num_value) * 100 
        END
    ) AS pass_completion_pct,
    AVG(t.num_value) FILTER (WHERE t.metric = 'Completed Line Breaks') AS completed_line_breaks,
    AVG(p.value) FILTER (WHERE p.phase = 'Build Up Opposed') AS build_up_opposed_pct,
    AVG(p.value) FILTER (WHERE p.phase = 'Progression') AS progression_pct,
    AVG(p.value) FILTER (WHERE p.phase = 'Final Third') AS final_third_pct
FROM team_key_stats_numeric t
LEFT JOIN team_phases p 
    ON t.team = p.team 
    AND p.phase IN ('Build Up Opposed', 'Progression', 'Final Third')
GROUP BY t.team
ORDER BY possession_pct DESC;

-- =========================================================
-- Creatring raw efficiency table
-- =========================================================
CREATE OR REPLACE TABLE team_raw_efficiency AS
WITH per_match AS (
    SELECT 
        team,
        match_id,
        match_team_id,
        MAX(CASE WHEN metric = 'xG (Expected Goals)' THEN num_value END) AS xg,
        MAX(CASE WHEN metric = 'Attempts at Goal (On Target)' THEN num_value END) AS attempts,
        MAX(CASE WHEN metric = 'Goals' THEN num_value END) AS goals,
        MAX(CASE WHEN metric = 'Total Passes (Complete)' THEN num_value END) AS total_passes,
        MAX(CASE WHEN metric = 'Possession' THEN num_value END) AS possession
    FROM team_key_stats_numeric
    WHERE metric IN (
        'xG (Expected Goals)',
        'Attempts at Goal (On Target)',
        'Goals',
        'Total Passes (Complete)',
        'Possession'
    )
    GROUP BY team, match_id, match_team_id
)
SELECT 
    team,
    SUM(xg) / SUM(attempts) AS xg_per_attempt,
    SUM(goals) / SUM(xg) AS goals_per_xg,
    (SUM(attempts) / SUM(total_passes)) * 100 AS attempts_per_100_passes,
    SUM(xg) / SUM(possession) AS xg_per_possession
FROM per_match
GROUP BY team
ORDER BY xg_per_attempt DESC;

-- =========================================================
--Calculating the tournament's average tournament score and the multiplier for each team
-- =========================================================
CREATE OR REPLACE TABLE team_multiplier AS
WITH all_opponents AS (
    SELECT team, opponent_1 AS opponent FROM team_opponents WHERE opponent_1 IS NOT NULL
    UNION ALL
    SELECT team, opponent_2 FROM team_opponents WHERE opponent_2 IS NOT NULL
    UNION ALL
    SELECT team, opponent_3 FROM team_opponents WHERE opponent_3 IS NOT NULL
    UNION ALL
    SELECT team, opponent_4 FROM team_opponents WHERE opponent_4 IS NOT NULL
    UNION ALL
    SELECT team, opponent_5 FROM team_opponents WHERE opponent_5 IS NOT NULL
    UNION ALL
    SELECT team, opponent_6 FROM team_opponents WHERE opponent_6 IS NOT NULL
    UNION ALL
    SELECT team, opponent_7 FROM team_opponents WHERE opponent_7 IS NOT NULL
    UNION ALL
    SELECT team, opponent_8 FROM team_opponents WHERE opponent_8 IS NOT NULL
)
SELECT 
    a.team,
    AVG(fp.fifa_points) AS avg_opponent_points,
    AVG(fp.fifa_points) / 1580.67 AS multiplier
FROM all_opponents a
LEFT JOIN fifa_points_adjusted fp ON a.opponent = fp.team
WHERE fp.team != 'AVG_OPPONENT_REFERENCE'
GROUP BY a.team
ORDER BY avg_opponent_points DESC;