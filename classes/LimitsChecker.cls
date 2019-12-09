/*
    public class with public interface -- not global, not shared across namespace
    should it be protected?
    
*/
public virtual class LimitsChecker implements LimitsInterface {   

    public static final String STARTPOINT = ': Start Point ****';
    public static final String NEXTPOINT = ': NEXT Point ****';
    public static final String DELTAPOINT = 'Changes since prior ';
    public static final String REMAINING = 'Remaining';
    public static final String CHECKPOINT = '**** Checking limits for: ';
    public static final String STEPCOUNT = '**** Checking ';
    
    Public String limitContext = '';
    Public String limitType = '';
    Public Integer stepContext = 0;    
    
    private String contextString = '';  
  
    private static Map<String,Integer> priorValueMap = new Map<String,Integer>();

    private static Boolean first = true;

    // each annotated class's inner class redefines this    
    public virtual Map<String,Integer> getLimits(){
        return new Map<String,Integer>();
    }

// TODO: consider changing the annotated showLimits and this method all to showLimits(string,enum)
    // show checkpoint info before this instance of limit data    
    public void showLimits(String checkPointName){
        contextString = checkPointName +' '; 
        if (Test.isRunningTest()){        
            System.debug('CONTEXTSTRING VALUE: ' + contextString);
            return;
        }
//        createEvent('CONTEXT: ' + contextString); 
        streamMessage('CONTEXT: ' + contextString);      
        showlimits();         
    }

    
    public void showLimits(){
    
        //get the current context, type, step and limit map              
        Map<String,Integer> nextValueMap = getLimits();
        
        if (stepContext>1){       
            //log context and step number before logging values for this subsequent checkpoint
//           system.debug(logginglevel.NONE, CHECKPOINT + contextString +' '+ limitContext +' - '+ limitType +' #'+ stepContext +  NEXTPOINT);
            nextLimits(priorValueMap, nextValueMap);
        }else{
            //log context and step number before logging values for this starting checkpoint        
//            system.debug(logginglevel.NONE, CHECKPOINT + contextString +' '+ limitContext +' - '+ limitType +' #'+ stepContext +  STARTPOINT);
            processLimits(nextValueMap);
        }
        priorValueMap.putAll(nextValueMap);
        if (Test.isRunningTest()){
            System.debug(logginglevel.WARN, '### ' + contextString +'  '+ stepContext + ' ###'); 
            return;
        }             
//        createEvent('### ' + contextString +'  '+ stepContext + ' ###');
        streamMessage('### ' + contextString +'  '+ stepContext + ' ###');
    }
   
    private static void processLimits(Map<String,Integer> aResult){
        String keyValue = '';
        for (String skey :aResult.keySet()) {
            keyValue += skey + aResult.get(skey) +'\r\n';
            if (Test.isRunningTest()){
                System.debug(logginglevel.WARN, skey + aResult.get(skey));
                continue;
            }
//            createEvent(skey + aResult.get(skey));
            streamMessage(skey + aResult.get(skey));                       
        }// for each key                  
    }
   
    private static void nextLimits(Map<String,Integer> priorResult, Map<String,Integer> nextResult){        
        processLimits(nextResult);
        // determine and display changes from prior to next for these limits
        for (String skey :nextResult.keySet()) {
            if (!skey.contains(REMAINING) && nextResult.get(skey)!=null && priorResult.get(skey)!=null){
                if (Test.isRunningTest()){
                    System.debug(logginglevel.WARN, DELTAPOINT + skey + (nextResult.get(skey)-priorResult.get(skey))); 
                    continue;
                }
//                createEvent(DELTAPOINT + skey + (nextResult.get(skey)-priorResult.get(skey))) ;
                streamMessage(DELTAPOINT + skey + (nextResult.get(skey)-priorResult.get(skey))) ;
            } //nested pb flow using compute and dml getting null value error until if statement rewritten to check for nulls                                         
        }            
    }

    @TestVisible
    public static void streamMessage(String msg){
        String path = '/services/data/v'+ RestRequestController.getAPI() +'/sobjects/StreamingChannel/0M61U0000008bf1SAA/push';
        String method = RestRequestController.HTTPPOST;
        String responseFormat = RestRequestController.APPJSON;
        String bodyContentStart = '{"pushEvents": [{"payload": "';
        String bodyContentEnd = '"}]}';
        String bodyContent = bodyContentStart+ msg +bodyContentEnd;
        String bodyContentType = RestRequestController.APPJSON;

        RestRequestController.RequestStrings req = new RestRequestController.RequestStrings(path, method, responseFormat, bodyContent, bodyContentType);
        HttpResponse httpRes = RestRequestController.makeRequest(req);
        
        String restRes;
        List<String> jsonList = new List<String>();
        
        if (httpRes.getStatusCode() == 201 || httpRes.getStatusCode() == 200 ){
            restRes = JSON.serializePretty(JSON.deserializeUntyped(httpRes.getBody())); // more like prettyprint 
        } else {
            restRes = 'Request/response problem: ' +' '+  httpRes.getStatusCode()  +' '+ httpRes.getStatus();  
            throw new CallOutException (restRes);          
        } 
        if (Test.isRunningTest()){
            Test.getEventBus().deliver();
        }         
        jsonList.add(restRes);
        system.debug(jsonList);        
    }
            
    @TestVisible
    private static void createEvent(String msg){
        
        List<Limits_Notifications__e> pubList = new List<Limits_Notifications__e>();
        Limits_Notifications__e pub = new Limits_Notifications__e();
        pub.Result_Message__c = msg;
        pubList.add(pub);
        List<Database.SaveResult> results = EventBus.publish(pubList); 
        if (Test.isRunningTest()){
            Test.getEventBus().deliver();
        }               

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
    } 

    public enum LimitList {DML, SOQL, SOSL, Compute, Messaging, ApexAPI}

    public Enum Context{
        APEX,
        FLOW,
        PROCESS,
        LIGHTNING
    }


    
}