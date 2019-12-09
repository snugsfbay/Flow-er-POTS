global class TestScheduler {

   public static final String DEFAULTCRON = '0 15 19 * * ?';
   public static final String DEFAULTJOB = 'Initial Nightly Test Run';
   public static final String TESTING = ' TEST';
    
   public static ID initialize(){
       String jname = DEFAULTJOB;
       if (Test.isRunningTest()) jname = jname + TESTING;
       String jobID = setTime(DEFAULTCRON, DEFAULTJOB);
       return jobID;       
   }
    
    global static ID setTime(String sched, String jname){
       scheduledTests st = new scheduledTests();
       String jobID = system.schedule(jname, sched, st);
       return jobID;               
    }

}