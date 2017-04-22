--------------------------------------------------------
--  DDL for Table PLATFORM_LIST
--------------------------------------------------------

CREATE TABLE GAMETRACKER.PLATFORM_LIST
 (	GAME_ID NUMBER(13) NOT NULL,
    PLATFORM_ID NUMBER(13) NOT NULL,
    LAST_UPDATED TIMESTAMP NOT NULL,
    CONSTRAINT PLATFORM_LIST_PK PRIMARY KEY (GAME_ID, PLATFORM_ID),
    CONSTRAINT GAMEPLATFORM_FK FOREIGN KEY (GAME_ID) REFERENCES GAMES (ID),
    CONSTRAINT PLATFORM_FK FOREIGN KEY (PLATFORM_ID) REFERENCES PLATFORMS (ID)
) ORGANIZATION INDEX;

CREATE INDEX PLATFORM_LIST_IX ON PLATFORM_LIST(PLATFORM_ID);
