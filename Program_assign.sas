%let path=/home/u63193716/sasuser.v94/assignment;
libname tsa "&path";

options validvarname = v7;

proc import datafile= "&path/TSAClaims2002_2017.csv"
	dbms=csv
	out=tsa.claims_cleaned
	replace;
	guessingrows= max;
run;


/* Displaying Content of dataset */
proc contents data = TSA.claims_cleaned;
run;

/* Remove duplicates */
proc sort data=tsa.claims_cleaned
			out = tsa.claims_cleaned
			nodupkey
			dupout= tsa.claim_cleaned_dups;
	by _all_;
run;

/* All missing and "-" values in col. claim_type, Claim_site, Disposition changed to Unknown */
data TSA.claims_cleaned;
	 set tsa.claims_cleaned;
	 
	 if Claim_type =(' ') or Claim_type =('-')
	 then Claim_type = "Unknown";
	 else if Claim_Type = 'Passenger Property Loss/Personal Injur' then Claim_Type='Passenger Property Loss';
     else if Claim_Type = 'Passenger Property Loss/Personal Injury' then Claim_Type='Passenger Property Loss';
     else if Claim_Type = 'Property Damage/Personal Injury' then Claim_Type='Property Damage';


	 if Claim_site =(' ') or Claim_site =('-')
	 then Claim_site = "Unknown";
	 
	 if Disposition =(' ') or Disposition  =('-')
	 then Disposition = "Unknown";
	 else if Disposition = 'losed: Contractor Claim' then Disposition = 'Closed:Contractor Claim';
     else if Disposition = 'Closed: Canceled' then Disposition = 'Closed:Canceled';
     
    
     State =upcase(State);
     StateName=propcase(Statename);
     
     if(Incident_date > Date_received or
        Date_received = . or
        Incident_date = . or
        year(Incident_date) < 2002 or
        year(Incident_date) > 2017 or
        year(Date_received) < 2002 or
        year(Date_received) > 2017) then Date_issues = "Need Review";
        
        
      format date_received incident_date date9. close_amount dollar20.2;
      
      label Airport_code="Airport Code"
      		Airport_name="Airport Name"
      		Claim_Number="Claim Number"
      		Claim_Site="Claim Site"
      		Claim_type="Claim Type"
      		Close_Amount="Close Amount"
      		Date_issues="Date Issues"
      		Date_Received="Date Received"
      		Incident_Date="Incident Date"
      		Item_Category="Item Category";
      		
      		
      Drop county city;
run;

proc sort data = tsa.claims_cleaned;
	by Incident_date;
run;

proc contents data=tsa.claims_cleaned varnum;
run;



proc freq data = TSA.claims_cleaned;
	table claim_type claim_site disposition; 
run;


/* This step would be help full in report */

/*1. How many data issues are in the overall data */ 
ods proclabel "Overall Date Issues";
title "Overall Date Issues in the Data: Jaykumar Patel";
proc freq data=tsa.Claims_Cleaned;
     table Date_Issues / missing nocum nopercent ;
run;
title;



/*2. How many claims per year of Incident_Date are in the overall data?*/
ods graphics on;
ods proclabel "Overall Claims by Year";
title "Overall Claims by Year: Jaykumar Patel";
proc freq data=tsa.Claims_Cleaned;
     table Incident_Date /nocum nopercent plots=freqplot;
     format Incident_Date year4.;
     where Date_Issues is null;
run;
title;


/3.
/*a. What are the frequency values for Claim_Type for the selected state?*/
/*b. What are the frequency values for Claim_Site for the selected state?*/
/*c. What are the frequency values for Disposition for the selected state?*/
ods proclabel "&statename Claims Overview";
title "Texas Claim Types, Claim Sites  and Disposition: Jaykumar Patel";
proc freq data=tsa.Claims_Cleaned order=freq;
table Claim_Type Claim_Site Disposition / nocum nopercent;
where StateName = "Texas" and Date_issues is null;
run;
title;





/*d.What is the mean, minimum, maximum and sum of Close_Amount for the selected state? Rounded to the nearest integer.*/
ods proclabel "Statename Close Amount Statistics";
title "Close Amount Statistics for Texas: Jaykumar Patel ";
proc means data=tsa.Claims_Cleaned min mean max sum maxdec=0;
  var Close_Amount;
  where StateName = "Texas" and Date_issues is null;
run;
title;
ods pdf close;