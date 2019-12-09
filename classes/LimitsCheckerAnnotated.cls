/*
    Virtual class template/example to ensure basic functionality for the code when called from Apex, PB or LC 

    Problems with this design pattern:
        Invocable and AuraEnabled methods must be static
        Super cannot be referenced in a static context so 
            concrete child cannot have static annotation and reference parent method
        -virtual cannot be static,
        -invokable and auraenabled must be static. 
        Static methods cannot be overridden in child classes.
        Child cannot inherit static annotated methods and must implement the interface.
*/
global virtual class LimitsCheckerAnnotated implements LimitsInterfaceAnnotated{ 

//    @invocableMethod
    global virtual void iShowLimits(){ //should be static to be invocable
    }    // note that static cannot be override, so I can't extend this class

//    @AuraEnabled
    global virtual void aShowLimits(){ //should be static to be auraenabled
    }   

    global virtual void showLimits(){
    }
    /*
        inner class can have an AuraEnabled method, but how can I call it?
    */   
    public virtual class LimitsObj extends LimitsChecker{   
        public override Map<String,Integer> getLimits(){        
            return new Map<String,Integer>();                                    
        }
    }
    
}