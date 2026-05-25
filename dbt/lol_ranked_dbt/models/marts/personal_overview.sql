WITH history AS (
    SELECT * FROM {{ ref('personal_match_history') }}
),

lagged AS (
    SELECT
        match_number,
        win,
        LAG(win) OVER (ORDER BY match_number) AS prev_win
    FROM history
),

grouped AS (
    SELECT
        match_number,
        win,
        SUM(CASE WHEN win != prev_win THEN 1 ELSE 0 END)
            OVER (ORDER BY match_number)        AS streak_group
    FROM lagged
),

current_streak AS (
    SELECT
        win                                     AS current_streak_type,
        COUNT(*)                                AS current_streak_length
    FROM grouped
    WHERE streak_group = (SELECT MAX(streak_group) FROM grouped)
    GROUP BY win
),

general_stats AS (
    SELECT
        COUNT(*)                                                AS total_games,
        SUM(CASE WHEN win THEN 1 ELSE 0 END)                   AS total_wins,
        SUM(CASE WHEN NOT win THEN 1 ELSE 0 END)               AS total_losses,
        ROUND(AVG(CASE WHEN win THEN 1.0 ELSE 0.0 END), 3)     AS win_rate,
        ROUND(AVG(kda), 2)                                      AS avg_kda,
        ROUND(AVG(kills), 2)                                    AS avg_kills,
        ROUND(AVG(deaths), 2)                                   AS avg_deaths,
        ROUND(AVG(assists), 2)                                  AS avg_assists,
        ROUND(AVG(damage_dealt), 0)                             AS avg_damage,
        ROUND(AVG(gold_earned), 0)                              AS avg_gold,
        ROUND(AVG(cs), 1)                                       AS avg_cs,
        ROUND(AVG(game_duration_mins), 1)                       AS avg_game_duration_mins,
        (SELECT champion_name FROM history
         GROUP BY champion_name
         ORDER BY COUNT(*) DESC LIMIT 1)                        AS most_played_champion,
        (SELECT champion_name FROM history
         WHERE champion_name IN (
             SELECT champion_name FROM history
             GROUP BY champion_name HAVING COUNT(*) >= 3
         )
         GROUP BY champion_name
         ORDER BY AVG(CASE WHEN win THEN 1.0 ELSE 0.0 END) DESC
         LIMIT 1)                                               AS best_winrate_champion
    FROM history
)

SELECT
    g.total_games,
    g.total_wins,
    g.total_losses,
    g.win_rate,
    g.avg_kda,
    g.avg_kills,
    g.avg_deaths,
    g.avg_assists,
    g.avg_damage,
    g.avg_gold,
    g.avg_cs,
    g.avg_game_duration_mins,
    g.most_played_champion,
    g.best_winrate_champion,
    cs.current_streak_type,
    cs.current_streak_length
FROM general_stats g
CROSS JOIN current_streak cs