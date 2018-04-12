--      get_snap_id.sql
--      set pagesize 2000 linesize 300
--      select * from (select snap_id, INSTANCE_NUMBER, end_interval_time from DBA_HIST_SNAPSHOT order by snap_id desc, INSTANCE_NUMBER) where rownum < 60  ;

define SQL_ID=&1
define BEGIN_SNAP_ID=&2
define END_SNAP_ID=&3

SET SERVEROUTPUT ON
set long 999999999

set heading on pagesize 200 linesize 250 feedback on verify off

begin
DBMS_SQLTUNE.drop_tuning_task ( task_name => 'SYS_SQLPROF_&&SQL_ID' );
end;
/


--BEGIN
--    DBMS_SQLTUNE.RESET_TUNING_TASK ( task_name => 'SYS_SQLPROF_&&SQL_ID' );
--END;
--/


-- Tuning task created for specific a statement from the AWR.
DECLARE
  l_sql_tune_task_id  VARCHAR2(100);
BEGIN
  l_sql_tune_task_id := DBMS_SQLTUNE.create_tuning_task (
                          begin_snap  => &&BEGIN_SNAP_ID,
                          end_snap    => &&END_SNAP_ID,
                          sql_id      => '&&SQL_ID',
                          scope       => DBMS_SQLTUNE.scope_comprehensive,
                          time_limit  => 10000,
                          task_name   => 'SYS_SQLPROF_&&SQL_ID',
                          description => 'Tuning task for sql_id = &&SQL_ID.');
  DBMS_OUTPUT.put_line('l_sql_tune_task_id: ' || l_sql_tune_task_id);
END;
/


BEGIN
        DBMS_SQLTUNE.EXECUTE_TUNING_TASK( task_name => 'SYS_SQLPROF_&&SQL_ID' );
END;
/

-- Result:

spool /home/oracle/scripts/log/tuning_&&1..txt
SET LONG 99999999
SET LONGCHUNKSIZE 1000
SET LINESIZE 300
SELECT DBMS_SQLTUNE.REPORT_TUNING_TASK( 'SYS_SQLPROF_&&SQL_ID') FROM DUAL;

set serveroutput on echo off
declare
  -- input variables
  input_task_owner dba_advisor_tasks.owner%type:='SYS';
  input_task_name dba_advisor_tasks.task_name%type:='SYS_SQLPROF_&&SQL_ID';
  input_show_outline boolean:=false;
  -- local variables
  task_id  dba_advisor_tasks.task_id%type;
  outline_data xmltype;
  benefit number;
begin
  for o in ( select * from dba_advisor_objects where owner=input_task_owner and task_name=input_task_name and type='SQL')
  loop
          -- get the profile hints (opt_estimate)
          dbms_output.put_line('--- PROFILE HINTS from '||o.task_name||' ('||o.object_id||') statement '||o.attr1||':');
          dbms_output.put_line('/*+');
          for r in (
            select hint,benefit from (
             select case when attr5 like 'OPT_ESTIMATE%' then cast(attr5 as varchar2(4000)) when attr1 like 'OPT_ESTIMATE%' then attr1 end hint,benefit
             from dba_advisor_recommendations t join dba_advisor_rationale r using (task_id,rec_id)
             where t.owner=o.owner and t.task_name = o.task_name and r.object_id=o.object_id and t.type='SQL PROFILE'
             --and r.message='This attribute adjusts optimizer estimates.'
            ) order by to_number(regexp_replace(hint,'^.*=([0-9.]+)[^0-9].*$','1'))
          ) loop
           dbms_output.put_line('   '||r.hint); benefit:=to_number(r.benefit)/100;
          end loop;
          dbms_output.put_line('*/');
          -- get the outline hints
          begin
          select outline_data into outline_data from (
              select case when other_xml is not null then extract(xmltype(other_xml),'/*/outline_data/hint') end outline_data
              from dba_advisor_tasks t join dba_sqltune_plans p using (task_id)
              where t.owner=o.owner and t.task_name = o.task_name and p.object_id=o.object_id  and t.advisor_name='SQL Tuning Advisor' --11gonly-- and execution_type='TUNE SQL'
              and p.attribute='Using SQL profile'
          ) where outline_data is not null;
          exception when no_data_found then null;
          end;
          exit when not input_show_outline;
          dbms_output.put_line('--- OUTLINE HINTS from '||o.task_name||' ('||o.object_id||') statement '||o.attr1||':');
          dbms_output.put_line('/*+');
          for r in (
              select (extractvalue(value(d), '/hint')) hint from table(xmlsequence(extract( outline_data , '/'))) d
          ) loop
           dbms_output.put_line('   '||r.hint);
          end loop;
          dbms_output.put_line('*/');
          dbms_output.put_line('--- Benefit: '||to_char(to_number(benefit),'FM99.99')||'%');
  end loop;
  dbms_output.put_line('');
end;
/
spool off

--begin
--DBMS_SQLTUNE.drop_tuning_task ( task_name => 'SYS_SQLPROF_&&SQL_ID' );
--end;
--/

!ls -lrth /home/oracle/scripts/log/tuning_*txt

