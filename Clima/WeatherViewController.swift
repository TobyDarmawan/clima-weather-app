//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "38f7110fd425351833d2be42a3732038"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    var longitude = String()
    var latitude = String()
    var weatherDataModel = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData (url : String, parameters : [String : String]){
        Alamofire.request(url, method: .get, parameters : parameters).responseJSON{
            response in
            if response.result.isSuccess{
                print ("succeeded in getting weather data")
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)

            }
            else{
                print (response.result.error)
                self.cityLabel.text = "Connection issues"
            }
        }
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData (json : JSON){
        print (json)
        if let temp = json ["main"]["temp"].double{
            weatherDataModel.temperature = Int (temp - 273.15)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json ["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition : weatherDataModel.condition)
            updateUIWithWeatherData()
        }
        else{
            cityLabel.text = "weather unavailable"
        }
        
        
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData (){
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = String (weatherDataModel.temperature)
        weatherIcon.image = UIImage (named: weatherDataModel.weatherIconName)
        
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations [locations.count-1]
        if location.horizontalAccuracy>0{
            //locationManager.stopUpdatingLocation()
            longitude = String(location.coordinate.longitude)
            latitude = String(location.coordinate.latitude)
            let params : [String : String] = ["lat":latitude,"lon":longitude,"appid":APP_ID]
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
        
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print (error)
        print ("error in retrieving GPS information")
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    func userEnteredANewCityName(city : String) {
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
        updateUIWithWeatherData()
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
            let changeCityVC = segue.destination as! ChangeCityViewController
            changeCityVC.delegate = self
        }
        
    }
    
    
    
    
}


