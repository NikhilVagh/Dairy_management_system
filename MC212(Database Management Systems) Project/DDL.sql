CREATE SCHEMA dairy_management_system;

SET SEARCH_PATH TO dairy_management_system;

CREATE DOMAIN MOBILE_NUMBER AS DECIMAL(10,0) CHECK(VALUE >= 1000000000 AND VALUE <= 9999999999);

CREATE TABLE WORKER (

	WORKER_ID INTEGER PRIMARY KEY,
	W_FIRST_NAME VARCHAR(10) NOT NULL,
	W_LAST_NAME VARCHAR(10) NOT NULL,
	W_ADDRESS TEXT NOT NULL,
	W_BIRTH_DATE DATE NOT NULL,
	W_JOINING_DATE DATE NOT NULL,
	W_SALARY DECIMAL(6,0)
);

CREATE TABLE WORKER_MOBILE_NUMBER (

	WMN_WORKER_ID INTEGER REFERENCES WORKER(WORKER_ID) ON DELETE CASCADE ON UPDATE CASCADE,
	WMN_MO_NO MOBILE_NUMBER,
	PRIMARY KEY(WMN_WORKER_ID,WMN_MO_NO)
);

CREATE TABLE MANAGER (
	M_WORKER_ID INTEGER REFERENCES WORKER(WORKER_ID) ON DELETE CASCADE ON UPDATE CASCADE PRIMARY KEY,
	M_USER_NAME VARCHAR(15) NOT NULL UNIQUE,
	M_PASSWORD VARCHAR(8) NOT NULL
);

CREATE TABLE CUSTOMER (

	C_MOBILE_NO MOBILE_NUMBER PRIMARY KEY,
	C_FIRST_NAME VARCHAR(10) NOT NULL,
	C_LAST_NAME VARCHAR(10) NOT NULL,
	C_LOCALITY VARCHAR(20),
	C_PINCODE DECIMAL(6,0) CHECK(C_PINCODE >= 100000 AND C_PINCODE <= 999999),
	C_CITY VARCHAR(10),
	W_ID INTEGER DEFAULT 1 NOT NULL,
	FOREIGN KEY(W_ID) REFERENCES WORKER(WORKER_ID) ON DELETE SET DEFAULT ON UPDATE CASCADE
);

CREATE TABLE FEEDBACK (

	F_TITLE VARCHAR(20),
	CUSTOMER_MO_NO MOBILE_NUMBER REFERENCES CUSTOMER(C_MOBILE_NO) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY(CUSTOMER_MO_NO),
	F_RATING DECIMAL(2,1) CHECK(F_RATING >= 0.0 AND F_RATING <= 5.0) NOT NULL,
	F_COMMENT TEXT
);

CREATE TABLE OUTLET (
 
	OUTLET_CODE VARCHAR(5),
	PRIMARY KEY(OUTLET_CODE),
	O_STARTING_DATE DATE NOT NULL,
	O_ADDRESS TEXT NOT NULL
);
 
CREATE TABLE OUTLET_MOBILE_NUMBER (

	OMN_OUTLET_CODE VARCHAR(5) REFERENCES OUTLET(OUTLET_CODE) ON DELETE CASCADE ON UPDATE CASCADE,
	OMN_MOBILE_NO MOBILE_NUMBER,
	PRIMARY KEY(OMN_OUTLET_CODE,OMN_MOBILE_NO)
);

CREATE TABLE WORKING (

	W_WORKER_ID INTEGER REFERENCES WORKER(WORKER_ID) ON DELETE CASCADE ON UPDATE CASCADE,
	W_OUTLET_ID VARCHAR(5) REFERENCES OUTLET(OUTLET_CODE) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY(W_WORKER_ID,W_OUTLET_ID)
);

CREATE TABLE BILL (

	BILL_ID DECIMAL(11,0) PRIMARY KEY,
	B_PAYMENT_TYPE VARCHAR(8) NOT NULL,
	B_TOTAL_AMOUNT DOUBLE PRECISION NOT NULL,
	B_TOTAL_TAX REAL,
	B_DATE DATE NOT NULL,
	C_MO_NO MOBILE_NUMBER REFERENCES CUSTOMER(C_MOBILE_NO) ON UPDATE CASCADE ON DELETE RESTRICT,
	O_CODE VARCHAR(5) DEFAULT 'MAIN' NOT NULL,
	FOREIGN KEY(O_CODE) REFERENCES OUTLET(OUTLET_CODE) ON DELETE SET DEFAULT ON UPDATE CASCADE
);

