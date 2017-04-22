--------------------------------------------------------
--  DDL for Table GAMES
--------------------------------------------------------

CREATE TABLE GAMETRACKER.GAMES
 (	ID NUMBER(13,0) GENERATED ALWAYS AS IDENTITY,
    NAME VARCHAR2(128 CHAR) NOT NULL ENABLE,
    RATING NUMBER(1,0),
    REVIEW CLOB,
    TIME_PLAYED NUMBER(13),
    RELEASE_DATE DATE,
    GROUVEE_URL VARCHAR2(2048 CHAR),
    GIANTBOMB_ID NUMBER(13,0),
    LAST_UPDATED TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT GAMES_PK PRIMARY KEY (ID)
);
