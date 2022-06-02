
/* My first ECL code */

Layout_Person := RECORD 
  UNSIGNED1 PersonID;
  STRING25 FirstName;
  STRING25 LastName;
  STRING25 State;
END;

myPeople  := DATASET( [  {1, 'Sarvesh', 'Prabhu', 'GA'},
                        {2, 'Nila', 'Prabhu', 'GA'},
                        {3, 'Dhiya', 'Prabhu', 'GA'},
                        {34, 'Arun', 'Kumar', 'IN'}
                      ], Layout_Person); 

results1 := myPeople(LastName = 'Prabhu');
results2 := myPeople(LastName = 'Johnson');
results3 := myPeople(State = 'IN');

OUTPUT(results1); 

OUTPUT(results2); 

OUTPUT(results3); 
