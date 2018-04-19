


[oracle@stagepasco:/home/oracle]sqlplus / as sysasm

SQL*Plus: Release 12.1.0.2.0 Production on Thu Apr 19 09:29:42 2018

Copyright (c) 1982, 2014, Oracle.  All rights reserved.


Connected to:
Oracle Database 12c Enterprise Edition Release 12.1.0.2.0 - 64bit Production
With the Automatic Storage Management option

SQL> create pfile='/tmp/init+ASM.ora' from spfile;

File created.

SQL> shutdown immediate;
ASM diskgroups volume disabled
ASM diskgroups dismounted
ASM instance shutdown
SQL> startup pfile='/tmp/init+ASM.ora';
ASM instance started

Total System Global Area 1140850688 bytes
Fixed Size                  2933400 bytes
Variable Size            1112751464 bytes
ASM Cache                  25165824 bytes
ASM diskgroups mounted
ASM diskgroups volume enabled

SQL> create spfile='+DATA/init.ora' from pfile='/tmp/init+ASM.ora';
create spfile='+DATA/init.ora' from pfile='/tmp/init+ASM.ora'
*
ERROR at line 1:
ORA-17502: ksfdcre:4 Failed to create file +DATA/init.ora
ORA-15221: ASM operation requires compatible.asm of 11.2.0.0.0 or higher



drop diskgroup ARCH including contents;

CREATE DISKGROUP ARCH external REDUNDANCY DISK 'ORCL:ARC01' ATTRIBUTE 'au_size'='16777216';

SQL> select group_number, name,compatibility, database_compatibility from v$asm_diskgroup;

GROUP_NUMBER NAME
------------ ------------------------------
COMPATIBILITY
------------------------------------------------------------
DATABASE_COMPATIBILITY
------------------------------------------------------------
           2 DATA
10.1.0.0.0
10.1.0.0.0

           1 ARCH
12.1.0.0.0
10.1.0.0.0

GROUP_NUMBER NAME
------------ ------------------------------
COMPATIBILITY
------------------------------------------------------------
DATABASE_COMPATIBILITY
------------------------------------------------------------


SQL> alter diskgroup ARCH set attribute 'compatible.asm'='12.1.0.0.0';

Diskgroup altered.

SQL> shutdown immediate;
ASM diskgroups volume disabled
ORA-15032: not all alterations performed
ORA-15027: active use of diskgroup "DATA" precludes its dismount


SQL> startup
ORA-01081: cannot start already-running ORACLE - shut it down first
SQL> shutdown immediate;
ORA-00060: deadlock detected while waiting for resource
SQL> shutdown abort
ASM instance shutdown
SQL> startup
ASM instance started

Total System Global Area 1140850688 bytes
Fixed Size                  2933400 bytes
Variable Size            1112751464 bytes
ASM Cache                  25165824 bytes
ORA-15032: not all alterations performed
ORA-15017: diskgroup "ARCH" cannot be mounted
ORA-15013: diskgroup "ARCH" is already mounted
ORA-15017: diskgroup "DATA" cannot be mounted
ORA-15013: diskgroup "DATA" is already mounted


SQL> drop diskgroup ARCH including contents;

Diskgroup dropped.

SQL> CREATE DISKGROUP ARCH external REDUNDANCY DISK 'ORCL:ARC01' ATTRIBUTE 'au_size'='16777216';

Diskgroup created.

SQL> exit
Disconnected from Oracle Database 12c Enterprise Edition Release 12.1.0.2.0 - 64bit Production
With the Automatic Storage Management option
you have mail in /var/spool/mail/oracle
[oracle@stagepasco:/home/oracle]asmcmd
ASMCMD> lsdg
State    Type    Rebal  Sector  Block        AU  Total_MB  Free_MB  Req_mir_free_MB  Usable_file_MB  Offline_disks  Voting_files  Name
MOUNTED  EXTERN  N         512   4096  16777216    501744   501584                0          501584              0             N  ARCH/
MOUNTED  EXTERN  N         512   4096  16777216   2559920  2559504                0         2559504              0             N  DATA/

