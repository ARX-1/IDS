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
    -- Triggery 4. části
    begin execute immediate 'drop trigger TRG_CART_ITEM_CHECK_PRICE'; exception when others then null; end;
    begin execute immediate 'drop trigger TRG_ORDER_TOTAL_RECALC'; exception when others then null; end;

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
    -- Uložené procedury 4. části
    begin execute immediate 'drop procedure PRINT_CUSTOMER_SUMMARY'; exception when others then null; end;
    begin execute immediate 'drop procedure CREATE_ORDER_FROM_CART'; exception when others then null; end;
    -- Indexy 4. části
    begin execute immediate 'drop index IDX_ORDER_ITEM_PRODUCT'; exception when others then null; end;
    begin execute immediate 'drop index IDX_PRODUCT_CATEGORY'; exception when others then null; end;
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
create sequence SEQ_CUSTOMER_ID      start with 11      increment by 1 nocache;
create sequence SEQ_SHOPPING_CART_ID start with 50010   increment by 1 nocache;
create sequence SEQ_ADDRESS_ID       start with 1000010 increment by 1 nocache;
create sequence SEQ_CATEGORY_ID      start with 1005    increment by 1 nocache;
create sequence SEQ_PRODUCT_ID       start with 6004    increment by 1 nocache;
create sequence SEQ_ORDER_ID         start with 70008   increment by 1 nocache;
create sequence SEQ_PAYMENT_ID       start with 90008   increment by 1 nocache;
create sequence SEQ_SHOP_CART_ITEM_ID start with 60010  increment by 1 nocache;
create sequence SEQ_ORDER_ITEM_ID    start with 80013   increment by 1 nocache;

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

/*
GEN AI usage:

We used AI to generate additional sample data for our database.
We have created first 2 rows of each table manually, then we used AI to generate more rows based on our initial data.
Thanks to this approach we were able to quickly fill our database without spending too much time on repetetive manual work.
We have reviewed all the AI generated data and ensured that it is consistent with our database scheme.

Problems we encountered:
We had to modify indentation because the generated insert statements were in the same line as values
  so the lines were too long and hard to read for humans, we could fix it by changing the prompt but
  we decided to do it manually because we wanted to check the generated data anyway.

Because the sample data is not that important and it is only used as examples and testing later on in the project,
there was no need to verify the data with real world sources. We just wanted to have realistic looking data that fits
well with our theme.

Used AI tool: Claude sonnet 4.6
Conversation link: "https://claude.ai/share/3b0e902e-c335-430f-9bdf-e855bf2641b1"
*/

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
insert into ADDRESS_table (ID_address, ID_customer, city, street, postal_number, country, address_type)
values (1000000, 1, 'Brno', 'Kounicova 12', '60200', 'Czech Republic', 'delivery');
insert into ADDRESS_table (ID_address, ID_customer, city, street, postal_number, country, address_type)
values (1000001, 2, 'Ostrava', 'Nádražní 84', '70200', 'Czech Republic', 'billing');
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

