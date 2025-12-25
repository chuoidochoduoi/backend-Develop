
create DATABASE Test_sql;

create schema test_3h;
set search_path to test_3h;

--phan 1 c1
create table Customer(
    customer_id varchar(5) primary key ,
    customer_full_name varchar(100) not null ,
    customer_email varchar(100) not null unique ,
    customer_phone varchar(15) not null ,
    customer_address varchar(255) not null
);

create table Room(

        room_id varchar(5) primary key ,
        room_type varchar(50) not null ,
        room_price decimal(10,2) not null ,
        room_status varchar(20) not null ,
        room_area int not null
);

create table Booking(
        booking_id serial primary key ,
        customer_id varchar(5) not null ,
        room_id varchar(5) not null ,
        check_in_date date not null ,
        check_out_date date not null,
        total_amount decimal(10,2),
    foreign key (customer_id) references Customer(customer_id),
    foreign key (room_id) references Room(room_id)

);

create table Payment(
        payment_id serial primary key ,
        booking_id int not null ,
        payment_method varchar(50) not null ,
        payment_date date not null ,
        payment_amount decimal(10,2) not null ,

    foreign key (booking_id) references booking(booking_id)
);


--p1 c2

insert into customer(customer_id, customer_full_name, customer_email, customer_phone, customer_address)
VALUES ('C001','Nguyen Anh Tu','tu.nguyen@example.com','0912345678','Hanoi, Vietnam'),
       ('C002',   'Tran Thi Mai','mai.tran@example.com','0923456789','Ho Chi Minh, Vietnam'),
       ('C003','Le Minh Hoang','hoang.le@example.com','0934567890','Danang, Vietnam'),
       ('C004','Pham Hoang Nam','nam.pham@example.com','0945678901','Hue, Vietnam'),
       ('C005', 'Vu Minh Thu','thu.vu@example.com','0956789012','Hai Phong, Vietnam');


insert into Room(room_id, room_type, room_price, room_status, room_area)
VALUES('R001','Single',100.0,'Available',25),
    ('R002',  'Double',150.0,'Booked',40),
    ('R003',   'Suite',250.0,'Available',60),
    ('R004',  'Single',120.0,'Booked',30),
    ('R005',   'Double',160.0,'Available',35);


insert into Booking(customer_id, room_id, check_in_date, check_out_date, total_amount)
VALUES('C001', 'R001','2025-03-01','2025-03-05',400.0) ,
      ('C002', 'R002','2025-03-02','2025-03-06',600.0) ,
      ('C003', 'R003','2025-03-03','2025-03-07',1000.0) ,
      ('C004', 'R004','2025-03-04','2025-03-08',480.0) ,
      ('C005', 'R005','2025-03-05','2025-03-09',800.0) ;





insert into Payment(booking_id, payment_method, payment_date, payment_amount)
VALUES(1,'Cash','2025-03-05',400.0),
      (2,'Credit Card','2025-03-06',600.0),
      (3,'Bank Transfer','2025-03-07',1000.0),
      (4,'Cash','2025-03-08',480.0),
      (5,'Credit Card','2025-03-09',800.0);

-- p1 c3

update booking set total_amount = total_amount*0.9  where check_in_date <'2025-03-03';

-- p1 c4

delete from payment where payment_method= 'Cash' and payment_amount <500;

--p2 5

select customer_id,customer_full_name,customer_email,customer_phone from  customer
                                                                    order by customer_full_name desc ;

-- p2 6

select room_id,room_type,room_price,room_area from room order by room_area asc ;

-- p2 7

select c.customer_full_name,b.room_id,b.check_in_date,b.check_out_date from  booking b
    join customer c on b.customer_id = c.customer_id

-- p2 8

select c.customer_id,c.customer_full_name,p.payment_method,sum(p.payment_amount) as total_payment from customer c
    join Booking b on c.customer_id = b.customer_id
    join Payment P on b.booking_id = P.booking_id
    group by c.customer_id,c.customer_full_name,p.payment_method
    order by total_payment asc ;
