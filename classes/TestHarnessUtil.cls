public class TestHarnessUtil{

    @InvocableMethod(label='Create MetaData' description='Pass name and description for Metadata from Flow -- perform async deployment.')
    public static List<FlowOutputs> service(List<FlowInputs> inputValues){
        TestHarness__mdt newHarness = new TestHarness__mdt();
        if (inputValues.size() == 0 || String.isBlank(inputValues[0].name)){
            inputValues[0].name = 'Default Value, Please Change';
        }
        newHarness.label = inputValues[0].name;
        newHarness.developerName = inputValues[0].name.replaceAll('[^a-zA-Z0-9]',''); // dev name limited to alphanumeric
        // dev name can't start with digit
        newHarness.developerName = newHarness.developerName.left(1).replaceAll('[0-9]','X')+newHarness.developerName.substring(1); 
 
        newHarness.description__c = inputValues[0].description;
        
        // https://ashwanisoni.wordpress.com/2017/05/02/create-or-update-custom-metadata-type-via-apex-code-salesforce-summer-17/
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_interface_Metadata_DeployCallback.htm#apex_interface_Metadata_DeployCallback
        // https://developer.salesforce.com/docs/atlas.en-us.216.0.salesforce_vpm_guide.meta/salesforce_vpm_guide/vpm_designer_example_wait_platformevent.htm
        // Set up custom metadata to be created in the subscriber org.
        Integer count = [Select count() FROM TestHarness__mdt WHERE developerName LIKE :newHarness.developerName+'V%'];  // computed dev name and V for version...
        Integer maxNameLen = maxLength(count);
        newHarness.developerName = newHarness.developerName.left(maxNameLen);
        String fullname = 'TestHarness.' + newHarness.developerName.left(maxNameLen) + 'V' + (count+1); //Version is count incremented
        Metadata.CustomMetadata customMetadata = populateContainer(newHarness, fullname);
        FlowOutputs fo = new FlowOutputs();
        fo.developerName = customMetadata.fullName; // pass this back to Flow for use later.
   
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);
    
        // Setup deploy callback, MyDeployCallback implements the Metadata.DeployCallback interface 
        THMetadataCallback callback = new THMetadataCallback();
    
        // Enqueue custom metadata deployment
        // jobId is the deployment ID
        if (!Test.isRunningTest()){          
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
        }
        // create a platform event for success or failure and have flow listen for event
        // https://developer.salesforce.com/docs/atlas.en-us.216.0.salesforce_vpm_guide.meta/salesforce_vpm_guide/vpm_designer_example_wait_platformevent.htm
        List<FlowOutputs> devNameList = new List<FlowOutputs>{fo};
        return devNameList;
    } 

    @TestVisible
    private static Metadata.CustomMetadata populateContainer(TestHarness__mdt newHarness, String fullname){
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = fullname;
        customMetadata.label = newHarness.label;
    
        Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
        customField.field = 'Description__c';
        customField.value = newHarness.description__c;
    
        customMetadata.values.add(customField);
		return customMetadata;        
    }
    
    @TestVisible
    private static Integer maxLength(Integer count){
        Decimal d = count/10;        
        Integer maxNameLen = 39;  // truncate name to less than 40 characters and add to that name V for version and some version number.   
        if (d<1){
            maxNameLen--;
        } else if (d<3) {
            maxNameLen-=2;
        } else if (d>2) {
            maxNameLen-=3;
        }
		return maxNameLen;        
    }
    
    public class FlowInputs{
    
        @InvocableVariable
        public String name;
        
        @InvocableVariable
        public String description;                      
    
    }
    
    public class FlowOutputs{
    
        @InvocableVariable
        public String developerName;
    
    }

}