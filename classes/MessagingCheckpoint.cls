global class MessagingCheckpoint implements  LimitsInterfaceAnnotated{ 
    Public static final String MOBILE = 'Mobile Push Notifications: ';
    Public static final String EMAILMSG = 'Email: ';
    Public static final String LIMMOBILE = LimitsChecker.REMAINING + ' Mobile Push Notifications: ';
    Public static final String LIMEMAILMSG = LimitsChecker.REMAINING + ' Email: ';
      
    Private static String thisType = LimitsChecker.LimitList.Messaging.name();
    Private static Integer stepCount = 0;
    Private static String thisContext = LimitsChecker.Context.APEX.name();


    @invocableMethod
    global static void iShowLimits(){
        thisContext = LimitsChecker.Context.FLOW.name();
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
                  
            return new Map<String,Integer>{ MOBILE => Limits.getMobilePushApexCalls(), 
                                            EMAILMSG => Limits.getEmailInvocations(),
                                            LIMMOBILE => Limits.getLimitMobilePushApexCalls() - Limits.getMobilePushApexCalls(),
                                            LIMEMAILMSG => Limits.getLimitEmailInvocations() - Limits.getEmailInvocations()          
                                            };                                    
        }
    }
    
}