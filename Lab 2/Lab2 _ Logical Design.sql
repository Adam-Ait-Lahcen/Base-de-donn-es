-- =====================================================================
-- creating and using the database
-- =====================================================================

create database lab2;
use lab2;

-- =====================================================================
-- creating person table and its sub-tables
-- =====================================================================

create table Person (
pid int ,
first_name varchar(20),
last_name varchar(20),
email varchar(30),
affiliation varchar(30),
start_date date,
end_date date,
primary key(pid)
);

create table Student (
student_id int,
program varchar(30),
primary key(student_id),
foreign key (student_id) references Person(pid) ON DELETE CASCADE
);

create table Employee (
employee_id int,
phone_number int,
office varchar(30),
primary key(employee_id),
foreign key (employee_id) references Person(pid) ON DELETE CASCADE,

/*for the reports to relationship*/

supervisor int,
foreign key (supervisor) references Employee(employee_id) 
);

create table Academic (
academic_id int,       
primary key(academic_id),
foreign key (academic_id) references Employee(employee_id)
);

create table Faculty (
faculty_id int,
position  VARCHAR(30) NOT NULL,       
primary key(faculty_id),
foreign key (faculty_id) references Academic(academic_id)
);
create table NonAcademic (
non_academic_id int,
primary key(non_academic_id),
foreign key (non_academic_id) references Employee(employee_id)
);

create table Administrative (
admin_id int,
position  VARCHAR(30) NOT NULL,       
primary key(admin_id),
foreign key (admin_id) references NonAcademic(non_academic_id)
);

create table Technical (
tech_id int,
position  VARCHAR(30) NOT NULL,       
primary key(tech_id),
foreign key (tech_id) references NonAcademic(non_academic_id)
);

/*'advises' relationship between student and academic*/

create table Advises (
student_id int,
academic_id int not null,
primary key(student_id, academic_id),
foreign key (student_id) references Student(student_id),
foreign key (academic_id) references Academic(academic_id)
);


-- =====================================================================
-- Laboratories, Projects & Budgets :
-- =====================================================================

create table Laboratory(
lab_id int, 
lab_name varchar(30),
building varchar(30), 
room_number int,
discipline_area varchar(30),
primary key(lab_id),

/* for relationship suprevises with faculty*/

faculty_supervisor int not null,
foreign key(faculty_supervisor) references Faculty(faculty_id) ON DELETE NO ACTION
);

/*for relationship attached between lab and person*/

create table Attached(
lab_id int,
pid int not null,
primary key(lab_id, pid),
foreign key(lab_id) references Laboratory(lab_id),
foreign key(pid) references Person(pid)
);


create table Research_Project(
project_code int,
title varchar(30),
start_date date,
end_date date,
project_status varchar(10),
primary key(project_code)
);

/*for relationship participates between person and research project*/

create table Participates ( 
pid int not null , 
project_code int  ,
pRole varchar(15),
primary key (pid,project_code), 
foreign key (pid) references Person(pid) , 
foreign key (project_code) references Research_Project(project_code)
);

/*Budget table*/

create table Budget (
budgetLine varchar(30),
amountGranted decimal(10,2), 
amountDisbursed decimal(10,2), 
startDate date , 
endDate date , 
primary key (budgetLine) ,

/*budget manager relationship*/

managerID int not null, 
foreign key (managerID) references Academic(academic_id) ON DELETE NO ACTION
);

/*for relationship funds lab*/

create table FundsLab ( 
lab_id int , 
budgetLine varchar(30) not null , 
primary key (lab_id , budgetLine) , 
foreign key (lab_id) references Laboratory(lab_id) , 
foreign key (budgetLine) references Budget(budgetLine) 
);

/* for relationship funds research project*/

create table fundsPrj(
project_code int,
budgetLine varchar(30) not null,
primary key(project_code, budgetLine),
foreign key(project_code) references Research_Project(project_code),
foreign key(budgetLine) references Budget(budgetLine)
);


-- =====================================================================
-- Equipment & Certifications
-- =====================================================================

create table EquipmentModel(
model_id int,
commercial_name varchar(30),
manufacturer varchar(30),
category varchar(30),
special_training boolean,
requiredEnvironment varchar(30),
primary key(model_id)
);


