({

    doInit : function(component, event, helper) { 
        helper.fetchObjects(component);
        // get default object account and its fields          
        var objDetails = component.get("v.outputObject");
        // call the helper function
        helper.fetchValues(component,objDetails);
    },
    
    handleChange : function(component, event, helper) {
        component.set("v.outputFields", event.getParam('value').join(", "));
    }, 

    resetResults: function(component, event, helper) {
        component.set("v.outputFields",'createddate');
        component.set("v.outputObject", event.getParam('value'));
        var objDetails = component.get("v.outputObject");
        helper.fetchValues(component,objDetails);
    },    
    
})