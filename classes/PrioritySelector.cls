// look for existing test harness data for the given object
// If exists, use that priority
// Else find the highest priority used and use the next number

/**
 //Id thID = [SELECT Id FROM TestHarness__mdt WHERE label = 'Bhavana Test' LIMIT 1].Id;
Id thID = [SELECT Id FROM TestHarness__mdt WHERE label = 'Test Priority' LIMIT 1].Id;

system.debug(thID);

System.debug('account ' + PrioritySelector.getPriority('Account', thID));
System.debug('contact ' + PrioritySelector.getPriority('Contact', thID));
System.debug('lead ' + PrioritySelector.getPriority('Lead', thID));
System.debug('Case ' + PrioritySelector.getPriority('Case', thID));


**/
public class PrioritySelector {
    
	private static final Decimal UNDEFINED = -1.00;    
    
    Public static Decimal getPriority(String objectName, Id testHarnessId){
        
        Decimal priority = UNDEFINED;
        
        // get all the thds
        List<TestHarnessdata__mdt> thdList = [SELECT Id, Object_Priority_Index__c, Static_Resource_Object__c
                                              FROM TestHarnessdata__mdt 
                                              WHERE TestHarness__C = :testHarnessId
                                              order BY Object_Priority_Index__c 
                                              DESC
                                             ];

        if(thdList.size() > 0){
            for(TestHarnessdata__mdt thd: thdList){
                if(thd.Static_Resource_Object__c == objectName){
                    priority = thd.Object_Priority_Index__c;
                    break;
                }
            }
            if(priority == UNDEFINED){
                priority = thdList[0].Object_Priority_Index__c + 1;
            }
        } 
        
        // if still undefined, this is the first test harness data being added
        if(priority == UNDEFINED){ 
            priority = 1.00;
        }
        
        system.debug('Returning Priority ' + priority + ' for ' + objectName);
        return priority;
    } 
}