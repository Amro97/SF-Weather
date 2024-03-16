@isTest
public with sharing class WeatherWidgetControllerTest {

    @TestSetup
    static void makeData(){
        Forecast__c fr = new Forecast__c(
            Address__City__s = 'London',
            GeoLocation__Latitude__s = 35.0147035,
            GeoLocation__Longitude__s = 32.2736032
        );
        insert fr;
    }

    @IsTest
    static void getPicklistValuesTest(){
        Map<String,List<Map<String,String>>> stateOptions = WeatherWidgetController.getDependentPicklistValues('Address__StateCode__s');        
        List<WeatherWidgetController.OptionSelect> countryOptions = WeatherWidgetController.getPicklistValues('Address__CountryCode__s');
        
        System.assertNotEquals(null, stateOptions, 'State Options List is empty');
        System.assertNotEquals(0, countryOptions.size(), 'Country Options List is empty');
    }

    @IsTest
    static void updateAddressTest(){
        Forecast__c fr = [SELECT Id, Address__City__s FROM Forecast__c LIMIT 1];
        fr.Address__City__s = 'Tel Aviv';
        String res = WeatherWidgetController.updateAddress(fr);

        System.assertEquals('Success', res, 'Forecast Update failed');
    }

    @IsTest
    static void getWeatherTest(){

        Test.setMock(HttpCalloutMock.class, new WeatherHttpMockResponse());
        Test.startTest();
        String addressRes = WeatherWidgetController.getForecastByAddress('London', null, null);
        String geolocationRes = WeatherWidgetController.getForecastByGeoLocation(32.2736032, 35.0147035);
        Test.stopTest();
        System.assertEquals(true, addressRes.contains('"cod":"200"'), 'fetching Forecast by Address Failed');        
        System.assertEquals(true, geolocationRes.contains('"cod":"200"'), 'fetching Forecast by geolocation Failed');        
    }
}