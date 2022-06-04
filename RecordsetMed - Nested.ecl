/* Learning Outcomes: 
        Create Nested RECORD 
*/

addressSchema := RECORD
  String25 AddressType,
  String30 City,
  String2 State,
  String5 ZipCode
END;

paitentSchema := RECORD
  Integer5 PatientID,
  String25 FirstName,
  String50 LastName,
  addressSchema Addresses,
  Integer8 BirthDate   //YYYYMMDD
END;

patientDS := DATASET ([  {1, 'Susan', 'Davis', {'Home', 'Cumming', 'GA', '30024'}, 19710625}
                          ], paitentSchema);

OUTPUT(patientDS);


