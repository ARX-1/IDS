--THEME: internet shop

--do not use CREATE IF EXISTS
--referencne je oracle, nebude fungovat vsetko z mysql

--collision might happen due to references, drop as you can otherwise use force command
--fixed by begin execute, TODO: check whether it's valid

--Dropping tables
begin
    execute IMMEDIATE 'drop table SHOPPING_CART_ITEM CASCADE CONSTRAINTS';
exception when others then null;
end;
/

begin
    execute IMMEDIATE 'drop table ADDRESS_table CASCADE CONSTRAINTS';
exception when others then null;
end;
/

begin
    execute IMMEDIATE 'drop table PAYMENT CASCADE CONSTRAINTS';
exception when others then null;
end;
/

begin
    execute IMMEDIATE 'drop table ORDER_table CASCADE CONSTRAINTS';
exception when others then null;
end;
/

begin
    execute IMMEDIATE 'drop table SHOPPING_CART CASCADE CONSTRAINTS';
exception when others then null;
end;
/

begin
    execute IMMEDIATE 'drop table PRODUCT_table CASCADE CONSTRAINTS';
exception when others then null;
end;
/

begin
    execute IMMEDIATE 'drop table PRODUCT_CATEGORY CASCADE CONSTRAINTS';
exception when others then null;
end;
/

begin
    execute IMMEDIATE 'drop table CUSTOMER CASCADE CONSTRAINTS';
exception when others then null;
end;
/

begin
    execute IMMEDIATE 'drop table ORDER_ITEM CASCADE CONSTRAINTS';
exception when others then null;
end;
/

begin
    execute IMMEDIATE 'drop table SHOPPING_CART_ITEM CASCADE CONSTRAINTS';
exception when others then null;
end;
/

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