-- p2 9

select * from customer order by customer_full_name desc limit 3 offset 1;

-- p2 10

select c.customer_id,c.customer_full_name,count(booking_id) from customer c
                                                            join booking b on c.customer_id = b.customer_id
                                                            group by c.customer_id,customer_full_name
                                                            having count(booking_id)>1;

-- p2 11

select R.room_id,R.room_type,R.room_price,count(b.booking_id) as quantity from booking b
                                                                join Room R on b.room_id = R.room_id
                                                                group by R.room_id
                                                                having count(b.booking_id) >2;

--p2 12

select c.customer_id,c.customer_full_name,b.room_id,sum(p.payment_amount) from  customer c
                        join booking b on c.customer_id = b.customer_id
                        join Payment P on b.booking_id = P.booking_id
                        group by c.customer_id,c.customer_full_name,b.room_id
                        having sum(p.payment_amount) > 1000;

-- p2 13

select customer_id,customer_full_name,customer_email,customer_phone from customer
                                    where customer_full_name ilike '%Minh%' or customer_address ilike '%hanoi%'
                                    order by customer_full_name asc ;

-- p2 14

select room_id,room_type,room_price from room order by room_price desc limit 5 offset 5;


-- p3 15

create view booking_information as
select r.room_id,r.room_type,c.customer_id,c.customer_full_name,b.check_in_date from booking b
                        join customer c on b.customer_id = c.customer_id
                        join room r on b.room_id = r.room_id
                        where b.check_in_date <'2025-03-04';

--p3 16

create view customer_room_information as
select c.customer_id,c.customer_full_name,r.room_id,r.room_area,b.check_in_date from customer c
                        join booking b on c.customer_id = b.customer_id
                        join room r on b.room_id = r.room_id
                        where r.room_area>30;

--tg_op

-- p4 17
create or replace function insert_booking_rule()
returns trigger
language plpgsql
    as $$
    BEGIN
    if( new.check_in_date > new.check_out_date) then raise exception 'Ngày đặt phòng không thể sau ngày trả phòng được !';
        end if;
        return new;
    end;
    $$;

create or replace trigger check_insert_booking
    before  INSERT on booking for each row execute FUNCTION insert_booking_rule();

-- p4 18

create or replace function auto_update_status()
    returns trigger
    language plpgsql
as $$
BEGIN
        update room set room_status = 'Booked'where room_id =new.room_id;
        return new;
        end;
$$;

create or replace trigger update_room_status_on_booking
    after  INSERT on booking for each row execute FUNCTION auto_update_status();



-- p5 19
create table Customer(
                         customer_id varchar(5) primary key ,
                         customer_full_name varchar(100) not null ,
                         customer_email varchar(100) not null unique ,
                         customer_phone varchar(15) not null ,
                         customer_address varchar(255) not null
);
create or replace procedure add_customer(name varchar(100), email varchar(100), phone varchar(15), address varchar(255))
LANGUAGE plpgsql
AS $$
    declare
        id_customer varchar(5);
    begin
        id_customer = random(1,9999);

        if((select customer_id from customer where customer_id= id_customer) is not null ) then raise exception 'da ton tai';
        end if;
        insert into customer(customer_id, customer_full_name, customer_email, customer_phone, customer_address)
        values (id_customer,name,email,phone,address);
    end;
    $$;


call add_customer('Nguyen Anh Tu','tu.ngn@eam3le.com','0912345678','Hanoi, Vietnam');

-- p5 20
create or replace procedure add_payment(p_booking_id int, p_payment_method varchar(50), p_payment_amount decimal(10,2), p_payment_date date)
    LANGUAGE plpgsql
AS $$

begin
    insert into payment(booking_id, payment_method, payment_date, payment_amount)
    values (p_booking_id, p_payment_method,p_payment_date,p_payment_amount);

   end;
$$;

call add_payment(3,'Cash',50000,'2025-03-04')