CREATE TABLE SELLER (

	SELLER_ID DECIMAL(8) PRIMARY KEY,
	S_FIRST_NAME VARCHAR(10) NOT NULL,
	S_LAST_NAME VARCHAR(10) NOT NULL,
	S_COMPANY_NAME VARCHAR(20) NOT NULL,
	S_MOBILE_NO MOBILE_NUMBER NOT NULL
);

CREATE TABLE PRODUCT (
	
	PRODUCT_ID VARCHAR(8) PRIMARY KEY,
	P_NAME VARCHAR(20) NOT NULL,
	P_COMPANY_NAME VARCHAR(20) NOT NULL,
	P_TAX REAL NOT NULL,
	P_UNIT_PRICE REAL NOT NULL,
	P_QUANTITY INTEGER NOT NULL,
	P_PROFIT REAL NOT NULL,
	P_SELLER_ID DECIMAL(8) REFERENCES SELLER(SELLER_ID) ON DELETE SET DEFAULT ON UPDATE CASCADE
);

CREATE TABLE INCLUDE_PRODUCT (

	I_BILL_ID DECIMAL(11) REFERENCES BILL(BILL_ID) ON DELETE CASCADE ON UPDATE CASCADE,
	I_PRODUCT_ID VARCHAR(8) REFERENCES PRODUCT(PRODUCT_ID) ON DELETE CASCADE ON UPDATE CASCADE,
	I_QUANTITY DECIMAL(5),
	PRIMARY KEY(I_BILL_ID,I_PRODUCT_ID)
);

CREATE TABLE MILK (

	M_PRODUCT_ID VARCHAR(8) REFERENCES PRODUCT(PRODUCT_ID) ON DELETE CASCADE ON UPDATE CASCADE,
	M_TYPE VARCHAR(10) CHECK(M_TYPE IN ('COW','BUFFALO','GOAT','SHEEP')),
	M_FAT REAL CHECK(M_FAT <= 7.0 AND M_FAT >= 0.0),
	PRIMARY KEY(M_PRODUCT_ID),
	M_TOTAL_QUANTITY INTEGER NOT NULL
);

CREATE TABLE TRANSPORT (

	TRANSPORT_ID DECIMAL(10) PRIMARY KEY,
	DRIVER_FIRST_NAME VARCHAR(10) NOT NULL,
	DRIVER_LAST_NAME VARCHAR(10) NOT NULL,
	T_DATE DATE NOT NULL,
	ADDRESS TEXT NOT NULL,
	T_TOTAL_AMOUNT DOUBLE PRECISION NOT NULL,
	MERCHANT_FIRST_NAME VARCHAR(10) NOT NULL,
	MERCHANT_LAST_NAME VARCHAR(10) NOT NULL,
	MERCHANT_MO_NO MOBILE_NUMBER NOT NULL,
	T_BILL_ID DECIMAL(11) UNIQUE REFERENCES BILL(BILL_ID) ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
	T_WORKER_ID INTEGER DEFAULT 1 NOT NULL,
	FOREIGN KEY(T_WORKER_ID) REFERENCES WORKER(WORKER_ID) ON DELETE SET DEFAULT ON UPDATE CASCADE
);

CREATE TABLE SELLING_REPORT(
	SR_TOTAL_QUANTITY INTEGER NOT NULL,
	SR_TOTAL_AMOUNT DOUBLE PRECISION NOT NULL,
	SR_TOTAL_PROFIT REAL NOT NULL,
	SR_DATE DATE NOT NULL,
	SR_PRODUCT_CODE VARCHAR(8) REFERENCES PRODUCT(PRODUCT_ID) ON DELETE NO ACTION ON UPDATE CASCADE, 
	SR_OUTLET_CODE VARCHAR(5) DEFAULT 'MAIN',
	FOREIGN KEY(SR_OUTLET_CODE) REFERENCES OUTLET(OUTLET_CODE) ON DELETE SET DEFAULT ON UPDATE CASCADE,	
	PRIMARY KEY(SR_DATE,SR_PRODUCT_CODE,SR_OUTLET_CODE)
);

CREATE TABLE PURCHASE_REPORT(
	PR_DATE DATE NOT NULL,
	PAYMENT_TYPE VARCHAR(8) NOT NULL, 
	PR_TOTAL_AMOUNT DOUBLE PRECISION NOT NULL,
	SELLER_ID  DECIMAL(8) REFERENCES SELLER(SELLER_ID) ON DELETE SET DEFAULT ON UPDATE CASCADE, 
	OUTLET_CODE VARCHAR(5) DEFAULT 'MAIN',
	FOREIGN KEY(OUTLET_CODE) REFERENCES OUTLET(OUTLET_CODE) ON DELETE SET DEFAULT ON UPDATE CASCADE,
	PRIMARY KEY(PR_DATE,SELLER_ID,OUTLET_CODE)
);