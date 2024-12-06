-- 202412 DB 100만건 Insert 해보기
-- 한 번에 1,0000건씩 나누어서 삽입하면 커밋할 때 시스템 리소스 사용을 줄일 수 있다.
-- b_table : a_table 동일구조이다. table명 입력하여 대량의 데이터 Insert 가능하다.
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