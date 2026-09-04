CREATE TABLE gametracker.grouvee_import_payload (
    source_name VARCHAR2(128 CHAR) NOT NULL,
    payload CLOB NOT NULL CHECK (payload IS JSON),
    loaded_at TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT grouvee_import_payload_pk PRIMARY KEY (source_name)
);