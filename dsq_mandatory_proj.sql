# 1. Calculate average Unit Price for each CustomerId.
select customerID,unitprice,round(avg(unitprice),2)as average_unitprice 
	from orders o 
    join order_details od on o.orderid=od.orderid
    group by customerid order by customerid;
 
select customerID,unitprice,
avg(unitprice) over(order by customerid) avg_unitprice
from orders o join order_details od on o.orderid=od.orderid
group by customerid;

select avg(unitprice) from orders o join order_details od on o.orderid=od.orderid where CustomerID='ANATR';

# 2. Calculate average Unit Price for each group of CustomerId AND EmployeeId.
select customerid,employeeid,unitprice,round(avg(unitprice),2) avg_unitprice
	from orders o join order_details od on o.orderid=od.orderid
    group by customerid,employeeid order by CustomerID;

select customerid,employeeid,unitprice,
avg(unitprice) over(order by customerid) avg_unitprice
from orders o join order_details od on o.orderid=od.orderid
    group by customerid,employeeid;
    

# 3. Rank Unit Price in descending order for each CustomerId.
select customerid,unitprice,rank() over(partition by customerid order by unitprice desc) ranking from
	order_details od join orders o on od.orderid=o.orderid;

# 4. How can you pull the previous order date’s Quantity for each ProductId.
select orderid,od.productid,ProductName,quantity,
lag(quantity,1) over(partition by od.ProductID order by quantity) previous_order_quantity from order_details od
	join products p on od.ProductID=p.ProductID
    ;
    
# 5. How can you pull the following order date’s Quantity for each ProductId.
select orderid,od.productid,ProductName,quantity,
lead(quantity,1,quantity) over(partition by od.ProductID order by quantity) previous_order_quantity from order_details od
	join products p on od.ProductID=p.ProductID;
    
# 6. Pull out the very first Quantity ever ordered for each ProductId.
select orderid,od.productid,ProductName,quantity,
first_value(quantity) over(partition by od.ProductID order by quantity) firstvalue
 from order_details od
	join products p on od.ProductID=p.ProductID;

# 7. Calculate a cumulative moving average UnitPrice for each CustomerId.
select customerid,unitprice,avg(unitprice) over(partition by CustomerID ORDER BY CustomerID
     ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) moving_avg
	from orders o join order_details od on o.orderid=od.orderid;
select customerid,unitprice,avg(unitprice) over(partition by CustomerID ORDER BY CustomerID
     ROWS BETWEEN current row AND 2 following) moving_avg
	from orders o join order_details od on o.orderid=od.orderid;

#Theoretical questions:


# 1.Can you define a trigger that is invoked automatically before a new row is inserted into a table?
Before inserting new data into table we can apply the before insert trigger .
use usingimport;    #here I am using the usingimport database
create table demotrigger(id int primary key auto_increment,
	fname varchar(100),lname varchar(100),age int,branch varchar(50),op_time datetime);
insert into demotrigger(fname,lname,age,branch,op_time) values
	('abc','def',20,'mech',now());
select * from demotrigger;
delimiter $$
create trigger beftrigger before insert on demotrigger for each row
	if new.branch<>'mech' then
    signal sqlstate '50001' set message_text = 'Please enter mechanical branch only';
    end if;$$
drop trigger beftrigger;
insert into demotrigger(fname,lname,age,branch,op_time) values
	('pqr','stu',25,'mech',now());
insert into demotrigger(fname,lname,age,branch,op_time) values
	('gdfgd','fhdf',25,'civil',now());
select * from demotrigger;

# 2. What are the different types of triggers?
There are 6 different types of triggers
		--BEFORE INSERT
        --BEFORE UPDATE
        --BEFORE DELETE
        --AFTER INSERT
        --AFTER UPDATE
        --AFTER DELETE

create table student_info(id int primary key auto_increment,first_name varchar(100),
	last_name varchar(100),age int,branch varchar(50));
insert into student_info(first_name,last_name,age,branch) values
	('Rajitha','Ramineni',30,'ds19'),('shanaya','varma',2,'ds20'),
    ('saritha','palla',32,'ds18'),('nandan','varma',33,'ds21');
select * from student_info;

BEFORE INSERT : Before inserting any new data into tables we can apply before insert trigger

delimiter //
create trigger befinsert_trigger before insert on student_info for each row
	if new.age > 40 then
    signal sqlstate '50001' set message_text = 'age shoould not greater than 40 ';
    end if;//
#drop trigger befinsert_trigger;
insert into student_info(first_name,last_name,age,branch) values
	('abc','xyz',20,'ds22');
insert into student_info(first_name,last_name,age,branch) values
	('def','xyz',41,'ds22');
select * from student_info;

BEFORE UPDATE : 
Before Any modifications or changes apply to the tables we can apply apply before update trigger to get the
	 before updated data and save that data into one more table
create table befupdate(id int primary key auto_increment,optype varchar(50),fname varchar(100),
	lname varchar(100),age int,branch varchar(100),optime datetime);
create trigger beforeupdate_trigger before update on student_info for each row
	insert into befupdate set optype='update',optime=now(),
    fname=old.first_name,lname=old.last_name,age=old.age,branch=old.branch;
update student_info set last_name='Mylarishetti' where id=2;
select * from student_info;
select * from befupdate;