--Fitness category:
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (5001, 1003, 'Kettlebell 24 kg', 1899, 'Cast iron kettlebell for strength and conditioning workouts.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (5002, 1003, 'Yoga Mat Pro', 699, 'Non-slip, extra-thick mat for yoga and floor exercises.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (5003, 1003, 'Adjustable Pull-up Bar', 1299, 'Doorframe pull-up bar with adjustable width for home training.', 21, 1);

--Hiking category:
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (6001, 1004, 'Salomon X Ultra 4 GTX', 4999, 'Waterproof hiking shoes with advanced grip for technical terrain.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (6002, 1004, 'Black Diamond Trail Trekking Poles', 2499, 'Lightweight aluminium trekking poles with ergonomic cork grips.', 21, 1);
insert into PRODUCT_table (ID_product, ID_category, product_name, price, product_description, DPH, activity)
values (6003, 1004, 'Osprey Atmos AG 65 Backpack', 7999, 'Anti-Gravity suspended mesh backpack for multi-day trail adventures.', 21, 1);

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

--SELECT QUERIES

-- Dotaz 1 (JOIN 2 tabulek: ORDER_table + CUSTOMER)
-- Zobrazí všechny objednávky spolu s celým jménem a e-mailem zákazníka, který je zadal.
-- Využití v aplikaci: stránka správy objednávek v administraci – přehled, kdo a kdy
-- co objednal a zda je objednávka zaplacena.
SELECT
    o.ID_order,
    c.customer_name || ' ' || c.customer_surname  AS customer_fullname,
    c.email,
    o.date_created,
    o.total_amount,
    CASE o.order_state WHEN 1 THEN 'Paid' ELSE 'Unpaid' END AS order_status
FROM ORDER_table o
JOIN CUSTOMER c ON o.ID_customer = c.ID_customer
ORDER BY o.date_created DESC;

-- Dotaz 2 (JOIN 2 tabulek: PRODUCT_table + PRODUCT_CATEGORY)
-- Vypíše všechny aktivní produkty spolu s názvem jejich kategorie a cenou.
-- Využití v aplikaci: výpis produktů na e-shopu seřazený podle kategorie a ceny.
SELECT
    p.ID_product,
    p.product_name,
    pc.category_name,
    p.price,
    p.DPH
FROM PRODUCT_table p
JOIN PRODUCT_CATEGORY pc ON p.ID_category = pc.ID_category
WHERE p.activity = 1
ORDER BY pc.category_name, p.price;

-- Dotaz 3 (JOIN 4 tabulek: ORDER_ITEM + ORDER_table + CUSTOMER + PRODUCT_table)
-- Generuje detailní prodejní přehled: ke každé položce objednávky zobrazí zákazníka,
-- datum objednávky, název produktu a celkovou cenu řádku (množství × prodejní cena).
-- Využití v aplikaci: generování prodejních reportů v administraci.
SELECT
    o.ID_order,
    c.customer_name || ' ' || c.customer_surname  AS customer_fullname,
    o.date_created,
    p.product_name,
    oi.quantity,
    oi.selling_price,
    oi.quantity * oi.selling_price AS line_total
FROM ORDER_ITEM oi
JOIN ORDER_table o ON oi.ID_order = o.ID_order
JOIN CUSTOMER c ON o.ID_customer = c.ID_customer
JOIN PRODUCT_table p ON oi.ID_product = p.ID_product
ORDER BY o.date_created, o.ID_order;

-- Dotaz 4 (GROUP BY + agregační funkce: SUM, COUNT)
-- Spočítá celkovou útratu a počet zaplacených objednávek pro každého zákazníka.
-- Využití v aplikaci: identifikace nejlepších zákazníků pro věrnostní program nebo cílené akce.
SELECT
    c.ID_customer,
    c.customer_name || ' ' || c.customer_surname AS customer_fullname,
    COUNT(o.ID_order) AS paid_order_count,
    SUM(o.total_amount) AS total_spent
FROM CUSTOMER c
JOIN ORDER_table o ON c.ID_customer = o.ID_customer
WHERE o.order_state = 1
GROUP BY c.ID_customer, c.customer_name, c.customer_surname
ORDER BY total_spent DESC;

-- Dotaz 5 (GROUP BY + agregační funkce: COUNT, AVG, MIN, MAX)
-- Zobrazí počet aktivních produktů a jejich cenové statistiky (průměr, minimum, maximum)
-- v každé kategorii.
-- Využití v aplikaci: přehledová stránka kategorií se statistikami produktů.
SELECT
    pc.category_name,
    COUNT(p.ID_product) AS product_count,
    AVG(p.price) AS avg_price,
    MIN(p.price) AS min_price,
    MAX(p.price) AS max_price
FROM PRODUCT_CATEGORY pc
JOIN PRODUCT_table p ON pc.ID_category = p.ID_category
WHERE p.activity = 1
GROUP BY pc.ID_category, pc.category_name
ORDER BY product_count DESC;

-- Dotaz 6 (EXISTS)
-- Najde všechny aktivní zákazníky (user_status = 1), kteří mají alespoň jednu
-- zaplacenou objednávku (order_state = 1).
-- Využití v aplikaci: sestavení mailing listu ověřených kupujících pro newslettery
-- nebo věrnostní kampaně.
SELECT
    c.ID_customer,
    c.customer_name,
    c.customer_surname,
    c.email
FROM CUSTOMER c
WHERE c.user_status = 1
  AND EXISTS (
      SELECT 1
      FROM ORDER_table o
      WHERE o.ID_customer = c.ID_customer
        AND o.order_state = 1
  )
ORDER BY c.customer_surname;

-- Dotaz 7 (IN s vnořeným SELECTem)
-- Vrátí všechny produkty, které byly alespoň jednou zakoupeny (figurují v některé objednávce).
-- Využití v aplikaci: administrátorský dashboard – rozlišení prodávaných produktů
-- od těch, o které zatím nebyl zájem.
SELECT
    p.ID_product,
    p.product_name,
    p.price,
    CASE p.activity WHEN 1 THEN 'Active' ELSE 'Inactive' END AS status
FROM PRODUCT_table p
WHERE p.ID_product IN (
    SELECT DISTINCT oi.ID_product
    FROM ORDER_ITEM oi
)
ORDER BY p.price DESC;

-- ============================================================
-- 4th part - advanced database objects
-- ============================================================

SET SERVEROUTPUT ON;

-- TRIGGER 1: TRG_CART_ITEM_CHECK_PRICE
-- BEFORE INSERT OR UPDATE na SHOPPING_CART_ITEM.
-- Ověří, že quantity > 0.
-- Načte aktuální katalogovou cenu produktu z PRODUCT_table.
-- Pokud price_at_insertion není zadáno (NULL), doplní ho automaticky.
-- Pokud price_at_insertion zadáno je, zkontroluje shodu s katalogem.
-- Díky BEFORE triggeru se cena nastaví ještě před kontrolou NOT NULL
-- constraintu tabulky, takže INSERT s NULL cenou projde.

CREATE OR REPLACE TRIGGER TRG_CART_ITEM_CHECK_PRICE
BEFORE INSERT OR UPDATE ON SHOPPING_CART_ITEM
FOR EACH ROW
DECLARE
    v_product_price PRODUCT_table.price%TYPE;
BEGIN
    -- Kontrola kladného množství
    IF :NEW.quantity <= 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Množství musí být větší než 0.');
    END IF;

    -- Načtení aktuální ceny produktu z katalogu
    SELECT price INTO v_product_price
    FROM PRODUCT_table
    WHERE ID_product = :NEW.ID_product;

    -- Pokud cena nebyla zadána, doplní se automaticky z katalogu
    IF :NEW.price_at_insertion IS NULL THEN
        :NEW.price_at_insertion := v_product_price;
    ELSIF :NEW.price_at_insertion != v_product_price THEN
        RAISE_APPLICATION_ERROR(-20011,
            'Cena produktu ' || :NEW.ID_product ||
            ' nesouhlasi s katalogovou cenou (' || v_product_price || ').');
    END IF;
END TRG_CART_ITEM_CHECK_PRICE;
/

-- Předvedení TRG_CART_ITEM_CHECK_PRICE:
-- Vložíme položku do košíku zákazníka 9 (košík 50008) BEZ zadání ceny (NULL).
-- Trigger automaticky doplní cenu produktu 6001 (Salomon X Ultra 4 GTX = 4999 Kč).
-- ID_shopping_cart_item = NULL -> TRG_SHOP_CART_ITEM_PK přiřadí hodnotu ze sekvence.
INSERT INTO SHOPPING_CART_ITEM
    (ID_shopping_cart_item, ID_shopping_cart, ID_product, quantity, price_at_insertion)
VALUES (NULL, 50008, 6001, 1, NULL);

-- Ověření: price_at_insertion se rovná aktuální katalogové ceně produktu
SELECT
    sci.ID_shopping_cart_item,
    sci.ID_product,
    p.product_name,
    sci.quantity,
    sci.price_at_insertion   AS price_auto_set,
    p.price                  AS catalog_price
FROM SHOPPING_CART_ITEM sci
JOIN PRODUCT_table p ON sci.ID_product = p.ID_product
WHERE sci.ID_shopping_cart = 50008
ORDER BY sci.ID_shopping_cart_item;

-- TRIGGER 2: TRG_ORDER_TOTAL_RECALC

-- AFTER INSERT OR UPDATE OR DELETE na ORDER_ITEM.
-- Po každé změně položek objednávky přepočítá ORDER_table.total_amount
-- jako SUM(quantity * selling_price) pro dotčenou objednávku.
-- Při UPDATE se změnou ID_order přepočítá starou i novou objednávku.

-- Compound trigger (Oracle 12c+) eliminuje problém "mutating table" –
-- ID dotčených objednávek se shromáždí v AFTER EACH ROW a přepočet
-- proběhne až v AFTER STATEMENT, kdy tabulka ORDER_ITEM není mutující.

CREATE OR REPLACE TRIGGER TRG_ORDER_TOTAL_RECALC
FOR INSERT OR UPDATE OR DELETE ON ORDER_ITEM
COMPOUND TRIGGER

    -- Typ a kolekce pro uchování ID dotčených objednávek
    TYPE t_id_list IS TABLE OF ORDER_table.ID_order%TYPE INDEX BY PLS_INTEGER;
    v_ids  t_id_list;
    v_idx  PLS_INTEGER := 0;

    -- Po každém řádku uložíme ID objednávky (nebo objednávek při přesunu)
    AFTER EACH ROW IS
    BEGIN
        IF INSERTING THEN
            v_idx := v_idx + 1;
            v_ids(v_idx) := :NEW.ID_order;
        ELSIF DELETING THEN
            v_idx := v_idx + 1;
            v_ids(v_idx) := :OLD.ID_order;
        ELSE -- UPDATING
            v_idx := v_idx + 1;
            v_ids(v_idx) := :NEW.ID_order;
            IF :OLD.ID_order != :NEW.ID_order THEN
                -- Položka se přesunula do jiné objednávky – přepočítáme obě
                v_idx := v_idx + 1;
                v_ids(v_idx) := :OLD.ID_order;
            END IF;
        END IF;
    END AFTER EACH ROW;

    -- Po skončení DML příkazu přepočítáme total_amount pro všechny dotčené objednávky
    AFTER STATEMENT IS
    BEGIN
        FOR i IN 1 .. v_idx LOOP
            UPDATE ORDER_table
            SET total_amount = (
                SELECT SUM(quantity * selling_price)
                FROM ORDER_ITEM
                WHERE ID_order = v_ids(i)
            )
            WHERE ID_order = v_ids(i);
        END LOOP;
        -- Reset pro případ opakovaného spuštění v téže DML operaci
        v_idx := 0;
        v_ids.DELETE;
    END AFTER STATEMENT;

END TRG_ORDER_TOTAL_RECALC;
/

-- Předvedení TRG_ORDER_TOTAL_RECALC:
-- Vložíme novou objednávku pro zákazníka 3 s dočasnou hodnotou total_amount = 1.
-- Vložíme položku ORDER_ITEM (produkt 2000, množství 2, cena 3239).
-- Trigger přepočítá total_amount -> 2 * 3239 = 6478.
DECLARE
    v_new_order_id ORDER_table.ID_order%TYPE;
BEGIN
    -- Vložení objednávky s dočasnou hodnotou (trigger se nevztahuje na ORDER_table)
    INSERT INTO ORDER_table (ID_order, ID_customer, date_created, order_state, total_amount)
    VALUES (NULL, 3, SYSDATE, 0, 1)
    RETURNING ID_order INTO v_new_order_id;

    DBMS_OUTPUT.PUT_LINE('Vlozena objednavka ID: ' || v_new_order_id || ', docasna total_amount = 1');

    -- Vložení položky -> TRG_ORDER_TOTAL_RECALC přepočítá total_amount
    INSERT INTO ORDER_ITEM (ID_order_item, ID_product, ID_order, quantity, selling_price)
    VALUES (NULL, 2000, v_new_order_id, 2, 3239);

    DBMS_OUTPUT.PUT_LINE('Vlozena polozka: produkt 2000, qty=2, cena=3239 => ocekavany soucet = 6478');
END;
/

-- Ověření: total_amount v ORDER_table odpovídá součtu položek (6478)
SELECT
    o.ID_order,
    o.ID_customer,
    o.total_amount                      AS total_po_triggeru,
    SUM(oi.quantity * oi.selling_price) AS spocitany_soucet
FROM ORDER_table o
JOIN ORDER_ITEM oi ON o.ID_order = oi.ID_order
WHERE o.ID_customer = 3
GROUP BY o.ID_order, o.ID_customer, o.total_amount
ORDER BY o.ID_order DESC;

-- ULOŽENÁ PROCEDURA 1: PRINT_CUSTOMER_SUMMARY
-- Vstup: p_customer_id – ID zákazníka.
-- Načte zákazníka do proměnné CUSTOMER%ROWTYPE.
-- Spočítá celkový počet jeho objednávek.
-- Spočítá celkovou útratu ze zaplacených objednávek (order_state = 1).
-- Výsledek vypíše přes DBMS_OUTPUT.
-- Použité prvky: %ROWTYPE, %TYPE, výjimka NO_DATA_FOUND.

CREATE OR REPLACE PROCEDURE PRINT_CUSTOMER_SUMMARY(
    p_customer_id IN CUSTOMER.ID_customer%TYPE
)
IS
    v_customer    CUSTOMER%ROWTYPE;
    v_order_count NUMBER;
    v_total_spent ORDER_table.total_amount%TYPE;
BEGIN
    -- Načtení zákazníka; NO_DATA_FOUND pokud neexistuje
    SELECT * INTO v_customer
    FROM CUSTOMER
    WHERE ID_customer = p_customer_id;

    -- Celkový počet objednávek zákazníka
    SELECT COUNT(*) INTO v_order_count
    FROM ORDER_table
    WHERE ID_customer = p_customer_id;

    -- Celková útrata ze zaplacených objednávek
    SELECT NVL(SUM(total_amount), 0) INTO v_total_spent
    FROM ORDER_table
    WHERE ID_customer = p_customer_id
      AND order_state = 1;

    DBMS_OUTPUT.PUT_LINE('=== Souhrn zakaznika ===');
    DBMS_OUTPUT.PUT_LINE('ID:         ' || v_customer.ID_customer);
    DBMS_OUTPUT.PUT_LINE('Jmeno:      ' || v_customer.customer_name || ' ' || v_customer.customer_surname);
    DBMS_OUTPUT.PUT_LINE('E-mail:     ' || v_customer.email);
    DBMS_OUTPUT.PUT_LINE('Objednavky: ' || v_order_count);
    DBMS_OUTPUT.PUT_LINE('Zaplaceno:  ' || v_total_spent || ' Kc');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Zakaznik s ID ' || p_customer_id || ' neexistuje.');
END PRINT_CUSTOMER_SUMMARY;
/

-- Předvedení PRINT_CUSTOMER_SUMMARY pro zákazníka 1 (Martin Fucheek):
-- Má 1 zaplacenou objednávku (70000) za 4798 Kč.
BEGIN
    PRINT_CUSTOMER_SUMMARY(1);
END;
/

-- ULOŽENÁ PROCEDURA 2: CREATE_ORDER_FROM_CART
-- Vstup: p_customer_id – ID zákazníka.
-- Najde aktivní košík zákazníka (shopping_cart_status = 1).
-- Kurzorem projde položky košíku (SHOPPING_CART_ITEM).
-- Vytvoří novou objednávku v ORDER_table (ID přes SEQ_ORDER_ID).
-- Pro každou položku košíku vytvoří ORDER_ITEM (ID přes SEQ_ORDER_ITEM_ID).
-- Nastaví košík jako neaktivní (shopping_cart_status = 0).
-- Použité prvky: explicitní kurzor, %TYPE, výjimky (NO_DATA_FOUND, vlastní chyby).
-- TRG_ORDER_TOTAL_RECALC automaticky přepočítá total_amount
-- objednávky při vkládání každé položky.

CREATE OR REPLACE PROCEDURE CREATE_ORDER_FROM_CART(
    p_customer_id IN CUSTOMER.ID_customer%TYPE
)
IS
    v_cart_id      SHOPPING_CART.ID_shopping_cart%TYPE;
    v_new_order_id ORDER_table.ID_order%TYPE;
    v_item_count   NUMBER;
    v_cart_total   ORDER_table.total_amount%TYPE;
    v_new_item_id  ORDER_ITEM.ID_order_item%TYPE;

    -- Kurzor přes položky aktivního košíku (otevře se po zjištění v_cart_id)
    CURSOR c_cart_items IS
        SELECT ID_product, quantity, price_at_insertion
        FROM SHOPPING_CART_ITEM
        WHERE ID_shopping_cart = v_cart_id;
BEGIN
    -- Nalezení aktivního košíku zákazníka
    BEGIN
        SELECT ID_shopping_cart INTO v_cart_id
        FROM SHOPPING_CART
        WHERE ID_customer      = p_customer_id
          AND shopping_cart_status = 1
          AND ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001,
                'Zakaznik ' || p_customer_id || ' nema zadny aktivni kosik.');
    END;

    -- Kontrola, zda košík není prázdný
    SELECT COUNT(*) INTO v_item_count
    FROM SHOPPING_CART_ITEM
    WHERE ID_shopping_cart = v_cart_id;

    IF v_item_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002,
            'Kosik ' || v_cart_id || ' zakaznika ' || p_customer_id || ' je prazdny.');
    END IF;

    -- Předvýpočet celkové částky z košíku (TRG_ORDER_TOTAL_RECALC ji stejně přepočítá)
    SELECT SUM(quantity * price_at_insertion) INTO v_cart_total
    FROM SHOPPING_CART_ITEM
    WHERE ID_shopping_cart = v_cart_id;

    -- Vytvoření nové objednávky
    v_new_order_id := SEQ_ORDER_ID.NEXTVAL;
    INSERT INTO ORDER_table (ID_order, ID_customer, date_created, order_state, total_amount)
    VALUES (v_new_order_id, p_customer_id, SYSDATE, 0, v_cart_total);

    -- Vložení položek objednávky z košíku
    FOR r_item IN c_cart_items LOOP
        v_new_item_id := SEQ_ORDER_ITEM_ID.NEXTVAL;
        INSERT INTO ORDER_ITEM (ID_order_item, ID_product, ID_order, quantity, selling_price)
        VALUES (v_new_item_id, r_item.ID_product, v_new_order_id,
                r_item.quantity, r_item.price_at_insertion);
    END LOOP;

    -- Deaktivace košíku
    UPDATE SHOPPING_CART
    SET shopping_cart_status = 0
    WHERE ID_shopping_cart = v_cart_id;

    DBMS_OUTPUT.PUT_LINE('Objednavka ' || v_new_order_id ||
        ' vytvorena z kosiku ' || v_cart_id ||
        ' (' || v_item_count || ' pol., celkem ' || v_cart_total || ' Kc).');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Chyba pri vytvareni objednavky: ' || SQLERRM);
        RAISE;
