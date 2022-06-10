/*
    Gradient Boosted Tree Regression
*/
  
IMPORT STD;
IMPORT $.^ AS LT;
IMPORT LT.LT_Types;
IMPORT ML_Core;
IMPORT ML_Core.Types;

#OPTION('outputLimit', 100);

file_scope := '~Sarvesh';
project_scope := 'MedFiles';
in_files_scope := 'in';
out_files_scope := 'out';

file_csv := file_scope + '::' + project_scope + '::' + in_files_scope + '::Sarvesh_Densenet161_split_0_inference_CSV';

/* Spray a CSV file from the landing zone to Thor */

/*
STD.File.SprayDelimited('university.us-hpccsystems-dev.azure.lnrsg.io',
       '/var/lib/HPCCSystems/mydropzone/Sarvesh_Densenet161_split_0_inference.csv',
       ,,,,
       'Data', 
       file_name,
       -1,
       ,,allowOverwrite := TRUE,
       replicate := FALSE,
       compress := TRUE
       );
*/

/* Label Ilustration 

    ID	Label
    0	barretts
    1	bbps-0-1
    2	bbps-2-3
    3	dyed-lifted-polyps
    4	dyed-resection-margins
    5	hemorrhoids
    6	ileum
    7	impacted-stool
    8	normal-cecum
    9	normal-pylorus
    10	normal-z-line
    11	oesophagitis-a
    12	oesophagitis-b-d
    13	polyp
    14	retroflex-rectum
    15	retroflex-stomach
    16	short-segment-barretts
    17	ulcerative-colitis-0-1
    18	ulcerative-colitis-1-2
    19	ulcerative-colitis-2-3
    20	ulcerative-colitis-grade-1
    21	ulcerative-colitis-grade-2
    22	ulcerative-colitis-grade-3
*/
 
/* Record Set for medical images - Densenet161_split_0 and 1 */ 
DenseNet161_Record := RECORD
    UNSIGNED8 id;
    STRING128 ImageId;
    UNSIGNED8 Label;
    REAL A;
    REAL B;
    REAL C;
    REAL D;
    REAL E;
    REAL F;
    REAL G;
    REAL H;
    REAL I;
    REAL J;
    REAL K;
    REAL L;
    REAL M;
    REAL N;
    REAL O;
    REAL P;
    REAL Q;
    REAL R;
    REAL S;
    REAL T;
    REAL U;
    REAL V;
    REAL W;
END;

//Read the contents of the file 
trainRecs_All := DATASET(file_csv, DenseNet161_Record, CSV(HEADING(1)));

// Prepare Training dataset 
trainDat := trainRecs_All(id <= 1000);

// Prepare Test dataset 
testDat := trainRecs_All(ID > 1000, ID <= 2500);

ctRec := DenseNet161_Record;
INTEGER8 numCols := 26;
SET OF UNSIGNED nominalFields := [11, 52];

maxLevels := 255;
forestSize := 10;  // Zero indicates auto choice
// 5, 7, 12, 20

maxTreeDepth := 255;
//earlyStopThreshold := 0.0;

earlyStopThreshold := 0.0001;
// .1, .25, .5, .75, 1

learningRate := 1;
numFeatures := 0; // Zero is automatic choice
nonSequentialIds := FALSE; // True to renumber ids, numbers and work-items to test
                            // support for non-sequentiality
numWIs := 1;    // The number of independent work-items to create
maxRecs := 500; // Note that this has to be less than or equal to the number of records
                // in CovTypeDS (currently 5000)

t_Discrete := Types.t_Discrete;
t_FieldReal := Types.t_FieldReal;
DiscreteField := Types.DiscreteField;
NumericField := Types.NumericField;
GenField := LT_Types.GenField;
BfTreeNodeDat := LT_Types.BfTreeNodeDat;

ML_Core.ToField(trainDat, trainNF);
ML_Core.ToField(testDat, testNF);

OUTPUT(trainNF, NAMED('trainNF'));
OUTPUT(testNF, NAMED('testNF'));

// Take out the first field from training set (Elevation) to use as the target value.  Re-number the other fields
// to fill the gap

X0 := PROJECT(trainNF(number != 1 AND id <= maxRecs), TRANSFORM(GenField,
        SELF.isOrdinal := FALSE,
        SELF.number := IF(nonSequentialIds, (5*LEFT.number -1), LEFT.number -1),
        SELF.id := IF(nonSequentialIds, 5*LEFT.id, LEFT.id),
        SELF := LEFT));
        
OUTPUT(X0, NAMED('X0'));

Y0 := PROJECT(trainNF(number = 1 AND id <= maxRecs), TRANSFORM(GenField,
        SELF.isOrdinal := FALSE,
        SELF.number := 1,
        SELF.id := IF(nonSequentialIds, 5*LEFT.id, LEFT.id),
        SELF := LEFT));

OUTPUT(Y0, NAMED('Y0'));
        
// Generate multiple work items
X := NORMALIZE(X0, numWIs, TRANSFORM(RECORDOF(LEFT),
          SELF.wi := IF(nonSequentialIds, 5*COUNTER, COUNTER),
          SELF := LEFT));

OUTPUT(X, NAMED('X'));
          
Y := NORMALIZE(Y0, numWIs, TRANSFORM(RECORDOF(LEFT),
          SELF.wi := IF(nonSequentialIds, 5*COUNTER, COUNTER),
          SELF := LEFT));

OUTPUT(Y, NAMED('Y'));

// Fixup IDs of nominal fields to match
nomFields := [10,51];  

