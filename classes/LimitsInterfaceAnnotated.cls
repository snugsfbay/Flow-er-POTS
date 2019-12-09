/*
    Works with LimitsChecker and govlimitsDebugger subclasses to enable use with flows and Lightning components
    without requiring the use of parameters to specify which limits to show in debug log
*/
global interface LimitsInterfaceAnnotated {

    /*  Note that only one invocable method is allowed per class
        Reference: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_annotation_InvocableMethod.htm?search_text=invocable%20method
    */    
    void iShowLimits();

    /*
        Note that only static methods can be called from client-side code 
        and shouldn't be mixed with instance methods or properties which return data because...?
        Reference: https://developer.salesforce.com/docs/atlas.en-us.210.0.lightning.meta/lightning/controllers_server_apex_auraenabled_annotation.htm?search_text=auraenabled
    */    
    void aShowLimits();    

    /*
        simplify the user interface for showing limits and unify it here with other user interface options and behaviors
    */
    void showLimits();        
}