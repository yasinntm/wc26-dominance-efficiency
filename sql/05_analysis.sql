-- =========================================================
-- Joining Dominance & Efficiency scores for each team and assigning quadrants
-- =========================================================
CREATE OR REPLACE TABLE quadrant_map AS
SELECT 
    d.team,
    d.dominance_z,
    e.efficiency_z,
    CASE 
        WHEN d.dominance_z >= 0 AND e.efficiency_z >= 0 THEN 'Above Avg Dominance / Above Avg Efficiency'
        WHEN d.dominance_z >= 0 AND e.efficiency_z <  0 THEN 'Above Avg Dominance / Below Avg Efficiency'
        WHEN d.dominance_z <  0 AND e.efficiency_z >= 0 THEN 'Below Avg Dominance / Above Avg Efficiency'
        ELSE 'Below Avg Dominance / Below Avg Efficiency'
    END AS quadrant
FROM dominance_z_scores d
LEFT JOIN efficiency_z_scores e ON d.team = e.team

-- =========================================================
-- Final placement for all teams
-- =========================================================
CREATE OR REPLACE TABLE tournament_results AS
SELECT * FROM (VALUES
    ('Spain', 1),
    ('Argentina', 2),
    ('England', 3),
    ('France', 4),
    ('Morocco', 5),
    ('Belgium', 5),
    ('Switzerland', 5),
    ('Norway', 5),
    ('Canada', 9),
    ('Paraguay', 9),
    ('Brazil', 9),
    ('Mexico', 9),
    ('Portugal', 9),
    ('USA', 9),
    ('Egypt', 9),
    ('Colombia', 9),
    ('Germany', 17),
    ('Netherlands', 17),
    ('South Africa', 17),
    ('Australia', 17),
    ('Côte d''Ivoire', 17),
    ('Japan', 17),
    ('Cabo Verde', 17),
    ('Austria', 17),
    ('Croatia', 17),
    ('Congo DR', 17),
    ('Sweden', 17),
    ('Ghana', 17),
    ('Ecuador', 17),
    ('Bosnia and Herzegovina', 17),
    ('Algeria', 17),
    ('Senegal', 17),
    ('IR Iran', 33),
    ('Korea Republic', 34),
    ('Scotland', 35),
    ('Uruguay', 36),
    ('Türkiye', 37),
    ('Saudi Arabia', 38),
    ('Czechia', 39),
    ('New Zealand', 40),
    ('Qatar', 41),
    ('Curaçao', 42),
    ('Panama', 43),
    ('Jordan', 44),
    ('Haiti', 45),
    ('Uzbekistan', 46),
    ('Tunisia', 47),
    ('Iraq', 48)
) AS t(team, placement);

-- =========================================================
-- Final combined table behind the quadrant plot 
-- =========================================================
CREATE OR REPLACE TABLE wc_final_analysis AS
SELECT 
    q.team,
    q.dominance_z,
    q.efficiency_z,
    q.quadrant,
    r.placement
FROM quadrant_map q
LEFT JOIN tournament_results r ON q.team = r.team
ORDER BY r.placement;

-- =========================================================
-- Quadrant team counts, avg and best placements
-- =========================================================
SELECT 
    quadrant,
    COUNT(*) AS teams,
    AVG(r.placement) AS avg_placement,
    MIN(r.placement) AS best_placement,
FROM quadrant_map q
LEFT JOIN tournament_results r ON q.team = r.team
GROUP BY quadrant
ORDER BY avg_placement;


-- =========================================================
-- Correlation between both indexes
-- =========================================================
SELECT CORR(dominance_z, efficiency_z) AS dominance_efficiency_correlation
FROM quadrant_map;


-- =========================================================
-- Quadrant Distribution
-- =========================================================
SELECT 
    quadrant,
    COUNT(*) AS teams,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct
FROM wc_final_analysis
GROUP BY quadrant
ORDER BY teams DESC;














