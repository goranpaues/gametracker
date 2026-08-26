-- Change to PDB which was created inside parent iamge
ALTER SESSION SET CONTAINER = ORCLPDB1;

-- Enable Enterprise Manager Express on port 5501
EXEC dbms_xdb_config.sethttpsport(5501);

-- Create table space for demo application
DECLARE
  v_ts_id V$TABLESPACE.TS#%TYPE;
BEGIN
  SELECT TS# into v_ts_id FROM V$TABLESPACE WHERE name = 'GURANTS';
EXCEPTION
  WHEN no_data_found THEN
    EXECUTE IMMEDIATE
      'CREATE SMALLFILE TABLESPACE "GAMETRACKER" ' ||
      '  DATAFILE ''/opt/oracle/oradata/ORCLCDB/ORCLPDB1/gametracker-1.dbf'' SIZE 512M AUTOEXTEND ON NEXT 128M MAXSIZE 1024M ' ||
      '  LOGGING ' ||
      '  DEFAULT NOCOMPRESS ' ||
      '  ONLINE ' ||
      '  EXTENT MANAGEMENT LOCAL AUTOALLOCATE ' ||
      '  SEGMENT SPACE MANAGEMENT AUTO';
END;
/

-- Create user:
DECLARE
  v_id DBA_USERS.USER_ID%TYPE;
BEGIN
  SELECT USER_ID INTO v_id FROM DBA_USERS WHERE username = 'GAMETRACKER';
EXCEPTION
  WHEN no_data_found THEN
    EXECUTE IMMEDIATE
      'CREATE USER gametracker IDENTIFIED BY gametracker PROFILE "DEFAULT" ACCOUNT UNLOCK DEFAULT TABLESPACE  "GAMETRACKER" TEMPORARY TABLESPACE "TEMP"';
END;
/

GRANT "CONNECT" TO gametracker;
GRANT "DBA" TO gametracker;

EXIT;
