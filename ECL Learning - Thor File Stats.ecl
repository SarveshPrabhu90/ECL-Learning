/* 
    Learning outcome 
    Learning File Statistics  
*/

IMPORT STD; 

// Using MODULE structure to return multiple values from a FUNCTION

GetThorFileStats(VARSTRING medFileName) := FUNCTION
    result := MODULE
        EXPORT RecordSize := STD.File.GetLogicalFileAttribute(medFileName,'recordSize');
        EXPORT RecordCount := STD.File.GetLogicalFileAttribute(medFileName,'recordCount');
        EXPORT Size := STD.File.GetLogicalFileAttribute(medFileName,'size');
        EXPORT ClusterName := STD.File.GetLogicalFileAttribute(medFileName,'clusterName');
        EXPORT Directory := STD.File.GetLogicalFileAttribute(medFileName,'directory');
        EXPORT Numparts := STD.File.GetLogicalFileAttribute(medFileName,'numparts');
        EXPORT Owner := STD.File.GetLogicalFileAttribute(medFileName,'owner');
        EXPORT Description := STD.File.GetLogicalFileAttribute(medFileName,'description');
        EXPORT ECL := STD.File.GetLogicalFileAttribute(medFileName,'ECL');
        EXPORT Partmask := STD.File.GetLogicalFileAttribute(medFileName,'partmask');
        EXPORT Name := STD.File.GetLogicalFileAttribute(medFileName,'name');
        EXPORT Modified := STD.File.GetLogicalFileAttribute(medFileName,'modified');
        EXPORT Protected := STD.File.GetLogicalFileAttribute(medFileName,'protected');
        EXPORT Format := STD.File.GetLogicalFileAttribute(medFileName,'format');
        EXPORT Job := STD.File.GetLogicalFileAttribute(medFileName,'job');
        EXPORT CheckSum := STD.File.GetLogicalFileAttribute(medFileName,'checkSum');
        EXPORT Kind := STD.File.GetLogicalFileAttribute(medFileName,'kind');
        EXPORT CsvSeparate := STD.File.GetLogicalFileAttribute(medFileName,'csvSeparate');
        EXPORT CsvTerminate := STD.File.GetLogicalFileAttribute(medFileName,'csvTerminate');
        EXPORT CsvEscape := STD.File.GetLogicalFileAttribute(medFileName,'csvEscape');
        EXPORT HeaderLength := STD.File.GetLogicalFileAttribute(medFileName,'headerLength');
        EXPORT FooterLength := STD.File.GetLogicalFileAttribute(medFileName,'footerLength');
        EXPORT Rowtag := STD.File.GetLogicalFileAttribute(medFileName,'rowtag');
        EXPORT Workunit := STD.File.GetLogicalFileAttribute(medFileName,'workunit');
        EXPORT Accessed := STD.File.GetLogicalFileAttribute(medFileName,'accessed');
        EXPORT ExpireDays := STD.File.GetLogicalFileAttribute(medFileName,'expireDays');
        EXPORT MaxRecordSize := STD.File.GetLogicalFileAttribute(medFileName,'maxRecordSize');
        EXPORT CsvQuote := STD.File.GetLogicalFileAttribute(medFileName,'csvQuote');
        EXPORT BlockCompressed := STD.File.GetLogicalFileAttribute(medFileName,'blockCompressed');
        EXPORT CompressedSize := STD.File.GetLogicalFileAttribute(medFileName,'compressedSize');
        EXPORT FileCrc := STD.File.GetLogicalFileAttribute(medFileName,'fileCrc');
        EXPORT FormatCrc := STD.File.GetLogicalFileAttribute(medFileName,'formatCrc');
    END;

    RETURN result;
END;

file_scope := '~ECL_Learning';
project_scope := 'MedFiles';
in_files_scope := 'in';
out_files_scope := 'out';

// medFileName is a Thor File 
medFileName := file_scope + '::' + project_scope + '::' + in_files_scope +  '::patientVisitInfo_S1';

/*
    // medFileName is a CSV file in Thor 
    medFileName := file_scope + '::' + project_scope + '::' + out_files_scope +  '::patientVisitInfo_File_1.csv';
*/

