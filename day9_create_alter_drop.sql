
-- CREATE --

-- (1) 간단한 '직원' 정보를 관리하는 테이블 생성
-- employee_id (INT), name (VARCHAR(50)), join_date (DATE) 세 개의 열을 포함하여 employees 테이블을 생성

CREATE TABLE employees (
    employee_id INT -- 정수 자료형
    , name VARCHAR(50) -- 문자열 자료형 (가변 길이, 최대 길이:50)
    , join_date DATE -- 날짜 자료형
);

SELECT * FROM employees;

-- ALTER --

-- (2) employees 테이블에 직원의 '부서(department)' 정보를 저장하기 위해, 
-- 최대 30글자의 텍스트를 담을 수 있는 department 열을 추가

ALTER TABLE employees 
ADD COLUMN department VARCHAR(30);

SELECT * FROM employees;

-- 부서 열 레코드 삽입

INSERT INTO employees
VALUES 
    (1, '김민준', '2022-03-15', '영업팀'),
    (2, '이서연', '2021-09-01', '마케팅팀'),
    (3, '박도윤', '2023-01-10', '개발팀'),
    (4, '최지우', '2022-07-22', '영업팀'),
    (5, '정시우', '2020-11-05', '개발팀'),
    (6, '강하은', '2023-05-30', '디자인팀'),
    (7, '조은우', '2021-02-18', '개발팀'),
    (8, '윤서아', '2022-10-03', '마케팅팀'),
    (9, '장예준', '2023-02-20', '개발팀'),
    (10, '임지아', '2022-01-01', '디자인팀');

SELECT * FROM employees;

-- (3) department 열의 데이터 타입을 최대 50글자를 저장할 수 있도록 변경

ALTER TABLE employees
ALTER COLUMN department 
TYPE VARCHAR(50);

-- (4) name을 employee_name으로 더 명확하게 열의 이름을 변경

ALTER TABLE employees
RENAME COLUMN name TO employee_name;

SELECT * FROM employees;

-- (5) employees 테이블에서 join_date 열을 삭제

ALTER TABLE employees
DROP COLUMN join_date;

SELECT * FROM employees;

-- (6) 연습용으로 만들었던 employees 테이블을 삭제

DROP TABLE employees;
