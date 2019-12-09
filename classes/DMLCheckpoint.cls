/*
    Because this is the code that users will access via Apex, PB and Lightning
        It is named for comprehension within PB and app builder.
        It controls functions related to calling the correct limits methods,
            Limits are grouped according to the class name.
            Context, type and step count are controlled by the LimitsObj.
            
*/
global class DMLCheckpoint implements  LimitsInterfaceAnnotated{ 
    Public static final String ROWS = 'DML Rows: ';
    Public static final String STMNTS = 'DML Statements: ';
    Public static final String LIMROWS = LimitsChecker.REMAINING + ' Rows: ';
    Public static final String LIMSTMNTS = LimitsChecker.REMAINING + ' Statements: ';

    Private static String thisType = LimitsChecker.LimitList.DML.name();
    Private static Integer stepCount = 0;
    Private static String thisContext = LimitsChecker.Context.APEX.name();


    @invocableMethod
    global static void iShowLimits(){
        thisContext = LimitsChecker.Context.FLOW.name() + '/PROCESS BUILDER';
        LimitsObj lim = new LimitsObj();        
        lim.showlimits();
    }    

    @AuraEnabled
    global static void aShowLimits(){
        thisContext = LimitsChecker.Context.LIGHTNING.name();
        LimitsObj lim = new LimitsObj();
        lim.showlimits();
    }   

    global static void showLimits(){
        thisContext = LimitsChecker.Context.APEX.name();
        limitsObj lim = new limitsObj();
        lim.showlimits();
    }
    
    /*
        inner class can have an AuraEnabled method, but how can I call it?
    */   
    public class LimitsObj extends LimitsChecker{
    
        // public variables from LimitsChecker that will be overridden
        public Integer stepContext;
        public String limitType;
        public String limitContext; 
          
        public override Map<String,Integer> getLimits(){ 
        
            //override or overshadow variables in parent class with values from this class.
            ((LimitsChecker) this).limitContext = thisContext;
            ((LimitsChecker) this).limitType = thisType;
            ((LimitsChecker) this).stepContext = ++stepCount; 
                       
            return new Map<String,Integer>{ ROWS => Limits.getDMLRows(), 
                                            STMNTS => Limits.getDMLStatements(),
                                            LIMROWS => Limits.getLimitDMLRows() - Limits.getDMLRows(),
                                            LIMSTMNTS => Limits.getLimitDMLStatements() - Limits.getDMLStatements()       
                                            };                                    
        }
    }
    
}