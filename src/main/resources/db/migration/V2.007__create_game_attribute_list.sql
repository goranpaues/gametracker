CREATE TABLE gametracker.game_attribute_list (
    game_id NUMBER(13,0) NOT NULL,
    attribute_id NUMBER(13,0) NOT NULL,
    last_updated TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT game_attribute_list_pk PRIMARY KEY (game_id, attribute_id),
    CONSTRAINT game_attribute_list_game_fk FOREIGN KEY (game_id) REFERENCES gametracker.games(id),
    CONSTRAINT game_attribute_list_attribute_fk FOREIGN KEY (attribute_id) REFERENCES gametracker.game_attributes(id)
) ORGANIZATION INDEX;