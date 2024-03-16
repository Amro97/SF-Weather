@isTest
global class WeatherHttpMockResponse implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setBody('{"cod":"200","message":0,"cnt":1,"list":[{"dt":1710622800,"main":{"temp":10.14,"feels_like":9.19,"temp_min":10,"temp_max":10.14,"pressure":1020,"sea_level":1020,"grnd_level":1015,"humidity":76,"temp_kf":0.14},"weather":[{"id":500,"main":"Rain","description":"light rain","icon":"10n"}],"clouds":{"all":75},"wind":{"speed":3.67,"deg":174,"gust":10.45},"visibility":10000,"pop":0.25,"rain":{"3h":0.18},"sys":{"pod":"n"},"dt_txt":"2024-03-16 21:00:00"}],"city":{"id":2643743,"name":"London","coord":{"lat":51.5085,"lon":-0.1257},"country":"GB","population":1000000,"timezone":0,"sunrise":1710569498,"sunset":1710612392}}');
        res.setStatusCode(200);
        res.setStatus('OK');
        return res;
    }
}