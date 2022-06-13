CREATE DATABASE GESTIONSALLE;
USE GESTIONSALLE;
drop table if exists ADMIN;

drop table if exists ENSEIGNANT;

drop table if exists NIVEAU;

drop table if exists OCCUPER;

drop table if exists PERIODE;

drop table if exists SALLE;

drop table if exists UE;

/*==============================================================*/
/* Table: ADMIN                                                 */
/*==============================================================*/
create table ADMIN
(
   EMAIL                varchar(255) not null,
   PASSEWORD            varchar(155),
   primary key (EMAIL)
);

/*==============================================================*/
/* Table: ENSEIGNAT                                             */
/*==============================================================*/
create table ENSEIGNANT
(
   MATRICULEENS         varchar(15) not null,
   NOMENS               varchar(50),
   PRENOMENS            varchar(25),
   TELENS               varchar(15),
   EMAIL                varchar(255),
   PASSWORD             varchar(255),
   primary key (MATRICULEENS)
);

/*==============================================================*/
/* Table: NIVEAU                                                */
/*==============================================================*/
create table NIVEAU
(
   IDNIVEAU             varchar(15) not null,
   NOMNIVEAU            varchar(25),
   primary key (IDNIVEAU)
);

/*==============================================================*/
/* Table: OCCUPER                                               */
/*==============================================================*/
create table OCCUPER
(
   IDSALLE              varchar(15) not null,
   MATRICULEENS         varchar(15) not null,
   IDPERIODE            int not null,
   PRESENCE             bool,
   primary key (IDSALLE, MATRICULEENS, IDPERIODE)
);

/*==============================================================*/
/* Table: PERIODE                                               */
/*==============================================================*/
create table PERIODE
(
   IDPERIODE            int not null auto_increment,
   DATECOUR             timestamp,
   HEUREDEPART           time,
   HEUREFIN             time,
   primary key (IDPERIODE)
);

/*==============================================================*/
/* Table: SALLE                                                 */
/*==============================================================*/
create table SALLE
(
   IDSALLE              varchar(15) not null,
   NOMSALLE             varchar(15),
   primary key (IDSALLE)
);

/*==============================================================*/
/* Table: UE                                                    */
/*==============================================================*/
create table UE
(
   IDUE                 varchar(15) not null,
   MATRICULEENS         varchar(15) not null,
   IDNIVEAU             varchar(15) not null,
   INTITULE           varchar(150),
   primary key (IDUE)
);

alter table OCCUPER add constraint FK_OCCUPER foreign key (IDSALLE)
      references SALLE (IDSALLE) on delete restrict on update restrict;

alter table OCCUPER add constraint FK_OCCUPER2 foreign key (MATRICULEENS)
      references ENSEIGNAT (MATRICULEENS) on delete restrict on update restrict;

alter table OCCUPER add constraint FK_OCCUPER3 foreign key (IDPERIODE)
      references PERIODE (IDPERIODE) on delete restrict on update restrict;

alter table UE add constraint FK_APPARTENIR foreign key (IDNIVEAU)
      references NIVEAU (IDNIVEAU) on delete restrict on update restrict;

alter table UE add constraint FK_ENSEIGNE foreign key (MATRICULEENS)
      references ENSEIGNAT (MATRICULEENS) on delete restrict on update restrict;
-- DATA INSERTION IN THE TABLE  
insert into ENSEIGNANT (MATRICULEENS,NOMENS,PRENOMENS,TELENS,EMAIl,PASSWORD) 
VALUES ("20S215","FOMEKONG","EVARIS","+237655426861","evaris@gmail.com.","adminevaris"),
	   ("20S214","MESSI","ANGUELE","+237655426468","messi@gmail.com.","adminevaris"),
       ("20S216","TAPAMO","TAPAMO","+237652428695","tapamo@gmail.com","admintapamo"),
       ("20S217","ABESSOLO","ABESSOLO","+237652425695","abessolo@gmail.com","admintabessolo");
