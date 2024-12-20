*** 참고 ***
(1) LISTAGG(column_name, delimiter) WITHIN GROUP (ORDER BY sort_column)
    - column_name: 결합하려는 열의 이름
    - delimiter: 각 값 사이에 삽입할 구분자. 예: ',', ';', '|'
    - WITHIN GROUP (ORDER BY sort_column): 데이터를 결합하기 전에 정렬할 기준 열

(2) REGEXP_SUBSTR(컬럼, '[^,]+', 1, LEVEL)
    - 컬럼: 쉼표로 구분된 문자열이 있는 컬럼
    - '[^,]+':
        정규식 패턴입니다.
        [^,]+는 쉼표가 아닌 문자들로 이루어진 연속된 문자열을 의미합니다.
        쉼표를 기준으로 문자열을 나눕니다.
    - 1: 검색 시작 위치입니다. 문자열의 첫 번째 문자부터 검색합니다.
    - LEVEL: 몇 번째로 매칭된 값을 추출할지 지정합니다.
        LEVEL은 계층형 쿼리(예: CONNECT BY)에서 자동으로 증가하며, 반복적으로 각 요소를 추출합니다.

(3) CONNECT BY LEVEL
    - 계층형 쿼리를 사용하여 LEVEL 값을 증가시킵니다.
    - LEVEL 값은 REGEXP_SUBSTR에서 몇 번째 항목을 추출할지 결정합니다.
    - 조건문을 사용하여 데이터 끝까지 탐색합니다.
;

-- 성능개선하기! -- 
SELECT REGEXP_SUBSTR(컬럼, '[^,]+', 1, LEVEL) USER_ID
FROM DUAL
CONNECT BY REGEXP_SUBSTR(컬럼,'[^,]+',1,LEVEL) IS NOT NULL;

EX) 다음예제 통하여 확인하자
SELECT 'A,B,C,D' AS 컬럼 FROM DUAL;

SELECT REGEXP_SUBSTR(컬럼, '[^,]+', 1, LEVEL) USER_ID
FROM DUAL
CONNECT BY REGEXP_SUBSTR(컬럼, '[^,]+', 1, LEVEL) IS NOT NULL;

    ** 동작 과정 **
    LEVEL = 1:
    REGEXP_SUBSTR('A,B,C,D', '[^,]+', 1, 1) → A
    출력: A
    LEVEL = 2:
    REGEXP_SUBSTR('A,B,C,D', '[^,]+', 1, 2) → B
    출력: B
    LEVEL = 3:
    REGEXP_SUBSTR('A,B,C,D', '[^,]+', 1, 3) → C
    출력: C
    LEVEL = 4:
    REGEXP_SUBSTR('A,B,C,D', '[^,]+', 1, 4) → D
    출력: D
    LEVEL = 5:
    REGEXP_SUBSTR('A,B,C,D', '[^,]+', 1, 5) → NULL
    조건을 만족하지 않으므로 종료.

    결과
    USER_ID
    A
    B
    C
    D

1. 정규식 대신 다른 방법 사용
2. PL/SQL 사용자 정의 함수 활용
3. SQL과 XMLTABLE 사용
4. 병렬 처리(PARALLEL QUERY) 활성화