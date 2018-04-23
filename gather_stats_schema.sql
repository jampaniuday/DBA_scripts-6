--This is used to collect schema stats
--By raymond cao 4/12/2018
 exec dbms_stats.gather_schema_stats( -
ownname          => '&schema_name', -
options          => 'GATHER AUTO', -
estimate_percent => dbms_stats.auto_sample_size, -
method_opt       => 'for all columns size auto', -
cascade          => true, -
degree           => 20 -
);
/

