-- 오라클DB에서 현재작업중인 DB내역 확인하기

-- 1. 현재 활성 세션 확인 : 현재 데이터베이스에서 동작 중인 세션 정보를 확인하려면 v$session 뷰를 사용
SELECT sid, serial#, username, status, osuser, machine, program, logon_time
FROM v$session
WHERE username IS NOT NULL;

-- SID: 세션 ID
-- SERIAL#: 세션의 고유 번호 (강제로 세션을 종료할 때 필요)
-- USERNAME: 오라클 사용자 이름
-- STATUS: 세션 상태 (ACTIVE, INACTIVE 등)
-- OSUSER: OS 사용자 이름
-- MACHINE: 세션을 시작한 클라이언트 머신
-- PROGRAM: 실행 중인 프로그램 이름


-- 2. 실행 중인 SQL 확인
SELECT s.sid, s.serial#, s.username, q.sql_text, q.elapsed_time, q.cpu_time
FROM v$session s
JOIN v$sql q ON s.sql_id = q.sql_id
WHERE s.status = 'ACTIVE';

-- SQL_TEXT: 실행 중인 SQL의 텍스트
-- ELAPSED_TIME: SQL 실행에 소요된 총 시간(마이크로초)
-- CPU_TIME: SQL 실행 시 사용된 CPU 시간


-- 3. 트랜잭션 정보를 확인하려면 v$transaction 뷰를 사용
SELECT s.sid, t.start_time, t.used_ublk, t.used_urec, s.username
FROM v$transaction t
JOIN v$session s ON t.ses_addr = s.saddr;

-- SID: 세션 ID
--START_TIME: 트랜잭션 시작 시간
--USED_UBLK: UNDO 블록 사용량
--USED_UREC: UNDO 레코드 사용량


-- 4. 테이블 및 리소스 잠금 확인
SELECT l.session_id, s.username, o.object_name, o.object_type, l.locked_mode
FROM v$locked_object l
JOIN dba_objects o ON l.object_id = o.object_id
JOIN v$session s ON l.session_id = s.sid;

/*
OBJECT_NAME: 잠긴 객체 이름(테이블, 뷰 등)
LOCKED_MODE:
0: No Lock
1: Null Lock
2: Row Share (RS) Lock
3: Row Exclusive (RX) Lock
6: Exclusive Lock
*/


-- 5. TEMP 테이블스페이스 사용량 확인
SELECT s.sid, s.serial#, s.username, u.tablespace, u.segtype, u.blocks * 8 / 1024 AS temp_usage_mb
FROM v$sort_usage u
JOIN v$session s ON u.session_addr = s.saddr
ORDER BY temp_usage_mb DESC;

-- TEMP_USAGE_MB: 세션이 사용하는 TEMP 공간(MB 단위)
-- SEGTYPE: 세션에서 생성한 세그먼트 유형(예: SORT, TEMP TABLE 등)


-- 6. CPU 및 메모리 사용량 확인
-- CPU 사용량 확인
SELECT s.sid, s.serial#, s.username, t.value AS cpu_usage
FROM v$session s
JOIN v$sesstat t ON s.sid = t.sid
JOIN v$statname n ON t.statistic# = n.statistic#
WHERE n.name = 'CPU used by this session';
-- 메모리 사용량 확인
SELECT s.sid, s.serial#, s.username, t.value AS memory_usage
FROM v$session s
JOIN v$sesstat t ON s.sid = t.sid
JOIN v$statname n ON t.statistic# = n.statistic#
WHERE n.name = 'session uga memory';


-- 7. 대기 이벤트 확인
SELECT sid, event, state, wait_time, seconds_in_wait
FROM v$session_wait
WHERE state = 'WAITING';

-- EVENT: 세션이 기다리는 이벤트(예: 디스크 I/O, 락 등)
-- STATE: 현재 상태(WAITING, WAITED)
-- WAIT_TIME: 대기 시간
-- SECONDS_IN_WAIT: 대기한 시간(초 단위)


-- 8. 전체 세션 요약
SELECT
    s.sid,
    s.serial#,
    s.username,
    s.status,
    s.osuser,
    s.program,
    q.sql_text
FROM v$session s
LEFT JOIN v$sql q ON s.sql_id = q.sql_id
WHERE s.username IS NOT NULL
ORDER BY s.status DESC, s.username;


-- 9. 결론
-- 현재 작업 중인 DB 정보를 확인 : v$session, v$sql, v$transaction, v$locked_object 등의 뷰를 사용할 수 있다.






