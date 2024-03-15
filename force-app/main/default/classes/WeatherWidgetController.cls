public with sharing class WeatherWidgetController {

    private static Weather_Widget_Config__mdt getWeatherWidgetConfigs(){
        return [SELECT API_Key__c, Forecast_Count__c, Measurement_Unit__c FROM Weather_Widget_Config__mdt LIMIT 1];
    }

    @AuraEnabled
    public static String getForecastByGeoLocation(Decimal lat, Decimal lon){
        try {
            Weather_Widget_Config__mdt configs = getWeatherWidgetConfigs();
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndPoint('callout:OpenWeatherAPI'
                +'?cnt='+configs.Forecast_Count__c
                +'&lat='+lat
                +'&lon='+lon
                +'&appid='+configs.API_Key__c
                +'&units='+configs.Measurement_Unit__c);
            HttpResponse res = http.Send(req);
            return res.getBody();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()+e.getStackTraceString());
        }
    }
}