END CREATE_ORDER_FROM_CART;
/

-- Předvedení CREATE_ORDER_FROM_CART:
-- Zákazník 1 (Martin Fucheek) má aktivní košík 50000 se dvěma položkami:
-- produkt 2002 (Asics Gel-Kayano 31), qty=1, cena=3499
-- produkt 3001 (Arena Cobra Ultra Swipe), qty=1, cena=1299
-- Procedura košík převede na objednávku a deaktivuje ho.
BEGIN
    CREATE_ORDER_FROM_CART(1);
END;
/

-- Ověření: nová objednávka zákazníka 1 a její položky
SELECT
    o.ID_order,
    o.ID_customer,
    o.date_created,
    CASE o.order_state WHEN 1 THEN 'Zaplacena' ELSE 'Nezaplacena' END AS stav,
    o.total_amount
FROM ORDER_table o
WHERE o.ID_customer = 1
ORDER BY o.ID_order;

SELECT
    oi.ID_order_item,
    oi.ID_order,
    p.product_name,
    oi.quantity,
    oi.selling_price,
    oi.quantity * oi.selling_price AS line_total
FROM ORDER_ITEM oi
JOIN PRODUCT_table p  ON oi.ID_product = p.ID_product
JOIN ORDER_table   o  ON oi.ID_order   = o.ID_order
WHERE o.ID_customer = 1
ORDER BY oi.ID_order, oi.ID_order_item;

