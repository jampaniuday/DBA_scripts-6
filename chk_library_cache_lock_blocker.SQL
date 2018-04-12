column h_wait format A20
SELECT s.sid,  
    waiter.p1raw w_p1r,
    waiter.p2raw w_p2r,
    holder.event h_wait,
    holder.p1raw h_p1r,
    holder.p2raw h_p2r,
    count(s.sid) users_blocked,
    sql.hash_value
FROM
    v$sql sql,
    v$session s,
    x$kgllk l,
    v$session_wait waiter,
    v$session_wait holder
WHERE
    s.sql_hash_value = sql.hash_value and
    l.KGLLKADR=waiter.p2raw and
    s.saddr=l.kgllkuse and
    waiter.event like 'library cache lock' and
    holder.sid=s.sid
GROUP BY
    s.sid,
    waiter.p1raw ,
    waiter.p2raw ,
    holder.event ,
    holder.p1raw ,
    holder.p2raw ,
    sql.hash_value
;