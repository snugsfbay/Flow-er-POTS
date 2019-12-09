@istest
class TestSchedulerTest {

   @isTest
   static void testCron() {
       Integer startCount = [SELECT count() FROM CronTrigger]; 
       Test.startTest();
          
          // Schedule the test job
          String jobID = TestScheduler.initialize();
          CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                            FROM CronTrigger WHERE id = :jobId];
    
          // Verify the expressions are the same
          System.assertEquals(TestScheduler.DEFAULTCRON, ct.CronExpression);
    
          // Verify the job has not run
          System.assertEquals(0, ct.TimesTriggered);
        
       Test.stopTest();
       System.assertNotEquals(startCount, [SELECT count() FROM CronTrigger]);
   }
   
}