-- INDEXY A EXPLAIN PLAN
-- Dotaz: celkové tržby a počet prodaných položek podle kategorie.
-- Joinuje: PRODUCT_CATEGORY ← PRODUCT_table ← ORDER_ITEM
-- Agreguje: SUM(quantity * selling_price), COUNT, GROUP BY category_name.

-- Krok 1: EXPLAIN PLAN před vytvořením indexů
-- U malých ukázkových dat Oracle typicky zvolí full table scan,
-- protože je pro malé tabulky levnější než přístup přes index.
-- U větší produkční databáze by bez indexů výkon výrazně klesal.
EXPLAIN PLAN FOR
SELECT
    pc.category_name,
    COUNT(oi.ID_order_item)             AS items_sold,
    SUM(oi.quantity * oi.selling_price) AS total_revenue
FROM PRODUCT_CATEGORY pc
JOIN PRODUCT_table p ON pc.ID_category = p.ID_category
JOIN ORDER_ITEM oi   ON p.ID_product   = oi.ID_product
GROUP BY pc.category_name
ORDER BY total_revenue DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Krok 2: Vytvoření indexů
-- IDX_ORDER_ITEM_PRODUCT: urychluje join ORDER_ITEM -> PRODUCT_table přes ID_product
-- IDX_PRODUCT_CATEGORY: urychluje join PRODUCT_table -> PRODUCT_CATEGORY přes ID_category
CREATE INDEX IDX_ORDER_ITEM_PRODUCT ON ORDER_ITEM(ID_product);
CREATE INDEX IDX_PRODUCT_CATEGORY   ON PRODUCT_table(ID_category);

