/*
	Beginnings of test class.
	For now, it can demonstrate the capabilities of the RestRequestController for POST and DELETE
	postTest method Posts an Account record.
	deleteTest method Deletes the Account record.

	Refactored all methods to call getAPI() rather than using the APIV property from the controller 
		class so that the property could be depricated.  
*/
//@isTest
public class RestRequestControllerTEST {

//	@isTest
    public static void postTest(){
        String accJSON = '{  "name" : "Wingo Ducks",  "phone" : "707-555-1234",  "website" : "www.wingo.ca.us"}';

        String path = '/services/data/v'+ RestRequestController.getAPI() +'/sobjects/Account';
        String method = RestRequestController.HTTPPOST;
        String responseFormat = RestRequestController.APPJSON;
        String bodyContent = accJSON;
        String bodyContentType = RestRequestController.APPJSON;

        RestRequestController.RequestStrings req = new RestRequestController.RequestStrings(path, method, responseFormat, bodyContent, bodyContentType);
		HttpResponse httpRes = RestRequestController.makeRequest(req);
        
        String restRes;
        List<String> jsonList = new List<String>();
        
        if (httpRes.getStatusCode() == 201){
            restRes = JSON.serializePretty(JSON.deserializeUntyped(httpRes.getBody())); // more like prettyprint 
        } else {
			restRes = 'Request/response problem: ' +' '+  httpRes.getStatusCode()  +' '+ httpRes.getStatus();  
            throw new CallOutException (restRes);          
        }        
        jsonList.add(restRes);
        system.debug(jsonList);
        
        system.assert([select Count() from Account where name = 'Wingo Ducks'] == 1);
        
    }  
    
    public static void deleteTest(){
        String aid = [SELECT id FROM Account WHERE Name = 'Wingo Ducks' LIMIT 1].id;
        String path = '/services/data/v'+ RestRequestController.getAPI() +'/sobjects/Account/'+aid;
        String method = 'DELETE';
        String responseFormat = RestRequestController.APPJSON;
        String bodyContent = RestRequestController.EMPTY;
        String bodyContentType = RestRequestController.APPJSON;

        RestRequestController.RequestStrings req = new RestRequestController.RequestStrings(path, method, responseFormat, bodyContent, bodyContentType);
		HttpResponse httpRes = RestRequestController.makeRequest(req);
        
        String restRes;
        List<String> jsonList = new List<String>();
        
        if (httpRes.getStatusCode() == 204){
            restRes = httpRes.getBody();  
        } else {
			restRes = 'Request/response problem: ' +' '+  httpRes.getStatusCode()  +' '+ httpRes.getStatus();  
            throw new CallOutException (restRes);          
        }        
        jsonList.add(restRes);
        system.debug(jsonList);  
        
        system.assert([select Count() from Account where name = 'Wingo Ducks'] == 0);
    }

    public static void postTestResource(){
        String base64EncodedBody = EncodingUtil.base64Encode(Blob.valueof('Just a TEST'));

        String path = '/services/data/v'+ RestRequestController.getAPI() +'/tooling/sobjects/StaticResource';
        String method = RestRequestController.HTTPPOST;
        String responseFormat = RestRequestController.APPJSON;
        String bodyContent = '{"Name":"TestAPI"'+
                                ',"ContentType":"text/csv"'+
            					',"Description":"Written via API by RESTRequestControllerTEST"'+
                                ',"Body":"'+ base64EncodedBody +'"'+
                                ',"CacheControl":"Public"}';
        String bodyContentType = RestRequestController.APPJSON;

        RestRequestController.RequestStrings req = new RestRequestController.RequestStrings(path, method, responseFormat, bodyContent, bodyContentType);
		HttpResponse httpRes = RestRequestController.makeRequest(req);
        
        String restRes;
        List<String> jsonList = new List<String>();
        
        if (httpRes.getStatusCode() == 201){
            restRes = JSON.serializePretty(JSON.deserializeUntyped(httpRes.getBody())); // more like prettyprint 
        } else {
      restRes = 'Request/response problem: ' +' '+  httpRes.getStatusCode()  +' '+ httpRes.getStatus();  
            throw new CallOutException (restRes);          
        }        
        jsonList.add(restRes);
        system.debug(jsonList);

        system.assert([select Count() from StaticResource where name = 'TestAPI'] == 1);
    }

