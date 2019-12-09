@isTest
public class complexDataTest {
    
    

    @isTest
    static void createData(){
        List<String> dataSiloList = new List<String>{'Account', 'Contact', 'Opportunity', 'Product2', 'PriceBookEntry', 'Case', 'OpportunityLineItem', 'OpportunityContactRole'};
        GenericTestData.aDataSiloListMap = GenericTestData.sobjectCreate(dataSiloList);
        GenericTestData.countObj(dataSiloList, LOGGINGLEVEL.DEBUG);
        system.debug(GenericTestData.aDataSiloListMap);
    }


    @isTest
    static void ocroli(){
        List<String> sobjList = new List<String>{'Account', 'Contact', 'Opportunity', 'OpportunityContactRole', 'Case', 'Product2', 'PricebookEntry', 'OpportunityLineItem'};
        for (String s :sobjList){
            GenericTestData.parseAndInsert(s);    
        }    
        GenericTestData.countObj(sobjList, LOGGINGLEVEL.DEBUG);
        system.debug(GenericTestData.aDataSiloListMap);
    }
 
    
}