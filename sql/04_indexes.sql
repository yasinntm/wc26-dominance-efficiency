-- =========================================================
-- Calculating Dominance z-scores
-- =========================================================
CREATE OR REPLACE TABLE dominance_z_scores AS
WITH stats AS (
    SELECT 
        AVG(adj_possession_pct) AS mean_possession,
        STDDEV_POP(adj_possession_pct) AS std_possession,
        AVG(adj_build_up_opposed_pct) AS mean_build_up,
        STDDEV_POP(adj_build_up_opposed_pct) AS std_build_up,
        AVG(adj_progression_pct) AS mean_progression,
        STDDEV_POP(adj_progression_pct) AS std_progression,
        AVG(adj_final_third_pct) AS mean_final_third,
        STDDEV_POP(adj_final_third_pct) AS std_final_third,
        AVG(adj_pass_completion) AS mean_pass_completion,
        STDDEV_POP(adj_pass_completion) AS std_pass_completion,
        AVG(adj_completed_line_breaks) AS mean_line_breaks,
        STDDEV_POP(adj_completed_line_breaks) AS std_line_breaks
    FROM team_adjusted_dominance
)
SELECT 
    t.team,
    (t.adj_possession_pct - s.mean_possession) / s.std_possession AS z_possession_pct,
    (t.adj_build_up_opposed_pct - s.mean_build_up) / s.std_build_up AS z_build_up_opposed_pct,
    (t.adj_progression_pct - s.mean_progression) / s.std_progression AS z_progression_pct,
    (t.adj_final_third_pct - s.mean_final_third) / s.std_final_third AS z_final_third_pct,
    (t.adj_pass_completion - s.mean_pass_completion) / s.std_pass_completion AS z_pass_completion,
    (t.adj_completed_line_breaks - s.mean_line_breaks) / s.std_line_breaks AS z_completed_line_breaks,
    (
        (t.adj_possession_pct - s.mean_possession) / s.std_possession +
        (t.adj_build_up_opposed_pct - s.mean_build_up) / s.std_build_up +
        (t.adj_progression_pct - s.mean_progression) / s.std_progression +
        (t.adj_final_third_pct - s.mean_final_third) / s.std_final_third +
        (t.adj_pass_completion - s.mean_pass_completion) / s.std_pass_completion +
        (t.adj_completed_line_breaks - s.mean_line_breaks) / s.std_line_breaks
    ) / 6 AS dominance_z
FROM team_adjusted_dominance t
CROSS JOIN stats s
ORDER BY dominance_z DESC;

-- =========================================================
-- Calculating Efficiency z-scores
-- =========================================================
CREATE OR REPLACE TABLE efficiency_z_scores AS
WITH stats AS (
    SELECT 
        AVG(adj_xg_per_attempt) AS mean_xg_per_attempt,
        STDDEV_POP(adj_xg_per_attempt) AS std_xg_per_attempt,
        AVG(adj_goals_per_xg) AS mean_goals_per_xg,
        STDDEV_POP(adj_goals_per_xg) AS std_goals_per_xg,
        AVG(adj_attempts_per_100_passes) AS mean_attempts_per_100_passes,
        STDDEV_POP(adj_attempts_per_100_passes) AS std_attempts_per_100_passes,
        AVG(adj_xg_per_possession) AS mean_xg_per_possession,
        STDDEV_POP(adj_xg_per_possession) AS std_xg_per_possession
    FROM team_adjusted_efficiency
)
SELECT 
    t.team,
    (t.adj_xg_per_attempt - s.mean_xg_per_attempt) / s.std_xg_per_attempt AS z_xg_per_attempt,
    (t.adj_goals_per_xg - s.mean_goals_per_xg) / s.std_goals_per_xg AS z_goals_per_xg,
    (t.adj_attempts_per_100_passes - s.mean_attempts_per_100_passes) / s.std_attempts_per_100_passes AS z_attempts_per_100_passes,
    (t.adj_xg_per_possession - s.mean_xg_per_possession) / s.std_xg_per_possession AS z_xg_per_possession,
    (
        (t.adj_xg_per_attempt - s.mean_xg_per_attempt) / s.std_xg_per_attempt +
        (t.adj_goals_per_xg - s.mean_goals_per_xg) / s.std_goals_per_xg +
        (t.adj_attempts_per_100_passes - s.mean_attempts_per_100_passes) / s.std_attempts_per_100_passes +
        (t.adj_xg_per_possession - s.mean_xg_per_possession) / s.std_xg_per_possession
    ) / 4 AS efficiency_z
FROM team_adjusted_efficiency t
CROSS JOIN stats s
ORDER BY efficiency_z DESC;