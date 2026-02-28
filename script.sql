--THEME: internet shop

--do not use CREATE IF EXISTS
--referencne je oracle, nebude fungovat vsetko z mysql

--collision might happen due to references, drop as you can otherwise use force command
--here should come the DROP TABLE commands
--okey takze boolean nefunguje --FIXED
drop table CUSTOMER CASCADE CONSTRAINTS;
drop table SHOPPING_CART CASCADE CONSTRAINTS;
drop table ADDRESS CASCADE CONSTRAINTS;
drop table PRODUCT_CATEGORY CASCADE CONSTRAINTS;
drop table PRODUCT CASCADE CONSTRAINTS;
drop table ORDER_table CASCADE CONSTRAINTS;
drop table PAYMENT CASCADE CONSTRAINTS;

--TABLES

create table CUSTOMER (
    ID_customer int not null,
    customer_name varchar2(20) not null,
    customer_surname varchar2(20),
    email varchar2(100) not null,
    phone_number varchar2(20) not null,
    registration_date int, --DDMMYYYY, DATE type ?
    user_status number(1),
    --TODO: password
    --TODO: generate ID when none is given  
    -- restrictions: 
    CONSTRAINT PK_ID_customer_check primary key (ID_customer),
    CONSTRAINT email_check check (REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$')), -- generated format
    CONSTRAINT user_status_check  check (user_status in (0, 1))
);

create table SHOPPING_CART(
    ID_shopping_cart int not null,  -- PK
    ID_customer int not null,       -- FK
    --TODO date_created ?
    --date_created DATE DEFAULT SYSDATE, --should automatically add real time
    shopping_cart_status number(1),

    --restrictions:
    CONSTRAINT PK_ID_shopping_cart_check primary key (ID_shopping_cart),
    
    --foreign key
    CONSTRAINT FK_ID_cart_customer_check foreign key (ID_customer) references CUSTOMER(ID_customer),
    CONSTRAINT shopping_cart_status_check check (shopping_cart_status in (0, 1))
);

create table ADDRESS(
    ID_address int not null,    -- PK
    ID_customer int not null,   -- FK
    city varchar2(50) not null,
    street varchar2(100),
    postal_number varchar2(30) not null,
    country varchar2(50) not null,
    --TODO: 
    --adress_type varchar2(50)

    --restrictions:
    CONSTRAINT PK_ID_adress_check primary key (ID_address),
    
    --foreign key
    CONSTRAINT FK_ID_adress_customer_check foreign key (ID_customer) references CUSTOMER(ID_customer)
);

create table PRODUCT_CATEGORY(
    ID_category int not null,  -- PK
    category_name varchar2(100) not null,
    category_description varchar2(200),

    --restrictions:
    CONSTRAINT PK_ID_category_check primary key(ID_category)
);

create table PRODUCT(
    ID_product int not null,    -- PK
    ID_category int not null,   -- FK
    product_name varchar2(100) not null,
    EAN_code int,
    price int not null,
    product_description varchar2(200),
    DPH int,
    activity number(1),

    --restrictions:
    CONSTRAINT PK_ID_product_check primary key (ID_product),
    
    --foreign key:
    CONSTRAINT FK_ID_product_category_check foreign key (ID_category) references PRODUCT_CATEGORY(ID_category),
    CONSTRAINT activity_check check (activity in (0,1))
);



create table ORDER_table(
    ID_order int not null,         --PK
    ID_customer int not null,      --FK
    ID_shopping_cart int not null, --FK
    date_created int, --DDMMYYYY
    order_state number(1), --1 if paid, 0 otherwise
    total_amount int, --TODO: restrict that this cannot be 0

    --restrictions:
    CONSTRAINT PK_ID_order_check primary key (ID_order),
  
    --foregin keys:
    CONSTRAINT FK_ID_order_customer_check foreign key (ID_customer) references CUSTOMER(ID_customer),
    CONSTRAINT FK_ID_order_shopping_cart_check foreign key (ID_shopping_cart) references SHOPPING_CART(ID_shopping_cart),
    CONSTRAINT order_state_check check (order_state in (0, 1))
);

create table PAYMENT(
    ID_payment int not null,    --PK
    ID_order int not null,      --FK
    payment_date int, --DDMMYYYY
    total_amount int, --TODO: same as in the ORDER
    order_state number(1), --1 if paid, 0 otherwise, same as ORDER, duplicity..?

    --restrictions:
    CONSTRAINT PK_ID_payment_check primary key (ID_payment),

    --foreign keys:
    CONSTRAINT FK_ID_payment_order_check foreign key (ID_order) references ORDER_table(ID_order),
    CONSTRAINT payment_order_state_check check(order_state in (0, 1))
);

--TODO: add weak entities for shopping_cart_item, order_item

--TODO: add sample data
--customers
insert into CUSTOMER (ID_customer, customer_name, customer_surname, email, phone_number, registration_datem, user_status);
values (1, Martin, Fucheek, martin.fucheek@email.com, '+421999514321', 01022025, true);

insert into CUSTOMER (ID_customer, customer_name, customer_surname, email, phone_number, registration_datem, user_status);
values (2, Ondrej, Machula, ondrej.machula@email.com, '+421564514467', 01022025, true);