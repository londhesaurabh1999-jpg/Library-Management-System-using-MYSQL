select * from books;
select * from employees;
select * from return_status;
select * from issued_status;
select * from branch;
select* from members;
/*
2. CRUD Operations

    Create: Inserted sample records into the books table.
    Read: Retrieved and displayed data from various tables.
    Update: Updated records in the employees table.
    Delete: Removed records from the members table as needed.

*/
-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
insert into books(isbn,book_title,category,rental_price,status,author,publisher)
values
("978-1-60129-456-2","to kill Mockingbird","Classic",6.00,"yes","Harper Lee","JB LFppincent & co.");
-- Task 2: Update an Existing Member's Address
update members
set member_address="125 main st"
where member_id="c101";
-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
delete from issued_status
where issued_id="is127";
-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
select *from issued_status
where issued_emp_id="e101"; 
-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
select issued_emp_id ,count(issued_id) as total_books_issued 
from issued_status
group by issued_emp_id
having count(issued_id )>1;
select issued_emp_id 
from issued_status
group by issued_emp_id
having count(issued_id )>1;
-- 3. CTAS (Create Table As Select)
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
create table book_cnts
as
select b.isbn,
b.book_title,
count(ist.issued_id) as no_issued
from books b
join issued_status ist
on b.isbn=ist.issued_book_isbn 
group by 1,2;
select * from book_cnts;
 /*
 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. Retrieve All Books in a Specific Category:
*/
select* from books;
select * from books where category="history";
-- Task 8: Find Total Rental Income by Category:
select b.category,sum(b.rental_price)
from books b
join issued_status ist
on ist.issued_book_isbn=b.isbn
group by b.category;
select b.category,sum(b.rental_price),count(*)
from books b
join issued_status ist
on ist.issued_book_isbn=b.isbn
group by 1;
--  List Members Who Registered in the Last 180 Days:
select * from members;
insert into members(member_id,member_name,member_address,reg_date)
value("c204","sam","145 main st","2026-01-08"),
("c205","george","185 oak st","2026-02-08");

-- ect* from members 
-- re reg_dat currentate() - interval "180 days"
-- List Employees with Their Branch Manager's Name and their branch details:
select e.*,e2.emp_name as manager_name,b.branch_id,b.manager_id
from employees e
join branch b
on e.branch_id=b.branch_id
join employees e2
on b.manager_id=e2.emp_id;
-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:
create table books_rent_more_than_7
as
select * from books
where rental_price>=7;
select * from books_rent_more_than_7;
-- Task 12: Retrieve the List of Books Not Yet Returned
select  *
from return_status rst 
left join issued_status ist
on ist.issued_id=rst.issued_id;
-- 
select distinct ist.issued_book_name
from  issued_status ist
left join  return_status rst
on ist.issued_id=rst.issued_id
where rst.return_id is null;
/*
-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.
*/-- issued_status==members==books==return_status
-- filter books which is return
-- overdue>30
select ist.issued_member_id,
m.member_name,
b.book_title,
ist.issued_date,
rst.return_date,
datediff( current_date(),ist.issued_date) as overdue_days
from issued_status ist
join members m
on ist.issued_member_id=m.member_id
join books b
on b.isbn=ist.issued_book_isbn
left join return_status rst
on rst.issued_id=ist.issued_id
where 
rst.return_date is null
and
datediff( current_date(),ist.issued_date)>30
order by 1;
select current_date();

/*
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/

select * from books;
select * from return_status;
select * from issued_status;

-- Manually update
select * from issued_status
where issued_book_isbn="978-0-451-52994-2";

select * from books 
where isbn="978-0-451-52994-2";
update books
set status = "no"
where isbn="978-0-451-52994-2";

select * from return_status
where issued_id="IS130";
-- manually adding return id status
insert into return_status (return_id,issued_id,return_date,book_quality)
values
("RS120","IS130",curdate(),"GOOD");
 select * from return_status
 where issued_id="IS130";
select * from return_status;

--  store procedure
DELIMITER //

-- MySQL requires dropping the procedure first if it exists
DROP PROCEDURE IF EXISTS add_return_records //

CREATE PROCEDURE add_return_records(
    IN p_return_id varchar(25), 
    IN p_issued_id varchar(25), 
    IN p_book_quality varchar(10) 
)
BEGIN
    -- 1. Insert the return record
    INSERT INTO return_status (return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURDATE(), p_book_quality);

    -- 2. Update the book's status to 'yes' based on the isbn from the issued_status table
    UPDATE books 
    SET status = 'yes' 
    WHERE isbn = (
        SELECT issued_book_isbn 
        FROM issued_status 
        WHERE issued_id = p_issued_id
    );

    SELECT 'Return record added and book status updated.' AS message;
END //

DELIMITER ;
select*from return_status;
select * from books;

-- testing  functuion
select *  from return_status
where issued_id="IS135";
call add_return_records("RS138","IS135","Good");


/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.
*/
select* from branch;
select * from issued_status;
select * from books;
select * from return_status;
select * from employees;
create table branch_reports
as
select 
	b.branch_id,
    b.manager_id,
    count(ist.issued_id) as books_issued,
    count(rs.return_id) as books_returned,
    sum(bk.rental_price) as total_revenue
from 
	issued_status ist
join 
	employees e
on e.emp_id=ist.issued_emp_id
join 
	branch b
on b.branch_id=e.branch_id
left join 
	return_status rs -- done left join because i want all record or if he is giving only 17 record
on rs.issued_id=ist.issued_id
join 
	books bk
on ist.issued_book_isbn=bk.isbn
group by b.branch_id,b.manager_id;

select * from branch_reports; -- testing table

/*
Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members
containing members who have issued at least one book in the last 2 months.
*/
select * from issued_status;
create table active_members
as
select *  from members
where member_id in (select  
						distinct issued_member_id
					from issued_status
                    where 
						datediff( current_date(),issued_date)>675
					);
                    
/*
Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.
*/
 select * from books;
 select * from issued_status;
 select e.emp_name,b.*,count(ist.issued_id)
 from issued_status ist
 join books bk
 on ist.issued_book_isbn=bk.isbn
 join employees e
 on e.emp_id=ist.issued_emp_id
 join branch b
 on b.branch_id=e.branch_id
 group by 1,2;
 