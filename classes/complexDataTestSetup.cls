@isTest
public class complexDataTestSetup {
    
    

	@testSetup
    static void createData(){
        List<String> dataSiloList = new List<String>{'Account', 'Contact', 'Opportunity', 'Product2', 'PriceBookEntry', 'Case', 'OpportunityLineItem', 'OpportunityContactRole'};
        GenericTestData.aDataSiloListMap = GenericTestData.sobjectCreate(dataSiloList);
        GenericTestData.countObj(dataSiloList, LOGGINGLEVEL.DEBUG);
        system.debug(GenericTestData.aDataSiloListMap);
    }


	@isTest
    static void ocr(){
        List<String> sobjList = new List<String>{'Account', 'Contact', 'Opportunity', 'OpportunityContactRole'};
        for (String s :sobjList){
            GenericTestData.parseAndInsert(s);    
        }    
        GenericTestData.countObj(sobjList, LOGGINGLEVEL.DEBUG);
        system.debug(GenericTestData.aDataSiloListMap);
    }
 
    
}