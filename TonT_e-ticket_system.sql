-- Database project for e-ticket system (Ticket On Tap)
-- -------------------------------------------------Tables-----------------------------------------------------------

-- 1. passengerGroups table
CREATE TABLE passengerGroups (
    passengerGroup int NOT NULL PRIMARY KEY AUTO_INCREMENT,
    passengerType VarChar(255)
 );

-- 2. passengers table
CREATE TABLE passengers (
    passengerId  int NOT NULL PRIMARY KEY AUTO_INCREMENT,
    passengerFName  VarChar(255),
    passengerLName VarChar(255),
    passengerAge int,
    PASSENGERGROUP int ,
    createdDateTime DATETIME,
    modifiedDateTime DATETime,
    FOREIGN KEY (PASSENGERGROUP) REFERENCES passengerGroups (passengerGroup)
);

-- 3. Table for Stations
CREATE TABLE stations (
    stationId  int NOT NULL PRIMARY KEY AUTO_INCREMENT,
    stationName  VarChar(255)
);

-- 4. busses table
CREATE TABLE busses (
    busId  int NOT NULL PRIMARY KEY AUTO_INCREMENT,
    BusNumber  varchar(20)
);

-- 5. busRoute table
CREATE TABLE busRoute (
    busRouteId int NOT NULL PRIMARY KEY AUTO_INCREMENT,
    fromStation int,
    toStation int,
    BusID int,
    startingTime Time,
    ETAForToStation int,
    IsFromStationFirstStop boolean,
    IsToStationLastStop boolean,
    createdDateTime DATETIME,
    modifiedDateTime DATETIME,
    Constraint fk_fromStation FOREIGN KEY (fromStation) REFERENCES stations (stationId),
    Constraint fk_toStation FOREIGN KEY (toStation) REFERENCES stations (stationId),
    FOREIGN KEY (BusID) REFERENCES busses (busId)
);

-- 6. fare table
CREATE TABLE fare (
    fareId int NOT NULL PRIMARY KEY AUTO_INCREMENT,
    price double,
    busRouteId int,
    passengerGroupId int,
    constraint fk_frombusRoute FOREIGN KEY (busRouteId) REFERENCES busRoute(busRouteId),
    constraint fk_frompassengerGroups FOREIGN KEY (passengerGroupId) REFERENCES passengerGroups(passengerGroup)
);

-- 7. Tickets table
CREATE TABLE tickets (
    ticketId int PRIMARY KEY  AUTO_INCREMENT,
    ticketNumber int,
    fareid int,
    passengerid int,
    starttime time,
    endtime time,
    createdDateTime DATETIME,
    constraint fk_fromFare FOREIGN KEY (fareid) REFERENCES fare(fareId),
    constraint fk_fromPassengers FOREIGN KEY (passengerid) REFERENCES passengers (passengerId)
);

-- 8. Route History Table
CREATE TABLE routeHistory (
	routeHistoryId int PRIMARY KEY AUTO_INCREMENT,
	passengerid int,
	ticketid int,
   constraint ffk_fromPassengers FOREIGN KEY (passengerid) REFERENCES passengers (passengerId),
   constraint fk_fromTickets FOREIGN KEY (ticketid) REFERENCES tickets (ticketId)
);

-- ------------------------------------------------check table here------------------------------------------------
SELECT * FROM busRoute br;
SELECT * FROM busses b ;
SELECT * FROM fare f ;
SELECT * FROM passengerGroups pg ;
SELECT * FROM passengers p ;
SELECT * FROM routeHistory rh ;
SELECT * FROM stations s ;
SELECT * FROM tickets t ;

-- ------------------------------------Procedure/function, views, and triggers--------------------------------------------------------------

-- 1. procedure for checking any passenger travel details only in case of any criminal activities
-- This feature can help police to track down the suspect or criminal and it can save someone's life or any other unfortunate event.

DELIMITER //
CREATE procedure passengerTravelData (id int)
BEGIN 
 SELECT p.passengerId , passengerFName , passengerLName ,ticketNumber, starttime, t.createdDateTime  
 FROM  passengers p 
 Left JOIN tickets t 
 ON p.passengerId = t.passengerid 
 Where p.passengerId  = id;
END; //
DELIMITER ;

call passengerTravelData (1); -- CALLING PROCEDURE 

-- 2. --------------------View-------------------------------------------------------------------------------------------

-- view ---------------- you can check which type of user, using busses more frequently
CREATE VIEW passengerSpendingData AS 
 SELECT passengerType, SUM(price) AS 'TotalSpending' 
 FROM tickets t 
 LEFT JOIN fare f ON f.fareId = t.fareid 
 LEFT JOIN passengerGroups pg ON pg.passengerGroup = f.passengerGroupId 
 GROUP BY passengerType 
 ORDER BY TotalSpending DESC LIMit 1 ; 

