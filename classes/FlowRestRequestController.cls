public class FlowRestRequestController {

    @InvocableMethod(label='Get REST response' description='Pass list of strings and Returns the Response as list of strings.')
    // pass 0: path 1: method 2: responseFormat 3: bodyContent 4: bodyContentType
    // return 0: statusCode (string.valueOf) 1: bodyContent 2: status message
    public static List<FlowInfo> service(List<String> flowInput) {

        List<String> requestStrings = flowInput[0].split(','); 
      
        String path = requestStrings[0];
        String method = requestStrings[1];
        String responseFormat = requestStrings[2];
        String bodyContent = requestStrings[3];
        String bodyContentType  = requestStrings[4];
         
        HttpRequest request = buildRequest(path, method, responseFormat, bodyContent, bodyContentType);
        HttpResponse httpRes = sendRequest(request);
        List<FlowInfo> restRes = buildResponse(httpRes);

        return restRes;
    }
 
    private static HttpRequest buildRequest(String path, String method, String responseFormat, String bodyContent, String bodyContentType) {
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + '/services/data/v46.0/' + path);
        request.setMethod(method);
        
        if (!String.isBlank(bodyContent)) {
            request.setBody(bodyContent);
            request.setHeader('Content-Type', bodyContentType); 
        }
        
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        request.setHeader('ACCEPT', responseFormat);
        
        return request;
    }     
    
    private static HttpRequest buildRequest(String path) {
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + '/services/data/v44.0/' + path);
        request.setMethod('GET');        
        
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        request.setHeader('ACCEPT', 'application/json');
        
        return request;
    }
    
    
      
    private static HttpResponse sendRequest(HttpRequest request) {    
        return new Http().send(request);
    }
    

    
    private static List<FlowInfo> buildResponse(HttpResponse httpRes) {
        String restRes;
        List<FlowInfo> fi = new List<FlowInfo>();
        Map<String, Object> objMap = new Map<String, Object>();

        if (httpRes.getStatusCode() == 200){
            objMap = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());
        } else {
            throw new CallOutException ('Request/response problem: ' +' '+  httpRes.getStatusCode()  +' '+ httpRes.getStatus() );          
        }

        restRes = miniBody(objMap);        
        fi.addAll(deserializeFlowInfo(restRes));

        objMap = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());
        objMap = (Map<String, Object>)objMap.get('Metadata');
        fi[0].overviewRecords = '';
        for (MetaDesc md :MetaDesc.values()){
            String thisDesc = md.name();
            String flowOverview = '';
            List<Object> metaObjList = (List<Object>)objMap.get(thisDesc);
            flowOverview = flowOverview + overview(metaObjList, thisDesc);
            switch on thisDesc {
                when 'actionCalls' {
                    fi[0].overviewActionCalls = flowOverview;
                }
                when 'apexPluginCalls'{
                    fi[0].overviewApexPlugins = flowOverview;
                }
                when 'recordCreates'{
                    fi[0].overviewRecords = fi[0].overviewRecords + flowOverview;                
                }
                when 'recordDeletes'{
                    fi[0].overviewRecords = fi[0].overviewRecords + flowOverview;
                }
                when 'recordLookups'{
                    fi[0].overviewRecords = fi[0].overviewRecords + flowOverview;
                }
                when 'recordUpdates'{
                    fi[0].overviewRecords = fi[0].overviewRecords + flowOverview;
                }
                when 'subflows'{
                    fi[0].overviewSubflows = flowOverview;
                }
            }            
                        
        } 
               
        return fi;
    }

    private static String miniBody(Map<String, Object> objMap){
        String newJSON;

        objMap.remove('Metadata');
        objMap.remove('attributes');
        newJSON = JSON.serialize(objMap);

        return newJSON;
    }

    private static String overview(List<Object> metaObjList, String thisDesc){
        String newOverview ='';
        List<FlowOverview> foList = new List<FlowOverview>();
        for (object o :metaObjList){
            Map<String, Object> metaObj = (Map<String, Object>)o;
            metaObj.remove('connector');
            metaObj.remove('inputParameters');
            metaObj.remove('outputParameters');
            metaObj.remove('processMetadataValues');
            metaObj.remove('value');

            String newJSON = JSON.serialize(metaObj);            
            FlowOverview fo = (FlowOverview)JSON.deserialize(newJSON, FlowOverview.class);
            fo.thisType = thisDesc;
            foList.add(fo);                   
        }
        if (foList.size()>0)
        for (FlowOverview fo :foList){
            switch on thisDesc {
                when 'actionCalls' {
                    newOverview = newOverview + '\u000D\u00A0\u00A0 Action Call: ' + fo.actionName +'; '+ fo.actionType +'; <B>'+ fo.label +'</B>; '+ fo.description;
                }
                when 'apexPluginCalls'{
                    newOverview = newOverview + '\u000D\u00A0\u00A0 Legacy Apex: ' + fo.apexClass +'; <B>'+ fo.label +'</B>; '+ fo.description;
                }
                when 'recordCreates'{
                    newOverview = newOverview + '\u000D\u00A0\u00A0 Record Create: ' +' <B>'+ fo.label +'</B>; '+ fo.description;                
                }
                when 'recordDeletes'{
                    newOverview = newOverview + '\u000D\u00A0\u00A0 Record Delete: ' +' <B>'+ fo.label +'</B>; '+ fo.description;
                }
                when 'recordLookups'{
                    newOverview = newOverview + '\u000D\u00A0\u00A0 Record Lookup: ' +' <B>'+ fo.label +'</B>; '+ fo.description;
                }
                when 'recordUpdates'{
                    newOverview = newOverview + '\u000D\u00A0\u00A0 Record Update: ' +' <B>'+ fo.label +'</B>; '+ fo.description;
                }
                when 'subflows'{
                    newOverview = newOverview + '\u000D\u00A0\u00A0 Subflow: ' + fo.flowName +'; <B>'+ fo.label +'</B>; '+ fo.description;
                }
            }        
        }
        newOverview = newOverview.remove('; null');
 
        return newOverview;
    }
    
    private static List<FlowInfo> deserializeFlowInfo(String newJSON){
        List<FlowInfo> fiList = new List<FlowInfo>();
        FlowInfo fi = (FlowInfo)JSON.deserialize(newJSON, FlowInfo.class);
        fiList.add(fi);
        return fiList;
    }

    private static List<FlowInfo> deserializeFlowOverview(String newJSON){
        List<FlowInfo> fiList = new List<FlowInfo>();
        FlowInfo fi = (FlowInfo)JSON.deserialize(newJSON, FlowInfo.class);
        fiList.add(fi);
        return fiList;
    }

    private static void buildTestQuery(){
        // SELECT Id, ApexTestClass.Name, TestMethodName, FlowVersion.MasterLabel, NumElementsCovered, NumElementsNotCovered FROM FlowTestCoverage 
    }
    
    public class FlowInfo {
    
        @InvocableVariable
        public ID ID;

        @InvocableVariable
        public ID definitionID;    

        @InvocableVariable
        public String MasterLabel;

        @InvocableVariable
        public String manageableState;        

        @InvocableVariable
        public Integer versionNumber;

        @InvocableVariable
        public String status;

        @InvocableVariable
        public String description;

        @InvocableVariable
        public String processType;

        @InvocableVariable
        public DateTime createdDate;

        @InvocableVariable
        public String createdByID;

        @InvocableVariable
        public String lastModifiedByID;

        @InvocableVariable
        public DateTime lastModifiedDate;

        @InvocableVariable
        public String fullName;

        @InvocableVariable
        public String overviewRecords;        

        @InvocableVariable
        public String overviewActionCalls;

        @InvocableVariable
        public String overviewApexPlugins;

        @InvocableVariable
        public String overviewSubflows;
        
        @InvocableVariable
        public String overview;

    }

    private class FlowOverview {

        private String description;   

        private String label;     

        private String actionName;       

        private String actionType; 

        private String flowName;       

        private String apexClass;
        
        private String thisType;       

    }

    private enum MetaDesc {actionCalls, apexPluginCalls, recordCreates, recordDeletes, recordLookups, recordUpdates, subflows}

    class CallOutException extends Exception {}

}