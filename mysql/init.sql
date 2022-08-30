CREATE DATABASE demo;
CREATE USER 'josh'@'%' IDENTIFIED BY 'Your_User_Password';
GRANT ALL ON demo.* to 'josh'@'%';