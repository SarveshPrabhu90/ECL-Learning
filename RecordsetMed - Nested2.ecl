/* Learning Outcomes: 
        Create Nested DATASET 
*/

addressSchema := {String25 AddressType,
  String30 City,
  String2 State,
  String5 ZipCode };
  
paitentSchema := RECORD
  Integer5 PatientID,
  String25 FirstName,
  String50 LastName,
  DATASET(addressSchema) Addresses,
  Integer8 BirthDate   //YYYYMMDD
END;

patientDS := DATASET ([  {1, 'Susan', 'Davis', [
                                                    {'Home', 'Cumming', 'GA', '30024'}, 
                                                    {'Work', 'Alpharetta', 'GA', '30024'},
                                                    {'Vcation', 'Palm Beach', 'FL', '33411'},
                                                    {'Investment', 'Champaign', 'IL', '61874'}
                                                ], 19710625},
                         {2, 'Chris', 'Evans', [
                                                    {'Home', 'New York', 'NY', '00024'}, 
                                                    {'Work', 'NewJersey', 'NJ', '30024'},
                                                    {'Vcation', 'Miami', 'FL', '33411'}
                                                ], 19790105}                                                
                          ], paitentSchema);

OUTPUT(patientDS);

