
// ML_Core library practice  

/* 
    Learning outcome 
      Use of ML_Core library 
      Append SeqID to a dataset 
      Read from the dataset 
*/

/*
    Install GIT in the workstation where ECL IDE is present 

    Go to- https://gitforwindows.org/
    Download and Install 

    Verify the install with the following command 

    C:\Users\prabh>git version
    git version 2.36.1.windows.1

*/

/*
    ** IMPORTANT ** 
    Run the Windows PowerShell as Administrator (else the bundle will not install) 
    
    Install the ML Libraries from https://hpccsystems.com/download/free-modules/machine-learning-library#learningtrees

    cd "C:\Program Files (x86)\HPCCSystems\8.6.30\clienttools\bin"

    Verify ML_Core Install by typing the following command in the Command Prompt 

    C:\Users\prabh>ecl bundle info ML_Core
    Name:        ML_Core
    Version:     3.2.2
    Description: Common definitions for Machine Learning
    License:     See LICENSE.TXT
    Copyright:   Copyright (C) 2019 HPCC Systems
    Authors:     HPCCSystems
    Platform:    6.2.0
    ecl 'bundle' command error 0

    PS C:\Program Files (x86)\HPCCSystems\8.6.30\clienttools\bin> ecl bundle install https://github.com/hpcc-systems/GLM.git
    Installing bundle GLM version 3.0.1
    GLM requires PBblas, which cannot be loaded
    Specify --force to force installation of this bundle
    ecl 'bundle' command error 0

    PS C:\Program Files (x86)\HPCCSystems\8.6.30\clienttools\bin> ecl bundle install https://github.com/hpcc-systems/PBblas.git
    Installing bundle PBblas version 3.0.2
    PBblas        3.0.2      Parallel Block Basic Linear Algebra Subsystem
    Installation complete
    ecl 'bundle' command error 0
    PS C:\Program Files (x86)\HPCCSystems\8.6.30\clienttools\bin>

    PS C:\Program Files (x86)\HPCCSystems\8.6.30\clienttools\bin> ecl bundle install https://github.com/hpcc-systems/GNN.git
    Installing bundle GNN version 2.0
    GNN           2.0        Generalized Neural Network Bundle
    Installation complete
    ecl 'bundle' command error 0
*/

IMPORT ML_Core;
IMPORT ML_Core.Types as Types;

file_scope := '~ECL_Learning';
project_scope := 'MedFiles';
in_files_scope := 'in';

logicalMedFile := file_scope + '::' + project_scope + '::' + in_files_scope +  '::patientVisitInfo_S1';

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
patientVisitInfo := DATASET(logicalMedFile, patientVisitInfo_R1, THOR);
                   
OUTPUT(patientVisitInfo);

// Append SequenceID to the dataset using AppendSeqID from ML_Core 
// Output dataset is- patientVisitInfo_seq
ML_Core.AppendSeqID(patientVisitInfo, patientVisitID, patientVisitInfo_seq);      

OUTPUT(patientVisitInfo_seq);

OUTPUT(patientVisitInfo_seq(patientVisitID >= 5));

