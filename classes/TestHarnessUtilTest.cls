@isTest
public class TestHarnessUtilTest{

    @isTest
    public static void service(){
        TestHarnessUtil.FlowInputs fi = new TestHarnessUtil.FlowInputs();
        List<TestHarnessUtil.FlowInputs> fiList = new List<TestHarnessUtil.FlowInputs>();
        List<TestHarnessUtil.FlowOutputs> foList = new List<TestHarnessUtil.FlowOutputs>();
        
        fi.name = 'unitTest';
        fi.description = 'base code testing';
        fiList.add(fi);
        
        Test.startTest();
            foList = TestHarnessUtil.service(fiList);             
        Test.getEventBus().deliver();
        Test.stopTest();
        
        system.assert(foList[0].developerName.contains('V1'), 'TestHarness output incorrect');
       
    }
    @isTest
    public static void serviceNameDefault(){ //default name
        TestHarnessUtil.FlowInputs fi = new TestHarnessUtil.FlowInputs();
        List<TestHarnessUtil.FlowInputs> fiList = new List<TestHarnessUtil.FlowInputs>();
        List<TestHarnessUtil.FlowOutputs> foList = new List<TestHarnessUtil.FlowOutputs>();
        
        fi.name = ' ';
        fiList.add(fi);
        
        Test.startTest();
            foList = TestHarnessUtil.service(fiList);             
        Test.getEventBus().deliver();
        Test.stopTest();
        
        system.assert(foList[0].developerName.contains('V1'), 'TestHarness output incorrect');
       
    }

    @isTest
    public static void serviceNameLen(){ //name limited to 40
        TestHarnessUtil.FlowInputs fi = new TestHarnessUtil.FlowInputs();
        List<TestHarnessUtil.FlowInputs> fiList = new List<TestHarnessUtil.FlowInputs>();
        List<TestHarnessUtil.FlowOutputs> foList = new List<TestHarnessUtil.FlowOutputs>();
        
        fi.name = 'unitTest1234567890123456789012345678901234567890';
        fi.description = 'truncate code testing';
        fiList.add(fi);
        
        Test.startTest();
            foList = TestHarnessUtil.service(fiList);             
        Test.getEventBus().deliver();
        Test.stopTest();
        
        system.assert(foList[0].developerName.contains('V1'), 'TestHarness output incorrect');
        system.assert(foList[0].developerName.substringAfterLast('.').length()==40, foList[0].developerName.length()+' TestHarness output incorrect');

       
    }

    @isTest
    public static void serviceNameNumber(){ //name can't start with a number
        TestHarnessUtil.FlowInputs fi = new TestHarnessUtil.FlowInputs();
        List<TestHarnessUtil.FlowInputs> fiList = new List<TestHarnessUtil.FlowInputs>();
        List<TestHarnessUtil.FlowOutputs> foList = new List<TestHarnessUtil.FlowOutputs>();
        
        fi.name = '1unitTest';
        fi.description = 'naming restriction testing';
        fiList.add(fi);
        
        Test.startTest();
            foList = TestHarnessUtil.service(fiList);             
        Test.getEventBus().deliver();
        Test.stopTest();
        
        system.assert(foList[0].developerName.substringAfterLast('.').startsWith('X'), 'TestHarness name cannot start with number');
       
    }

    @isTest
    public static void maxLength(){
        system.assert(TestHarnessUtil.maxLength(0)==38,TestHarnessUtil.maxLength(0)+ ' Length error');
        system.assert(TestHarnessUtil.maxLength(10)==37,TestHarnessUtil.maxLength(10)+ ' Length error');
        system.assert(TestHarnessUtil.maxLength(100)==36,TestHarnessUtil.maxLength(100)+ ' Length error');
    }
    
    @isTest
    public static void populateContainer(){
        TestHarness__mdt th = new TestHarness__mdt();
        th.label = 'populateContainerTest';
        th.developerName = th.label;
        th.description__c = 'description field';
        String fullname = 'TestHarness.'+th.developerName;
        Metadata.CustomMetadata customMetadata = TestHarnessUtil.populateContainer(th, fullname);
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);  
        // roundtrip
        List<Metadata.Metadata> contents = mdContainer.getMetadata();
        System.assertEquals(1, contents.size());
        Metadata.CustomMetadata md = (Metadata.CustomMetadata) contents.get(0);        
        // Perform various assertions the layout metadata.
        System.assertEquals(fullname, md.fullName);            
    }

    @IsTest
    static void testTHCallback() {
        
        // Instantiate the callback.
        THMetadataCallback callback = new THMetadataCallback();
       
        // Create test result and context objects.
        Metadata.DeployResult result = new Metadata.DeployResult();
        result.status = Metadata.DeployStatus.Succeeded;
        result.numberComponentErrors = 0;
        result.numberComponentsDeployed = 1;
        Metadata.DeployDetails details = new Metadata.DeployDetails();
        Metadata.DeployMessage deployMessage = new Metadata.DeployMessage();
        deployMessage.fullname = 'UnitTesting';
        details.componentSuccesses.add(deployMessage);
        result.details = details;
        
        Metadata.DeployCallbackContext context = new Metadata.DeployCallbackContext();
        
        // Invoke the callback's handleResult method.
        Test.startTest();
        callback.handleResult(result, context);
        Test.stopTest();
    }

}