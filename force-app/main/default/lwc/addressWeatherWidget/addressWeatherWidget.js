
import { LightningElement, api, wire } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import getForecastByAddress from '@salesforce/apex/WeatherWidgetController.getForecastByAddress';
import updateAddress from '@salesforce/apex/WeatherWidgetController.updateAddress';
import getPicklistValues from '@salesforce/apex/WeatherWidgetController.getPicklistValues';
import getDependentPicklistValues from '@salesforce/apex/WeatherWidgetController.getDependentPicklistValues';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const FORECAST_FIELDS = [
    'Forecast__c.Address__City__s', 
    'Forecast__c.Address__CountryCode__s', 
    'Forecast__c.Address__PostalCode__s',
    'Forecast__c.Address__Street__s',
    'Forecast__c.Address__StateCode__s'
];
const ADDRESS_FORM = {
    Address__City__s: '',
    Address__CountryCode__s: '',
    Address__PostalCode__s: '',
    Address__StateCode__s: '',
    Address__Street__s: ''
};

export default class AddressWeatherWidget extends LightningElement {

    err = false;
    errorMsg = 'Weather Widget by Address is currently unavailable, please make sure that you have at least proper city name or try again later.';
    weatherRes;
    cardTitle;
    initialForm;
    addressForm = {...ADDRESS_FORM};
    countryOptions;
    stateOptionsMap;
    stateOptions;
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: FORECAST_FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            this.addressForm.Id = this.recordId;
            this.addressForm.Address__City__s = data.fields.Address__City__s.value;
            this.addressForm.Address__CountryCode__s = data.fields.Address__CountryCode__s.value;
            this.addressForm.Address__PostalCode__s = data.fields.Address__PostalCode__s.value;
            this.addressForm.Address__Street__s = data.fields.Address__Street__s.value;
            this.addressForm.Address__StateCode__s = data.fields.Address__StateCode__s.value;
            this.initialForm = {...this.addressForm};
            getForecastByAddress({
                city: data.fields.Address__City__s.value,
                zipCode: data.fields.Address__PostalCode__s.value,
                countryCode: data.fields.Address__CountryCode__s.value
            })
            .then(r => {
                const res = JSON.parse(r);
                const city = res.city.name?res.city.name:'unknown';
                const country = res.city.country?res.city.country:'unknown';
                this.cardTitle = 'address forecast: '+city+', '+country+'.';
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
                console.error('Inner process Error', JSON.stringify(e, null, 2));
            });
        } else if (error) {
            this.err = true;
            console.error('Wire Error:', JSON.stringify(error, null, 2));
        }
    }

    handleInputChange(e){
        if(e.target.name === 'Address__CountryCode__s'){
            this.updateStateOptions(e.target.value);
            this.addressForm.Address__CountryCode__s = this.countryOptions.find(opt => opt.value === e.detail.value).value;
            this.addressForm.Address__StateCode__s = null;
        }
        if(e.target.name === 'Address__StateCode__s'){
            this.addressForm.Address__StateCode__s = this.stateOptions.find(opt => opt.value === e.detail.value).value;
        }
        this.addressForm[e.target.name] = e.target.value;
        // console.log('form:', JSON.stringify(this.addressForm, null, 2));
    }

    updateStateOptions(countryCode){
        if(this.stateOptionsMap[countryCode]){
            this.stateOptions = this.stateOptionsMap[countryCode];
        } else {
            this.stateOptions = [];
        }
    }

    onSave(){
        updateAddress({forecastAddressInfo: this.addressForm})
        .then(r => {
            updateRecord({ fields: { Id: this.recordId }});
            const toastEvent = new ShowToastEvent({
                title: 'Success',
                message: 'Record page will refresh shortly.',
                variant: 'success',
            });
            this.dispatchEvent(toastEvent);
        })
        .catch(e => {
            console.error('Address Update Error:', JSON.stringify(e, null, 2));
            const toastEvent = new ShowToastEvent({
                title: 'Fail',
                message: 'Updating Record Address failed.',
                variant: 'error',
            });
            this.dispatchEvent(toastEvent);
        })
    }

    connectedCallback(){
        getDependentPicklistValues({fieldName: 'Address__StateCode__s'})
        .then(stateRes => {
            this.stateOptionsMap = stateRes;
            getPicklistValues({fieldName: 'Address__CountryCode__s'})
            .then(countryRes => {
                this.countryOptions = countryRes;
                this.updateStateOptions(this.addressForm.Address__CountryCode__s);
            })
            .catch(err => {
                console.error('Countries Error:', JSON.stringify(error, null, 2));
            });
        })
        .catch(err => {
            console.error('States Error:', JSON.stringify(error, null, 2));
        });
    }
}