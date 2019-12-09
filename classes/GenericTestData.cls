@isTest
public class GenericTestData {

    public Enum specialObjects {OpportunityContactRole, OpportunityLineItem}
    public static Map<String, List<SObject>> aDataSiloListMap = new Map<String, List<SObject>>();
    public static final String CREATING = 'Create';

    //method for adding data according to testHarness
    public static Map<String, List<SObject>> harnessCreate(List<String> harness){
        List<String> sobjList = new List<String>();
        List<String> srFilenames = new List<String>();
        Map<String, TestHarnessData__mdt> harnessDataMap = new Map<String, TestHarnessData__mdt>([SELECT id, Object_Type__c, static_resource_Name__c, static_resource_Object__c, object_Priority_Index__c
                                                                  FROM TestHarnessData__mdt 
                                                                  WHERE testharness__r.label = :harness AND operation__c = :CREATING
                                                                  ORDER BY object_Priority_Index__c
                                                                  ]);                                                               
        for ( TestHarnessData__mdt thd :harnessDataMap.values()){            
//            sobjList.add(thd.static_resource_Object__c); 
            sobjList.add(thd.Object_Type__c);
            srFilenames.add(thd.static_resource_Name__c);
        }    
        system.debug(sobjList);
        system.debug(srFilenames);                                                    
        Map<String, List<SObject>> dataSiloListMap = new Map<String, List<SObject>>();
        List<SObject> dataSiloList = new List<SObject>();
        Integer i = 0;
        for (String sobjName :sobjList){ //list is in order of necessity from parents to children
            Boolean excludeSpecial = false;
            for (specialObjects exclusion :specialObjects.values()){
                if (exclusion.name() == sobjName){
                    parseAndInsert(sobjName);
                    excludeSpecial = true;
                    break;
                }
            }
            if (excludeSpecial) continue;
            Schema.SObjectType soType = Schema.getGlobalDescribe().get(sobjName); 
            system.debug('soType ' + soType);
            dataSiloList.addAll(Test.loadData(soType, srFilenames[i])); // need sobjName and sobjFileName
            dataSiloListMap.put(sobjName, dataSiloList);
            Integer recordCount = Database.countQuery('SELECT count() FROM '+ sobjName);
            i++;
//            system.debug(Logginglevel.INFO, sobjName +': '+recordCount);
        }
        return dataSiloListMap;
    }

    //method for adding data where object name and static resource name are the same
    public static Map<String, List<SObject>> sobjectCreate(List<String> sobjList){
        Map<String, List<SObject>> dataSiloListMap = new Map<String, List<SObject>>();
        List<SObject> dataSiloList = new List<SObject>();
        for (string sobjName :sobjList){
            Boolean excludeSpecial = false;
            for (specialObjects exclusion :specialObjects.values()){
                if (exclusion.name() == sobjName){
                    parseAndInsert(sobjName);
                    excludeSpecial = true;
                    break;
                }
            }
            if (excludeSpecial) continue;
            Schema.SObjectType soType = Schema.getGlobalDescribe().get(sobjName);
            dataSiloList.addAll(Test.loadData(soType, sobjName));
            dataSiloListMap.put(sobjName, dataSiloList);
            Integer recordCount = Database.countQuery('SELECT count() FROM '+ sobjName);
//            system.debug(Logginglevel.INFO, sobjName +': '+recordCount);
        }
        return dataSiloListMap;
    }
    