-- Krok 3: EXPLAIN PLAN po vytvoření indexů
-- U malých ukázkových dat může Oracle stále volit full table scan,
-- protože je pro malé tabulky levnější než přístup přes index.
-- U větší produkční databáze s dostatkem statistik mohou indexy
-- IDX_ORDER_ITEM_PRODUCT (ORDER_ITEM.ID_product) a
-- IDX_PRODUCT_CATEGORY (PRODUCT_table.ID_category) pomoci optimalizátoru
-- zvolit efektivnější plán při joinu tabulek přes tyto sloupce.
-- Konkrétní plán závisí na statistikách a rozhodnutí optimalizátoru.
EXPLAIN PLAN FOR
SELECT
    pc.category_name,
    COUNT(oi.ID_order_item)             AS items_sold,
    SUM(oi.quantity * oi.selling_price) AS total_revenue
FROM PRODUCT_CATEGORY pc
JOIN PRODUCT_table p ON pc.ID_category = p.ID_category
JOIN ORDER_ITEM oi   ON p.ID_product   = oi.ID_product
GROUP BY pc.category_name
ORDER BY total_revenue DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- PŘÍSTUPOVÁ PRÁVA PRO DRUHÉHO ČLENA TÝMU (xbadiks00)
GRANT SELECT ON CUSTOMER           TO xbadiks00;
GRANT SELECT ON PRODUCT_CATEGORY   TO xbadiks00;
GRANT SELECT ON PRODUCT_table      TO xbadiks00;
GRANT SELECT ON ORDER_table        TO xbadiks00;
GRANT SELECT ON ORDER_ITEM         TO xbadiks00;
GRANT SELECT ON PAYMENT            TO xbadiks00;
GRANT SELECT ON SHOPPING_CART      TO xbadiks00;
GRANT SELECT ON SHOPPING_CART_ITEM TO xbadiks00;
GRANT SELECT ON ADDRESS_table      TO xbadiks00;

