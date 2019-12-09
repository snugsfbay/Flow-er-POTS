public class EnvironmentUtils {

    


    final String DOMAIN = '.my.salesforce.com';
    final String MYDOMAIN = [SELECT Domain FROM Domain LIMIT 1].Domain;
    final String SEPARATOR = '.cs'; //sandboxes, this goes away in Winter20
    final String INSTANCENAME = [select InstanceName from Organization LIMIT 1].InstanceName;
    
    Boolean sandbox = false;
    String name;
    
    public EnvironmentUtils(){
        sandbox = [SELECT isSandbox FROM Organization Limit 1].isSandbox; 
        name = Url.getOrgDomainUrl().toExternalForm();
        name = name.removeEnd(DOMAIN);
        name = name.removeStart(MYDOMAIN);
        name = name.substringBefore(SEPARATOR);                  
    }
    
    public Boolean getSandbox(){
        return sandbox;
    }
    
    public Boolean getProduction(){
        return !sandbox;
    }
    
    public String getSandboxName(){
        if (sandbox){
            return name.toUpperCase();
        }
        else return null;
    }
    
    
//EnvironmentUtils.getSobjMap();
//EnvironmentUtils.getDescribeSobj('mydomaindiscoverablelogin');  
// insightsexternaldatapart true false  
// orglifecyclenotification false true
// just for fun: http://titancronus.com/blog/2014/05/01/salesforce-acquiring-dependent-picklists-in-apex/
// performance: http://titancronus.com/blog/2014/07/03/acquiring-dependent-picklists-in-apex-contd/
// 
    private static Map<String, Schema.SObjectType> getSObjMap(){
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectType> objQueryMap = new Map<String,Schema.SObjectType>();
        // validate searchability
        for (String s :objGlobalMap.keySet() ){
            if ( objGlobalMap.get(s).getDescribe().isQueryable() && objGlobalMap.get(s).getDescribe().isAccessible()){
                objQueryMap.put(s,objGlobalMap.get(s));
            }
//            system.debug(objGlobalMap.get(s).getDescribe().getKeyPrefix() +' '+ s +' '+objGlobalMap.get(s).getDescribe().isQueryable() +' '+objGlobalMap.get(s).getDescribe().isAccessible());
        }
        return objQueryMap;
    } 
        
    private static Map<String, Schema.SObjectField> getDescribeSObj(String apiName){
        Map<String, Schema.SObjectField> objFieldMap = new Map<String, Schema.SObjectField>();
        Map<String, Schema.SObjectField> objQueryFieldMap = new Map<String, Schema.SObjectField>();

        Map<String,Schema.SObjectType> objQueryMap = getSObjMap();
        Schema.SObjectType objType = objQueryMap.get(apiName);
        if (objType==null){
            return objFieldMap;
        }
        objFieldMap = objType.getDescribe().fields.getMap();
        if (objFieldMap != null){
            for (String s :objFieldMap.keySet()){
                system.debug(s +' '+ objFieldMap.get(s).getDescribe().isAccessible());
                if (objFieldMap.get(s).getDescribe().isAccessible()){
                    objQueryFieldMap.put(s, objFieldMap.get(s));
                }
            }
        }
        return objQueryFieldMap;
    }
    
    @auraEnabled
    public static Map<String, String> getAccessibleFields(String obj){
        Map<String, Schema.SObjectField> fieldMap = new Map<String, Schema.SObjectField>();
        Map<String, String> fieldNameMap = new Map<String, String>();
        obj = obj.toLowerCase();
        fieldMap = getDescribeSObj(obj);
        List<String> sortKeyList = new List<String>(fieldMap.keySet());
        sortKeyList.sort();
        for (String s : sortKeyList){
            fieldNameMap.put(s, fieldMap.get(s).getDescribe().getLabel() +' ['+ s +']');
        }
        return fieldNameMap;
    }
    
    @auraEnabled
    public static Map<String, String> getAccessibleObjects(){
        Map<String, Schema.SObjectType> objMap = new Map<String, Schema.SObjectType>();
        Map<String, String> objNameMap = new Map<String, String>();
        objMap = getSObjMap();
        List<String> sortKeyList = new List<String>(objMap.keySet());
        sortKeyList.sort();
        for (String s : sortKeyList){
            objNameMap.put(s, objMap.get(s).getDescribe().getLabel() +' ['+ s +']');
        }        
        return objNameMap;
    }
    
    @invocableMethod
    public static void sendDebug(List<String> s){
        system.debug('String message from Flow:\u00A0' +s[0]);
    }
    
}