create table EquipmentUnit(
serial_number int,
acquisition_date date,
purchaseCost float,
EUstatus varchar(10),
portable boolean,
primary key(serial_number),

/*Instance of relationship between equipment model and equipment unit*/

equipmentModel int not null,
foreign key(equipmentModel) references EquipmentModel(model_id) ON DELETE NO ACTION,

/*Located in relationship */
located_in int not null,
foreign key(located_in) references Laboratory(lab_id) ON DELETE NO ACTION
);


create table Certification(
certif_code int,
title varchar(30),
issuing_authority varchar(30),
validity_period int,
safetyLevel varchar(30),
primary key(certif_code)
);

/*Equipment model require certification relationship*/

create table requires(
equipmentModel int,
certif_code int,
primary key(equipmentModel, certif_code),
foreign key(equipmentModel) references EquipmentModel(model_id),
foreign key(certif_code) references Certification(certif_code)
);

/*Person holds certification relationship*/

create table holds(
pid int,
certif_code int,
issueDate date,
expirationDate date,
grade varchar(10),
primary key(pid, certif_code),
foreign key(pid) references Person(pid),
foreign key(certif_code) references Certification(certif_code)
);



-- =====================================================================
-- Reservation table
-- =====================================================================

create table Reservation(
resId int,
submissionTs varchar(30),
plannedStart datetime,
plannedEnd datetime,
purpose varchar(30),
Rstatus varchar(10),
primary key(resId),

/*Reservation made by person relationship*/

made_by int not null,
foreign key(made_by) references Person(pid),

/*reservation for research project relationship*/
project_code int not null,
foreign key(project_code) references Research_Project(project_code),

/*person approves reservation*/
approver int,
foreign key (approver) references Person(pid)

);

/*Reservation reserves equipment unit*/

create table reserves(
res_id int,
equipmentUnit int,
primary key(res_id, equipmentUnit),
foreign key(res_id) references Reservation(resId),
foreign key(equipmentUnit) references EquipmentUnit(serial_number)
);



-- =====================================================================
-- Maintenance & Calibration — weak entities
-- =====================================================================

create table Maintenance(
equipmentUnit int,
startTs datetime,
endTs datetime,
Mtype varchar(10),
Mdescription varchar(50),
cost float,
outcome varchar(10),
doneby int not null,
foreign key (doneby) references Technical(tech_id) ON DELETE NO ACTION,
primary key(equipmentUnit, startTs),
foreign key(equipmentUnit) references EquipmentUnit(serial_number) ON DELETE CASCADE
);


create table CalibrationRecord
(
equipmentUnit int,
calibDate datetime,
calibrationType varchar(10),
result varchar(10),
nextDueDate date,
remarks varchar(500),
primary key(equipmentUnit, calibDate),
foreign key(equipmentUnit) references EquipmentUnit(serial_number) ON DELETE CASCADE
);


-- =====================================================================
-- Consumables, Suppliers & Stock
-- =====================================================================

create table Consumable(
consId int,
consName varchar(20),
unitOfMeasure varchar(10),
hazardLevel varchar(10),
reorderThreshold int,
primary key(consId)
);

/*Supplier table*/

create table Supplier(
suppId int,
suppName varchar(20),
contactEmail varchar(30),
phone int,
primary key(suppId)
);

create table Stocks 
(
consId int,
lab_id int,
Primary key(consId, lab_id),
lastRestockDate date,
QuantityOnHand int,
StorageCondition varchar(20),
foreign key (consId) references consumable(consId),
foreign key (lab_id) references Laboratory(lab_id),
monitor_by int not null,
monitoring_since date,
foreign key (monitor_by) references Technical (tech_id)
);

create table supplies 
(
consId int,
lab_id int,
suppId int,
unitPrice decimal(10,2) NOT NULL,
primary key(consId, lab_id, suppId),
foreign key (consId) references consumable(consId),
foreign key (lab_id) references laboratory(lab_id),
foreign key (suppId) references Supplier(suppId)
);

create table consumes 
(
consId int,
lab_id int,
resId int,
primary key(resId, lab_id, consId),
quantityUsed float not null,
foreign key (consId, lab_id) references Stocks(consId, lab_id),
foreign key (resId) references reservation(resId)
);















