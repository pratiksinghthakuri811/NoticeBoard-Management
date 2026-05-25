create database if not exists notice_board_management_system;
use notice_board_management_system;

create table if not exists users (
    user_id int primary key auto_increment,
    username varchar(30) not null unique,
    user_password varchar(30) not null,
    role enum('student','teacher') not null
);

create table if not exists notices (
    notice_id int primary key auto_increment,
    title varchar(100) not null,
    content text not null,
    created_by varchar(30) not null,
    created_at datetime default current_timestamp
);

drop procedure if exists registeruser;

delimiter $$

create procedure registeruser(
    in p_username varchar(30),
    in p_password varchar(30),
    in p_role varchar(30)
)
begin
    insert into users(username, user_password, role)
    values(p_username, p_password, p_role);

    select 'User registered successfully' as message;
end $$

delimiter ;

drop procedure if exists userlogin;

delimiter $$

create procedure userlogin(
    in p_username varchar(30),
    in p_password varchar(30)
)
begin
    select user_id, username, role
    from users
    where username = p_username
    and user_password = p_password;
end $$

delimiter ;

drop procedure if exists checkpermission;

delimiter $$

create procedure checkpermission(
    in p_username varchar(30)
)
begin
    declare v_role varchar(30);

    select role into v_role
    from users
    where username = p_username;

    if v_role is null then
        signal sqlstate '45000'
        set message_text = 'User not found';
    end if;

    if v_role != 'teacher' then
        signal sqlstate '45000'
        set message_text = 'Access denied: only teachers can perform this action';
    end if;
end $$

delimiter ;

drop procedure if exists createnotice;

delimiter $$

create procedure createnotice(
    in p_username varchar(30),
    in p_title varchar(100),
    in p_content text
)
begin
    call checkpermission(p_username);

    insert into notices(title, content, created_by)
    values(p_title, p_content, p_username);

    select 'Notice created successfully' as message;
end $$

delimiter ;

drop procedure if exists viewnotices;

delimiter $$

create procedure viewnotices()
begin
    select notice_id, title, content, created_by, created_at
    from notices
    order by created_at desc;
end $$

delimiter ;

drop procedure if exists updatenotice;

delimiter $$

create procedure updatenotice(
    in p_username varchar(30),
    in p_notice_id int,
    in p_title varchar(100),
    in p_content text
)
begin
    call checkpermission(p_username);

    update notices
    set title = p_title,
        content = p_content
    where notice_id = p_notice_id;

    select 'Notice updated successfully' as message;
end $$

delimiter ;

drop procedure if exists deletenotice;

delimiter $$

create procedure deletenotice(
    in p_username varchar(30),
    in p_notice_id int
)
begin
    call checkpermission(p_username);

    delete from notices
    where notice_id = p_notice_id;

    select 'Notice deleted successfully' as message;
end $$

delimiter ;

call registeruser('mr_sharma', 'teach123', 'teacher');
call registeruser('ram_student', 'stud123', 'student');

call userlogin('mr_sharma', 'teach123');
call userlogin('ram_student', 'stud123');

call createnotice('mr_sharma', 'Exam Schedule', 'Final exams start June 10');

call viewnotices();

call updatenotice('mr_sharma', 1, 'Updated Exam Schedule', 'Exam starts June 15');

call deletenotice('mr_sharma', 1);

call createnotice('ram_student', 'Test', 'This should fail');
