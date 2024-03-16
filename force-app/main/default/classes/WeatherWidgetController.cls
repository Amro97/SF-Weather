public with sharing class WeatherWidgetController {

    public class OptionSelect{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
  
        OptionSelect(String value, String label){
            this.label = label;
            this.value = value;
        }
    }  

    private static Weather_Widget_Config__mdt getWeatherWidgetConfigs(){
        return [SELECT API_Key__c, Forecast_Count__c, Measurement_Unit__c FROM Weather_Widget_Config__mdt LIMIT 1];
    }

    private static String callOpenWeatherAPI(String params){
        Weather_Widget_Config__mdt configs = getWeatherWidgetConfigs();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndPoint('callout:OpenWeatherAPI'
            + '?cnt=' + configs.Forecast_Count__c
            + '&appid=' + configs.API_Key__c
            + '&units=' + configs.Measurement_Unit__c
            + params);
        HttpResponse res = http.Send(req);
        return res.getBody();
    }

    @AuraEnabled(cacheable=true)
    public static String getForecastByGeoLocation(Decimal lat, Decimal lon){
        try {
            String queryParams = '&lat='+lat+'&lon='+lon;
            return callOpenWeatherAPI(queryParams); 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()+e.getStackTraceString());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getForecastByAddress(String city, String zipCode, String countryCode){
        try {
            String queryParams = '&q='+city;
            queryParams += zipCode != null ? ','+zipCode : '';
            queryParams += countryCode != null ? ','+countryCode : '';
            return callOpenWeatherAPI(queryParams);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()+e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String updateAddress(Forecast__c forecastAddressInfo){
        try {
            update forecastAddressInfo;
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()+e.getStackTraceString());
        }
    }

    @AuraEnabled(cacheable = true)
    public static List<OptionSelect> getPicklistValues(String fieldName){
        try {
            list<OptionSelect> ret = new List<OptionSelect>(); 
            Sobject object_name = new Forecast__c();
            Schema.sObjectType sobject_type = object_name.getSObjectType(); //grab the sobject that was passed
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
            for (Schema.PicklistEntry a : field_map.get(fieldName).getDescribe().getPickListValues()) { //for all values in the picklist list
                  ret.add(new OptionSelect(a.getValue(), a.getLabel())); //add the value and label to our final list
            }
            return ret;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()+e.getStackTraceString());
        }
    }

    @AuraEnabled(cacheable = true)
    public static Map<String, List<Map<String,String>>> getDependentPicklistValues(String fieldName){
        try {
            Map<String, List<String>> ret = new Map<String, List<String>>(); 
            Sobject object_name = new Forecast__c();
            Schema.sObjectType sobject_type = object_name.getSObjectType(); //grab the sobject that was passed
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
            return getDependentPicklistValues2(field_map.get(fieldName));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()+e.getStackTraceString());
        }
    }
  
    private static Map<String, List<Map<String,String>>> getDependentPicklistValues2(Schema.sObjectField dependToken) {
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null) {
            return new Map<String, List<Map<String,String>>>();
        }
     
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
     
        //ValidFor is encrypted (base64 formation) field on the schema of picklist entry. 
        //The next algorithm is to decript the value of validFor
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<Map<String,String>>> dependentPicklistValues = new Map<String,List<Map<String,String>>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                        String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                            (controlEntries == null
                                    ?   (Object) (index == 1)
                                    :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getValue() : null)
                            );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<Map<String,String>>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(
                        new Map<String,String>{
                            'label' => entry.getLabel(),
                            'value' => entry.getValue()
                        }
                    );
                }
            }
        }
        return dependentPicklistValues;
    }  
}