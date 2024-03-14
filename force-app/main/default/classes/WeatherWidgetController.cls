public with sharing class WeatherWidgetController {

    @AuraEnabled
    public static String getForecastByGeoLocation(Decimal lat, Decimal lon){
        try {
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndPoint('https://api.openweathermap.org/data/2.5/forecast?cnt=8&lat='+lat+'&lon='+lon+'&appid=0eecf413b93be374feccb1c64f3f385a&units=metric');
            HttpResponse res = http.Send(req);
            return res.getBody();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}