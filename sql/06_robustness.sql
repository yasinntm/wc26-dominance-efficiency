-- =========================================================
-- Alternative Dominance Index to check for sensitivity to Completed Line Breaks
-- =========================================================
CREATE OR REPLACE TABLE dominance_z_scores_alt AS
SELECT 
    team,
    z_possession_pct,
    z_build_up_opposed_pct,
    z_progression_pct,
    z_final_third_pct,
    z_pass_completion,
    (
        z_possession_pct +
        z_build_up_opposed_pct +
        z_progression_pct +
        z_final_third_pct +
        z_pass_completion
    ) / 5 AS dominance_z
FROM dominance_z_scores
ORDER BY dominance_z DESC;

-- =========================================================
-- Alternative Efficiency Index to check for sensitivity to xG per Possession
-- =========================================================
CREATE OR REPLACE TABLE efficiency_z_scores_alt AS
SELECT 
    team,
    z_xg_per_attempt,
    z_goals_per_xg,
    z_attempts_per_100_passes,
    (
        z_xg_per_attempt +
        z_goals_per_xg +
        z_attempts_per_100_passes
    ) / 3 AS efficiency_z
FROM efficiency_z_scores;

-- =========================================================
-- Both Dominance scores side-by-side
-- =========================================================
SELECT 
    a.team,
    a.dominance_z AS dominance_z_base,
    b.dominance_z AS dominance_z_alt,
    b.dominance_z - a.dominance_z AS diff
FROM dominance_z_scores a
LEFT JOIN dominance_z_scores_alt b ON a.team = b.team
ORDER BY diff DESC;

-- =========================================================
-- Correlation between alternative dominance and baseline efficiency
-- =========================================================
SELECT CORR(d.dominance_z, q.efficiency_z) AS dominance_efficiency_correlation
FROM dominance_z_scores_alt d
JOIN dominance_z_scores q ON d.team = q.team;

