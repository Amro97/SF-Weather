
import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getForecastByGeoLocation from '@salesforce/apex/WeatherWidgetController.getForecastByGeoLocation';

const FORECAST_FIELDS = ['Forecast__c.GeoLocation__Longitude__s', 'Forecast__c.GeoLocation__Latitude__s'];

export default class GeoWeatherWidget extends LightningElement {

    err = false;
    errorMsg = 'Weather Widget by GeoLocation is currently unavailable, please make sure that you have geolocation on the record or try again later';
    weatherRes;
    cardTitle;
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: FORECAST_FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            getForecastByGeoLocation({lat: data.fields.GeoLocation__Latitude__s.value, lon: data.fields.GeoLocation__Longitude__s.value})
            .then(r => {
                const res = JSON.parse(r);
                const city = res.city.name?res.city.name:'unknown';
                const country = res.city.country?res.city.country:'unknown';
                this.cardTitle = 'geolocation forecast: '+city+', '+country+'.';
                this.weatherRes = [...res.list];
                this.weatherRes.forEach(forecast => {
                    forecast.weather.forEach(weather => {
                        weather.icon = 'https://openweathermap.org/img/wn/'+weather.icon+'.png';
                    })
                });
                this.err = false;
            })
            .catch(e => {
                this.err = true;
                console.error(JSON.stringify(e, null, 2));
            });
        } else if (error) {
            this.err = true;
            console.error(JSON.stringify(error, null, 2));
        }
    }
}