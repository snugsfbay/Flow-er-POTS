/*
    @author:         Bonny Hinners
    @description:    Test class for creating test data in silo
                     Creates records for Accounts, some with related contacts
                     Defines constants for max values of Gov Limits
                     Creates lowercase alphabet string for test searches 
    @references:     Called by GovLimTest
                     Relies on valid CSV files as static resources */
@isTest
public class CreateTestData {

    public static final Integer MAXSOQLROWS = 50000;
    public static final Integer MAXSOQLQUERIES = 100;
    public static final Integer MAXSOQLAGGQS = 300;
    public static final Integer MAXDMLROWS = 10000;
    public static final Integer MAXDMLSTMNTS = 150;
    public static final Integer MAXSOSL = 20;
    public static final Integer MAXCPUTIME = 10000;
    public static final Integer MAXHEAP = 6000000;

    public static String lcAlpha(){
        return 'abcdefghijklmnopqrstuvwxyz';
    }
    
    public static void createAC() {
//        System.AssertEquals(0,[SELECT COUNT() FROM Account]);
       
        List<SObject> dataList = new List<SObject>();
        for (Integer i=1; i<=20; i++){
            dataList.addAll(Test.loadData(Account.sObjectType, 'TestAccountsBasic'));            
        }
//        system.debug('accounts: ' +[SELECT COUNT() FROM Account]);
        for (Integer i=1; i<=10; i++){
            dataList.addAll(Test.loadData(Contact.sObjectType,'TestContactsBasic'));             
        }
//        system.debug('contacts: '+[SELECT COUNT() FROM Contact]);
//        system.debug('sforce contacts: ' +[SELECT COUNT() FROM Contact WHERE Account.Name='sForce']);
//        system.debug('accounts: ' +[SELECT COUNT() FROM Account]);        
//        System.assert([SELECT COUNT() FROM Account]>0, 'Account data error');
//        System.assert([SELECT COUNT() FROM Contact]>0, 'Contact data error');
    }

    public static void createA() {       
        List<SObject> dataList = new List<SObject>();
        for (Integer i=1; i<=20; i++){
            dataList.addAll(Test.loadData(Account.sObjectType, 'TestAccountsBasic'));            
        }
    }

    public static void setFixedSearchResults(){
    
        Map<ID,SObject> objMap = new Map<ID,SObject>([SELECT ID FROM Account WHERE Name LIKE 'sF%']);
        List<ID> fixedSearchResults = new List<ID>(objMap.keyset());
        objMap = new Map<ID,SObject>([SELECT ID FROM Contact WHERE Account.Name LIKE 'sF%']);
        fixedSearchResults.addAll(objMap.keyset());
        Test.setFixedSearchResults(fixedSearchResults);
        system.debug('Minimum Fixed Search Results Setup: ' + [SELECT COUNT() From Account WHERE Name='sForce'] + ', ' + [SELECT COUNT() FROM Contact WHERE Account.Name='sForce']);
/*
        SOSLLimits lim = new SOSLLimits();
        lim.showLimits();
        List<List<SObject>> searchList = [FIND 'sF*' IN ALL FIELDS RETURNING Account (Id, Name), Contact];
        system.debug(searchList.size());
        system.debug(searchList[0].size());
        system.debug(searchList[1].size());
        system.debug(searchList);
        lim.showLimits();
*/
    }

    public static void longCPUTest(){
    
        List<Account> aLockList = [SELECT Name,BillingPostalCode FROM Account WHERE Name = 'GenePoint' FOR UPDATE];
        Integer i = 0;
        
        Do{
            ComputeCheckpoint.showlimits();
            i = Limits.getCPUTime();   
        }While (i < Limits.getLimitCpuTime() - 64);
        
        for (Account a : aLockList){
            a.BillingPostalCode = '94044';
        }
        update aLockList;
        system.debug(aLockList);
//        system.debug(LimitsChecker.umlString);

    }
    

    public static void longLockTest(){
    
        List<Account> aLockList = [SELECT Name,BillingPostalCode FROM Account WHERE Name = 'GenePoint' FOR UPDATE];
        Integer i = 0;
        
        Do{
            ComputeCheckpoint.showlimits();
            i = Limits.getCPUTime();   
        }While (i < Limits.getLimitCpuTime() - 64);
        
        for (Account a : aLockList){
            a.BillingPostalCode = '94043';
        }
        update aLockList;
        system.debug(aLockList);
//        system.debug(LimitsChecker.umlString);

    }    
    

       
    @isTest static void runSimpleAC(){
        createAC();
        system.assert([SELECT COUNT() FROM Account]> 0, 'No Accounts added.');
        system.assert([SELECT COUNT() FROM Contact]>0, 'No Contacts added.');
    }

    @isTest static void runSimpleA(){
        createA();
        system.assert([SELECT COUNT() FROM Account]> 0, 'No Accounts added.');
        system.assert([SELECT COUNT() FROM Contact]==0, 'Contacts added.');
    }

    @isTest static void pbActiveAccount(){
        test.startTest();
        createA(); //testing only true for active Process Builder condition, otherwise this test fails 
        test.getEventBus().deliver(); // required for events to work with tests
        test.stopTest();       
        system.assert([SELECT COUNT() FROM Account WHERE Active__c!=null]> 0, 'No Active Accounts. PB Automation (testlim) may be inactive.');
        system.assert([SELECT COUNT() FROM Contact]==0, 'Contacts added.');
    }
    
}