// Named OUTPUT
OUTPUT(GetThorFileStats(medFileName).ClusterName, NAMED('ClusterName'));

// Or, simply return the VarString output - it's flexible   
GetThorFileStats(medFileName).Workunit;
GetThorFileStats(medFileName).ECL;
GetThorFileStats(medFileName).Format; 

GetThorFileStats(medFileName).RecordCount;
GetThorFileStats(medFileName).RecordSize;
GetThorFileStats(medFileName).MaxRecordSize;
GetThorFileStats(medFileName).CompressedSize;

medFileName2 := file_scope + '::' + project_scope + '::' + in_files_scope +  '::patientVisitInfo_S2';

/*   
    Verifies the file in DALI
    A boolean TRUE/FALSE flag indicating that, when TRUE, compares physical CRCs of all the parts on disk. This may be slow on large files.

    OK                          The file parts match the datastore information
    Could not find file:        filename The logical filename was not found
    Could not find part file:   partname The partname was not found
    Modified time differs for:  partname The partname has a different timestamp
    File size differs for:      partname The partname has a file size
    File CRC differs for:       partname The partname has a different CRC

*/

STD.File.VerifyFile(medFileName, TRUE);

STD.File.VerifyFile(medFileName2, FALSE);

/*
    Compare Files  

    0   file1 and file2 match exactly
    1   file1 and file2 contents match, but file1 is newer than file2
    -1  file1 and file2 contents match, but file2 is newer than file1
    2   file1 and file2 contents do not match and file1 is newer than file2
    -2  file1 and file2 contents do not match and file2 is newer than file1    
*/

compareResults := STD.File.CompareFiles(medFileName, medFileName2);

MAP(    compareResults = 0 => OUTPUT('File ' + medFileName + ' and File ' + medFileName2 + ' are matched exactly '),
        compareResults = 1 => OUTPUT('File contents match, but ' + medFileName + ' is newer than ' + medFileName2),
        compareResults = -1 => OUTPUT('File contents match, but ' + medFileName2 + ' is newer than ' + medFileName),
        compareResults = 2 => OUTPUT('File contents do not match, but ' + medFileName + ' is newer than ' + medFileName2),
        compareResults = -2 => OUTPUT('File contents match, but ' + medFileName2 + ' is newer than ' + medFileName),
        OUTPUT('FileCompare returned an unexpected value of ' + compareResults)
    );

/* // For Reference Only - No need to define it 

EXPORT FsLogicalFileNameRecord := RECORD
    STRING name;
END;

EXPORT FsLogicalFileInfoRecord := RECORD(FsLogicalFileNameRecord)
    BOOLEAN superfile;
    UNSIGNED8 size;
    UNSIGNED8 rowcount;
    STRING19 modified;
    STRING owner;
    STRING cluster;
END;

*/

// Returns all normal files
OUTPUT(STD.File.LogicalFileList(), NAMED('LogicalFilesList'));

OUTPUT(COUNT(STD.File.LogicalFileList()), NAMED('LogicalFilesListCount'));

IF( COUNT(STD.File.LogicalFileList()) > 4, 
        OUTPUT(('More than 1 file present'), NAMED('LogicalFilesCount'), OVERWRITE), 
        OUTPUT(('Need to work hard'), NAMED('LogicalFilesCount'), OVERWRITE)
        );

// Returns all SuperFiles
OUTPUT(STD.File.LogicalFileList(,FALSE,TRUE), NAMED('SuperFilesList'));

logicalFileCount := COUNT(STD.File.LogicalFileList());
superFileCount := COUNT((STD.File.LogicalFileList(,FALSE,TRUE)));

totalThorFiles := SUM(logicalFileCount, superFileCount);

OUTPUT(totalThorFiles, NAMED('Total_Thor_Files'));

OUTPUT(MIN(logicalFileCount, superFileCount), NAMED('Min_Of_a_Set'));

OUTPUT(MAX(logicalFileCount, superFileCount), NAMED('Max_Of_a_Set'));

OUTPUT(AVE(logicalFileCount, superFileCount), NAMED('Average_Of_a_Set'));
