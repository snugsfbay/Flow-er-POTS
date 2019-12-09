global class ComputeCheckpoint implements  LimitsInterfaceAnnotated{ 
    Public static final String CPU = 'CPU Time: ';
    Public static final String HEAP = 'Heap: ';
    Public static final String LIMCPU = LimitsChecker.REMAINING + ' CPU Time: ';
    Public static final String LIMHEAP = LimitsChecker.REMAINING + ' Heap: ';
      
    Private static String thisType = LimitsChecker.LimitList.Compute.name();
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
                  
            return new Map<String,Integer>{ CPU => Limits.getCpuTime(), 
                                            HEAP => Limits.getHeapSize(),
                                            LIMCPU => Limits.getLimitCpuTime() - Limits.getCpuTime(),
                                            LIMHEAP => Limits.getLimitHeapSize() - Limits.getHeapSize()          
                                            };                                    
        }
    }
    
}