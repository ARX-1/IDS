--THEME: internet shop

--Dropping tables
begin
    execute IMMEDIATE 'drop table PAYMENT CASCADE CONSTRAINTS';
    execute IMMEDIATE 'drop table ORDER_ITEM CASCADE CONSTRAINTS';
    execute IMMEDIATE 'drop table ORDER_table CASCADE CONSTRAINTS';
    execute IMMEDIATE 'drop table SHOPPING_CART_ITEM CASCADE CONSTRAINTS';
    execute IMMEDIATE 'drop table SHOPPING_CART CASCADE CONSTRAINTS';
    execute IMMEDIATE 'drop table ADDRESS_table CASCADE CONSTRAINTS';
    execute IMMEDIATE 'drop table PRODUCT_table CASCADE CONSTRAINTS';
    execute IMMEDIATE 'drop table PRODUCT_CATEGORY CASCADE CONSTRAINTS';
    execute IMMEDIATE 'drop table CUSTOMER CASCADE CONSTRAINTS';
exception when others then null;
end;
/

begin
    -- Triggers
    begin execute immediate 'drop trigger TRG_CUSTOMER_BI_SET_ID'; exception when others then null; end;
    begin execute immediate 'drop trigger TRG_CUSTOMER_PK'; exception when others then null; end;
    begin execute immediate 'drop trigger TRG_SHOPPING_CART_PK'; exception when others then null; end;
    begin execute immediate 'drop trigger TRG_ADDRESS_TABLE_PK'; exception when others then null; end;
    begin execute immediate 'drop trigger TRG_PRODUCT_CATEGORY_PK'; exception when others then null; end;
    begin execute immediate 'drop trigger TRG_PRODUCT_TABLE_PK'; exception when others then null; end;
    begin execute immediate 'drop trigger TRG_ORDER_TABLE_PK'; exception when others then null; end;
    begin execute immediate 'drop trigger TRG_PAYMENT_PK'; exception when others then null; end;
    begin execute immediate 'drop trigger TRG_SHOP_CART_ITEM_PK'; exception when others then null; end;
    begin execute immediate 'drop trigger TRG_ORDER_ITEM_PK'; exception when others then null; end;

    -- Sequences
    begin execute immediate 'drop sequence SEQ_CUSTOMER_ID'; exception when others then null; end;
    begin execute immediate 'drop sequence SEQ_SHOPPING_CART_ID'; exception when others then null; end;
    begin execute immediate 'drop sequence SEQ_ADDRESS_ID'; exception when others then null; end;
    begin execute immediate 'drop sequence SEQ_CATEGORY_ID'; exception when others then null; end;
    begin execute immediate 'drop sequence SEQ_PRODUCT_ID'; exception when others then null; end;
    begin execute immediate 'drop sequence SEQ_ORDER_ID'; exception when others then null; end;
    begin execute immediate 'drop sequence SEQ_PAYMENT_ID'; exception when others then null; end;
    begin execute immediate 'drop sequence SEQ_SHOP_CART_ITEM_ID'; exception when others then null; end;
    begin execute immediate 'drop sequence SEQ_ORDER_ITEM_ID'; exception when others then null; end;
end;
/



--TABLES

