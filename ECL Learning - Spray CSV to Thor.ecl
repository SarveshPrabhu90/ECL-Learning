/* 
    Learning outcome 
        Spray a CSV file from the landing zone to Thor 
*/

IMPORT STD;

file_scope := '~ECL_Learning';
project_scope := 'MedFiles';
in_files_scope := 'in';
out_files_scope := 'out';

/*
        Ref: https://hpccsystems.com/training/documentation/standard-library-reference/html/SprayVariable.html

        data -- Destination Group in the Cluster 
        -1   -- Default for timeout 
*/

file_name := file_scope + '::' + project_scope + '::' + in_files_scope + '::PatientMasterFile';

STD.File.SprayDelimited('127.0.0.1',
       '/var/lib/HPCCSystems/mydropzone/CustomerMockData.csv',
       ,,,,
       'data', 
       file_name,
       -1,
       ,,allowOverwrite := TRUE,
       replicate := FALSE,
       compress := TRUE
       );

GetThorFileStats(VARSTRING medFileName) := FUNCTION
    result := MODULE
        EXPORT Size := STD.File.GetLogicalFileAttribute(medFileName,'size');
        EXPORT RecordCount := STD.File.GetLogicalFileAttribute(medFileName,'recordCount');
        EXPORT RecordSize := STD.File.GetLogicalFileAttribute(medFileName,'recordSize');
        EXPORT CompressedSize := STD.File.GetLogicalFileAttribute(medFileName,'compressedSize');
    END;

    RETURN result;
END;

GetThorFileStats(file_name).Size;
GetThorFileStats(file_name).RecordCount;
GetThorFileStats(file_name).RecordSize;
GetThorFileStats(file_name).CompressedSize;

STD.File.VerifyFile(file_name, TRUE);

// Define an ECL RECORD to read the CSV file  
patientInfoSchema := RECORD 
    STRING20 ID;
    STRING1 Gender;
    STRING10 Birthdate;
    STRING30 Maiden_name;
    STRING50 LastName;
    STRING30 FirstName;
    STRING100 Street;
    STRING30 City;
    STRING2 State;
    STRING10 Zip;
    STRING20 Phone;
    STRING50 Email;
    STRING40 CC_Type;
    STRING50 CC_Number;
    STRING10 CC_Cvc;
    STRING10 CC_Expiry;
END;

// Read the contents of the file 
// CSV(HEADING(1) -- indicates first row is a header 
patientInfo := DATASET(file_name, patientInfoSchema, CSV(HEADING(1)));
                   
OUTPUT(patientInfo, NAMED('PatientData'));

DISTRIBUTE(patientInfo);

// Write to a Compressed Thor File
patient_file_name := file_scope + '::' + project_scope + '::' + in_files_scope + '::PatientMaster';

OUTPUT(patientInfo,,patient_file_name, THOR, COMPRESSED, OVERWRITE); 


// Add UniqueID and DateAdded to each row in the file 

// EXPORT UniqueInteger := STD.System.Util.GetUniqueInteger();

// Define an ECL RECORD to read the CSV file  
patientSchema := RECORD 
    
    STRING20 ID;
    STRING1 Gender;
    STRING10 Birthdate;
    STRING30 Maiden_name;
    STRING50 LastName;
    STRING30 FirstName;
    STRING100 Street;
    STRING30 City;
    STRING2 State;
    STRING10 Zip;
    STRING20 Phone;
    STRING50 Email;
    STRING40 CC_Type;
    STRING50 CC_Number;
    STRING10 CC_Cvc;
    STRING10 CC_Expiry;
END;