insert into SALLE (IDSALLE,NOMSALLE)
VALUES ("R101","SICTL1"),
       ("S005","SICTL2"),
       ("R103","SICTL3");
insert into PERIODE (DATECOUR,HEUREDEPART,HEUREFIN)
VALUES ('2020-06-06 07:00:00','07:00:00','11:00:00'),
       ('2020-06-06 12:00:00','12:00:00','16:00:00'),
	   ('2020-07-06 07:00:00','07:00:00','11:00:00'),
       ('2020-07-06 12:00:00','12:00:00','16:00:00');
insert into NIVEAU(IDNIVEAU,NOMNIVEAU)
VALUES ("ICTL1","ICTL1"),
	   ("ICTL2","ICTL2"),
       ("ICTL3","ICTL3");
insert into UE (IDUE,MATRICULEENS,IDNIVEAU,INTITULE) 
VALUES ("ICT202","20S215","ICTL2","Mobile Application Development"),
       ("ICT204","20S214","ICTL2","Data Structure:"),
       ("ICT104","20S214","ICTL1","Data Structure"),
       ("ICT210","20S216","ICTL2","Database"),
       ("ICT110","20S217","ICTL1","Database");
       
insert into OCCUPER (IDSALLE,MATRICULEENS,IDPERIODE,PRESENCE) VALUE ("R101","20S215",1,false) ;   
	
select * from SALLE;
select * from ENSEIGNANT;
select * from PERIODE;       
select * from OCCUPER;       
-- PROCEDURES ET FONCTIONS  
/* Lister les salles de classes*/
DELIMITER |	   
CREATE PROCEDURE ListSalle()
BEGIN
 SELECT * FROM SALLE;
END |
DELIMITER ;
/* Lister les professeurs */
DELIMITER |
CREATE PROCEDURE ListProf()
BEGIN
 SELECT * FROM ENSEIGNANT;
END | 
DELIMITER ;
/* Programmer cour  */
DELIMITER | 
CREATE PROCEDURE ProgrammerCour(IN salle varchar(15),matriculeEns varchar(15),periode int)
BEGIN
 DECLARE occurence INT DEFAULT 0;
 
 SELECT COUNT(*) INTO occurence
 FROM OCCUPER
 WHERE 
 IDSALLE = salle AND IDPERIODE = periode;
 SELECT salle,matriculeEns,periode;
 IF occurence = 1 THEN
  SELECT "Cour deja programmer a cet instant :) Bien vouloir deplacer sur une autre plage horaire";
 ELSE 
  SELECT "Aucun cour programme a cet instant";
  IF EXISTS (SELECT 1 FROM SALLE where IDSALLE = salle) THEN
      IF EXISTS(SELECT 1 FROM ENSEIGNANT where MATRICULEENS = matriculeEns) THEN 
       IF EXISTS(SELECT 1 FROM PERIODE where IDPERIODE = periode) THEN
             insert into OCCUPER (IDSALLE,MATRICULEENS,IDPERIODE,PRESENCE) VALUE (salle,matriculeEns,periode,false) ;   
             SELECT "COUR AJOUTE AVEC SUCCES ";
       ELSE 
         SELECT "INFORMATIONS ERRONNES";
       END IF;
      ELSE 
	   SELECT "INFORMATIONS D'ENTREE ERRONES";
	  END IF;
  ELSE
    SELECT "Informations erronees ";
  END IF;  
  -- 
  
 END IF ;
END |
DELIMITER ;
DROP PROCEDURE ProgrammerCour;

DELIMITER | 
CREATE PROCEDURE ListProgramme()
BEGIN
SELECT O.IDSALLE , O.MATRICULEENS , P.DATECOUR ,P.HEUREDEPART , P.HEUREFIN FROM OCCUPER AS O INNER JOIN PERIODE AS P ON P.IDPERIODE=O.IDPERIODE;
END |
DELIMITER ; 
DROP PROCEDURE ListProgramme;
-- EXECUTION 
CALL ListSalle();
CALL ListProf();
CALL ProgrammerCour("R111","20S217",4);
CALL ListProgramme();
