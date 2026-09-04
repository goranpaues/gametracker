CREATE OR REPLACE PROCEDURE gametracker.import_games AS
    c_source_name    CONSTANT VARCHAR2(128 CHAR) := 'grouvee_export.json';
    l_json_file      BFILE := BFILENAME('GROUVEE_JSON_DIR', c_source_name);
    l_json_doc       CLOB;
    l_dest_offset    INTEGER := 1;
    l_src_offset     INTEGER := 1;
    l_lang_context   INTEGER := 0;
    l_warning        INTEGER;
BEGIN
    DBMS_LOB.CREATETEMPORARY(l_json_doc, TRUE);
    DBMS_LOB.FILEOPEN(l_json_file, DBMS_LOB.FILE_READONLY);
    DBMS_LOB.LOADCLOBFROMFILE(
        dest_lob     => l_json_doc,
        src_bfile    => l_json_file,
        amount       => DBMS_LOB.LOBMAXSIZE,
        dest_offset  => l_dest_offset,
        src_offset   => l_src_offset,
        bfile_csid   => DBMS_LOB.DEFAULT_CSID,
        lang_context => l_lang_context,
        warning      => l_warning
    );
    DBMS_LOB.FILECLOSE(l_json_file);

    MERGE INTO gametracker.grouvee_import_payload tgt
    USING (
        SELECT c_source_name AS source_name, l_json_doc AS payload
        FROM dual
    ) src
        ON (tgt.source_name = src.source_name)
    WHEN MATCHED THEN UPDATE
        SET tgt.payload = src.payload,
            tgt.loaded_at = SYSTIMESTAMP
    WHEN NOT MATCHED THEN INSERT (
        source_name,
        payload,
        loaded_at
    ) VALUES (
        src.source_name,
        src.payload,
        SYSTIMESTAMP
    );

    MERGE INTO gametracker.games g
    USING (
        WITH source_payload AS (
            SELECT payload
            FROM gametracker.grouvee_import_payload
            WHERE source_name = c_source_name
        ),
        collection_core AS (
            SELECT
                jt.grouvee_game_id,
                jt.name,
                jt.rating,
                NULLIF(TRIM(jt.review_title), '') AS review_title,
                REGEXP_REPLACE(
                    REGEXP_REPLACE(jt.review, 'href="https?://[^"]*"', 'href=""'),
                    'https?://[^[:space:]<"]+',
                    ''
                ) AS review,
                CASE
                    WHEN REGEXP_LIKE(TRIM(jt.release_date_txt), '^[[:digit:]]{4}$')
                        THEN TO_DATE(TRIM(jt.release_date_txt) || '-01-01', 'YYYY-MM-DD')
                    WHEN REGEXP_LIKE(TRIM(jt.release_date_txt), '^[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}$')
                        THEN TO_DATE(TRIM(jt.release_date_txt), 'YYYY-MM-DD')
                END AS release_date,
                TO_DATE(NULLIF(jt.date_added_txt, ''), 'YYYY-MM-DD') AS date_added_to_collection,
                jt.grouvee_url,
                jt.igdb_id,
                jt.giantbomb_id
            FROM source_payload p
            CROSS JOIN JSON_TABLE(
                p.payload,
                '$.collection[*]'
                COLUMNS (
                    grouvee_game_id NUMBER PATH '$.id',
                    name VARCHAR2(128 CHAR) PATH '$.name',
                    rating NUMBER PATH '$.rating' NULL ON EMPTY NULL ON ERROR,
                    review_title VARCHAR2(512 CHAR) PATH '$.review_title' NULL ON EMPTY NULL ON ERROR,
                    review CLOB PATH '$.review' NULL ON EMPTY NULL ON ERROR,
                    release_date_txt VARCHAR2(10 CHAR) PATH '$.release_date' NULL ON EMPTY NULL ON ERROR,
                    date_added_txt VARCHAR2(10 CHAR) PATH '$.date_added_to_collection' NULL ON EMPTY NULL ON ERROR,
                    grouvee_url VARCHAR2(2048 CHAR) PATH '$.url',
                    igdb_id NUMBER PATH '$.igdb_id' NULL ON EMPTY NULL ON ERROR,
                    giantbomb_id NUMBER PATH '$.giantbomb_id' NULL ON EMPTY NULL ON ERROR
                )
            ) jt
        ),
        date_rollup AS (
            SELECT
                jt.grouvee_game_id,
                SUM(NVL(jt.seconds_played, 0)) AS time_played,
                MAX(jt.level_of_completion) KEEP (
                    DENSE_RANK LAST ORDER BY
                        CASE WHEN jt.level_of_completion IS NULL THEN 0 ELSE 1 END,
                        NVL(jt.date_row_number, 0)
                ) AS level_of_completion
            FROM source_payload p
            CROSS JOIN JSON_TABLE(
                p.payload,
                '$.collection[*]'
                COLUMNS (
                    grouvee_game_id NUMBER PATH '$.id',
                    NESTED PATH '$.dates[*]'
                    COLUMNS (
                        date_row_number FOR ORDINALITY,
                        seconds_played NUMBER PATH '$.seconds_played' NULL ON EMPTY NULL ON ERROR,
                        level_of_completion VARCHAR2(64 CHAR) PATH '$.level_of_completion' NULL ON EMPTY NULL ON ERROR
                    )
                )
            ) jt
            GROUP BY jt.grouvee_game_id
        )
        SELECT
            c.grouvee_game_id,
            c.name,
            c.rating,
            c.review_title,
            c.review,
            c.release_date,
            c.date_added_to_collection,
            c.grouvee_url,
            c.igdb_id,
            c.giantbomb_id,
            d.time_played,
            d.level_of_completion
        FROM collection_core c
        LEFT JOIN date_rollup d
            ON d.grouvee_game_id = c.grouvee_game_id
    ) src
        ON (g.grouvee_game_id = src.grouvee_game_id)
    WHEN MATCHED THEN UPDATE
        SET g.name = src.name,
            g.rating = src.rating,
            g.review = src.review,
            g.review_title = src.review_title,
            g.release_date = src.release_date,
            g.time_played = src.time_played,
            g.grouvee_url = src.grouvee_url,
            g.igdb_id = src.igdb_id,
            g.giantbomb_id = src.giantbomb_id,
            g.date_added_to_collection = src.date_added_to_collection,
            g.level_of_completion = src.level_of_completion,
            g.last_updated = SYSTIMESTAMP
    WHEN NOT MATCHED THEN INSERT (
        grouvee_game_id,
        name,
        rating,
        review,
        review_title,
        release_date,
        time_played,
        grouvee_url,
        igdb_id,
        giantbomb_id,
        date_added_to_collection,
        level_of_completion
    ) VALUES (
        src.grouvee_game_id,
        src.name,
        src.rating,
        src.review,
        src.review_title,
        src.release_date,
        src.time_played,
        src.grouvee_url,
        src.igdb_id,
        src.giantbomb_id,
        src.date_added_to_collection,
        src.level_of_completion
    );

    MERGE INTO gametracker.shelves tgt
    USING (
        WITH source_payload AS (
            SELECT payload
            FROM gametracker.grouvee_import_payload
            WHERE source_name = c_source_name
        ),
        source_shelves AS (
            SELECT DISTINCT
                kv.shelf_name
            FROM source_payload p
            CROSS JOIN JSON_TABLE(
                p.payload,
                '$.collection[*]'
                COLUMNS (
                    shelves_json CLOB FORMAT JSON PATH '$.shelves'
                )
            ) jt
            CROSS JOIN JSON_TABLE(
                JSON_QUERY(jt.shelves_json, '$.keyvalue()' WITH WRAPPER),
                '$[*]'
                COLUMNS (
                    shelf_name VARCHAR2(128 CHAR) PATH '$.key'
                )
            ) kv
        )
        SELECT shelf_name
        FROM source_shelves
    ) src
        ON (tgt.name = src.shelf_name)
    WHEN NOT MATCHED THEN INSERT (
        name
    ) VALUES (
        src.shelf_name
    );

    DELETE FROM gametracker.shelf_list sl
    WHERE sl.game_id IN (
        WITH source_payload AS (
            SELECT payload
            FROM gametracker.grouvee_import_payload
            WHERE source_name = c_source_name
        ),
        source_games AS (
            SELECT DISTINCT
                jt.grouvee_game_id
            FROM source_payload p
            CROSS JOIN JSON_TABLE(
                p.payload,
                '$.collection[*]'
                COLUMNS (
                    grouvee_game_id NUMBER PATH '$.id'
                )
            ) jt
        )
        SELECT g.id
        FROM gametracker.games g
        JOIN source_games sg
            ON sg.grouvee_game_id = g.grouvee_game_id
    );

    INSERT INTO gametracker.shelf_list (
        game_id,
        shelf_id,
        date_added,
        shelf_order
    )
    WITH source_payload AS (
        SELECT payload
        FROM gametracker.grouvee_import_payload
        WHERE source_name = c_source_name
    ),
    source_shelves AS (
        SELECT DISTINCT
            jt.grouvee_game_id,
            kv.shelf_name,
            TO_DATE(
                JSON_VALUE(kv.shelf_value, '$.date_added' RETURNING VARCHAR2(30 CHAR) NULL ON EMPTY NULL ON ERROR),
                'YYYY-MM-DD"T"HH24:MI:SS"Z"'
            ) AS date_added,
            JSON_VALUE(kv.shelf_value, '$.order' RETURNING NUMBER NULL ON EMPTY NULL ON ERROR) AS shelf_order
        FROM source_payload p
        CROSS JOIN JSON_TABLE(
            p.payload,
            '$.collection[*]'
            COLUMNS (
                grouvee_game_id NUMBER PATH '$.id',
                shelves_json CLOB FORMAT JSON PATH '$.shelves'
            )
        ) jt
        CROSS JOIN JSON_TABLE(
            JSON_QUERY(jt.shelves_json, '$.keyvalue()' WITH WRAPPER),
            '$[*]'
            COLUMNS (
                shelf_name VARCHAR2(128 CHAR) PATH '$.key',
                shelf_value CLOB FORMAT JSON PATH '$.value'
            )
        ) kv
    )
    SELECT
        g.id,
        s.id,
        ss.date_added,
        ss.shelf_order
    FROM source_shelves ss
    JOIN gametracker.games g
        ON g.grouvee_game_id = ss.grouvee_game_id
    JOIN gametracker.shelves s
        ON s.name = ss.shelf_name;

    MERGE INTO gametracker.platforms tgt
    USING (
        WITH source_payload AS (
            SELECT payload
            FROM gametracker.grouvee_import_payload
            WHERE source_name = c_source_name
        ),
        source_platforms AS (
            SELECT DISTINCT
                kv.platform_name
            FROM source_payload p
            CROSS JOIN JSON_TABLE(
                p.payload,
                '$.collection[*]'
                COLUMNS (
                    platforms_json CLOB FORMAT JSON PATH '$.platforms'
                )
            ) jt
            CROSS JOIN JSON_TABLE(
                JSON_QUERY(jt.platforms_json, '$.keyvalue()' WITH WRAPPER),
                '$[*]'
                COLUMNS (
                    platform_name VARCHAR2(128 CHAR) PATH '$.key'
                )
            ) kv
        )
        SELECT platform_name
        FROM source_platforms
    ) src
        ON (tgt.name = src.platform_name)
    WHEN NOT MATCHED THEN INSERT (
        name
    ) VALUES (
        src.platform_name
    );

    DELETE FROM gametracker.platform_list pl
    WHERE pl.game_id IN (
        WITH source_payload AS (
            SELECT payload
            FROM gametracker.grouvee_import_payload
            WHERE source_name = c_source_name
        ),
        source_games AS (
            SELECT DISTINCT
                jt.grouvee_game_id
            FROM source_payload p
            CROSS JOIN JSON_TABLE(
                p.payload,
                '$.collection[*]'
                COLUMNS (
                    grouvee_game_id NUMBER PATH '$.id'
                )
            ) jt
        )
        SELECT g.id
        FROM gametracker.games g
        JOIN source_games sg
            ON sg.grouvee_game_id = g.grouvee_game_id
    );

    INSERT INTO gametracker.platform_list (
        game_id,
        platform_id
    )
    WITH source_payload AS (
        SELECT payload
        FROM gametracker.grouvee_import_payload
        WHERE source_name = c_source_name
    ),
    source_platforms AS (
        SELECT DISTINCT
            jt.grouvee_game_id,
            kv.platform_name
        FROM source_payload p
        CROSS JOIN JSON_TABLE(
            p.payload,
            '$.collection[*]'
            COLUMNS (
                grouvee_game_id NUMBER PATH '$.id',
                platforms_json CLOB FORMAT JSON PATH '$.platforms'
            )
        ) jt
        CROSS JOIN JSON_TABLE(
            JSON_QUERY(jt.platforms_json, '$.keyvalue()' WITH WRAPPER),
            '$[*]'
            COLUMNS (
                platform_name VARCHAR2(128 CHAR) PATH '$.key'
            )
        ) kv
    )
    SELECT
        g.id,
        p.id
    FROM source_platforms sp
    JOIN gametracker.games g
        ON g.grouvee_game_id = sp.grouvee_game_id
    JOIN gametracker.platforms p
        ON p.name = sp.platform_name;

    MERGE INTO gametracker.game_attributes tgt
    USING (
        WITH source_payload AS (
            SELECT payload
            FROM gametracker.grouvee_import_payload
            WHERE source_name = c_source_name
        ),
        collection_members AS (
            SELECT
                jt.genres_json,
                jt.franchises_json,
                jt.series_json,
                jt.developers_json,
                jt.publishers_json
            FROM source_payload p
            CROSS JOIN JSON_TABLE(
                p.payload,
                '$.collection[*]'
                COLUMNS (
                    genres_json CLOB FORMAT JSON PATH '$.genres',
                    franchises_json CLOB FORMAT JSON PATH '$.franchises',
                    series_json CLOB FORMAT JSON PATH '$.series',
                    developers_json CLOB FORMAT JSON PATH '$.developers',
                    publishers_json CLOB FORMAT JSON PATH '$.publishers'
                )
            ) jt
        ),
        source_attributes AS (
            SELECT DISTINCT
                'GENRE' AS attribute_type,
                kv.attribute_name AS attribute_name
            FROM collection_members cm
            CROSS JOIN JSON_TABLE(
                JSON_QUERY(cm.genres_json, '$.keyvalue()' WITH WRAPPER),
                '$[*]'
                COLUMNS (
                    attribute_name VARCHAR2(128 CHAR) PATH '$.key'
                )
            ) kv
            UNION ALL
            SELECT DISTINCT
                'FRANCHISE' AS attribute_type,
                kv.attribute_name AS attribute_name
            FROM collection_members cm
            CROSS JOIN JSON_TABLE(
                JSON_QUERY(cm.franchises_json, '$.keyvalue()' WITH WRAPPER),
                '$[*]'
                COLUMNS (
                    attribute_name VARCHAR2(128 CHAR) PATH '$.key'
                )
            ) kv
            UNION ALL
            SELECT DISTINCT
                'SERIES' AS attribute_type,
                kv.attribute_name AS attribute_name
            FROM collection_members cm
            CROSS JOIN JSON_TABLE(
                JSON_QUERY(cm.series_json, '$.keyvalue()' WITH WRAPPER),
                '$[*]'
                COLUMNS (
                    attribute_name VARCHAR2(128 CHAR) PATH '$.key'
                )
            ) kv
            UNION ALL
            SELECT DISTINCT
                'DEVELOPER' AS attribute_type,
                kv.attribute_name AS attribute_name
            FROM collection_members cm
            CROSS JOIN JSON_TABLE(
                JSON_QUERY(cm.developers_json, '$.keyvalue()' WITH WRAPPER),
                '$[*]'
                COLUMNS (
                    attribute_name VARCHAR2(128 CHAR) PATH '$.key'
                )
            ) kv
            UNION ALL
            SELECT DISTINCT
                'PUBLISHER' AS attribute_type,
                kv.attribute_name AS attribute_name
            FROM collection_members cm
            CROSS JOIN JSON_TABLE(
                JSON_QUERY(cm.publishers_json, '$.keyvalue()' WITH WRAPPER),
                '$[*]'
                COLUMNS (
                    attribute_name VARCHAR2(128 CHAR) PATH '$.key'
                )
            ) kv
        )
        SELECT DISTINCT
            attribute_type,
            attribute_name
        FROM source_attributes
    ) src
        ON (tgt.attribute_type = src.attribute_type AND tgt.name = src.attribute_name)
    WHEN NOT MATCHED THEN INSERT (
        attribute_type,
        name
    ) VALUES (
        src.attribute_type,
        src.attribute_name
    );

    DELETE FROM gametracker.game_attribute_list gal
    WHERE gal.game_id IN (
        WITH source_payload AS (
            SELECT payload
            FROM gametracker.grouvee_import_payload
            WHERE source_name = c_source_name
        ),
        source_games AS (
            SELECT DISTINCT
                jt.grouvee_game_id
            FROM source_payload p
            CROSS JOIN JSON_TABLE(
                p.payload,
                '$.collection[*]'
                COLUMNS (
                    grouvee_game_id NUMBER PATH '$.id'
                )
            ) jt
        )
        SELECT g.id
        FROM gametracker.games g
        JOIN source_games sg
            ON sg.grouvee_game_id = g.grouvee_game_id
    );

    INSERT INTO gametracker.game_attribute_list (
        game_id,
        attribute_id
    )
    WITH source_payload AS (
        SELECT payload
        FROM gametracker.grouvee_import_payload
        WHERE source_name = c_source_name
    ),
    collection_members AS (
        SELECT
            jt.grouvee_game_id,
            jt.genres_json,
            jt.franchises_json,
            jt.series_json,
            jt.developers_json,
            jt.publishers_json
        FROM source_payload p
        CROSS JOIN JSON_TABLE(
            p.payload,
            '$.collection[*]'
            COLUMNS (
                grouvee_game_id NUMBER PATH '$.id',
                genres_json CLOB FORMAT JSON PATH '$.genres',
                franchises_json CLOB FORMAT JSON PATH '$.franchises',
                series_json CLOB FORMAT JSON PATH '$.series',
                developers_json CLOB FORMAT JSON PATH '$.developers',
                publishers_json CLOB FORMAT JSON PATH '$.publishers'
            )
        ) jt
    ),
    source_attributes AS (
        SELECT DISTINCT
            cm.grouvee_game_id,
            'GENRE' AS attribute_type,
            kv.attribute_name AS attribute_name
        FROM collection_members cm
        CROSS JOIN JSON_TABLE(
            JSON_QUERY(cm.genres_json, '$.keyvalue()' WITH WRAPPER),
            '$[*]'
            COLUMNS (
                attribute_name VARCHAR2(128 CHAR) PATH '$.key'
            )
        ) kv
        UNION ALL
        SELECT DISTINCT
            cm.grouvee_game_id,
            'FRANCHISE' AS attribute_type,
            kv.attribute_name AS attribute_name
        FROM collection_members cm
        CROSS JOIN JSON_TABLE(
            JSON_QUERY(cm.franchises_json, '$.keyvalue()' WITH WRAPPER),
            '$[*]'
            COLUMNS (
                attribute_name VARCHAR2(128 CHAR) PATH '$.key'
            )
        ) kv
        UNION ALL
        SELECT DISTINCT
            cm.grouvee_game_id,
            'SERIES' AS attribute_type,
            kv.attribute_name AS attribute_name
        FROM collection_members cm
        CROSS JOIN JSON_TABLE(
            JSON_QUERY(cm.series_json, '$.keyvalue()' WITH WRAPPER),
            '$[*]'
            COLUMNS (
                attribute_name VARCHAR2(128 CHAR) PATH '$.key'
            )
        ) kv
        UNION ALL
        SELECT DISTINCT
            cm.grouvee_game_id,
            'DEVELOPER' AS attribute_type,
            kv.attribute_name AS attribute_name
        FROM collection_members cm
        CROSS JOIN JSON_TABLE(
            JSON_QUERY(cm.developers_json, '$.keyvalue()' WITH WRAPPER),
            '$[*]'
            COLUMNS (
                attribute_name VARCHAR2(128 CHAR) PATH '$.key'
            )
        ) kv
        UNION ALL
        SELECT DISTINCT
            cm.grouvee_game_id,
            'PUBLISHER' AS attribute_type,
            kv.attribute_name AS attribute_name
        FROM collection_members cm
        CROSS JOIN JSON_TABLE(
            JSON_QUERY(cm.publishers_json, '$.keyvalue()' WITH WRAPPER),
            '$[*]'
            COLUMNS (
                attribute_name VARCHAR2(128 CHAR) PATH '$.key'
            )
        ) kv
    )
    SELECT DISTINCT
        g.id,
        a.id
    FROM source_attributes sa
    JOIN gametracker.games g
        ON g.grouvee_game_id = sa.grouvee_game_id
    JOIN gametracker.game_attributes a
        ON a.attribute_type = sa.attribute_type
       AND a.name = sa.attribute_name;

    IF DBMS_LOB.ISTEMPORARY(l_json_doc) = 1 THEN
        DBMS_LOB.FREETEMPORARY(l_json_doc);
    END IF;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        IF DBMS_LOB.FILEISOPEN(l_json_file) = 1 THEN
            DBMS_LOB.FILECLOSE(l_json_file);
        END IF;
        IF DBMS_LOB.ISTEMPORARY(l_json_doc) = 1 THEN
            DBMS_LOB.FREETEMPORARY(l_json_doc);
        END IF;
        RAISE;
END import_games;
