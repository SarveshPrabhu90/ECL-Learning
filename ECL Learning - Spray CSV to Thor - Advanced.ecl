/* 
    Learning outcome 
        Spray a CSV file from the landing zone to Thor 
        Learn PARALLEL, INDEPENDENT, SEQUENTIAL, SprayDelimited, DISTRIBUTE
*/

IMPORT STD;

/* Function declarations */

GetThorFileStats(VARSTRING medFileName) := FUNCTION
    result := MODULE
        EXPORT Size := STD.File.GetLogicalFileAttribute(medFileName,'size');
        EXPORT RecordCount := STD.File.GetLogicalFileAttribute(medFileName,'recordCount');
        EXPORT RecordSize := STD.File.GetLogicalFileAttribute(medFileName,'recordSize');
        EXPORT CompressedSize := STD.File.GetLogicalFileAttribute(medFileName,'compressedSize');
    END;

    RETURN result;
END;

/* Spray File Practice - Advanced - using PARALLEL, INDEPENDENT, SEQUENTIAL */

file_scope := '~ECL_Learning';
project_scope := 'MedFiles';
in_files_scope := 'in';
out_files_scope := 'out';

fileToSpray := '/var/lib/HPCCSystems/mydropzone/CustomerMockData.csv';

thorCSVFile := file_scope + '::' + project_scope + '::' + in_files_scope + '::PatientMaster_CSV';
logicalPatientFile := file_scope + '::' + project_scope + '::' + in_files_scope + '::PatientMaster';

DeleteOldFiles :=
    PARALLEL(
                IF( STD.File.FileExists(thorCSVFile), STD.File.DeleteLogicalFile(thorCSVFile) );
                IF( STD.File.FileExists(logicalPatientFile), STD.File.DeleteLogicalFile(logicalPatientFile) );
            ) : INDEPENDENT;

SprayNewFile  :=
    PARALLEL(
                /*
                        data -- Destination Group in the Cluster 
                        -1   -- Default for  
                */

                STD.File.SprayDelimited('127.0.0.1',
                    fileToSpray,
                    ,,,,
                    'data', 
                    thorCSVFile,
                    -1,
                    ,,allowOverwrite := FALSE,
                    replicate := FALSE,
                    compress := TRUE
                    );
            ) : INDEPENDENT;

SEQUENTIAL(DeleteOldFiles,SprayNewFile);

OUTPUT(STD.File.VerifyFile(thorCSVFile, TRUE), NAMED('FileExists'));
OUTPUT(GetThorFileStats(thorCSVFile).Size, NAMED('FileSizeBytes'));
OUTPUT(GetThorFileStats(thorCSVFile).RecordCount, NAMED('RecordCount'));
OUTPUT(GetThorFileStats(thorCSVFile).RecordSize, NAMED('RecordSizeBytes'));
OUTPUT(GetThorFileStats(thorCSVFile).CompressedSize, NAMED('CompressedSizeBytes'));

// Define an ECL RECORD to read the CSV file  
patientInfoRawSchema := RECORD 
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
patientDSRaw := DATASET(thorCSVFile, patientInfoRawSchema, CSV(HEADING(1)));
                   
DISTRIBUTE(patientDSRaw);

// Define an ECL RECORD to Transform 
// Add UniqueID and DateAdded to each row in the file 
// Ref: INTEGER datatype sizes - https://hpccsystems.com/training/documentation/ecl-language-reference/html/INTEGER.html

patientSchema := RECORD 
    UNSIGNED8 UniqueID;
    INTEGER8 DateAdded;
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

patientSchema TransformPatientData(patientDSRaw patients) := TRANSFORM
    SELF.UniqueID := STD.System.Util.GetUniqueInteger();
    SELF.DateAdded := STD.Date.CurrentDate(True);

    SELF.Gender := STD.Str.ToUpperCase(patients.Gender); 
    SELF.State := STD.Str.ToUpperCase(patients.State); 
    SELF.CC_Type := STD.Str.ToUpperCase(patients.CC_Type);
  
    SELF.ID := patients.ID;
    
    SELF := patients; 
END;

patientDS_Cleaned := PROJECT(patientDSRaw, TransformPatientData(LEFT));

// Write to a Compressed Thor File
OUTPUT(patientDS_Cleaned,,logicalPatientFile, THOR, COMPRESSED, OVERWRITE); 
