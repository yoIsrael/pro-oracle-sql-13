WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK ; 

variable o number 
execute :o := order_id.nextval

variable c number 
execute :c := &customer_id 

execute oe.record_new_order(:c,:o) ; 

variable s number 
execute :s := &salesperson_id 
variable d number 
execute :d := &discount 

savepoint create_order ; 

insert into orders
 (order_id, order_date, order_mode, order_status, customer_id, sales_rep_id)
 (:o, sysdate, 'direct', 1, :c, :s) ;

--- Add first ordered item and reduce on-hand inventory 

savepoint detail_item1 ;

variable i number 
execute :i := &first_item 

variable q number 
execute :q := &item_quantity 

variable p number 
execute :p := get_ListPrice(:i)

insert into order_items
 (order_id, line_item_id, product_id, unit_price, discount_price, quantity)
 (:o, 1, :i, :p, :p-(:p*:d), :q) ;

update inventories
   set quantity_on_hand = quantity_on_hand - :q
 where product_id = :i and warehouse_id = 1 ;

--- Get Order Total

variable t number 
execute :t := get_OrderTotal(:o)

-- Request credit authorization 

savepoint credit_auth ; 

execute billing.credit_request(:c,:t) ;

--- Update order total 

savepoint order_total ;

update orders
   set order_total = :t
 where order_id = :o ;

select order_id,
       customer,
       mobile,
       status,
       order_total,
       order_date
  from order_detail_header

select line_item_id ITEM, 
       product_name, 
       unit_price,
       discount_price,
       quantity,
       line_item_total
 where order_id = :o
 order by line_item_id ;

rollback ;

select * from order_log ;