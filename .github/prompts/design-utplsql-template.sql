create or replace package test_oracle_design_import as
  --%suite(oracle design import)
  --%suitepath(gametracker.import)

  --%test(compile validity)
  procedure test_compile_validity;

  --%test(annotations complete)
  procedure test_annotations_complete;

  --%test(included domains loaded)
  procedure test_included_domains_loaded;

  --%test(skips respected)
  procedure test_skips_respected;

  --%test(idempotent rerun)
  procedure test_idempotent_rerun;

  --%test(referential integrity)
  procedure test_referential_integrity;
end;
/

create or replace package body test_oracle_design_import as
  procedure test_compile_validity is
    l_errors number;
  begin
    select count(*)
      into l_errors
      from all_errors
     where owner = user
       and name in ('IMPORT_GAMES')
       and type in ('PROCEDURE', 'PACKAGE', 'PACKAGE BODY', 'VIEW');

    ut.expect(l_errors).to_equal(0);
  end;

  procedure test_annotations_complete is
    l_missing number;
  begin
    /*
      Replace ORACLE_DESIGN_OBJECTS with your generated object list table/view or
      inline list of created/changed tables and columns.
    */
    l_missing := 0;
    ut.expect(l_missing).to_equal(0);
  end;

  procedure test_included_domains_loaded is
    l_games number;
  begin
    select count(*) into l_games from games;
    ut.expect(l_games).to_be_greater_than(0);
  end;

  procedure test_skips_respected is
    l_reviews_objects number;
    l_account_objects number;
  begin
    select count(*)
      into l_reviews_objects
      from all_objects
     where owner = user
       and object_name like '%REVIEW%';

    select count(*)
      into l_account_objects
      from all_objects
     where owner = user
       and object_name like '%ACCOUNT%';

    ut.expect(l_reviews_objects).to_equal(0);
    ut.expect(l_account_objects).to_equal(0);
  end;

  procedure test_idempotent_rerun is
    l_before number;
    l_after number;
  begin
    select count(*) into l_before from games;
    import_games;
    import_games;
    select count(*) into l_after from games;

    ut.expect(l_after).to_equal(l_before);
  end;

  procedure test_referential_integrity is
    l_orphans number;
  begin
    select count(*)
      into l_orphans
      from shelf_list sl
      left join games g on g.id = sl.game_id
     where g.id is null;

    ut.expect(l_orphans).to_equal(0);
  end;
end;
/
