CREATE TABLE gametracker.game_attributes (
    id NUMBER(13,0) GENERATED ALWAYS AS IDENTITY,
    attribute_type VARCHAR2(30 CHAR) NOT NULL,
    name VARCHAR2(128 CHAR) NOT NULL,
    last_updated TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT game_attributes_pk PRIMARY KEY (id),
    CONSTRAINT game_attributes_type_ck CHECK (attribute_type IN ('DEVELOPER', 'FRANCHISE', 'GENRE', 'PUBLISHER', 'SERIES')),
    CONSTRAINT game_attributes_type_name_uk UNIQUE (attribute_type, name)
);