    public static Map<String,SObject> parseAndReturn(String sobjName){
       blob csvFile = [Select Body From StaticResource where Name = :sobjName].body;
       String csvData = csvFile.toString();
       csvData = csvData.replace('\r\n', '\r');
       csvData = csvData.replace('\n', '\r');
       List<String> rowsAndColumns = csvData.split('\r');
       Map<String,SObject> sobjMap = new Map<String,SObject>();
       String lastIndex = '';
       List<String> fieldList = rowsAndColumns[0].split(',');
       sobject sobj = (sobject)Type.forName(sobjName).newinstance();
//       system.debug(sobjName +' '+ fieldList );
       Map<String, SObjectField> sobjFieldMap = sobj.getSobjectType().getDescribe().fields.getMap();
//       system.debug(sobjFieldMap.keySet());
       for (Integer i=1; i < rowsAndColumns.size(); i++){
           sobj = (sobject)Type.forName(sobjName).newinstance();
           rowsAndColumns[i] = rowsAndColumns[i].replaceAll('("[^",]+),([^"]+")', '%1%2');
           List<String> columnList = rowsAndColumns[i].split(',');                      
           for (Integer x=1; x < fieldList.size() && x < columnList.size(); x++){
               if (!String.isBlank(columnList[x])) {
                   columnList[x] = columnList[x].replace('%1%2', ',');
               }
//               system.debug(sobjName +'.'+ fieldList[x]);
               Schema.SObjectField fieldInfo = sobjFieldMap.get(fieldList[x]);                
//               system.debug((!String.isblank(columnList[x])) +' -&- '+ (fieldInfo!=null) +' -&- '+ (fieldInfo.getDescribe().isUpdateable()));              
               if (!String.isblank(columnList[x]) && fieldInfo!=null && fieldInfo.getDescribe().isCreateable()){                                       
                   fieldList[x] = fieldInfo.getDescribe().getName();
                   if (fieldInfo.getDescribe().getType()==Schema.displayType.REFERENCE){                       
                       String parentSObj = fieldInfo.getDescribe().getReferenceTo()[0].getDescribe().getName(); // todo step through list for whoID whatID
                       String parentField = 'ID';
                       if (fieldInfo.getDescribe().getReferenceTargetField() != null) {
                           parentField = fieldInfo.getDescribe().getReferenceTargetField();
                       } 
//                       system.debug(sobjName +'.'+ fieldList[x] +' <--> '+ parentSObj +'.'+ parentField);   
                       String query = 'SELECT '+  parentField +' FROM '+ parentSObj;
                       if (columnList[x].length()<6 ){ //any integer temp id
                           Integer idx = Integer.valueOf(columnList[x])-1;
                           if (parentSObj == 'Account') {
                               idx = Integer.valueOf(columnList[x])-88; // todo custom metadata
                           }                           
                           sobj.put(fieldList[x],Database.query(query)[idx].id);
                       } else if (columnList[x].length()>=15){
                           sobj.put(fieldList[x], columnList[x]);
                       }
                   } else {
                       switch on fieldInfo.getDescribe().getSOAPType() {
                           when DOUBLE {
                               sobj.put(fieldList[x], Decimal.valueOf(columnList[x]));
                           }
                           when INTEGER {
                               sobj.put(fieldList[x], Integer.valueOf(columnList[x]));
                           }                       
                           when DATE {
                               sobj.put(fieldList[x], Date.valueOf(columnList[x]));
                           }
                           when DATETIME {
                               sobj.put(fieldList[x], DateTime.valueOf(columnList[x]));
                           }
                           when BOOLEAN {
                               if (columnList[x] == 'false' || columnList[x] == '0\r' || columnList[x] == '0'){
                                   sobj.put(fieldList[x], false);
                               } else {
                                   sobj.put(fieldList[x], true);
                               }
                           } 
                           when STRING {
                               sobj.put(fieldList[x], columnList[x].remove('&'));
                           }                                                                            
                       }  // switch              
                   } // else if not reference
              } // if updateable
           } // for each column and field
           sobjMap.put(columnList[0],sobj);
           lastIndex = columnList[0];  
       } // for each row and record
       return sobjMap;
    }
    
    public static void parseAndInsert(String sobjName){
        Map<String,SObject> sobjMap = parseAndReturn(sobjName); 
        insert sobjMap.values();
//       system.debug(sobjMap.get(lastIndex).ID);            
    }        

    public static void parseAndValidate(String sobjName){
        Map<String,SObject> sobjMap = parseAndReturn(sobjName);
        
    }    
    