-- MATERIALIZOVANY POHLED: MV_CATEGORY_SALES
--
-- Materializovany pohled patri xbadiks00 a pouziva tabulky
-- xuchytj00 pres prefix schematu xuchytj00.
-- Tato sekce se spousti pod uctem xbadiks00.

BEGIN
    EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW MV_CATEGORY_SALES';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

CREATE MATERIALIZED VIEW MV_CATEGORY_SALES
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT
    pc.category_name,
    SUM(oi.quantity)                    AS total_items_sold,
    SUM(oi.quantity * oi.selling_price) AS total_revenue
FROM xuchytj00.ORDER_ITEM       oi
JOIN xuchytj00.PRODUCT_table    p  ON oi.ID_product  = p.ID_product
JOIN xuchytj00.PRODUCT_CATEGORY pc ON p.ID_category  = pc.ID_category
GROUP BY pc.category_name;

-- Ukázka: výpis pohledu
SELECT * FROM MV_CATEGORY_SALES ORDER BY total_revenue DESC;

-- Ruční refresh pohledu (přenačtení aktuálních dat ze zdrojových tabulek)
EXEC DBMS_MVIEW.REFRESH('MV_CATEGORY_SALES');

SELECT * FROM MV_CATEGORY_SALES ORDER BY total_revenue DESC;

