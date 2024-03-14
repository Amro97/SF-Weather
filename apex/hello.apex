// System.debug(123);
// https://api.openweathermap.org/data/3.0/onecall?lat=33.44&lon=-94.04&exclude=hourly,daily&appid={API key}

Http http = new Http();
HttpRequest req = new HttpRequest();
req.setMethod('GET');
// req.setEndPoint('https://api.openweathermap.org/data/2.5/forecast?cnt=8&lat=32.2736032&lon=35.0147035&appid=0eecf413b93be374feccb1c64f3f385a&units=metric');
// req.setEndPoint('https://api.open-meteo.com/v1/forecast?latitude=32.2736032&longitude=35.0147035&hourly=temperature_2m,weather_code&daily=&timezone=auto&start_date=2024-03-15&end_date=2024-03-15&time_mode=time_interval');
// req.setEndPoint('https://api.open-meteo.com/v1/forecast?latitude=32.2736032&longitude=35.0147035&hourly=temperature_2m,weather_code&daily=&timezone=auto&start_date=2024-03-15&end_date=2024-03-15&time_mode=time_interval');
req.setEndPoint('https://geocoding-api.open-meteo.com/v1/search?name=londona&count=1');
HttpResponse res = http.Send(req);
System.debug(res.getBody());