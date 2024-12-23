-- ****** 쿼리문 성능개선공부 ******

-- 1.
/*
A,B,C,D 등으로 구성된 행을 ,단위로 쪼개어 열로 나타내는 방법
*/
SELECT REGEXP_SUBSTR(컬럼, '[^,]+', 1, LEVEL) USER_ID
FROM DUAL
CONNECT BY REGEXP_SUBSTR(컬럼,'[^,]+',1,LEVEL) IS NOT NULL;
-- 컬럼의 값을 정규식을 사용해 쉼표(,)로 구분된 부분 문자열로 추출
-- 쉼표가 아닌([^,]) 문자들의 연속된 문자열을 찾음
-- LEVEL : 계층형 쿼리에서 제공하는 값을 사용해 몇 번째 패턴을 추출할지 결정
-- REGEXP_SUBSTR는 매칭되지 않으면 NULL을 반환, CONNECT BY 조건에 IS NOT NULL 추가

/*
CONNECT BY 방식의 쿼리문은 성능이 저하된다. 이를 막기 위하여 함수로 속도를 개선한다.
*/

-- A,B,C,D 로 되어 있는 컬럼을 열로 나누는 함수
CREATE OR REPLACE FUNCTION SPLIT_STRING(
  P_STRING IN VARCHAR2,
  P_DELIMITER IN VARCHAR2
) RETURN SYS.ODCIVARCHAR2LIST PIPELINED IS
  L_START NUMBER := 1;
  L_END NUMBER;
BEGIN
  LOOP
    L_END := INSTR(P_STRING, P_DELIMITER, L_START);
    IF L_END = 0 THEN
      PIPE ROW(SUBSTR(P_STRING, L_START));
      EXIT;
    END IF;
    PIPE ROW(SUBSTR(P_STRING, L_START, L_END - L_START));
    L_START := L_END + LENGTH(P_DELIMITER);
  END LOOP;
  RETURN;
END;
/

-- SPLIT_STRING 함수는 쉼표를 기준으로 문자열을 분리
-- **파이프라이닝(Pipelining)**으로 데이터를 행 단위로 반환하여 메모리 효율성을 높임



-- 2.
/*
위 방법과 합쳐서 열로 나누어진 한 세트를 다시 ,로 구분하여 행으로 만드는 방법
*/
SELECT LISTAGG(NAME, ',') 
FROM EMP_TABLE 
WHERE USER_ID IN (SELECT COLUMN_VALUE AS USER_ID FROM TABLE(SPLIT_STRING('A,B,C,D', ',')));

-- 함수로 변환, NULL 고려하여 함수생성
CREATE OR REPLACE FUNCTION GET_AGGREGATED_NAMES(
  P_STRING IN VARCHAR2
) RETURN VARCHAR2 IS
  L_RESULT VARCHAR2(4000);
BEGIN
  -- 입력값이 NULL인 경우 빈 문자열 반환
  IF P_STRING IS NULL THEN
    RETURN '';
  END IF;

  -- LISTAGG 수행
  SELECT LISTAGG(E.NAME, ',') WITHIN GROUP (ORDER BY E.NAME)
  INTO L_RESULT
  FROM EMP_TABLE E
  WHERE E.USER_ID IN (
    SELECT COLUMN_VALUE 
    FROM TABLE(SPLIT_STRING(P_STRING, ','))
  );

  RETURN L_RESULT;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN ''; -- 결과가 없을 경우 빈 문자열 반환
END;
/


-- 참고사항, NVL 사용하여 NULL 방어할 수 있다. LISTAGG은 FULL SCAN을 할 수 있다.
SELECT LISTAGG(E.NAME, ',') WITHIN GROUP (ORDER BY E.NAME)
FROM EMP_TABLE E
WHERE NVL(E.USER_ID, 'NULL') IN (
  SELECT NVL(COLUMN_VALUE, 'NULL') FROM TABLE(SPLIT_STRING(NULL, ','))
);


