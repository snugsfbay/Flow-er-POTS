global class FlowInputController {

    @InvocableMethod(label='TESTING' description='Pass multiple params.')
    global static void inputTest(List<FlowInputObj> flowInput) {
        system.debug(flowInput);

    }
 

    
    global class FlowInputObj {
    
        @InvocableVariable
        global String testHarnessDevName;

        @InvocableVariable
        global String selectedObject;    

        @InvocableVariable
        global String selectedFields;       

                                                           
    }

    class CallOutException extends Exception {}

}