card0 := SORT(X, number, value);
card1 := TABLE(card0, {number, value, valCnt := COUNT(GROUP)}, number, value);
card2 := TABLE(card1, {number, featureVals := COUNT(GROUP)}, number);
card := TABLE(card2, {cardinality := SUM(GROUP, featureVals)}, ALL);

OUTPUT(card1, NAMED('card1'));
OUTPUT(card2, NAMED('card2'));
OUTPUT(card, NAMED('card'));

X_nom := PROJECT(X, TRANSFORM(RECORDOF(LEFT),
                      SELF.isOrdinal := IF(LEFT.number in nomFields, FALSE, TRUE),
                      SELF := LEFT), LOCAL);

OUTPUT(X_nom, NAMED('X_nom'));
                      
F := LT.internal.BF_Regression(X_nom, Y, maxLevels:=maxLevels, forestSize:=forestSize,
                                maxTreeDepth:=maxTreeDepth,
                                earlyStopThreshold := earlyStopThreshold,
                                learningRate := learningRate);

                              
nodes0 := F.GetNodes : PERSIST('Sarvesh::BoostedForest_DenseNet_Split_0::out::Nodes', SINGLE, REFRESH(TRUE));

OUTPUT(nodes0, NAMED('Nodes0'));

nodes := DATASET('Sarvesh::Temp::Nodes', BfTreeNodeDat, THOR);

nodes1 := SORT(DISTRIBUTE(nodes, HASH32(wi, treeId)), wi, bfLevel, treeId, level, nodeId, LOCAL);
mod := F.Nodes2Model(nodes1);
OUTPUT(SORT(mod[..3000], wi, indexes), ALL, NAMED('Model'));

nodes2 := SORT(DISTRIBUTE(F.Model2Nodes(mod), HASH32(wi, treeId)), wi, bfLevel, treeId, level, nodeId, LOCAL);

cmp := JOIN(nodes1, nodes2, LEFT.wi = RIGHT.wi AND LEFT.bfLevel = RIGHT.bfLevel AND
                     LEFT.treeId = RIGHT.treeId AND LEFT.level = RIGHT.level AND
                     LEFT.nodeId = RIGHT.nodeId,
              TRANSFORM({nodes1, UNSIGNED err}, SELF.err := IF(LEFT.number != RIGHT.number OR
                                                          LEFT.bfLevel != RIGHT.bfLevel OR
                                                          LEFT.value != RIGHT.value OR
                                                          LEFT.isLeft != RIGHT.isLeft OR
                                                          LEFT.parentId != RIGHT.parentId OR
                                                          LEFT.isOrdinal != RIGHT.isOrdinal OR
                                                          LEFT.support != RIGHT.support OR
                                                          LEFT.depend != RIGHT.depend,
                                                          1, 0),
                                                 SELF := LEFT), FULL OUTER, LOCAL);

cmp2 := JOIN(nodes1, nodes2, LEFT.wi = RIGHT.wi AND LEFT.bfLevel = RIGHT.bfLevel AND
                     LEFT.treeId = RIGHT.treeId AND LEFT.level = RIGHT.level AND
                     LEFT.nodeId = RIGHT.nodeId,
              TRANSFORM({nodes1, UNSIGNED err}, SELF.err := IF(LEFT.number != RIGHT.number OR
                                                          LEFT.bfLevel != RIGHT.bfLevel OR
                                                          LEFT.value != RIGHT.value OR
                                                          LEFT.isLeft != RIGHT.isLeft OR
                                                          LEFT.parentId != RIGHT.parentId OR
                                                          LEFT.isOrdinal != RIGHT.isOrdinal OR
                                                          LEFT.support != RIGHT.support OR
                                                          LEFT.depend != RIGHT.depend,
                                                          1, 0),
                                                 SELF := RIGHT), FULL OUTER, LOCAL);
                                                 
OUTPUT(SORT(cmp(err>0), wi, bfLevel, treeId, level, nodeId, LOCAL), {err, wi, bfLevel, treeId, level, nodeId, parentId, isLeft, number, value, depend, support, isOrdinal, id}, NAMED('Compare1'));
OUTPUT(SORT(cmp2(err>0), wi, bfLevel, treeId, level, nodeId, LOCAL), {err, wi, bfLevel, treeId, level, nodeId, parentId, isLeft, number, value, depend, support, isOrdinal, id}, NAMED('Compare2'));
OUTPUT(SORT(nodes1, wi, bfLevel, treeId, level, nodeId, LOCAL), {wi, bfLevel, treeId, level, nodeId, parentId, isLeft, number, value, depend, support, isOrdinal, id}, ALL, NAMED('InitialNodes'));
OUTPUT(SORT(nodes2, wi, bfLevel, treeId, level, nodeId, LOCAL), {wi, bfLevel, treeId, level, nodeId, parentId, isLeft, number, value, depend, support, isOrdinal, id}, ALL, NAMED('FinalNodes'));

nodes1cnt := COUNT(nodes1);
nodes2cnt := COUNT(nodes2);

modCnt := COUNT(mod);
OUTPUT(modCnt, NAMED('ModelRecs'));

errCnt := SUM(cmp, err);
zerCnt := COUNT(nodes2(wi=0));
summary := DATASET([{nodes1cnt, nodes2cnt, errCnt, zerCnt}], {UNSIGNED nodes1cnt, UNSIGNED nodes2cnt, UNSIGNED errCnt, UNSIGNED zerCnt});

OUTPUT(summary, NAMED('Summary'));

OUTPUT(nodes(treeId=1), ALL, NAMED('NodesTree1'));