-- KOMPLEXNÍ SELECT: přehled zákazníků s kategorizací podle útraty
-- Dotaz zjistí pro každého zákazníka počet objednávek a celkovou
-- útratu ze zaplacených objednávek, poté zákazníky rozdělí pomocí
-- CASE na: VIP customer, Regular customer, Inactive customer.
-- WITH zajišťuje přehlednost – výpočty jsou odděleny od prezentace.
-- Využití: věrnostní program, cílené marketingové kampaně.


WITH customer_stats AS (
    SELECT
        c.ID_customer,
        c.customer_name || ' ' || c.customer_surname AS customer_fullname,
        c.email,
        COUNT(o.ID_order) AS order_count,
        NVL(SUM(CASE WHEN o.order_state = 1 THEN o.total_amount ELSE 0 END), 0) AS total_spent
    FROM CUSTOMER c
    LEFT JOIN ORDER_table o ON c.ID_customer = o.ID_customer
    GROUP BY c.ID_customer, c.customer_name, c.customer_surname, c.email
)
SELECT
    cs.ID_customer,
    cs.customer_fullname,
    cs.email,
    cs.order_count,
    cs.total_spent,
    CASE
        WHEN cs.total_spent >= 10000 OR cs.order_count >= 3 THEN 'VIP customer'
        WHEN cs.order_count >= 1                            THEN 'Regular customer'
        ELSE                                                     'Inactive customer'
    END AS customer_category
FROM customer_stats cs
ORDER BY cs.total_spent DESC;
