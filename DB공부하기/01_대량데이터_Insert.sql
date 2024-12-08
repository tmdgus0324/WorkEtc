
-- 1. 대량데이터 Insert 시 트랜잭션 크기를 나누어 데이터 작업수행

-- 한 번에 1,0000건씩 나누어서 Insert하면 커밋할 때 시스템 리소스 사용을 줄일 수 있다.
-- b_table = a_table 동일구조이다. table명 입력하여 대량의 데이터 Insert 가능하다.
DECLARE
  CURSOR c_data IS
    SELECT * FROM b_table;
  TYPE t_data IS TABLE OF b_table%ROWTYPE;
  v_data t_data;
BEGIN
  OPEN c_data;
  LOOP
    FETCH c_data BULK COLLECT INTO v_data LIMIT 10000;
    EXIT WHEN v_data.COUNT = 0;
    FORALL i IN 1..v_data.COUNT
      INSERT INTO a_table VALUES v_data(i);
    COMMIT;
  END LOOP;
  CLOSE c_data;
END;

-- BULK COLLECT : 데이터를 한 번에 많이 읽어들여 성능을 향상시킵니다.
-- FORALL : Insert작업을 배치로 처리하여 여러 개의 Insert를 한번에 실행합니다.

-- 또다른예시... 이게 더 좋은방법?
DECLARE
    CURSOR cur_batch IS
        SELECT * FROM source_table
        WHERE ROWNUM <= 2000000; -- 필요한 데이터 조건
    TYPE t_batch IS TABLE OF source_table%ROWTYPE;
    l_batch t_batch;
    l_commit_size CONSTANT PLS_INTEGER := 10000; -- 배치 크기
BEGIN
    OPEN cur_batch;
    LOOP
        FETCH cur_batch BULK COLLECT INTO l_batch LIMIT l_commit_size; -- 배치로 읽기
        EXIT WHEN l_batch.COUNT = 0;

        -- 데이터 INSERT
        FORALL i IN 1 .. l_batch.COUNT
            INSERT INTO target_table VALUES l_batch(i);

        -- 배치마다 커밋
        COMMIT;
    END LOOP;
    CLOSE cur_batch;
END;

-- 또다른방법2... OFFSET 및 FETCH를 사용한 INSERT (11g 이상)
BEGIN
    FOR i IN 0..199 LOOP
        INSERT INTO target_table
        SELECT *
        FROM (
            SELECT * FROM source_table
            ORDER BY id -- 적절한 기준으로 정렬
        )
        OFFSET i * 10000 ROWS FETCH NEXT 10000 ROWS ONLY; -- 배치 크기: 10,000

        COMMIT; -- 배치마다 커밋
    END LOOP;
END;


-- 2. 인덱스 및 제약 조건 확인

-- 인덱스 비활성화
ALTER INDEX idx_a_table_column DISABLE;

-- 제약조건 비활성화
ALTER TABLE a_table DISABLE CONSTRAINT fk_constraint_name;

-- 인덱스, 제약조건 활성화
ALTER INDEX idx_a_table_column ENABLE;
ALTER TABLE a_table ENABLE CONSTRAINT fk_constraint_name;


-- 3. 데이터 작업 후 통계 갱신

-- 2만 건의 데이터가 Insert되면, 인덱스 및 통계가 최신 상태가 아니게 될 수 있다.
-- Insert 후 테이블의 통계를 갱신하여 쿼리 성능을 유지하는 것이 좋다.
-- a_table의 최신 통계를 수집하고 최적화된 실행 계획을 생성할 수 있도록 도와준다.

EXEC DBMS_STATS.GATHER_TABLE_STATS('schema_name', 'a_table');


-- 4. 작업 후 확인 사항

SELECT COUNT(*) FROM a_table;

-- 리소스 모니터링 진행 후 작업 마무리






