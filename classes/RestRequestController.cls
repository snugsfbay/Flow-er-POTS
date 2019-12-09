/*

    Description: Returns JSON string result for any specified call to the REST APIs, including Tooling API or Reports API
        Public method getAPI() to use in any code to represent the latest API version # for the current org to make REST requests more dynamic.
    See: Flowexplorer has a valid default use case to call and display the results, for example
        flowInput = {!path},{!method},{!responseFormat},{!bodyContent},{!bodyContentType} 
        '/services/data/v44.0/analytics/reports/00O1U000006JDBU,GET,application/json,,application/json'
    Example Execute Anonymous: 
        List<String> inputList = new List<String>();
        inputList.add('/services/data/v44.0/analytics/reports/00O1U000006JDBU,GET,application/json,,application/json');
        system.debug(restRequestController.service(inputList));
    Design Notes: Flow requires a List for input and a List for output, but there can be a single value in the list. In this case,
        the Flow sends a single string of comma separated values for each request for use in the private buildRequest method.
        Similarly, execute anonymous sends a single string of comma separated values.
        Invocable methods can be called by Apex, they cannot be called by Lightning nor by remote requests from external apps.
    References:
        https://gist.githubusercontent.com/peterknolle/bf9d1811b1256651f8d0/raw/144a4fdbec65fb03db8137c93e098102fbba2e62/RestRequestController.cls
        http://peterknolle.com/rest-api-lightning-component/
        https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_annotation_InvocableMethod.htm

    ToDo: test class, consider pros and cons of making the class public rather than global -- do we want a tool that customers can
        use in their own implementations of Flow?  If not, why not?

*/

global with sharing class RestRequestController {
    
//    public static final String APIV = getAPI(); //String value constant representing current org's latest API version
    public static final String SRVCDATA = '/services/data/';
    public static final String HTTPGET = 'GET';
    public static final String HTTPPOST = 'POST';
    public static final String HTTPPATCH = 'PATCH';
    public static final String APPJSON = 'application/JSON';
    public static final String PRETTYPRINT = 'X-PrettyPrint:1';
    public static final String EMPTY = '';
    
    public static final String REQPATH = 'path';
    public static final String REQMETHOD = 'method';
    public static final String REQRESPONSEFORMAT = 'responseFormat';
    public static final String REQBODYCONTENT = 'bodyContent';
    public static final String REQBODYCONTENTTYPE = 'bodyContentType';
    


    @InvocableMethod(label='Get REST response' description='Pass list of strings and Return the Response as list of strings.')
    // pass 0: path 1: method 2: responseFormat 3: bodyContent 4: bodyContentType
    // response 0: statusCode (string.valueOf) 1: bodyContent 2: status message
    // return value is JSON string of response bodyContent
    global static List<String> service(List<String> flowInput) {
        //system.debug(flowInput);
        List<String> tmpStrings = new List<String>();
        List<String> requestStrings = new List<String>();
        if (flowInput[0].contains('query')){ // handle query strings to allow commas between query fields
            if (flowInput[0].contains(HTTPGET)){ // only GET allowed with REST queries
                tmpStrings = flowInput[0].split(','+HTTPGET+',');
                requestStrings.add(tmpStrings[0]);
                requestStrings.add(HTTPGET);  
            }
            requestStrings.addAll(tmpStrings[1].split(','));                
        } else {
            requestStrings = flowInput[0].split(',');
        }
 
//        system.debug(requestStrings);       
        String path = requestStrings[0];
        String method = requestStrings[1];
        String responseFormat = requestStrings[2];
        String bodyContent = requestStrings[3];
        String bodyContentType  = requestStrings[4];

        RequestStrings req = new RequestStrings(path, method, responseFormat, bodyContent, bodyContentType);
        HttpResponse httpRes = makeRequest(req);
        List<String> restRes = buildResponse(httpRes);
        
        return restRes;
    }
    
    public static HttpResponse makeRequest(RequestStrings req){
        HttpRequest request = buildRequest(req);
        HttpResponse httpRes = sendRequest(request);
        
        return httpRes;
    }        

    private static HttpRequest buildRequest(RequestStrings req) {
        Map<String, String> reqMap = req.getRequestMap();
        HttpRequest request = new HttpRequest();        
        
        request.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + reqMap.get(REQPATH));
        request.setMethod(reqMap.get(REQMETHOD));
        
        if (!String.isBlank(reqMap.get(REQBODYCONTENT))) {
            request.setBody(reqMap.get(REQBODYCONTENT));
            request.setHeader('Content-Type', reqMap.get(REQBODYCONTENTTYPE)); 
        }
        
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        request.setHeader('ACCEPT', reqMap.get(REQRESPONSEFORMAT));
        
        system.debug(request);
        return request;
    }   
              
    private static HttpResponse sendRequest(HttpRequest request) {    
        return new Http().send(request);
    }
    
    private static List<String> buildResponse(HttpResponse httpRes) {
        String restRes;
        List<String> jsonList = new List<String>();
        
        if (httpRes.getStatusCode() == 200 || httpRes.getStatusCode() == 201 || httpRes.getStatusCode() == 204){
            restRes = JSON.serializePretty(JSON.deserializeUntyped(httpRes.getBody())); // more like prettyprint 
            restRes = restRes.replace(' ','\u00A0'); //https://salesforce.stackexchange.com/questions/154596/unicode-non-breaking-space-is-not-considered-white-space
        } else {
            restRes = 'Request/response problem: ' +' '+  httpRes.getStatusCode()  +' '+ httpRes.getStatus();  
            throw new CallOutException (restRes);          
        }        
        jsonList.add(restRes);
        // commenting this out for now
        //system.debug(jsonList);
        return jsonList;
    }
/*
system.debug(RESTRequestController.APIV);
switching this to public so that the method doesn't run each and every time we load this class.
so that we consume fewer API calls
*/        
    @TestVisible
    public static String getAPI(){
        RequestStrings req = new RequestStrings(SRVCDATA, HTTPGET, APPJSON, EMPTY, APPJSON);
        HttpResponse httpRes = makeRequest(req);        

        List<VersionResponse> versionList = (List<VersionResponse>)System.JSON.deserialize(httpRes.getBody(), List<VersionResponse>.class);
        String restRes = versionList[versionList.size()-1].version;
        return restRes;        
    }
    
    private class VersionResponse{
        public String label; 
        public String url; 
        public String version; 
    }
    
    public class RequestStrings{
        private String path;
        private String method; 
        private String responseFormat; 
        private String bodyContent; 
        private String bodyContentType;

/*
RESTRequestController.RequestStrings req = new RESTRequestController.RequestStrings('a','b','c','d','e');
system.debug(req);
*/        
        public RequestStrings(String path, String method, String responseFormat, String bodyContent, String bodyContentType){
            this.path = path;
            this.method = method;
            this.responseFormat = responseFormat;
            this.bodyContent = bodyContent;
            this.bodyContentType = bodyContentType;
        }

/*
Map<string, string> reqmap = req.getRequestMap();
system.debug(reqmap);
*/
        public Map<String, String> getRequestMap(){
            Map<String, String> requestMap = new Map<String, String>();
            requestMap.put(REQPATH, this.path);
            requestMap.put(REQMETHOD, this.method);
            requestMap.put(REQRESPONSEFORMAT, this.responseFormat);
            requestMap.put(REQBODYCONTENT, this.bodyContent);
            requestMap.put(REQBODYCONTENTTYPE, this.bodyContentType);
            return requestMap;
        }
        
    }    
    
    class CallOutException extends Exception {}

}