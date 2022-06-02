
// ML_Core GLM Practice   

/* 
    Learning outcome 
      Use of ML_Core library 
      Practice simple usage of GLM without observation weights 
*/

IMPORT ML_Core;
IMPORT ML_Core.Types as Types;
IMPORT GLM;
IMPORT GLM.Family;

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
                   
// Convert dataset to the standard NumericField format 
ML_Core.ToField(patientVisitInfo, patientVisitInfo_NF);
OUTPUT(patientVisitInfo_NF);

// Get predictor data
X_int := patientVisitInfo_NF(number <> 1);
X := PROJECT(X_int, TRANSFORM(
  Types.NumericField,
  SELF.number := LEFT.number - 1, SELF := LEFT));
  
// Get binomial response column
Y_int := patientVisitInfo_NF(number = 1);
Y_Binomial := PROJECT(Y_int, TRANSFORM(
  Types.NumericField,
  SELF.value := IF(LEFT.value < 0, 0.0, 1.0), SELF := LEFT));
 
BinomialSetup := GLM.GLM(X, Y_binomial, Family.Binomial);
BinomialMdl := BinomialSetup.GetModel();
BinomialPreds := BinomialSetup.Predict(X, BinomialMdl);
BinomialDeviance := GLM.Deviance_Detail(Y_Binomial, BinomialPreds, BinomialMdl, Family.Binomial);

OUTPUT(GLM.ExtractBeta_full(BinomialMdl), NAMED('Model'));
OUTPUT(BinomialPreds, NAMED('Preds'));
OUTPUT(BinomialDeviance, NAMED('Deviance'));


