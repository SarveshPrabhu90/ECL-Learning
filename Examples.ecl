
/*

STEP 1: Create some dummy data on disk

getEmployee := DATASET([{1, 'Mary', 'Peters'}, 
                        {2, 'John', 'Smith'}], 
                        {STRING1 id, STRING25 first, STRING25 last});


OUTPUT(getEmployee,,'~training-samples::in::employee', OVERWRITE); 
STEP 2: Read the same dataset twice and output (NOTE: Target should be Thor)

//Read the sample file twice
getEmployee1 := DATASET('~training-samples::in::employee', 
                   {STRING1 id, STRING25 first, STRING25 last}, THOR);

getEmployee2 := DATASET('~training-samples::in::employee', 
                   {STRING1 id, STRING25 first, STRING25 last}, THOR);

//Output the results of each of the reads
OUTPUT(getEmployee1);
OUTPUT(getEmployee2);


Function Example 

OUTPUT(softwareEmployees,,'~training-samples::in::software_employee', OVERWRITE); 
OUTPUT(salesEmployees,,'~training-samples::in::sales_employee', OVERWRITE); 
Since both files share the same structure, it would make sense to abstract the read to a common function:

DATASET getEmployee (STRING filePath) := FUNCTION 
  RETURN DATASET(filePath,  {STRING1 id, STRING25 first, STRING25 last}, THOR);
END;

OUTPUT(getEmployee('~training-samples::in::software_employee'));
OUTPUT(getEmployee('~training-samples::in::sales_employee'));

-- Module and file examples 
https://github.com/hpcc-systems/Solutions-ECL-Training/blob/master/docs/ECL_Programming_Structures.md

-- Read file and File attributes
https://github.com/hpcc-systems/Solutions-ECL-Training/blob/master/Taxi_Tutorial/README.md

*/
