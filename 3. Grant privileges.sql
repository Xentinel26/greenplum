reassign owned by admin1 to usuario;
drop owned by admin1;
reassign owned by admin2 to usuario;
drop owned by admin2;
reassign owned by simple_user1 to usuario;
drop owned by simple_user1;

drop user if exists admin1;
drop user if exists admin2 ;
drop user if exists simple_user1;

create user admin1 with encrypted password 'admin1' login ;
create user admin2 with encrypted password 'admin2' login ;
create user simple_user1 with encrypted password 'simple_user' login ;

-- super user gives permission to admin1
grant usage on schema finance to admin1 with grant option ;
grant update,select on finance.stock to admin1 with grant option ;