    public static void deleteTestResource(){
        String rid = [SELECT id FROM StaticResource WHERE Name = 'TestAPI' OR Name ='TestAPIv2' LIMIT 1].id;
        String path = '/services/data/v'+ RestRequestController.getAPI() +'/tooling/sobjects/StaticResource/'+rid;
        String method = 'DELETE';
        String responseFormat = RestRequestController.APPJSON;
        String bodyContent = RestRequestController.EMPTY;
        String bodyContentType = RestRequestController.APPJSON;

        RestRequestController.RequestStrings req = new RestRequestController.RequestStrings(path, method, responseFormat, bodyContent, bodyContentType);
		HttpResponse httpRes = RestRequestController.makeRequest(req);
        
        String restRes;
        List<String> jsonList = new List<String>();
        
        if (httpRes.getStatusCode() == 204){
            restRes = httpRes.getBody();  
        } else {
			restRes = 'Request/response problem: ' +' '+  httpRes.getStatusCode()  +' '+ httpRes.getStatus();  
            throw new CallOutException (restRes);          
        }        
        jsonList.add(restRes);
        system.debug(jsonList);  
        
        system.assert([select Count() from StaticResource where name = 'TestAPI'] == 0);
    }  
    
// /services/data/v45.0/tooling/sobjects/ValidationRule/03dB0000000ALSA?_HttpMethod=PATCH
// {"Metadata" : {"active" : false, "errorConditionFormula" : "Id == 'a'", "errorMessage" : "This ID is invalid" }}
//{"active":true,"urls":null,"shouldEvaluateOnClient":null,"errorMessage":"This ID is invalid","errorDisplayField":null,"errorConditionFormula":"Id == 'a'","description":null}
// Currently the tooling api does not support patching multiple records or retrieving 
// the metadata portion of the Validation Rule with a query that results in multiple records
// "Query this field only if the query result contains no more than one record. Otherwise, an error is returned. If more than one record exists, use multiple queries to retrieve the records. This limit protects performance."
    public static void getPatchTestVRule(){
        // Limit query to one record at a time, based on REST API doc and required fields for Patch
        String path = '/services/data/v'+ RestRequestController.getAPI() +'/tooling/query?q=SELECT+ID,+active,+metadata,+errorMessage+FROM+VALIDATIONRULE+WHERE+Active=true+LIMIT+1';
        String method = RestRequestController.HTTPGET;
        String responseFormat = RestRequestController.APPJSON;
        String bodyContent = '';
        String bodyContentType = RestRequestController.APPJSON;

        RestRequestController.RequestStrings req = new RestRequestController.RequestStrings(path, method, responseFormat, bodyContent, bodyContentType);
		HttpResponse httpRes = RestRequestController.makeRequest(req);
        
        String restRes;
        
        if (httpRes.getStatusCode() == 200){            
            Map<String, Object> objMap = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());
            List<Object> vrRecords = (List<Object>)objMap.get('records');
            system.debug(vrRecords);
            Map<String, Object> thisVR = (Map<String, Object>)vrRecords[0];
            String thisID = (String)thisVR.get('Id');
            path = '/services/data/v'+ RestRequestController.getAPI() +'/tooling/sobjects/ValidationRule/'+ thisID +'?_HttpMethod=PATCH';
			//system.debug(JSON.serialize(thisVR.get('Metadata')));
            method = RestRequestController.HTTPPOST;
            bodyContent = '{"Metadata" :'+ JSON.serialize(thisVR.get('Metadata')) +'}';
            bodyContent = bodyContent.replace('"active":true', '"active":false');
//            system.debug(bodyContent);
	        req = new RestRequestController.RequestStrings(path, method, responseFormat, bodyContent, bodyContentType);
			httpRes = RestRequestController.makeRequest(req);
        } else {
			restRes = 'Request/response problem: ' +' '+  httpRes.getStatusCode()  +' '+ httpRes.getStatus();  
            throw new CallOutException (restRes);          
        }        
		               
    }

    
    
