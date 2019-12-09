global class ScheduledTests implements Schedulable {
    public List<Messaging.SendEmailResult> eResults;
    
    global void execute(SchedulableContext SC) {
        ID jid = TestUtil.enqueueTests();
        if(Test.isRunningTest()) eResults = TestUtil.sendTestResultEmail(jid, UserInfo.getUserEmail());
    }

   
}