create table ADDRESS_table(
    ID_address int not null,    -- PK
    ID_customer int not null,   -- FK
    city varchar2(50) not null,
    street varchar2(100),
    postal_number varchar2(30) not null,
    country varchar2(50) not null,
    --TODO: 
    --adress_type varchar2(50)

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
    EAN_code int,
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

--TODO: add tables for shopping_cart_item, order_item
create table SHOPPING_CART_ITEM(
    ID_shopping_cart_item int not null,     --PK
    ID_shopping_cart int not null,          --FK
    ID_product int not null,                --FK

    date_added_to_cart int, --DDMMYYYY
    --shopping_cart_item_state, --TODO: not sure why we need that

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

--TODO: add sample data
--Customers:
insert into CUSTOMER (ID_customer, customer_name, customer_surname, email, phone_number, registration_date, user_status)
values (1, 'Martin', 'Fucheek', 'martin.fucheek@email.com', '+421999514321', 01022025, 1);
insert into CUSTOMER (ID_customer, customer_name, customer_surname, email, phone_number, registration_date, user_status)
values (2, 'Ondrej', 'Machula', 'ondrej.machula@email.com', '+421564514467', 01022025, 1);
insert into CUSTOMER (ID_customer, customer_name, customer_surname, email, phone_number, registration_date, user_status)
values (3, 'Andrej', 'Soska', 'andrej.soska@email.com', '+421999565487', 27052007, 0);
insert into CUSTOMER (ID_customer, customer_name, customer_surname, email, phone_number, registration_date, user_status)
values (4, 'Jakub', 'Novotný', 'jakub.novotny@email.com', '+420731445892', 01022025, 1);
insert into CUSTOMER (ID_customer, customer_name, customer_surname, email, phone_number, registration_date, user_status)
values (5, 'Petra', 'Kučerová', 'petra.kucerova@email.com', '+420728963441', 01022025, 1);
insert into CUSTOMER (ID_customer, customer_name, customer_surname, email, phone_number, registration_date, user_status)
values (6, 'Tomáš', 'Doležal', 'tomas.dolezal@email.com', '+420602784512', 01022025, 1);
insert into CUSTOMER (ID_customer, customer_name, customer_surname, email, phone_number, registration_date, user_status)
values (7, 'Lucie', 'Svobodová', 'lucie.svobodova@email.com', '+420775632198', 01022025, 1);
insert into CUSTOMER (ID_customer, customer_name, customer_surname, email, phone_number, registration_date, user_status)
values (8, 'David', 'Král', 'david.kral@email.com', '+420739852147', 01022025, 1);
insert into CUSTOMER (ID_customer, customer_name, customer_surname, email, phone_number, registration_date, user_status)
values (9, 'Barbora', 'Veselá', 'barbora.vesela@email.com', '+420721369845', 01022025, 1);

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
insert into PRODUCT_table (ID_product, ID_category, product_name, EAN_code, price, product_description, DPH, activity)
values (2000, 1000, 'Addidas Adizero Evo SL', 1232584569642, 3239, 'Feather-light speed for every stride.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, EAN_code, price, product_description, DPH, activity)
values (2001, 1000, 'Nike Zoom Fly 6', 1232564569642, 3239, 'Feather-light speed for every stride.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, EAN_code, price, product_description, DPH, activity)
values (2002, 1000, 'Asics Gel Nimbus 26', 1232584569643, 3899, 'Soft cushioning for long-distance comfort.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, EAN_code, price, product_description, DPH, activity)
values (2003, 1000, 'New Balance Fresh Foam 1080v13', 1232584569644, 4199, 'Smooth, plush ride for everyday training.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, EAN_code, price, product_description, DPH, activity)
values (2004, 1000, 'Puma Deviate Nitro 2', 1232584569645, 3599, 'Responsive propulsion for faster runs.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, EAN_code, price, product_description, DPH, activity)
values (2005, 1000, 'Hoka Clifton 9', 1232584569646, 3499, 'Lightweight cushioning for effortless miles.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, EAN_code, price, product_description, DPH, activity)
values (2006, 1000, 'Saucony Endorphin Speed 4', 1232584569647, 4299, 'Versatile speed shoe with energetic rebound.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, EAN_code, price, product_description, DPH, activity)
values (2007, 1000, 'Brooks Ghost 16', 1232584569648, 3299, 'Balanced cushioning for smooth daily runs.', 21, 1);

--Swimming category:
insert into PRODUCT_table (ID_product, ID_category, product_name, EAN_code, price, product_description, DPH, activity)
values (3000, 1001, 'Speedo Biofuse Training Fins', 7894561230001, 899, 'Comfortable training fins for improved kick strength.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, EAN_code, price, product_description, DPH, activity)
values (3001, 1001, 'Arena Powerfin Pro', 7894561230002, 1199, 'Short-blade fins designed for explosive power.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, EAN_code, price, product_description, DPH, activity)
values (3002, 1001, 'Finis Long Floating Fins', 7894561230003, 999, 'Long fins ideal for technique and endurance training.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, EAN_code, price, product_description, DPH, activity)
values (3003, 1001, 'TYR Stryker Silicone Fins', 7894561230004, 1099, 'Soft silicone construction for natural movement.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, EAN_code, price, product_description, DPH, activity)
values (3004, 1001, 'Mad Wave Pool Fins', 7894561230005, 849, 'Short training fins for increased kick tempo.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, EAN_code, price, product_description, DPH, activity)
values (3005, 1001, 'Cressi Light Swim Fins', 7894561230006, 799, 'Lightweight fins suitable for pool and open water.', 21, 1);

--Cycling category:
insert into PRODUCT_table (ID_product, ID_category, product_name, EAN_code, price, product_description, DPH, activity)
values (4001, 1002, 'Specialized Tarmac SL7', 3214567890123, 129999, 'Aero efficiency and lightweight performance in one frame.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, EAN_code, price, product_description, DPH, activity)
values (4002, 1002, 'Cannondale SuperSix EVO 4', 3214567890124, 114999, 'Balanced stiffness and comfort for fast road riding.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, EAN_code, price, product_description, DPH, activity)
values (4003, 1002, 'Trek Émonda SL 6', 3214567890125, 109999, 'Ultra‑light climbing bike with race‑ready geometry.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, EAN_code, price, product_description, DPH, activity)
values (4004, 1002, 'Giant TCR Advanced 2', 3214567890126, 89999, 'Efficient all‑rounder built for speed and precision.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, EAN_code, price, product_description, DPH, activity)
values (4005, 1002, 'Bianchi Sprint 105', 3214567890127, 94999, 'Classic Italian design with modern race performance.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, EAN_code, price, product_description, DPH, activity)
values (4006, 1002, 'Canyon Ultimate CF SL 7', 3214567890128, 104999, 'Lightweight carbon frame with excellent handling.', 21, 1);

