--- purchasing_report.sql

break on supplier skip 1 

column target_price format 999,999.99 

set termout off

spool logs/purchasing_report.txt

select p.supplier_id SUPPLIER, 
       p.supplier_product_id SUPP_PROD_ID, 
       p.product_name PRODUCT_NAME, 
       i.quantity_on_hand QTY_ON_HAND, 
      (p.min_price * .5) TARGET_PRICE
 where p.product_id = i.product_id
 order by p.supplier_id, p.supplier_product_id ;

spool off set termout on