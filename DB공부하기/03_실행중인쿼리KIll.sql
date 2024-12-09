

-- 1. 실행 중인 SQL 확인
SELECT s.sid, s.serial#, s.username, q.sql_text, q.elapsed_time, q.cpu_time
FROM v$session s
JOIN v$sql q ON s.sql_id = q.sql_id
WHERE s.status = 'ACTIVE';

-- 2. sid, serial 번호 확인 후 동작중인 쿼리 kill작업진행
begin
    rdsadmin.rdsadmin_util.kill(
        sid => 88,
        serial => 49026);
end;

-- 3. Alter Kill할 때는 SYS권한이 있어야 한다. 근데 이건 잘 안되었음...
ALTER SYSTEM KILL SESSION '9,18322';
ALTER SYSTEM KILL SESSION '9,18322' IMMEDIATE;



