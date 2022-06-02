/* ECL Read from Thor File, make a change, and despray to a CSV file */

/* Learning Outcome: 
        Read from a Thor File 
        Make changes 
        Write to a CSV file in Thor 
        Despray the CSV file in Thor to a CSV file in Landing zone
        Verify by downloading the CSV file from ECL Watch
*/

IMPORT STD;

file_scope := '~ECL_Learning';
project_scope := 'MedFiles';
in_files_scope := 'in';
out_files_scope := 'out';
        
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

logicalMedFile := file_scope + '::' + project_scope + '::' + in_files_scope +  '::patientVisitInfo_S2';
 
//Read the contents of the file 
patientVisitInfo := DATASET(logicalMedFile, patientVisitInfo_R1, THOR);

// Examine the output 
OUTPUT(patientVisitInfo);
           
//Sort the file by ProviderID, LastName, FirstName 
patientVisitInfoSort1 := SORT(patientVisitInfo, ProviderID, LastName, FirstName);

// Examine the output          
OUTPUT(patientVisitInfoSort1);

// Output to a CSV file in Thor 
medFilr_csv_file_path_Thor := file_scope + '::' + project_scope + '::' + out_files_scope +  '::patientVisitInfo_File_1.csv';

OUTPUT(patientVisitInfoSort1,,medFilr_csv_file_path_Thor,CSV,OVERWRITE);

// Despray to landing zone 
medFilr_csv_file_path_landingZone := 'C:\\hpccdata\\mydropzone\\patientVisitInfo_File_1.csv';

STD.File.DeSpray(medFilr_csv_file_path_Thor, '10.0.0.199', medFilr_csv_file_path_landingZone, allowoverwrite:=TRUE);
                
