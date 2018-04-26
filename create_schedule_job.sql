SQL> create user test identified by temp#123 default tablespace users;

User created.

SQL> grant connect, resource to test;

Grant succeeded.

SQL> select max(sequence#) from v$archived_log


MAX(SEQUENCE#)
--------------
          1177

SQL> create table test.test as select * from dba_objects;
create table test.test as select * from dba_objects
                                        *
ERROR at line 1:
ORA-01950: no privileges on tablespace 'USERS'


SQL> alter user test quota unlimited on users;

User altered.

SQL> create table test.test as select * from dba_objects;

Table created.

SQL> select count(*) from dba_objects;

  COUNT(*)
----------
     91878

SQL> create procedure test.insert_rows as
  2  begin
  3  insert into test.test select * from dba_objects;
  4  commit;
  5  end;
  6  /

Warning: Procedure created with compilation errors.

SQL> show errors
Errors for PROCEDURE TEST.INSERT_ROWS:

LINE/COL ERROR
-------- -----------------------------------------------------------------
3/1      PL/SQL: SQL Statement ignored
3/37     PL/SQL: ORA-00942: table or view does not exist
SQL> grant select on dba_objects to test;

Grant succeeded.

SQL> alter procedure test.insert_rows compile;

Procedure altered.

SQL> show errors
No errors.

SQL> begin
  2  dbms_scheduler.create_job (
  3  job_name=>'insert_test',
  4  job_type =>'stored_procedure',
  5  job_action=>'test.insert_rows',
  6  start_date=>'26-APR-18 03.00.00 PM',
  7  repeat_interval=>'FREQ=HOURLY');
  8  end;
  9  /

PL/SQL procedure successfully completed.


SQL> select job_name, job_type,job_action, start_date,enabled from dba_scheduler_jobs where job_name like 'INSERT%';

JOB_NAME                                                                                                                 JOB_TYPE
-------------------------------------------------------------------------------------------------------------------------------- ----------------
JOB_ACTION
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
START_DATE                                                                  ENABL
--------------------------------------------------------------------------- -----
INSERT_TEST                                                                                                              STORED_PROCEDURE
test.insert_rows
26-APR-18 03.00.00.000000 PM -07:00                                         FALSE


SQL> exec dbms_scheduler.enable('INSERT_TEST');

PL/SQL procedure successfully completed.

SQL> select job_name, job_type,job_action, start_date,enabled from dba_scheduler_jobs where job_name like 'INSERT%';

JOB_NAME                                                                                                                 JOB_TYPE
-------------------------------------------------------------------------------------------------------------------------------- ----------------
JOB_ACTION
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
START_DATE                                                                  ENABL
--------------------------------------------------------------------------- -----
INSERT_TEST                                                                                                              STORED_PROCEDURE
test.insert_rows
26-APR-18 03.00.00.000000 PM -07:00                                         TRUE