SELECT * FROM passengerSpendingData ;

-- 3. --------------------Trigger------------------------------------------------------------------------------------

-- Trigger -- this trigger insert any new ticket in the routeHistory table
Delimiter //
CREATE Trigger TicketDetails_trigger
AFTER INSERT ON tickets
FOR EACH ROW 
BEGIN
 INSERT INTO routeHistory (passengerid, ticketid)
 VALUES (new.passengerid, new.ticketId);
END; //
DELIMITER ;

-- 4. ------------------Procedure------------------------------------------------------------------------------------

-- procedure for getting tickets 
DELIMITER //
CREATE procedure makeTicket (ticketNumber int, fareid int, passengerid int, starttime time, createdDateTime DATETIME)
BEGIN 
 INSERT into tickets (ticketNumber, fareid, passengerid, starttime, createdDateTime)
 VALUES (ticketNumber, fareid, passengerid, starttime, createdDateTime);
call ticketValidity (); -- here I am calling another function in this procedure
END; //
DELIMITER ;

call makeTicket (912, 2, 2, CURTIME() , NOW());

-- 5. -----------------time addition----------------------------------------------------------------------------------------------------------

--  ----------this will add 2 hours on ticket buying time for validity
DELIMITER //
CREATE Procedure ticketValidity ()
BEGIN 
-- ** incase of ticket after 2200 Hours it is adding just 2 and I am getting more than 24 hours
-- for eg: if someone bought ticket at 2230 hours then it is making the ticket validity to 2430 hours ?? **
 UPDATE tickets SET endtime = starttime + INTERVAL 2 HOUR;  
END; //
DELIMITER ;
call ticketValidity ();

-- 6. --------------------It will show Time slot in which people are travelling more--------------------------------------------------------

SELECT  (SELECT  count(*) FROM tickets t Where starttime BETWEEN '06:00:00' AND '11:00:00')  AS MorningCount,
(SELECT count(*) FROM tickets t WHERE starttime BETWEEN '11:00:00' AND '16:00:00') AS AfternoonCount,
(SELECT  count(*) FROM tickets t WHERE starttime BETWEEN '16:00:00' AND '22:00:00') AS EveningCount,
(SELECT  count(*) FROM tickets t WHERE starttime BETWEEN '22:00:00' AND '06:00:00') AS NightRiders



-- ---------------------manual entries queries and other for others I used dbeaver to add value--------------------------------------------------------------------------

-- inserting dummy data in the tables -- I used this data for checking 

INSERT INTO passengers (passengerFName, passengerLName  ,passengerAge)
VALUES ("Narendra", "Modi", 21);
INSERT INTO passengers (passengerFName, passengerLName  ,passengerAge)
VALUES ("Justin", "Trudeau", 23);
INSERT INTO passengers (passengerFName, passengerLName  ,passengerAge)
VALUES ("Scott", "Morrison", 27);
INSERT INTO passengers (passengerFName, passengerLName  ,passengerAge)
VALUES ("Joe", "Biden", 25);
INSERT INTO passengers (passengerFName, passengerLName  ,passengerAge)
VALUES ("Jacinda", "Ardern", 27);

-- inserting values for passenger type in passenger group tables
INSERT into passengerGroups (passengerType) VALUES ('Student');
INSERT into passengerGroups (passengerType) VALUES ('Senior');
INSERT into passengerGroups (passengerType) VALUES ('Adult');

-- inserting fare valuues for different passenger type group
INSERT into fare (price, busRouteId ,passengerGroupId) VALUES (3.20,1,1); 
INSERT into fare (price, busRouteId ,passengerGroupId) VALUES (2.50,1,2); 
INSERT into fare (price, busRouteId ,passengerGroupId) VALUES (4.00,2,3); 

-- inserting dummy data for passenger
INSERT into passengers ( passengerFName, passengerLName , passengerAge , PASSENGERGROUP)
-- , createdDateTime ,modifiedDateTime) -- this will be created and inserted by procedures
VALUES ("Hugh", "Jackman", 25, 3)
-- , '20220412 10:34:09AM', '20220413 11:15:02 AM'); -- this will be created and inserted by procedures

-- inserting stations name
INSERT into stations (stationName) VALUES ("Humber College");
INSERT into stations (stationName) VALUES ("Kipling Station");

-- inserting bus number
insert into busses (BusNumber) VALUES ("123C");
INSERT into busses (BusNumber) VALUES ("46A");
