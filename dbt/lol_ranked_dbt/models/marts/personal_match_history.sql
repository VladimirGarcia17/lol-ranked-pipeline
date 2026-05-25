WITH matches AS (
    SELECT * FROM {{ ref('stg_matches') }}
),

participants AS (
    SELECT * FROM {{ ref('stg_participants') }}
),

player AS (
    SELECT *
    FROM participants
    WHERE LOWER(riot_id_game_name) = LOWER('Osiris')
    AND LOWER(riot_id_tagline) = LOWER('1011')
)

SELECT
    m.match_id,
    m.game_version,
    m.game_duration_mins,
    m.game_start_ts,
    m.game_end_ts,
    p.champion_name,
    p.champ_level,
    p.win,
    p.kills,
    p.deaths,
    p.assists,
    p.kda,
    p.total_damage_dealt_to_champions     AS damage_dealt,
    p.total_damage_taken                  AS damage_taken,
    p.gold_earned,
    p.gold_spent,
    p.total_minions_killed                AS cs,
    p.vision_score,
    p.time_spent_dead_secs,
    p.killing_sprees,
    p.double_kills,
    p.triple_kills,
    p.quadra_kills,
    p.penta_kills,
    p.first_blood_kill,
    p.team_id,
    CASE p.team_id
        WHEN 100 THEN 'Blue'
        WHEN 200 THEN 'Red'
    END                                   AS side,
    ROW_NUMBER() OVER (
        ORDER BY m.game_start_ts ASC
    )                                     AS match_number
FROM player p
JOIN matches m ON p.match_id = m.match_id
ORDER BY m.game_start_ts DESC