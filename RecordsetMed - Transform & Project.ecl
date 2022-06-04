IMPORT STD;

/* ECL RECORD, DATASET, JOIN, and OUTPUT */

/* Learning Outcomes: 
        Create inline DATASETs with appropriate RECORD sets 
        Populate and JOIN
        Perform SORT 
        OUTPUT results in BWR
        Examine how outputs are generated in BWR
        Outputs are saved in BWR but not as Thor files 
        Observe the sorted results 
*/

paitentSchema := RECORD
  Integer5 PatientID,
  String25 FirstName,
  String50 LastName,
  String30 rawCity,
  String2 rawState,
  String5 ZipCode,
  Integer8 BirthDate   //YYYYMMDD
END;

rawPatientDS := DATASET ([  {1, 'Susan', 'Davis', 'SuwaNEE', 'ga', '30024', 19710625},
                          {2, 'Jack', 'Morrison', 'Cumming', 'gA', '30041', 19631101},
                          {3, 'Sam', 'Mentos', 'alpharetta', 'Ga', '30005', 19810909},
                          {4, 'Zach', 'Beacham', 'johns Creek', 'GA', '30021', 19740804},
                          {5, 'Malcom', 'Marshall', 'Johns creek', 'GA', '30021', 20180315},
                          {6, 'Mac', 'Beacham', 'Champaign', 'Il', '61820', 20150921},
                          {7, 'Ashley', 'Bordon', 'Savoy', 'IL', '61874', 20100331},
                          {8, 'Marjorie', 'Green', 'chicago', 'iL', '60611', 19461130},
                          {9, 'Lillian', 'Venson', 'CumberLANd', 'il', '60656', 19721212}
                          ], paitentSchema);
                         
cleanPatientSchema := RECORD
    Integer5 PatientID,
    Integer8 Age,
    String30 City_Enhanced,
    String2 State_Enhanced
 END;

 enhancedPaitentSchema := RECORD
  Integer5 PatientID,
  String25 FirstName,
  String50 LastName,
  String30 City,
  String2 State,
  String5 ZipCode,
  Integer8 BirthDate,
  Integer8 Age
END;

/* 
  STD.Date.CurrentDate(True) -- returns the system date 
  [1..4] -- returns the characters from position 1 through 4

  Type casting by explicitly specifying the data type -- https://hpccsystems.com/training/documentation/ecl-language-reference/html/Type_Casting.html
*/

CurrentYear := (INTEGER) STD.Date.CurrentDate(True)[1..4];

cleanPatientSchema CleanPatientData(rawPatientDS patients) := TRANSFORM
  SELF.Age := CurrentYear - (INTEGER) patients.BirthDate[1..4];

  SELF.City_Enhanced := STD.Str.ToTitleCase(patients.rawCity); 
  SELF.State_Enhanced := STD.Str.ToUpperCase(patients.rawState);
  
  SELF.PatientID := patients.PatientID; 
  
  /* Also specified as below 
       SELF := patients;
  */     
END;

patientDS_Cleaned := PROJECT(rawPatientDS, CleanPatientData(LEFT));

patientDS := JOIN(rawPatientDS, patientDS_Cleaned, 
                            LEFT.PatientID=RIGHT.PatientID,
                            TRANSFORM(enhancedPaitentSchema, 
                                        SELF.PatientID := LEFT.PatientID, 
                                        SELF.FirstName := LEFT.FirstName,
                                        SELF.LastName := LEFT.LastName,
                                        SELF.City := RIGHT.City_Enhanced,
                                        SELF.State := RIGHT.State_Enhanced,
                                        SELF.ZipCode := LEFT.ZipCode,
                                        SELF.BirthDate := LEFT.BirthDate,
                                        SELF.Age := RIGHT.Age
                                        ) );

OUTPUT(patientDS);

hospitalSchema := RECORD
  Integer5 HospitalID,
  String60 HospitalName,
  String5 ZipCode,
  String60 City,
  String2 State,
END;

hospitalDS := DATASET  ([ {100, 'Emory', '30024', 'Suwanee', 'GA'},
                          {101, 'Northside', '30041', 'Cumming', 'GA'}, 
                          {102, 'Provena', '61820', 'Champaign', 'IL'},
                          {103, 'OSF', '61874', 'Peoria', 'IL'} 
                           ], hospitalSchema);
OUTPUT(hospitalDS); 

providerSchema := RECORD
  Integer5 ProviderID,
  String25 FirstName,
  String50 LastName,
  String30 City,
  String45 Specialization,
  Integer5 PrimaryHospitalID,
END;
  
providerDS := DATASET ([  {1001, 'Oliver', 'Tree', 'Alpharetta', 'Neurology', 100},
                          {1002, 'Ron', 'Owens', 'Cumming', 'Cardiology', 101},
                          {1003, 'Albert', 'Iorio', 'Champaign', 'Radiology', 102},
                          {1004, 'Stacey', 'Peacock', 'Peoria', 'Gastroenterology', 103}
                       ], providerSchema);
OUTPUT(providerDS);

patientVisitSchema := RECORD
  Integer5 PatientID,
  Integer5 ProviderID,
  String8 DateOfVisit,
  String125 ReasonOfVisit,
  String125 Diagnosis,
  String60 HospitalID,
END;
  
patientVisitDS := DATASET ([  {1, 1001,'05/05/22', 'Chronic Headache', 'Patient has mild MOH', 100},
                              {2, 1001, '01/09/22', 'Chronic Chest Pain', 'Patient has severe Costochondritis', 101},
                              {1, 1002, '03/04/22', 'Headache', 'Patient had lack of sleep', 100},
                              {1, 1001, '04/20/22', 'Fever', 'Patient had sorethroat', 100},                              
                              {3, 1001, '01/10/22', 'Flu', 'Seasonal Flu', 101},
                              {4, 1001, '01/10/22', 'Flu', 'Seasonal Flu', 101},
                              {5, 1001, '01/10/22', 'Melena', 'Seasonal Flu', 101},
                              {4, 1002, '11/11/22', 'Fever', 'Cold', 102},
                              {6, 1001, '01/01/22', 'Abdominal Pain', 'Calculus of bile duct without cholangitis or cholecystitis without obstruction', 101},
                              {7, 1003, '05/11/20', 'Hyperlipidemia', 'Anemia due to antineoplastic chemotherapy', 103},
                              {8, 1003, '07/16/21', 'Esophageal obstruction', 'Abnormal findings on diagnostic imaging of other parts of digestive tract', 103},
                              {8, 1004, '09/19/22', 'Duodenitis', 'Esophageal varices without bleeding', 102},
                              {9, 1004, '11/21/21', 'Obstruction of bile duct', 'Acute gastric ulcer without hemorrhage', 102},
                              {9, 1004, '10/31/20', 'Hematemesis', 'Ulcerative colitis', 103}
                              ], patientVisitSchema);

OUTPUT(patientVisitDS);

patientVisitInfo := JOIN(patientVisitDS, patientDS, 
                         LEFT.PatientID=RIGHT.PatientID);

// Output entire dataset                          
OUTPUT(patientVisitInfo);

// SORT functions 
patientVisitInfoSort1 := SORT(patientVisitInfo, ProviderID, LastName, FirstName);
patientVisitInfoSort2 := SORT(patientVisitInfo, City, LastName);

// Output select fields 
OUTPUT(patientVisitInfoSort1, {ProviderID, LastName, FirstName, City, DateOfVisit, ReasonOfVisit, PatientID});

OUTPUT(patientVisitInfoSort2, {ProviderID, LastName, FirstName, City, DateOfVisit, ReasonOfVisit, PatientID});

