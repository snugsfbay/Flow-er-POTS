public class THMetadataCallback implements Metadata.DeployCallback {

    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            List<TestHarnessDeployed__e> thEventList = new List<TestHarnessDeployed__e>();
            for(Metadata.DeployMessage deployMessage : result.details.componentSuccesses) { 
                if (deployMessage.fullName == 'package.xml') continue;
                TestHarnessDeployed__e thdE = new TestHarnessDeployed__e();
                thdE.DeveloperName__c = deployMessage.fullName; 
                thdE.ID_of_Test_Harness__c = deployMessage.id;
                if (deployMessage.problem == null) {
                    thdE.Result_Message__c = deployMessage.fullName +' created';
                } else {
                    thdE.Result_Message__c = deployMessage.fullName +' '+ deployMessage.problem;
                }
                thEventList.add(thdE);
            }  
            
            List<Database.SaveResult> results = EventBus.publish(thEventList);        
            if (Test.isRunningTest()){ Test.getEventBus().deliver(); }
            
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) { // throw exception
                        System.debug('Error returned: ' +
                                    err.getStatusCode() +
                                    ' - ' +
                                    err.getMessage());
                    }
                }
            }             
            
        } else {
            //throw exception

        }

    }
    
    
}