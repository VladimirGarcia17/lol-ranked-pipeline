WITH history AS (
    SELECT * FROM {{ ref('personal_match_history') }}
)

SELECT
    champion_name,
    COUNT(*)                                                AS total_games,
    SUM(CASE WHEN win THEN 1 ELSE 0 END)                   AS total_wins,
    ROUND(AVG(CASE WHEN win THEN 1.0 ELSE 0.0 END), 3)     AS win_rate,
    ROUND(AVG(kda), 2)                                      AS avg_kda,
    ROUND(AVG(kills), 2)                                    AS avg_kills,
    ROUND(AVG(deaths), 2)                                   AS avg_deaths,
    ROUND(AVG(assists), 2)                                  AS avg_assists,
    ROUND(AVG(damage_dealt), 0)                             AS avg_damage,
    ROUND(AVG(gold_earned), 0)                              AS avg_gold,
    ROUND(AVG(cs), 1)                                       AS avg_cs,
    ROUND(AVG(vision_score), 1)                             AS avg_vision_score,
    SUM(double_kills)                                       AS total_double_kills,
    SUM(triple_kills)                                       AS total_triple_kills,
    SUM(quadra_kills)                                       AS total_quadra_kills,
    SUM(penta_kills)                                        AS total_penta_kills,
    ROUND(AVG(game_duration_mins), 1)                       AS avg_game_duration_mins
FROM history
GROUP BY champion_name
ORDER BY total_games DESC