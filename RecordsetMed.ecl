
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
  String30 City,
  String2 State,
  String5 ZipCode   
END;

patientDS := DATASET ([  {1, 'John', 'Britto', 'Suwanee', 'GA', '30024'},
                          {2, 'Jack', 'Rat', 'Cumming', 'GA', '30041'},
                          {3, 'Sam', 'Mentos', 'Alpharetta', 'GA', '30005'},
                          {4, 'Zach', 'Beacham', 'Johns Creek', 'GA', '30021'},
                          {5, 'Malcom', 'Marshall', 'Johns Creek', 'GA', '30021'},
                          {6, 'Mac', 'Beacham', 'Cumming', 'GA', '30041'}
                          ], paitentSchema);
                         
OUTPUT(patientDS);

hospitalSchema := RECORD
  Integer5 HospitalID,
  String60 HospitalName,
  String5 ZipCode,
  String60 City,
  String2 State,
END;

hospitalDS := DATASET  ([ {100, 'Emory', '30024', 'Suwanee', 'GA'},
                          {101, 'Northside', '30041', 'Cumming', 'GA'}  ], hospitalSchema);
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
                          {1002, 'Ron', 'Owens', 'Cumming', 'Cardiology', 101} ], providerSchema);
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
                              {5, 1001, '01/10/22', 'Flu', 'Seasonal Flu', 101},
                              {4, 1002, '11/11/22', 'Fever', 'Cold', 102},
                              {6, 1001, '01/01/22', 'Abdominal Pain', 'Ulcer', 101}
                              ], patientVisitSchema);

OUTPUT(patientVisitDS);

patientVisitInfo := JOIN(patientVisitDS, patientDS, 
                         LEFT.PatientID=RIGHT.PatientID);

// Output entire dataset                          
OUTPUT(patientVisitInfo);

// Output select fields 
//OUTPUT(patientVisitInfo, {ProviderID, PatientID, FirstName, LastName});

// SORT functions 
patientVisitInfoSort1 := SORT(patientVisitInfo, ProviderID, LastName, FirstName);
patientVisitInfoSort2 := SORT(patientVisitInfo, City, LastName);

// Output select fields 
OUTPUT(patientVisitInfoSort1, {ProviderID, LastName, FirstName, City, DateOfVisit, ReasonOfVisit, PatientID});

OUTPUT(patientVisitInfoSort2, {ProviderID, LastName, FirstName, City, DateOfVisit, ReasonOfVisit, PatientID});