BEFORE DELETE TRIGGER : 
Before deleting any data from table apply before delete trigger the table and keep the old data into one table

create table deleted_data(id int primary key auto_increment,optype varchar(50),fname varchar(100),
	lname varchar(100),age int,branch varchar(100),optime datetime);
create trigger befdelete before delete on student_info for each row
	insert into deleted_data set optype='before deleted',optime=now(),
    fname=old.first_name,lname=old.last_name,age=old.age,branch=old.branch;
delete from student_info where age=20;
select * from student_info;
select * from deleted_data;

#AFTER INSERT TRIGGER
if we insert any new data into an existing table by using the after insert trigger we can store the new data into 
one new table
create table after_insert(id int primary key auto_increment,optype varchar(50),fname varchar(100),
	lname varchar(100),age int,branch varchar(100),optime datetime);
create trigger afterinsert_trigger after update on student_info for each row
	insert into after_insert set optype='insertion',optime=now(),
    fname=new.first_name,lname=new.last_name,age=new.age,branch=new.branch;
insert into student_info(first_name,last_name,age,branch) values('siri','varma',13,'ds23');
drop trigger afterinsert_trigger;
select * from student_info;
select * from after_insert;

AFTER UPDATE TRIGGER
create table after_update(id int primary key auto_increment,optype varchar(50),fname varchar(100),
	lname varchar(100),age int,branch varchar(100),optime datetime);
create trigger afterupdate_trigger after update on student_info for each row
	insert into after_update set optype='updation',optime=now(),
    fname=old.first_name,lname=old.last_name,age=old.age,branch=old.branch;
drop trigger afterupdate_trigger;
insert into student_info(first_name,last_name,age,branch) values('abhi','varma',20,'ds23');
select * from student_info;
update student_info set id=6,last_name='bekkam' where id=7;
select * from after_update;


AFTER DELETE TRIGGER
create table after_delete(id int primary key auto_increment,optype varchar(50),fname varchar(100),
	lname varchar(100),age int,branch varchar(100),optime datetime);
create trigger afterdelete_trigger after delete on student_info for each row
	insert into after_insert set optype='deletion',optime=now(),
    fname=old.first_name,lname=old.last_name,age=old.age,branch=old.branch;
delete from student_info where age<15;
select * from student_info;
select * from afterdelete_trigger;


# 3. How is Metadata expressed and structured?
METADATA: metadata is data about the data.
--It holds information about the each data element in database.
--e.g.,The information inside the book is a data and table of contents,title,author,indexes are metadata
--By using some functions we can get the metadata. By using desc we can get the description of table like 
	data types of columns in the table likewise by using many functions we can get the metadata 

select * from information_schema.tables where table_schema='usingimport'; #here we can get the all table names

select column_name from information_schema.columns 
	where table_schema='usingimport' and table_name='petrol_consumption';

select index_name from information_schema.statistics where table_schema='usingimport';

# 4. Explain RDS and AWS key management services.
Amazon RDS automatically integrates with AWS Key Management Service (AWS KMS) for key management. 
	Amazon RDS uses envelope encryption.
An AWS KMS key is a logical representation of a key. The KMS key includes metadata, 
	such as the key ID, creation date, description, and key state. The KMS key also contains the key 
	material used to encrypt and decrypt data.
AWS managed keys are KMS keys in your account that are created, managed, and used on your behalf 
	by an AWS service that is integrated with AWS KMS. You cant delete, edit, or rotate AWS managed keys.
AWS KMS keys are 256 bit in length and use the Advanced Encryption Standard (AES) in Galois/Counter Mode (GCM).

# 5. What is the difference between amazon EC2 and RDS?
Amazon RDS is a managed database-as-a-service that handles most of the management tasks and helps in 
	setting up, operating and scaling relational databases on the cloud. 
Amazon EC2 is a web service that helps run application programs in the AWS public cloud.

AWS RDS: 1.Amazon Relational Database  Service is a distributed relational database service provided by 
			Amazon Web Services. Amazon RDS brings ease of setup, operation, and scaling to relational 
            databases in AWS Cloud.
		 2.It is basically a SaaS-based service which automatically configures and maintains your database
			in the cloud.
		 3.There are several database engines supported by RDS, including 
			MySQL, MariaDB, PostgreSQL, Oracle, and Microsoft SQL Server.
		4.The type of database instance you select for each engine depends on its CPU, memory, storage, 
			and networking requirements.
AWS EC2 : 1.The Elastic Compute Cloud operates within Amazon Web Services and provides scalable computing power.
			With Amazon EC2, we can develop and deploy applications much more quickly since 
			we dont have to invest in any hardware.
		  2.We can use Amazon EC2 to launch as many or as few virtual servers as we need, in order to 
			configure security and networking and manage the storage.
RDS vs EC2 : 1.In a nutshell, both RDS and EC2 can be used to build a database within a secure environment that 
				supports high-performance applications and is scalable as well.
			2.If you dont want to manage and configure the database engine manually, then Amazon RDS may be 
				more helpful. Since RDS automatically manages time-consuming tasks such as configuration, 
                backups, and patches, you can focus on building your application.
			3.Amazon EC2 cloud computing platform lets you create as many virtual servers as you need. 
				You should manually configure security, networking and manage the stored data. 
                Having your own virtual servers is a great way to handle enterprise applications and 
                you will have the full control over the database including the SYS/SYSTEM user access.
