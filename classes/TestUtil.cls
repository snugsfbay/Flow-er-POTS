global class TestUtil {

    public static ID enqueueTests() {    
        TestSuiteMembership[] testClassIDs = [SELECT ApexClassID 
                                   FROM TestSuiteMembership 
                                   ];
        system.debug(testClassIDs.size());
        system.debug(testClassIDs);

        if (testClassIDs.size() > 0) {
            ApexTestQueueItem[] queueItems = new List<ApexTestQueueItem>();
            for (TestSuiteMembership tsm :testClassIDs){
                queueItems.add(new ApexTestQueueItem(ApexClassID=tsm.ApexClassID));
            }

            if (!Test.isRunningTest()){                
                insert queueItems;

                // Get the job ID of the first queue item returned.
                ApexTestQueueItem item = 
                   [SELECT ParentJobId FROM ApexTestQueueItem 
                    WHERE Id=:queueItems[0].Id LIMIT 1];
                return item.parentjobid;
            }
        }
        return null;
    }

    @invocableMethod
    public static void enqueueHarness() {    
        ApexClass[] testClassIDs = [SELECT ID 
                                   FROM ApexClass
                                   WHERE Name = 'GenericTestData' 
                                   ];

        if (testClassIDs.size() > 0) {
            ApexTestQueueItem[] queueItems = new List<ApexTestQueueItem>();
            for (ApexClass ac:testClassIDs){
                queueItems.add(new ApexTestQueueItem(ApexClassID=ac.ID));
            }
            Test_Run_Info__c runinfo = new Test_Run_Info__c();
            
            if (!Test.isRunningTest()){                
                insert queueItems;

                // Get the job ID of the first queue item returned.
                ApexTestQueueItem item = 
                   [SELECT ParentJobId FROM ApexTestQueueItem 
                    WHERE Id=:queueItems[0].Id LIMIT 1];
                runinfo.job_ID__c = item.parentjobid;
                runinfo.Harness_Name__c = [SELECT RunTestHarness__c FROM TestRun__mdt WHERE DeveloperName = 'Now' LIMIT 1].RunTestHarness__c;
                runinfo.Name = runinfo.Harness_Name__c + runinfo.job_ID__c;
//                upsert runinfo;
//                return item.parentjobid;
            }else{
                runinfo.job_ID__c = queueItems[0].id;
            }
            runinfo.Harness_Name__c = [SELECT RunTestHarness__c FROM TestRun__mdt WHERE DeveloperName = 'Now' LIMIT 1].RunTestHarness__c;
            runinfo.Name = runinfo.Harness_Name__c + runinfo.job_ID__c;
            insert runinfo;
        }


//        return null;
    }

    // Get the status and pass rate for each class
    // whose tests were run by the job.
    // that correspond to the specified job ID.
    public static List<String> checkClassStatus(ID jobId) {
        List<String> msgs = new List<String>();
        ApexTestQueueItem[] items = 
           [SELECT ApexClass.Name, Status, ExtendedStatus 
            FROM ApexTestQueueItem 
            WHERE ParentJobId=:jobId];
        for (ApexTestQueueItem item : items) {
            String extStatus = item.extendedstatus == null ? '' : item.extendedStatus;
            msgs.add(item.ApexClass.Name + ': ' + item.Status + extStatus);
        }
        return msgs;
    }

    // Get the result for each test method that was executed.
    public static List<String> checkMethodStatus(ID jobId) {
        List<String> msgs = new List<String>();
        ApexTestResult[] results = 
           [SELECT Outcome, ApexClass.Name, MethodName, Message, StackTrace 
            FROM ApexTestResult 
            WHERE AsyncApexJobId=:jobId];
        for (ApexTestResult atr : results) {
            msgs.add(atr.ApexClass.Name + '.' + atr.MethodName + ': ' + atr.Outcome);
            if (atr.message != null) {
                msgs.add(atr.Message + '\n at ' + atr.StackTrace);
            }
        }
        return msgs;
    }

    
    public static List<Messaging.SendEmailResult> sendTestResultEmail(ID jobID, String emailme){ 
        List<String> jobTestResults = new List<String>();
        jobTestResults = checkClassStatus(jobID);
        jobTestResults.addAll(checkMethodStatus(jobID));
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                
        String[] toAddresses = new String[] { emailme };    
        mail.setToAddresses(toAddresses);        
        String emailSubject = 'Integration Test Results ' + String.valueOf(Date.today());     
        mail.setSubject(emailSubject);
        String testResultEmailbody = '';
        for (String s :jobTestResults){
            testResultEmailbody = testResultEmailbody + s;
        }
        mail.setHtmlBody(testResultEmailbody);
        return Messaging.sendEmail(new Messaging.Email[] { mail });        
    }
    
}