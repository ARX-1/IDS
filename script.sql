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
    CONSTRAINT email_check check (REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$')),
    CONSTRAINT user_status_check  check (user_status in (0, 1))
);

create table SHOPPING_CART(
    ID_shopping_cart int not null,  -- PK
    ID_customer int not null,       -- FK
    date_created date default sysdate,
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
    date_created date default sysdate,
    order_state number(1), --1 if paid, 0 otherwise
    total_amount int,

    --restrictions:
    CONSTRAINT PK_ID_order_check primary key (ID_order),
  
    --foregin keys:
    CONSTRAINT FK_ID_order_customer_check foreign key (ID_customer) references CUSTOMER(ID_customer),
    CONSTRAINT order_state_check check (order_state in (0, 1)),
    CONSTRAINT order_total_amount_check check (total_amount > 0)
);

create table PAYMENT(
    ID_payment int not null,    --PK
    ID_order int not null,      --FK
    payment_date date default sysdate, 
    total_amount int,
    order_state number(1), --1 if paid, 0 otherwise
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
    CONSTRAINT payment_total_amount_check check (total_amount > 0),
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

--Automatic PK generation for all main tables
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

--Sample data
--Customers:
insert into CUSTOMER (ID_customer, customer_name, customer_surname, email, phone_number, password_hash, registration_date, user_status)
values (1, 'Martin', 'Fucheek', 'martin.fucheek@email.com', '+421999514321', 'pwdhash1', DATE '2025-02-01', 1);
insert into CUSTOMER (ID_customer, customer_name, customer_surname, email, phone_number, password_hash, registration_date, user_status)
values (2, 'Ondrej', 'Machula', 'ondrej.machula@email.com', '+421564514467', 'pwdhash2', DATE '2025-02-01', 1);
insert into CUSTOMER (ID_customer, customer_name, customer_surname, email, phone_number, password_hash, registration_date, user_status)
values (3, 'Jakub', 'Novák', 'jakub.novak@email.com', '+420731245678', 'pwdhash3', DATE '2025-02-03', 1);
insert into CUSTOMER (ID_customer, customer_name, customer_surname, email, phone_number, password_hash, registration_date, user_status)
values (4, 'Petra', 'Svobodová', 'petra.svobodova@gmail.com', '+420602314789', 'pwdhash4', DATE '2025-02-05', 1);
insert into CUSTOMER (ID_customer, customer_name, customer_surname, email, phone_number, password_hash, registration_date, user_status)
values (5, 'Tomáš', 'Horák', 'tomas.horak@seznam.cz', '+420773456123', 'pwdhash5', DATE '2025-02-08', 1);
insert into CUSTOMER (ID_customer, customer_name, customer_surname, email, phone_number, password_hash, registration_date, user_status)
values (6, 'Lucia', 'Kováčová', 'lucia.kovacova@email.sk', '+421911234567', 'pwdhash6', DATE '2025-02-10', 1);
insert into CUSTOMER (ID_customer, customer_name, customer_surname, email, phone_number, password_hash, registration_date, user_status)
values (7, 'Michal', 'Blaho', 'michal.blaho@email.sk', '+421905678234', 'pwdhash7', DATE '2025-02-12', 0);
insert into CUSTOMER (ID_customer, customer_name, customer_surname, email, phone_number, password_hash, registration_date, user_status)
values (8, 'Veronika', 'Procházková', 'veronika.prochazkova@gmail.com', '+420608987345', 'pwdhash8', DATE '2025-02-15', 1);
insert into CUSTOMER (ID_customer, customer_name, customer_surname, email, phone_number, password_hash, registration_date, user_status)
values (9, 'Radek', 'Poláček', 'radek.polacek@seznam.cz', '+420724561890', 'pwdhash9', DATE '2025-02-18', 1);
insert into CUSTOMER (ID_customer, customer_name, customer_surname, email, phone_number, password_hash, registration_date, user_status)
values (10, 'Zuzana', 'Tóthová', 'zuzana.tothova@email.sk', '+421944321098', 'pwdhash10', DATE '2025-02-20', 0);

--Addresses:
insert into ADDRESS_table (ID_address, ID_customer, city, street, postal_number, country)
values (1000000, 1, 'Brno', 'Kounicova 12', '60200', 'Czech Republic');
insert into ADDRESS_table (ID_address, ID_customer, city, street, postal_number, country)
values (1000001, 2, 'Ostrava', 'Nádražní 84', '70200', 'Czech Republic');
insert into ADDRESS_table (ID_address, ID_customer, city, street, postal_number, country, address_type)
values (1000002, 3, 'Praha', 'Wenceslas Square 15', '11000', 'Czech Republic', 'delivery');
insert into ADDRESS_table (ID_address, ID_customer, city, street, postal_number, country, address_type)
values (1000003, 4, 'Plzeň', 'Americká 23', '30100', 'Czech Republic', 'billing');
insert into ADDRESS_table (ID_address, ID_customer, city, street, postal_number, country, address_type)
values (1000004, 5, 'Olomouc', 'Třída Svobody 7', '77900', 'Czech Republic', 'delivery');
insert into ADDRESS_table (ID_address, ID_customer, city, street, postal_number, country, address_type)
values (1000005, 6, 'Bratislava', 'Obchodná 45', '81106', 'Slovakia', 'billing');
insert into ADDRESS_table (ID_address, ID_customer, city, street, postal_number, country, address_type)
values (1000006, 7, 'Košice', 'Hlavná 62', '04001', 'Slovakia', 'delivery');
insert into ADDRESS_table (ID_address, ID_customer, city, street, postal_number, country, address_type)
values (1000007, 8, 'České Budějovice', 'Piaristická 18', '37001', 'Czech Republic', 'billing');
insert into ADDRESS_table (ID_address, ID_customer, city, street, postal_number, country, address_type)
values (1000008, 9, 'Liberec', 'Moskevská 34', '46001', 'Czech Republic', 'delivery');
insert into ADDRESS_table (ID_address, ID_customer, city, street, postal_number, country, address_type)
values (1000009, 10, 'Žilina', 'Národná 11', '01001', 'Slovakia', 'billing');

--Product categories:
insert into PRODUCT_CATEGORY (ID_category, category_name, category_description)
values (1000, 'Running', 'Engineered for peak performance—trusted by elite runners and welcoming for beginners.');
insert into PRODUCT_CATEGORY (ID_category, category_name, category_description)
values (1001, 'Swimming', 'Built to glide through every lap, whether you are chasing personal records or enjoying a relaxed swim.');
insert into PRODUCT_CATEGORY (ID_category, category_name, category_description)
values (1002, 'Cycling', 'Gear and accessories for road, mountain, and recreational cycling.');
insert into PRODUCT_CATEGORY (ID_category, category_name, category_description)
values (1003, 'Fitness', 'Equipment and apparel designed for gym workouts and home training.');
insert into PRODUCT_CATEGORY (ID_category, category_name, category_description)
values (1004, 'Hiking', 'Durable footwear and clothing built for trails and outdoor adventures.');

--Products:

--Running category:
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (2000, 1000, 'Addidas Adizero Evo SL', 3239, 'Feather-light speed for every stride.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (2001, 1000, 'Nike Air Zoom Pegasus 41', 2999, 'Responsive cushioning for long-distance comfort.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (2002, 1000, 'Asics Gel-Kayano 31', 3499, 'Maximum stability and support for overpronators.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (2003, 1000, 'Brooks Ghost 16', 2799, 'Soft and smooth ride for neutral everyday runners.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (2004, 1000, 'New Balance Fresh Foam X 1080v13', 3899, 'Plush underfoot feel engineered for high-mileage training.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (2005, 1000, 'Saucony Endorphin Speed 4', 3299, 'Lightweight nylon plate for a propulsive, fast ride.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (2006, 1000, 'Hoka Clifton 9', 3199, 'Ultra-cushioned yet lightweight design for everyday miles.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (2007, 1000, 'Puma Deviate Nitro 3', 2899, 'Nitrogen-infused foam for explosive energy return.', 21, 0);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (2008, 1000, 'On Cloudmonster 2', 3599, 'Oversized CloudTec cushioning for a bouncy, effortless run.', 21, 1);

--Swimming category:
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (3001, 1001, 'Arena Cobra Ultra Swipe', 1299, 'Competition-grade goggles with wide panoramic vision.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (3002, 1001, 'Speedo Fastskin LZR Pure Valor', 3999, 'Hydrodynamic racing suit for elite competitive swimmers.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (3003, 1001, 'TYR Catalyst Training Paddles', 499, 'Ergonomic paddles to build upper body pulling strength.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (3004, 1001, 'Aqua Sphere Pull Buoy Pro', 399, 'High-density foam float for focused arm stroke training.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (3005, 1001, 'Speedo Aquabeat MP3 Waterproof Player', 2199, 'Waterproof music player built for swimmers on every lap.', 21, 0);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (3006, 1001, 'Nike Swim Hydroguard Rash Guard', 899, 'UV-protective rash guard for open water and pool use.', 21, 1);

--Cycling category:
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (4001, 1002, 'Specialized Tarmac SL7', 129999, 'Aero efficiency and lightweight performance in one frame.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (4002, 1002, 'Garmin Edge 840 Solar', 12999, 'Solar-charging GPS cycling computer with advanced navigation.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (4003, 1002, 'Shimano RC7 Road Cycling Shoes', 4499, 'Stiff carbon sole for efficient power transfer on every climb.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (4004, 1002, 'Castelli Competizione Kit', 3799, 'Aerodynamic race suit designed for maximum speed on the road.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (4005, 1002, 'Bontrager Ballista MIPS Helmet', 5999, 'Lightweight aero helmet with integrated MIPS safety system.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (4006, 1002, 'Wahoo KICKR Smart Trainer', 28999, 'High-precision indoor smart trainer for immersive cycling simulation.', 21, 0);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (4007, 1002, 'Continental Grand Prix 5000 TL', 1599, 'Tubeless road tyre with exceptional grip and low rolling resistance.', 21, 1);

--Shopping carts:
insert into SHOPPING_CART (ID_shopping_cart, ID_customer, shopping_cart_status)
values (50000, 1, 1);
insert into SHOPPING_CART (ID_shopping_cart, ID_customer, shopping_cart_status)
values (50001, 2, 1);
insert into SHOPPING_CART (ID_shopping_cart, ID_customer, shopping_cart_status)
values (50002, 3, 1);
insert into SHOPPING_CART (ID_shopping_cart, ID_customer, shopping_cart_status)
values (50003, 4, 0);
insert into SHOPPING_CART (ID_shopping_cart, ID_customer, shopping_cart_status)
values (50004, 5, 1);
insert into SHOPPING_CART (ID_shopping_cart, ID_customer, shopping_cart_status)
values (50005, 6, 1);
insert into SHOPPING_CART (ID_shopping_cart, ID_customer, shopping_cart_status)
values (50006, 7, 0);
insert into SHOPPING_CART (ID_shopping_cart, ID_customer, shopping_cart_status)
values (50007, 8, 1);
insert into SHOPPING_CART (ID_shopping_cart, ID_customer, shopping_cart_status)
values (50008, 9, 1);
insert into SHOPPING_CART (ID_shopping_cart, ID_customer, shopping_cart_status)
values (50009, 10, 0);

--Shopping cart items:
insert into SHOPPING_CART_ITEM (ID_shopping_cart_item, ID_shopping_cart, ID_product, quantity, price_at_insertion, date_added_to_cart)
values (60000, 50000, 2002, 1, 3499, DATE '2026-03-04');
insert into SHOPPING_CART_ITEM (ID_shopping_cart_item, ID_shopping_cart, ID_product, quantity, price_at_insertion, date_added_to_cart)
values (60001, 50000, 3001, 1, 1299, DATE '2026-03-04');
insert into SHOPPING_CART_ITEM (ID_shopping_cart_item, ID_shopping_cart, ID_product, quantity, price_at_insertion, date_added_to_cart)
values (60002, 50001, 2001, 1, 2999, DATE '2026-03-05');
insert into SHOPPING_CART_ITEM (ID_shopping_cart_item, ID_shopping_cart, ID_product, quantity, price_at_insertion, date_added_to_cart)
values (60003, 50001, 4003, 1, 4499, DATE '2026-03-05');
insert into SHOPPING_CART_ITEM (ID_shopping_cart_item, ID_shopping_cart, ID_product, quantity, price_at_insertion, date_added_to_cart)
values (60004, 50002, 2005, 2, 3299, DATE '2026-03-07');
insert into SHOPPING_CART_ITEM (ID_shopping_cart_item, ID_shopping_cart, ID_product, quantity, price_at_insertion, date_added_to_cart)
values (60005, 50002, 3003, 1, 499, DATE '2026-03-07');
insert into SHOPPING_CART_ITEM (ID_shopping_cart_item, ID_shopping_cart, ID_product, quantity, price_at_insertion, date_added_to_cart)
values (60006, 50003, 4005, 1, 5999, DATE '2026-03-09');
insert into SHOPPING_CART_ITEM (ID_shopping_cart_item, ID_shopping_cart, ID_product, quantity, price_at_insertion, date_added_to_cart)
values (60007, 50004, 2007, 1, 2899, DATE '2026-03-11');
insert into SHOPPING_CART_ITEM (ID_shopping_cart_item, ID_shopping_cart, ID_product, quantity, price_at_insertion, date_added_to_cart)
values (60008, 50004, 3004, 2, 399, DATE '2026-03-11');
insert into SHOPPING_CART_ITEM (ID_shopping_cart_item, ID_shopping_cart, ID_product, quantity, price_at_insertion, date_added_to_cart)
values (60009, 50005, 2003, 1, 2799, DATE '2026-03-13');

--Orders:
insert into ORDER_table (ID_order, ID_customer, date_created, order_state, total_amount)
values (70000, 1, DATE '2026-03-05', 1, 4798);
insert into ORDER_table (ID_order, ID_customer, date_created, order_state, total_amount)
values (70001, 2, DATE '2026-03-05', 1, 7498);
insert into ORDER_table (ID_order, ID_customer, date_created, order_state, total_amount)
values (70002, 3, DATE '2026-03-07', 1, 2799);
insert into ORDER_table (ID_order, ID_customer, date_created, order_state, total_amount)
values (70003, 4, DATE '2026-03-08', 0, 6997);
insert into ORDER_table (ID_order, ID_customer, date_created, order_state, total_amount)
values (70004, 5, DATE '2026-03-10', 1, 7198);
insert into ORDER_table (ID_order, ID_customer, date_created, order_state, total_amount)
values (70005, 6, DATE '2026-03-12', 1, 1599);
insert into ORDER_table (ID_order, ID_customer, date_created, order_state, total_amount)
values (70006, 8, DATE '2026-03-15', 0, 8298);
insert into ORDER_table (ID_order, ID_customer, date_created, order_state, total_amount)
values (70007, 9, DATE '2026-03-18', 1, 1599);

--Order items:
--Order 70000 (Customer 1): 3499 + 1299 = 4798
insert into ORDER_ITEM (ID_order_item, ID_product, ID_order, quantity, selling_price)
values (80000, 2002, 70000, 1, 3499);
insert into ORDER_ITEM (ID_order_item, ID_product, ID_order, quantity, selling_price)
values (80001, 3001, 70000, 1, 1299);
--Order 70001 (Customer 2): 2999 + 4499 = 7498
insert into ORDER_ITEM (ID_order_item, ID_product, ID_order, quantity, selling_price)
values (80002, 2001, 70001, 1, 2999);
insert into ORDER_ITEM (ID_order_item, ID_product, ID_order, quantity, selling_price)
values (80003, 4003, 70001, 1, 4499);
--Order 70002 (Customer 3): 2799
insert into ORDER_ITEM (ID_order_item, ID_product, ID_order, quantity, selling_price)
values (80004, 2003, 70002, 1, 2799);
--Order 70003 (Customer 4): 2*499 + 5999 = 6997
insert into ORDER_ITEM (ID_order_item, ID_product, ID_order, quantity, selling_price)
values (80005, 3003, 70003, 2, 499);
insert into ORDER_ITEM (ID_order_item, ID_product, ID_order, quantity, selling_price)
values (80006, 4005, 70003, 1, 5999);
--Order 70004 (Customer 5): 3199 + 3999 = 7198
insert into ORDER_ITEM (ID_order_item, ID_product, ID_order, quantity, selling_price)
values (80007, 2006, 70004, 1, 3199);
insert into ORDER_ITEM (ID_order_item, ID_product, ID_order, quantity, selling_price)
values (80008, 3002, 70004, 1, 3999);
--Order 70005 (Customer 6): 1599
insert into ORDER_ITEM (ID_order_item, ID_product, ID_order, quantity, selling_price)
values (80009, 4007, 70005, 1, 1599);
--Order 70006 (Customer 8): 4499 + 3799 = 8298
insert into ORDER_ITEM (ID_order_item, ID_product, ID_order, quantity, selling_price)
values (80010, 4003, 70006, 1, 4499);
insert into ORDER_ITEM (ID_order_item, ID_product, ID_order, quantity, selling_price)
values (80011, 4004, 70006, 1, 3799);
--Order 70007 (Customer 9): 1599
insert into ORDER_ITEM (ID_order_item, ID_product, ID_order, quantity, selling_price)
values (80012, 4007, 70007, 1, 1599);

--Payments (disjoint + total specialization):
insert into PAYMENT (ID_payment, ID_order, payment_date, total_amount, order_state, payment_type, authorization_code, card_last4)
values (90000, 70000, DATE '2026-03-05', 4798, 1, 'CARD', 'AUTH-70000-A1', '1111');
insert into PAYMENT (ID_payment, ID_order, payment_date, total_amount, order_state, payment_type, iban, variable_symbol)
values (90001, 70001, DATE '2026-03-05', 7498, 1, 'BANK_TRANSFER', 'CZ6508000000192000145399', '70001');
insert into PAYMENT (ID_payment, ID_order, payment_date, total_amount, order_state, payment_type, authorization_code, card_last4)
values (90002, 70002, DATE '2026-03-07', 2799, 1, 'CARD', 'AUTH-70002-B3', '4827');
insert into PAYMENT (ID_payment, ID_order, payment_date, total_amount, order_state, payment_type, iban, variable_symbol)
values (90003, 70003, DATE '2026-03-08', 6997, 0, 'BANK_TRANSFER', 'SK3112000000198742637541', '70003');
insert into PAYMENT (ID_payment, ID_order, payment_date, total_amount, order_state, payment_type, authorization_code, card_last4)
values (90004, 70004, DATE '2026-03-10', 7198, 1, 'CARD', 'AUTH-70004-C5', '3391');
insert into PAYMENT (ID_payment, ID_order, payment_date, total_amount, order_state, payment_type, iban, variable_symbol)
values (90005, 70005, DATE '2026-03-12', 1599, 1, 'BANK_TRANSFER', 'SK8975000000002134876520', '70005');
insert into PAYMENT (ID_payment, ID_order, payment_date, total_amount, order_state, payment_type, authorization_code, card_last4)
values (90006, 70006, DATE '2026-03-15', 8298, 0, 'CARD', 'AUTH-70006-D7', '7754');
insert into PAYMENT (ID_payment, ID_order, payment_date, total_amount, order_state, payment_type, iban, variable_symbol)
values (90007, 70007, DATE '2026-03-18', 1599, 1, 'BANK_TRANSFER', 'CZ5520100000002401107148', '70007');

commit;