create table CUSTOMER (
    ID_customer int not null,
    customer_name varchar2(20) not null,
    customer_surname varchar2(20),
    email varchar2(100) not null,
    phone_number varchar2(20) not null,
    registration_date date,
    user_status number(1),
    password_hash varchar2(255),
    -- restrictions: 
    CONSTRAINT PK_ID_customer_check primary key (ID_customer),
    CONSTRAINT email_check check (REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$')), -- generated format
    CONSTRAINT user_status_check  check (user_status in (0, 1))
);

create table SHOPPING_CART(
    ID_shopping_cart int not null,  -- PK
    ID_customer int not null,       -- FK
    date_created date default sysdate,
    --date_created DATE DEFAULT SYSDATE, --should automatically add real time
    shopping_cart_status number(1),

    --restrictions:
    CONSTRAINT PK_ID_shopping_cart_check primary key (ID_shopping_cart),
    
    --foreign key
    CONSTRAINT FK_ID_cart_customer_check foreign key (ID_customer) references CUSTOMER(ID_customer),
    CONSTRAINT shopping_cart_status_check check (shopping_cart_status in (0, 1))
);

create table ADDRESS_table(
    ID_address int not null,    -- PK
    ID_customer int not null,   -- FK
    city varchar2(50) not null,
    street varchar2(100),
    postal_number varchar2(30) not null,
    country varchar2(50) not null,
    address_type varchar2(50),

    --restrictions:
    CONSTRAINT PK_ID_address_check primary key (ID_address),
    
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

create table PRODUCT_table(
    ID_product int not null,    -- PK
    ID_category int not null,   -- FK
    product_name varchar2(100) not null,
    price int not null,
    product_description varchar2(200),
    DPH int,
    activity number(1),

    --restrictions:
    CONSTRAINT PK_ID_product_check primary key (ID_product),
    
    --foreign key:
    CONSTRAINT FK_ID_product_category_check foreign key (ID_category) references PRODUCT_CATEGORY(ID_category),
    CONSTRAINT product_activity_check check (activity in (0, 1))
);

create table ORDER_table(
    ID_order int not null,         --PK
    ID_customer int not null,      --FK
    --ID_shopping_cart int not null, --FK TODO: might remove this
    date_created date default sysdate,
    order_state number(1), --1 if paid, 0 otherwise
    total_amount int, --TODO: restrict that this cannot be 0

    --restrictions:
    CONSTRAINT PK_ID_order_check primary key (ID_order),
  
    --foregin keys:
    CONSTRAINT FK_ID_order_customer_check foreign key (ID_customer) references CUSTOMER(ID_customer),
    --CONSTRAINT FK_ID_order_shopping_cart_check foreign key (ID_shopping_cart) references SHOPPING_CART(ID_shopping_cart),
    CONSTRAINT order_state_check check (order_state in (0, 1))
);

create table PAYMENT(
    ID_payment int not null,    --PK
    ID_order int not null,      --FK
    payment_date date default sysdate, --DDMMYYYY
    total_amount int, --TODO: same as in the ORDER
    order_state number(1), --1 if paid, 0 otherwise, same as ORDER, duplicity..? TODO: !!!!
    payment_type varchar2(20) not null,
    authorization_code varchar2(30),
    card_last4 char(4),
    iban varchar2(34),
    variable_symbol varchar2(10),

    --restrictions:
    CONSTRAINT PK_ID_payment_check primary key (ID_payment),

    --foreign keys:
    CONSTRAINT FK_ID_payment_order_check foreign key (ID_order) references ORDER_table(ID_order),
    CONSTRAINT payment_order_state_check check(order_state in (0, 1)),
    --Generalization/specialization (PAYMENT -> CARD, BANK_TRANSFER):
    --Implemented as single table with discriminator payment_type.
    --This CHECK enforces TOTAL specialization (every payment has exactly one subtype)
    --and DISJOINT specialization (cannot be CARD and BANK_TRANSFER at the same time).
    CONSTRAINT payment_type_check check (payment_type in ('CARD', 'BANK_TRANSFER')),
    CONSTRAINT card_last4_format_check check (card_last4 is null or REGEXP_LIKE(card_last4, '^[0-9]{4}$')),
    CONSTRAINT iban_format_check check (iban is null or REGEXP_LIKE(iban, '^[A-Z]{2}[0-9A-Z]{13,32}$')),
    CONSTRAINT variable_symbol_format_check check (variable_symbol is null or REGEXP_LIKE(variable_symbol, '^[0-9]{1,10}$')),
    CONSTRAINT payment_specialization_check check (
        (payment_type = 'CARD'
            and authorization_code is not null
            and card_last4 is not null
            and iban is null
            and variable_symbol is null)
        or
        (payment_type = 'BANK_TRANSFER'
            and iban is not null
            and variable_symbol is not null
            and authorization_code is null
            and card_last4 is null)
    )
);

--TODO: add tables for shopping_cart_item, order_item
create table SHOPPING_CART_ITEM(
    ID_shopping_cart_item int not null,     --PK
    ID_shopping_cart int not null,          --FK
    ID_product int not null,                --FK
    quantity int not null, 
    price_at_insertion int not null,
    date_added_to_cart date default sysdate,

    --restrictions:
    CONSTRAINT PK_ID_shopping_cart_item_check primary key (ID_shopping_cart_item),
    CONSTRAINT FK_ID_shopping_cart_check foreign key (ID_shopping_cart) references SHOPPING_CART(ID_shopping_cart),
    CONSTRAINT FK_ID_item_product_check foreign key (ID_product) references PRODUCT_table(ID_product)
);

create table ORDER_ITEM(
    ID_order_item int not null,     --PK
    ID_product int not null,        --FK
    ID_order int not null,          --FK
    quantity int not null, 
    selling_price int not null,

    CONSTRAINT PK_ID_order_item_check primary key (ID_order_item),
    CONSTRAINT FK_ID_product_check foreign key (ID_product) references PRODUCT_table(ID_product),
    CONSTRAINT FK_ID_order_check foreign key (ID_order) references ORDER_table(ID_order)
);

--Automatic PK generation for all main tables. If PK is omitted or NULL in INSERT,
--the trigger assigns a value from the corresponding sequence.
create sequence SEQ_CUSTOMER_ID start with 10 increment by 1 nocache;
create sequence SEQ_SHOPPING_CART_ID start with 50009 increment by 1 nocache;
create sequence SEQ_ADDRESS_ID start with 1000009 increment by 1 nocache;
create sequence SEQ_CATEGORY_ID start with 1003 increment by 1 nocache;
create sequence SEQ_PRODUCT_ID start with 4007 increment by 1 nocache;
create sequence SEQ_ORDER_ID start with 70006 increment by 1 nocache;
create sequence SEQ_PAYMENT_ID start with 1 increment by 1 nocache;
create sequence SEQ_SHOP_CART_ITEM_ID start with 60008 increment by 1 nocache;
create sequence SEQ_ORDER_ITEM_ID start with 80008 increment by 1 nocache;

create or replace trigger TRG_CUSTOMER_PK
before insert on CUSTOMER
for each row
begin
    if :new.ID_customer is null then
        :new.ID_customer := SEQ_CUSTOMER_ID.nextval;
    end if;
end;
/

create or replace trigger TRG_SHOPPING_CART_PK
before insert on SHOPPING_CART
for each row
begin
    if :new.ID_shopping_cart is null then
        :new.ID_shopping_cart := SEQ_SHOPPING_CART_ID.nextval;
    end if;
end;
/

create or replace trigger TRG_ADDRESS_TABLE_PK
before insert on ADDRESS_table
for each row
begin
    if :new.ID_address is null then
        :new.ID_address := SEQ_ADDRESS_ID.nextval;
    end if;
end;
/

create or replace trigger TRG_PRODUCT_CATEGORY_PK
before insert on PRODUCT_CATEGORY
for each row
begin
    if :new.ID_category is null then
        :new.ID_category := SEQ_CATEGORY_ID.nextval;
    end if;
end;
/

create or replace trigger TRG_PRODUCT_TABLE_PK
before insert on PRODUCT_table
for each row
begin
    if :new.ID_product is null then
        :new.ID_product := SEQ_PRODUCT_ID.nextval;
    end if;
end;
/

create or replace trigger TRG_ORDER_TABLE_PK
before insert on ORDER_table
for each row
begin
    if :new.ID_order is null then
        :new.ID_order := SEQ_ORDER_ID.nextval;
    end if;
end;
/

create or replace trigger TRG_PAYMENT_PK
before insert on PAYMENT
for each row
begin
    if :new.ID_payment is null then
        :new.ID_payment := SEQ_PAYMENT_ID.nextval;
    end if;
end;
/

create or replace trigger TRG_SHOP_CART_ITEM_PK
before insert on SHOPPING_CART_ITEM
for each row
begin
    if :new.ID_shopping_cart_item is null then
        :new.ID_shopping_cart_item := SEQ_SHOP_CART_ITEM_ID.nextval;
    end if;
end;
/

create or replace trigger TRG_ORDER_ITEM_PK
before insert on ORDER_ITEM
for each row
begin
    if :new.ID_order_item is null then
        :new.ID_order_item := SEQ_ORDER_ITEM_ID.nextval;
    end if;
end;
/

--TODO: add sample data
--Customers:
insert into CUSTOMER (ID_customer, customer_name, customer_surname, email, phone_number, password_hash, registration_date, user_status)
values (1, 'Martin', 'Fucheek', 'martin.fucheek@email.com', '+421999514321', 'pwdhash1', DATE '2025-02-01', 1);
insert into CUSTOMER (ID_customer, customer_name, customer_surname, email, phone_number, password_hash, registration_date, user_status)
values (2, 'Ondrej', 'Machula', 'ondrej.machula@email.com', '+421564514467', 'pwdhash2', DATE '2025-02-01', 1);
insert into CUSTOMER (ID_customer, customer_name, customer_surname, email, phone_number, password_hash, registration_date, user_status)
values (3, 'Andrej', 'Soska', 'andrej.soska@email.com', '+421999565487', 'pwdhash3', DATE '2007-05-27', 0);
insert into CUSTOMER (ID_customer, customer_name, customer_surname, email, phone_number, password_hash, registration_date, user_status)
values (4, 'Jakub', 'Novotný', 'jakub.novotny@email.com', '+420731445892', 'pwdhash4', DATE '2025-02-01', 1);
insert into CUSTOMER (ID_customer, customer_name, customer_surname, email, phone_number, password_hash, registration_date, user_status)
values (5, 'Petra', 'Kučerová', 'petra.kucerova@email.com', '+420728963441', 'pwdhash5', DATE '2025-02-01', 1);
insert into CUSTOMER (ID_customer, customer_name, customer_surname, email, phone_number, password_hash, registration_date, user_status)
values (6, 'Tomáš', 'Doležal', 'tomas.dolezal@email.com', '+420602784512', 'pwdhash6', DATE '2025-02-01', 1);
insert into CUSTOMER (ID_customer, customer_name, customer_surname, email, phone_number, password_hash, registration_date, user_status)
values (7, 'Lucie', 'Svobodová', 'lucie.svobodova@email.com', '+420775632198', 'pwdhash7', DATE '2025-02-01', 1);
insert into CUSTOMER (ID_customer, customer_name, customer_surname, email, phone_number, password_hash, registration_date, user_status)
values (8, 'David', 'Král', 'david.kral@email.com', '+420739852147', 'pwdhash8', DATE '2025-02-01', 1);
insert into CUSTOMER (ID_customer, customer_name, customer_surname, email, phone_number, password_hash, registration_date, user_status)
values (9, 'Barbora', 'Veselá', 'barbora.vesela@email.com', '+420721369845', 'pwdhash9', DATE '2025-02-01', 1);
insert into CUSTOMER (customer_name, customer_surname, email, phone_number, password_hash, registration_date, user_status)
values ('Auto', 'Generated', 'auto.generated@email.com', '+420700000000', 'pwdhash_auto', DATE '2026-03-29', 1);

--Addresses:
insert into ADDRESS_table(ID_address, ID_customer, city, street, postal_number, country)
values (1000000, 1, 'Brno', 'Kounicova 12', '60200', 'Czech Republic');
insert into ADDRESS_table(ID_address, ID_customer, city, street, postal_number, country)
values (1000001, 2, 'Ostrava', 'Nádražní 84', '70200', 'Czech Republic');
insert into ADDRESS_table(ID_address, ID_customer, city, street, postal_number, country)
values (1000002, 3, 'Olomouc', 'Polská 3', '77900', 'Czech Republic');
insert into ADDRESS_table(ID_address, ID_customer, city, street, postal_number, country)
values (1000003, 4, 'Praha', 'Vinohradská 112', '13000', 'Czech Republic');
insert into ADDRESS_table(ID_address, ID_customer, city, street, postal_number, country)
values (1000004, 5, 'Plzeň', 'Klatovská tř. 45', '30100', 'Czech Republic');
insert into ADDRESS_table(ID_address, ID_customer, city, street, postal_number, country)
values (1000005, 6, 'Hradec Králové', 'Gočárova třída 18', '50002', 'Czech Republic');
insert into ADDRESS_table(ID_address, ID_customer, city, street, postal_number, country)
values (1000006, 7, 'České Budějovice', 'Husova tř. 22', '37001', 'Czech Republic');
insert into ADDRESS_table(ID_address, ID_customer, city, street, postal_number, country)
values (1000007, 8, 'Liberec', 'Masarykova 9', '46001', 'Czech Republic');
insert into ADDRESS_table(ID_address, ID_customer, city, street, postal_number, country)
values (1000008, 9, 'Zlín', 'tř. Tomáše Bati 154', '76001', 'Czech Republic');

--Product categories:
insert into PRODUCT_CATEGORY (ID_CATEGORY, category_name, category_description)
values (1000, 'Running', 'Engineered for peak performance—trusted by elite runners and welcoming for beginners.');
insert into PRODUCT_CATEGORY (ID_CATEGORY, category_name, category_description)
values (1001, 'Swimming', 'Built to glide through every lap, whether you are chasing personal records or enjoying a relaxed swim.');
insert into PRODUCT_CATEGORY (ID_CATEGORY, category_name, category_description)
values (1002, 'Cycling', 'Made to elevate every kilometer, whether you are conquering climbs or cruising city streets.');

--Products:

--Running category:
--Running category:
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (2000, 1000, 'Addidas Adizero Evo SL', 3239, 'Feather-light speed for every stride.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (2001, 1000, 'Nike Zoom Fly 6', 3239, 'Feather-light speed for every stride.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (2002, 1000, 'Asics Gel Nimbus 26', 3899, 'Soft cushioning for long-distance comfort.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (2003, 1000, 'New Balance Fresh Foam 1080v13', 4199, 'Smooth, plush ride for everyday training.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (2004, 1000, 'Puma Deviate Nitro 2', 3599, 'Responsive propulsion for faster runs.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (2005, 1000, 'Hoka Clifton 9', 3499, 'Lightweight cushioning for effortless miles.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (2006, 1000, 'Saucony Endorphin Speed 4', 4299, 'Versatile speed shoe with energetic rebound.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (2007, 1000, 'Brooks Ghost 16', 3299, 'Balanced cushioning for smooth daily runs.', 21, 1);

--Swimming category:
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (3000, 1001, 'Speedo Biofuse Training Fins', 899, 'Comfortable training fins for improved kick strength.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (3001, 1001, 'Arena Powerfin Pro', 1199, 'Short-blade fins designed for explosive power.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (3002, 1001, 'Finis Long Floating Fins', 999, 'Long fins ideal for technique and endurance training.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (3003, 1001, 'TYR Stryker Silicone Fins', 1099, 'Soft silicone construction for natural movement.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (3004, 1001, 'Mad Wave Pool Fins', 849, 'Short training fins for increased kick tempo.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (3005, 1001, 'Cressi Light Swim Fins', 799, 'Lightweight fins suitable for pool and open water.', 21, 1);

--Cycling category:
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (4001, 1002, 'Specialized Tarmac SL7', 129999, 'Aero efficiency and lightweight performance in one frame.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (4002, 1002, 'Cannondale SuperSix EVO 4', 114999, 'Balanced stiffness and comfort for fast road riding.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (4003, 1002, 'Trek Émonda SL 6', 109999, 'Ultra‑light climbing bike with race‑ready geometry.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (4004, 1002, 'Giant TCR Advanced 2', 89999, 'Efficient all‑rounder built for speed and precision.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (4005, 1002, 'Bianchi Sprint 105', 94999, 'Classic Italian design with modern race performance.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (4006, 1002, 'Canyon Ultimate CF SL 7', 104999, 'Lightweight carbon frame with excellent handling.', 21, 1);

--Shopping carts:
insert into SHOPPING_CART(ID_shopping_cart, ID_customer, shopping_cart_status)
values (50000, 1, 1);
insert into SHOPPING_CART(ID_shopping_cart, ID_customer, shopping_cart_status)
values (50001, 2, 1);
insert into SHOPPING_CART(ID_shopping_cart, ID_customer, shopping_cart_status)
values (50002, 3, 0);
insert into SHOPPING_CART(ID_shopping_cart, ID_customer, shopping_cart_status)
values (50003, 4, 1);
insert into SHOPPING_CART(ID_shopping_cart, ID_customer, shopping_cart_status)
values (50004, 5, 0);
insert into SHOPPING_CART(ID_shopping_cart, ID_customer, shopping_cart_status)
values (50005, 6, 1);
insert into SHOPPING_CART(ID_shopping_cart, ID_customer, shopping_cart_status)
values (50006, 7, 0);
insert into SHOPPING_CART(ID_shopping_cart, ID_customer, shopping_cart_status)
values (50007, 8, 1);
insert into SHOPPING_CART(ID_shopping_cart, ID_customer, shopping_cart_status)
values (50008, 9, 1);

--Shopping carts items:
insert into SHOPPING_CART_ITEM(ID_shopping_cart_item, ID_shopping_cart, ID_product, quantity, price_at_insertion, date_added_to_cart)
values (60000, 50000, 2002, 1, 3899, DATE '2026-03-04');
insert into SHOPPING_CART_ITEM(ID_shopping_cart_item, ID_shopping_cart, ID_product, quantity, price_at_insertion, date_added_to_cart)
values (60001, 50000, 3001, 1, 1199, DATE '2026-03-04');
insert into SHOPPING_CART_ITEM(ID_shopping_cart_item, ID_shopping_cart, ID_product, quantity, price_at_insertion, date_added_to_cart)
values (60002, 50001, 2005, 1, 3499, DATE '2026-03-03');
insert into SHOPPING_CART_ITEM(ID_shopping_cart_item, ID_shopping_cart, ID_product, quantity, price_at_insertion, date_added_to_cart)
values (60003, 50003, 4004, 1, 89999, DATE '2026-02-28');
insert into SHOPPING_CART_ITEM(ID_shopping_cart_item, ID_shopping_cart, ID_product, quantity, price_at_insertion, date_added_to_cart)
values (60004, 50005, 3003, 1, 1099, DATE '2026-03-01');
insert into SHOPPING_CART_ITEM(ID_shopping_cart_item, ID_shopping_cart, ID_product, quantity, price_at_insertion, date_added_to_cart)
values (60005, 50007, 2007, 1, 3299, DATE '2026-02-26');
insert into SHOPPING_CART_ITEM(ID_shopping_cart_item, ID_shopping_cart, ID_product, quantity, price_at_insertion, date_added_to_cart)
values (60006, 50008, 4002, 1, 114999, DATE '2026-03-04');
insert into SHOPPING_CART_ITEM(ID_shopping_cart_item, ID_shopping_cart, ID_product, quantity, price_at_insertion, date_added_to_cart)
values (60007, 50008, 3005, 1, 799, DATE '2026-03-04');

--Orders:
insert into ORDER_table (ID_order, ID_customer, date_created, order_state, total_amount)
values (70000, 1, DATE '2026-03-05', 1, 5098);
insert into ORDER_table (ID_order, ID_customer, date_created, order_state, total_amount)
values (70001, 2, DATE '2026-03-05', 1, 3499);
insert into ORDER_table (ID_order, ID_customer, date_created, order_state, total_amount)
values (70002, 4, DATE '2026-03-01', 1, 89999);
insert into ORDER_table (ID_order, ID_customer, date_created, order_state, total_amount)
values (70003, 6, DATE '2026-03-02', 1, 1099);
insert into ORDER_table (ID_order, ID_customer, date_created, order_state, total_amount)
values (70004, 8, DATE '2026-02-26', 1, 3299);
insert into ORDER_table (ID_order, ID_customer, date_created, order_state, total_amount)
values (70005, 9, DATE '2026-03-04', 1, 115798);

--Order items:
--Order 70000 (Customer 1, Cart 50000)
insert into ORDER_ITEM (ID_order_item, ID_product, ID_order, quantity, selling_price)
values (80000, 2002, 70000, 1, 3899);
insert into ORDER_ITEM (ID_order_item, ID_product, ID_order, quantity, selling_price)
values (80001, 3001, 70000, 1, 1199);
--Order 70001 (Customer 2, Cart 50001)
insert into ORDER_ITEM (ID_order_item, ID_product, ID_order, quantity, selling_price)
values (80002, 2005, 70001, 1, 3499);
--Order 70002 (Customer 4, Cart 50003)
insert into ORDER_ITEM (ID_order_item, ID_product, ID_order, quantity, selling_price)
values (80003, 4004, 70002, 1, 89999);
--Order 70003 (Customer 6, Cart 50005)
insert into ORDER_ITEM (ID_order_item, ID_product, ID_order, quantity, selling_price)
values (80004, 3003, 70003, 1, 1099);
--Order 70004 (Customer 8, Cart 50007)
insert into ORDER_ITEM (ID_order_item, ID_product, ID_order, quantity, selling_price)
values (80005, 2007, 70004, 1, 3299);
--Order 70005 (Customer 9, Cart 50008)
insert into ORDER_ITEM (ID_order_item, ID_product, ID_order, quantity, selling_price)
values (80006, 4002, 70005, 1, 114999);
insert into ORDER_ITEM (ID_order_item, ID_product, ID_order, quantity, selling_price)
values (80007, 3005, 70005, 1, 799);

--Payments (disjoint + total specialization demo):
insert into PAYMENT (ID_payment, ID_order, payment_date, total_amount, order_state, payment_type, authorization_code, card_last4)
values (90000, 70000, DATE '2026-03-05', 5098, 1, 'CARD', 'AUTH-70000-A1', '1111');
insert into PAYMENT (ID_payment, ID_order, payment_date, total_amount, order_state, payment_type, iban, variable_symbol)
values (90001, 70001, DATE '2026-03-05', 3499, 1, 'BANK_TRANSFER', 'CZ6508000000192000145399', '70001');
insert into PAYMENT (ID_payment, ID_order, payment_date, total_amount, order_state, payment_type, authorization_code, card_last4)
values (90002, 70002, DATE '2026-03-01', 89999, 1, 'CARD', 'AUTH-70002-B7', '1111');
insert into PAYMENT (ID_payment, ID_order, payment_date, total_amount, order_state, payment_type, iban, variable_symbol)
values (90003, 70003, DATE '2026-03-02', 1099, 1, 'BANK_TRANSFER', 'CZ0303000000000000112233', '70003');
insert into PAYMENT (ID_payment, ID_order, payment_date, total_amount, order_state, payment_type, authorization_code, card_last4)
values (90004, 70004, DATE '2026-02-26', 3299, 1, 'CARD', 'AUTH-70004-C3', '0002');
insert into PAYMENT (ID_payment, ID_order, payment_date, total_amount, order_state, payment_type, iban, variable_symbol)
values (90005, 70005, DATE '2026-03-04', 115798, 1, 'BANK_TRANSFER', 'CZ2010100000000011223344', '70005');


commit;
