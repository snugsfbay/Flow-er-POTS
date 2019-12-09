global class DML extends LimitsCheckerAnnotated{ 
    Public static final String ROWS = 'DML Rows: ';
    Public static final String STMNTS = 'DML Statements: ';
    Public static final String LIMROWS = LimitsChecker.REMAINING + ' Rows: ';
    Public static final String LIMSTMNTS = LimitsChecker.REMAINING + ' Statements: ';
/*
    @invocableMethod  
    global static void iShowLimits(){super.iShowLimits();}
    @AuraEnabled
    global void aShowLimits(){super.aShowLimits();}
    
    See problems noted in the abstract class regarding static methods.
*/    
    /*
        inner class can have an AuraEnabled method, but how can I call it?
    */   
    public class LimitsObj extends LimitsChecker{
//        @AuraEnabled   
        public override Map<String,Integer> getLimits(){        
            return new Map<String,Integer>{ ROWS => Limits.getDMLRows(), 
                                            STMNTS => Limits.getDMLStatements(),
                                            LIMROWS => Limits.getLimitDMLRows() - Limits.getDMLRows(),
                                            LIMSTMNTS => Limits.getLimitDMLStatements() - Limits.getDMLStatements()       
                                            };                                    
        }
    }
    
}