/* ECL Read from Thor File */

/* Learning Outcome: 
        Read from Thor File 
        Documemt as markdown in GitHub ReadMe.md
*/

patientVisitInfo_R1 := RECORD 
  integer5 PatientID,
  integer5 ProviderID,
  string8 DateofVisit,
  string125 ReasonofVisit,
  string125 Diagnosis,
  string60 Hospitalid,
  string25 FirstName,
  string50 LastName,
  string30 City,
  string2 State,
  string5 Zipcode
 END;
 
 //Read the contents of the file 
patientVisitInfo := DATASET('~ECL_Learning::MedFiles::in::patientVisitInfo_S1', patientVisitInfo_R1, THOR);
                   
OUTPUT(patientVisitInfo);