// /v45.0/tooling/composite/sobjects/?_HttpMethod=PATCH Tooling currently supports Flexipages only 
    public static void compositeTestResource(){
        String base64EncodedBody = EncodingUtil.base64Encode(Blob.valueof('Just a TEST'));

        String path = '/services/data/v'+ RestRequestController.getAPI() +'/composite/sobjects/?_HttpMethod=PATCH';
        String method = RestRequestController.HTTPPOST;
        String responseFormat = RestRequestController.APPJSON;
        String bodyContent = '{'+
                               '"allOrNone" : false,'+
                               '"records" : [{"attributes" : {"type" : "StaticResource"},'+
                                    '"Name":"TestAPI"'+
                                    ',"Id" : "0811U000001kFSXQA2"'+
                                    ',"Description":"Written via API by RESTRequestControllerTEST"'+
                                    ',"Body":"'+ base64EncodedBody +'"'+
                                    ',"CacheControl":"Public"}'+
                                 ']}';
        String bodyContentType = RestRequestController.APPJSON;

        RestRequestController.RequestStrings req = new RestRequestController.RequestStrings(path, method, responseFormat, bodyContent, bodyContentType);
		HttpResponse httpRes = RestRequestController.makeRequest(req);
        
        String restRes;
        List<String> jsonList = new List<String>();
        
        if (httpRes.getStatusCode() == 201){
            restRes = JSON.serializePretty(JSON.deserializeUntyped(httpRes.getBody())); // more like prettyprint 
        } else {
      		restRes = 'Request/response problem: ' +' '+  httpRes.getStatusCode()  +' '+ httpRes.getStatus();  
            throw new CallOutException (restRes);          
        }        
        jsonList.add(restRes);
        system.debug(jsonList);

        system.assert([select Count() from StaticResource where name = 'TestAPI'] == 1);        
    }    

//	@isTest
    public static void patchTestResource(){
        String base64EncodedBody = EncodingUtil.base64Encode(Blob.valueof('Just a TEST'));

        String path = '/services/data/v'+ RestRequestController.getAPI() +'/tooling/sobjects/StaticResource';
        String method = RestRequestController.HTTPPOST;
        String responseFormat = RestRequestController.APPJSON;
        String bodyContent = '{"Name":"TestAPI"'+
                                ',"ContentType":"text/csv"'+
            					',"Description":"Written via API by RESTRequestControllerTEST"'+
                                ',"Body":"'+ base64EncodedBody +'"'+
                                ',"CacheControl":"Public"}';
        String bodyContentType = RestRequestController.APPJSON;

        RestRequestController.RequestStrings req = new RestRequestController.RequestStrings(path, method, responseFormat, bodyContent, bodyContentType);
		HttpResponse httpRes = RestRequestController.makeRequest(req);
        
        String restRes;
        List<String> jsonList = new List<String>();
        
        if (httpRes.getStatusCode() == 201){
            restRes = JSON.serializePretty(JSON.deserializeUntyped(httpRes.getBody())); // more like prettyprint 
        } else {
      		restRes = 'Request/response problem: ' +' '+  httpRes.getStatusCode()  +' '+ httpRes.getStatus();  
            throw new CallOutException (restRes);          
        }        
        jsonList.add(restRes);
        system.debug(jsonList);

        system.assert([select Count() from StaticResource where name = 'TestAPI'] == 1);
        
        base64EncodedBody = EncodingUtil.base64Encode(Blob.valueof('Just a PATCH TEST'));
        String existingID = [select id from StaticResource where name = 'TestAPI' LIMIT 1].id;
        path = '/services/data/v'+ RestRequestController.getAPI() +'/tooling/sobjects/StaticResource/'+ existingID +'/?_HttpMethod=PATCH';
        method = 'POST';
        responseFormat = RestRequestController.APPJSON;
        bodyContent = '{'+
                        '"Name":"TestAPIv2"'+
                        ',"ContentType":"text/csv"'+
                        ',"Description":"Written via API PATCH by RESTRequestControllerTEST"'+
                        ',"Body":"'+ base64EncodedBody +'"'+
                        ',"CacheControl":"Public"'+
            			'}';
        bodyContentType = RestRequestController.APPJSON;

        req = new RestRequestController.RequestStrings(path, method, responseFormat, bodyContent, bodyContentType);
		httpRes = RestRequestController.makeRequest(req);
        
        jsonList = new List<String>();
        
        if (httpRes.getStatusCode() == 204){
            restRes = JSON.serializePretty(JSON.deserializeUntyped(httpRes.getBody())); // more like prettyprint 
        } else {
      		restRes = 'Request/response problem: ' +' '+  httpRes.getStatusCode()  +' '+ httpRes.getStatus();  
            throw new CallOutException (restRes);          
        }        
        jsonList.add(restRes);
        system.debug(jsonList);

        system.assert([select Count() from StaticResource where name = 'TestAPI'] == 0);        
        system.assert([select Count() from StaticResource where name = 'TestAPIv2'] == 1);        

        
    }
    
}