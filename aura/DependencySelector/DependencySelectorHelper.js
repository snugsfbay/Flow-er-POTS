({
    
	fetchObjects : function(component, objDetails) {
		var action = component.get("c.getAccessibleObjects");

        action.setCallback(this, function(response){
            if (response.getState() == "SUCCESS") {
                var results = response.getReturnValue();
                var objMap = [];
                for (var key in results){
                    objMap.push({label: results[key], value: key});
                }
            	component.set("v.QueryObjects",objMap);
        }else{
            alert('Unable to get Object List '+ response.getState());
        }                  
        });
        $A.enqueueAction(action);
	},    
    
	fetchValues : function(component, objDetails) {
		var action = component.get("c.getAccessibleFields");
        action.setParams({
            'obj' : objDetails
        });
        action.setCallback(this, function(response){
            if (response.getState() == "SUCCESS") {
                var results = response.getReturnValue();
                var fieldMap = [];
                for (var key in results){
                    fieldMap.push({label: results[key], value: key});
                }
            	component.set("v.FieldOptions",fieldMap);
        }else{
            alert('Unable to get Field List '+ response.getState());
        }                  
        });
        $A.enqueueAction(action);
	},
    
})