    public static void showObj(List<String> dataList, LOGGINGLEVEL ll){
        for (String s :dataList){
            String nameField = ', Name ';
            if (s == 'OpportunityContactRole' ) { nameField = ' ';}
            String query = 'SELECT ID' + nameField + 'FROM ' + s;
            for (SObject sobj : (Database.query(query))){
                system.debug(ll, sobj);
            }
        }  
    }

    public static void countObj(List<String> dataList, LOGGINGLEVEL ll){
        for (String s :dataList){
            String query = 'SELECT count() FROM ' + s;
            system.debug(ll, s +' '+ Database.countQuery(query));            
        }  
    }
    
    @istest
    static void createBasicTest(){
        List<String> harnessList = new List<String>{'Basic Test'};
        harnessCreate(harnessList);
        for (Contact c :[Select Account.Name FROM Contact]){
            System.assert(String.isNotBlank(c.account.name));
        }
        system.assert([SELECT Count() FROM Contact]>0);       
    }

    @istest
    static void createIntegrationTest(){
        List<String> harnessList = new List<String>{'Bhavana Test'};
        harnessCreate(harnessList);
        for (Contact c :[Select Account.Name FROM Contact]){
            System.assert(String.isNotBlank(c.account.name));
        }
        system.assert([SELECT Count() FROM Contact]>0);       
    }
    
    @istest
    static void createIntegrationHarnessTest(){
        List<String> harnessList = new List<String>{'Refactor Test'};
        harnessCreate(harnessList);
        for (Contact c :[Select Account.Name FROM Contact]){
            System.assert(String.isNotBlank(c.account.name));
        }
        system.assert([SELECT Count() FROM Contact]>0);       
    }    
    
    @istest
    static void createAccsCon(){
        List<String> dataSiloList = new List<String>{'Account', 'Contact'};
        sobjectCreate(dataSiloList);
        for (Contact c :[Select Account.Name FROM Contact]){
            System.assert(String.isNotBlank(c.account.name));
        }
    }
    
    @istest
    static void createAccsConOpp(){ //Opp line item does not work 'OpportunityLineItem' for too many reference objects
        List<String> dataSiloList = new List<String>{'Account', 'Contact', 'Opportunity', 'Product2', 'PriceBookEntry', 'Case', 'OpportunityLineItem', 'OpportunityContactRole'};
        sobjectCreate(dataSiloList);
        countObj(dataSiloList, LOGGINGLEVEL.DEBUG);
        for (String s :dataSiloList){
            String query = 'SELECT count() FROM ' + s;
            system.assert(Database.countquery(query)>0);            
        }         
    }  
    
/*    
//I wish I could load files from a zipped resource     
    @isTest
    static void createFromZip(){
    //cannot use zip files in test this way, either the static resource cannot be found or getContent is blocked during tests
//        PageReference fileRef = PageReference.forResource('Create', '/Account.csv');
//        system.debug(fileRef.getContent().toString());
//        Test.loadData(Account.sobjectType, 'Create/Account.csv');
        blob csvFile = [Select Body, Name From StaticResource where Name = 'Create/Account.csv'].body;
        system.debug(csvFile.toString());
    }
*/
    
    @isTest
    static void parseInsertTest(){
        List<String> sobjList = new List<String>{'Account', 'Contact', 'Opportunity', 'Case'};
        for (String s :sobjList){
            GenericTestData.parseAndInsert(s);    
        } 
        for (String s :sobjList){
            String query = 'SELECT count() FROM ' + s;
            system.assert(Database.countquery(query)>0);            
        }            
    }

    @isTest
    static void parseInsertTestProdPric(){ //Pricebook fails: required ID fields not updateable
        List<String> sobjList = new List<String>{'Product2', 'PriceBookEntry'};
        for (String s :sobjList){
            GenericTestData.parseAndInsert(s);    
        } 
        for (String s :sobjList){
            String query = 'SELECT count() FROM ' + s;
            system.assert(Database.countquery(query)>0);            
        }            
    }
    

}