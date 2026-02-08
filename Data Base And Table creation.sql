-- Library management system
-- creating schema and table

/* Database Creation: Created a database named library_db.
Table Creation: Created tables for branches, employees, members, books, 
issued status, and return status.
Each table includes relevant columns and relationships.
*/
create schema library_project;
use library_project;

create table branch
         (
             branch_id varchar(10) primary key,	
             manager_id varchar(15),	
             branch_address varchar(50),
             contact_no varchar(15)
             );

create table employees
		(
			emp_id varchar(10) primary key,	
            emp_name varchar(25),	
            position varchar(10),	
            salary  int ,
            branch_id varchar(10) -- fk
		);
        
create table books
		(
			isbn varchar(20) primary key,
            book_title varchar(75),
            category varchar(20),
            rental_price float,
            status varchar(10),
            author varchar(25),
            publisher varchar(55)
		);

create table members
		(
			member_id varchar(15) primary key,
			member_name varchar(20),
            member_address varchar(30),
            reg_date date
		);

create table issued_status
		(
			issued_id varchar(15) primary key,
            issued_member_id varchar(15), -- fk
            issued_book_name varchar(75), 
            issued_date date,
            issued_book_isbn varchar(20), -- fk
            issued_emp_id varchar(10)   -- fk 
		);
        
create table return_status
		(
        return_id varchar(10) primary key,
        issued_id varchar(10), -- fk
        return_book_name varchar(75),
        return_date date,
        return_book_isbn varchar(20)
        );
        
-- adding foreign key 
alter table issued_status
add constraint fk_members
foreign key(issued_member_id)
references members(member_id);

alter table issued_status
add constraint fk_books
foreign key(issued_book_isbn)
references books(isbn);

alter table issued_status
add constraint fk_employees
foreign key(issued_emp_id)
references employees(emp_id);


alter table employees
add constraint fk_branch
foreign key(branch_id)
references branch(branch_id);

alter table return_status
add constraint fk_issued_status
foreign key(issued_id)
references issued_status(issued_id);

        