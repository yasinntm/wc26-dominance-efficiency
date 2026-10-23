-- =========================================================
--Calculating adjusted dominance
-- =========================================================
CREATE OR REPLACE TABLE team_adjusted_dominance AS
WITH global_avg AS (
    SELECT 
        AVG(possession_pct) AS avg_possession,
        AVG(build_up_opposed_pct) AS avg_build_up,
        AVG(progression_pct) AS avg_progression,
        AVG(final_third_pct) AS avg_final_third,
        AVG(pass_completion_pct) AS avg_pass_completion,
        AVG(completed_line_breaks) AS avg_line_breaks
    FROM team_raw_dominance
)
SELECT 
    r.team,
    g.avg_possession + (r.possession_pct - g.avg_possession) * m.multiplier AS adj_possession_pct,
    g.avg_build_up + (r.build_up_opposed_pct - g.avg_build_up) * m.multiplier AS adj_build_up_opposed_pct,
    g.avg_progression + (r.progression_pct - g.avg_progression) * m.multiplier AS adj_progression_pct,
    g.avg_final_third + (r.final_third_pct - g.avg_final_third) * m.multiplier AS adj_final_third_pct,
    g.avg_pass_completion + (r.pass_completion_pct - g.avg_pass_completion) * m.multiplier AS adj_pass_completion,
    g.avg_line_breaks + (r.completed_line_breaks - g.avg_line_breaks) * m.multiplier AS adj_completed_line_breaks
FROM team_raw_dominance r
LEFT JOIN team_multiplier m ON r.team = m.team
CROSS JOIN global_avg g;

-- =========================================================
-- Adjusted efficiency table
-- =========================================================
CREATE OR REPLACE TABLE team_adjusted_efficiency AS
WITH global_avg AS (
    SELECT 
        AVG(xg_per_attempt) AS avg_xg_per_attempt,
        AVG(goals_per_xg) AS avg_goals_per_xg,
        AVG(attempts_per_100_passes) AS avg_attempts_per_100_passes,
        AVG(xg_per_possession) AS avg_xg_per_possession
    FROM team_raw_efficiency
)
SELECT 
    r.team,
    g.avg_xg_per_attempt + (r.xg_per_attempt - g.avg_xg_per_attempt) * m.multiplier AS adj_xg_per_attempt,
    g.avg_goals_per_xg + (r.goals_per_xg - g.avg_goals_per_xg) * m.multiplier AS adj_goals_per_xg,
    g.avg_attempts_per_100_passes + (r.attempts_per_100_passes - g.avg_attempts_per_100_passes) * m.multiplier AS adj_attempts_per_100_passes,
    g.avg_xg_per_possession + (r.xg_per_possession - g.avg_xg_per_possession) * m.multiplier AS adj_xg_per_possession
FROM team_raw_efficiency r
LEFT JOIN team_multiplier m ON r.team = m.team
CROSS JOIN global_avg g;