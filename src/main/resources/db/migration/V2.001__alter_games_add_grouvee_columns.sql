ALTER TABLE gametracker.games ADD (
    grouvee_game_id NUMBER(13,0),
    igdb_id NUMBER(13,0),
    review_title VARCHAR2(512 CHAR),
    date_added_to_collection DATE,
    level_of_completion VARCHAR2(64 CHAR)
);