/*
================================================================================
  Студент: Абрамов Данил Денисович
  Вариант: 3

  Описание предметной области
Описание хранящихся на складе товаров. Включает в себя: описание помещений, описание стеллажей, 
описание клиентов, описание товаров, хранящихся на стеллажах. Описание помещения состоит из: названия,
полезного объёма, температурных и влажностных условий. Описание стеллажа состоит из: номера, указания помещения, 
в котором стеллаж находится, количества мест для хранения в стеллаже, высоты, ширины и длины одного места,
максимальной суммарной нагрузки. Описание клиента состоит из: названия юридического лица и банковских реквизитов
в виде большого текста. Описание товара, хранящегося на стеллажах, состоит из: высоты, ширины, длины, 
веса, даты поступления, номера договора, указания, от какого клиента поступил, даты окончания договора, 
температурных и влажностных условий хранения, указания стеллажа, и позиции размещения на нём,
представляемой в виде целого номера.
На одном стеллаже могут храниться товары только одного клиента.
================================================================================
*/

DROP TABLE IF EXISTS item;
DROP TABLE IF EXISTS rack;
DROP TABLE IF EXISTS client;
DROP TABLE IF EXISTS room;


CREATE TABLE room (
    room_id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name             VARCHAR(100)  NOT NULL,
    useful_volume    NUMERIC(10,2) NOT NULL,        
    temperature_min  NUMERIC(4,1)  NOT NULL,          
    temperature_max  NUMERIC(4,1)  NOT NULL,          
    humidity_min     NUMERIC(4,1)  NOT NULL DEFAULT 0,    
    humidity_max     NUMERIC(4,1)  NOT NULL DEFAULT 100,  

    CONSTRAINT uq_room_name          UNIQUE (name),
    CONSTRAINT ck_room_name          CHECK (btrim(name) <> ''),
    CONSTRAINT ck_room_volume        CHECK (useful_volume > 0),
    CONSTRAINT ck_room_temperature   CHECK (temperature_min BETWEEN -60 AND 60
                                        AND temperature_max BETWEEN -60 AND 60
                                        AND temperature_min <= temperature_max),
    CONSTRAINT ck_room_humidity      CHECK (humidity_min BETWEEN 0 AND 100
                                        AND humidity_max BETWEEN 0 AND 100
                                        AND humidity_min <= humidity_max)
);


CREATE TABLE client (
    client_id     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    legal_name    VARCHAR(255) NOT NULL,
    bank_details  TEXT         NOT NULL,            

    CONSTRAINT uq_client_legal_name   UNIQUE (legal_name),
    CONSTRAINT ck_client_legal_name   CHECK (btrim(legal_name) <> ''),
    CONSTRAINT ck_client_bank_details CHECK (btrim(bank_details) <> '')
);


CREATE TABLE rack (
    rack_id        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    rack_number    INTEGER       NOT NULL,          
    room_id        INTEGER       NOT NULL,
    client_id      INTEGER,                        
    slots_count    INTEGER       NOT NULL,            
    slot_height    NUMERIC(7,2)  NOT NULL,            
    slot_width     NUMERIC(7,2)  NOT NULL,            
    slot_length    NUMERIC(7,2)  NOT NULL,            
    max_load       NUMERIC(10,2) NOT NULL,           

    CONSTRAINT fk_rack_room   FOREIGN KEY (room_id)
        REFERENCES room (room_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_rack_client FOREIGN KEY (client_id)
        REFERENCES client (client_id) ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT uq_rack_number_in_room UNIQUE (room_id, rack_number),
    CONSTRAINT uq_rack_client         UNIQUE (rack_id, client_id),

    CONSTRAINT ck_rack_number      CHECK (rack_number > 0),
    CONSTRAINT ck_rack_slots       CHECK (slots_count > 0),
    CONSTRAINT ck_rack_slot_size   CHECK (slot_height > 0
                                      AND slot_width  > 0
                                      AND slot_length > 0),
    CONSTRAINT ck_rack_max_load    CHECK (max_load > 0)
);

CREATE TABLE item (
    item_id             INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    height              NUMERIC(7,2)  NOT NULL,      
    width               NUMERIC(7,2)  NOT NULL,       
    length              NUMERIC(7,2)  NOT NULL,      
    weight              NUMERIC(10,3) NOT NULL,      
    arrival_date        DATE          NOT NULL DEFAULT CURRENT_DATE,
    contract_number     VARCHAR(50)   NOT NULL,
    client_id           INTEGER       NOT NULL,
    contract_end_date   DATE          NOT NULL,
    temperature_min     NUMERIC(4,1)  NOT NULL,       
    temperature_max     NUMERIC(4,1)  NOT NULL,      
    humidity_min        NUMERIC(4,1)  NOT NULL DEFAULT 0,    
    humidity_max        NUMERIC(4,1)  NOT NULL DEFAULT 100, 
    rack_id             INTEGER       NOT NULL,
    position_number     INTEGER       NOT NULL,     

    CONSTRAINT fk_item_client FOREIGN KEY (client_id)
        REFERENCES client (client_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_item_rack_client FOREIGN KEY (rack_id, client_id)
        REFERENCES rack (rack_id, client_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT uq_item_rack_position UNIQUE (rack_id, position_number),

    CONSTRAINT ck_item_size        CHECK (height > 0 AND width > 0 AND length > 0),
    CONSTRAINT ck_item_weight      CHECK (weight > 0),
    CONSTRAINT ck_item_contract_no CHECK (btrim(contract_number) <> ''),
    CONSTRAINT ck_item_dates       CHECK (contract_end_date >= arrival_date),
    CONSTRAINT ck_item_temperature CHECK (temperature_min BETWEEN -60 AND 60
                                      AND temperature_max BETWEEN -60 AND 60
                                      AND temperature_min <= temperature_max),
    CONSTRAINT ck_item_humidity    CHECK (humidity_min BETWEEN 0 AND 100
                                      AND humidity_max BETWEEN 0 AND 100
                                      AND humidity_min <= humidity_max),
    CONSTRAINT ck_item_position    CHECK (position_number > 0)
);


CREATE INDEX ix_rack_room   ON rack (room_id);
CREATE INDEX ix_rack_client ON rack (client_id);
CREATE INDEX ix_item_client ON item (client_id);


