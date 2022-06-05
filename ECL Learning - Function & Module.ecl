/* 
    Learning outcome 
        Function, Macro    
*/

STRING Function_Return_String(STRING128 medFileName) := FUNCTION
    RETURN medFileName + ' is a Thor file';
END;

OUTPUT(Function_Return_String('~ECL_Learning::MedFiles::in::patientVisitInfo_S2'), NAMED('Function_Result'));

/* Using MODULE structure to return multiple values from a FUNCTION */
IMPORT STD; 

GetGeneralStats() := FUNCTION
    result := MODULE
        EXPORT ESPUrl  := STD.File.GetEspUrl();
        EXPORT UniqueInteger := STD.System.Util.GetUniqueInteger();
        EXPORT HostName := STD.System.Util.GetHostName('127.0.0.1');
        EXPORT ResolvedHostName := STD.System.Util.ResolveHostName('localhost');
    END;

    RETURN result;
END;

GetGeneralStats().ESPUrl;
GetGeneralStats().UniqueInteger;
GetGeneralStats().HostName;
GetGeneralStats().ResolvedHostName;




