/* 
    Learning outcome 
        TABLE, GROUP, MERGE   
*/
IMPORT STD;

file_scope := '~ECL_Learning';
project_scope := 'MedFiles';
in_files_scope := 'in';
out_files_scope := 'out';

file_name := file_scope + '::' + project_scope + '::' + out_files_scope + '::PatientMaster';

/*
        Make sure that the CSV file is sprayed into Thor utilizing {ECL Learning - Spray CSV to Thor.ecl}
*/

