//
//  ViewController.swift
//  lab03
//
//  Created by Amen George on 2023-11-09.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate{

    @IBOutlet weak var currentLocBtn: UIButton!
    @IBOutlet weak var locView: UILabel!
    @IBOutlet weak var tempView: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var weatherLabel: UILabel!
    private var tempFlag:Bool = false
    private var cTemp:String = "Temperature"
    private var fTemp:String = "Temperature"
    private var backgroundImageView: UIImageView?
    let locManager = CLLocationManager()
    var isDay:Int = 0
    
    struct WeatherResponse:Decodable{
        let location:Location
        let current:Weather    }
    
    struct Location:Decodable{
        let name:String
    }
    
    struct Weather:Decodable{
        let temp_c:Float
        let temp_f:Float
        let is_day:Int
        let condition:WeatherCondition
    }
    
    struct WeatherCondition:Decodable{
        let text:String
        let code:Int
    }
    
    @IBOutlet weak var tempSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayImage(imageName: "snowflake", colours: [.white,.orange])
        
        currentLocBtn.setImage(UIImage(systemName: "location.circle"), for: .normal)
        
        textField.delegate = self
        getLocation()
//        if isDay == 1{
//            setupBackgroundImage("morning")
//        }else{
//            setupBackgroundImage("night")
//        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        getWeather(textField.text ?? "")
        return true
    }
  
    @IBAction func tempSwitchToggled(_ sender: UISwitch) {
        
        if sender.isOn{
            tempFlag = true
            tempView.text = fTemp
        }else{
            tempFlag = false
            tempView.text = cTemp
        }
        
    }
    @IBAction func locTapped(_ sender: Any) {
        getLocation()
    }
    private func setupBackgroundImage(_ day:String) {
        print(day)
        if let existingBackgroundView = backgroundImageView {
                existingBackgroundView.removeFromSuperview()
            }
            
            let backgroundImage = UIImage(named: day)
            backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
            backgroundImageView?.image = backgroundImage
            backgroundImageView?.contentMode = .scaleAspectFill
            
            if let bgImageView = backgroundImageView {
                view.insertSubview(bgImageView, at: 0)
            }
      }
    private func getLocation()
    {
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
            locManager.requestLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let first = locations.first else{
            return
        }
        getWeather("\(first.coordinate.latitude),\(first.coordinate.longitude)")
        print("\(first.coordinate.longitude) | \(first.coordinate.latitude)")
        locManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("\(error)")
    }
    
    @IBAction func searchTapped(_ sender: Any) {
        textField.endEditing(true)
        getWeather(textField.text ?? "")
    }
    
    private func getWeather(_ location:String?){
        guard let location = location else{
            return
        }
        
        guard let url = getUrl(loc: location) else{
            print("could not  get url")
            return
        }
        
        print(url)
        
        let urlSession = URLSession.shared
        
        let dataTask = urlSession.dataTask(with: url) { data, response, err in
            
            guard err == nil else{
                print("error occured")
                return
            }
            
            guard let data = data else{
                print("No data found")
                return
            }
            
            if let weatherResponse = self.parseJson(data: data){
                print(weatherResponse.location.name)
                print(weatherResponse.current.temp_c)
                print(weatherResponse.current.is_day)
                
                DispatchQueue.main.async {
                    self.locView.text = weatherResponse.location.name
                    self.cTemp = "\(weatherResponse.current.temp_c) C"
                    self.fTemp = "\(weatherResponse.current.temp_f) F"
                    self.weatherLabel.text = weatherResponse.current.condition.text
                    print(weatherResponse.current.condition.code)
                    self.isDay=weatherResponse.current.is_day
                    if self.isDay == 1{
                        self.setupBackgroundImage("morning")
                        switch weatherResponse.current.condition.code{
                        case 1000:
                            self.displayImage(imageName: "sun.max", colours: [.white,.orange])
                        case 1003:
                            self.displayImage(imageName: "cloud.sun", colours: [.white,.orange])
                        case 1006,1009:
                            self.displayImage(imageName: "cloud", colours: [.white,.orange])
                        case 1030,1135,1147:
                            self.displayImage(imageName: "cloud.fog", colours: [.white,.orange])
                        case 1063,1180,1186,1072,1189:
                            self.displayImage(imageName: "cloud.sun.rain", colours: [.white,.orange])
                        case 1066,1210,1213,1216,1219,1222,1225,1255,1258,1117:
                            self.displayImage(imageName: "cloud.snow", colours: [.white,.orange])
                        case 1114,1069,1204,1207,1237,1249,1252,1261,1264:
                            self.displayImage(imageName: "cloud.sleet", colours: [.white,.orange])
                        case 1087,1083,1195,1240:
                            self.displayImage(imageName: "cloud.drizzle", colours: [.white,.orange])
                        case 1086,1089,1192,1198,1201,1243,1246:
                            self.displayImage(imageName: "cloud.heavyrain", colours: [.white,.orange])
                        case 1150,1153,1168,1171:
                            self.displayImage(imageName: "cloud.sun.bolt", colours: [.white,.orange])
                        case 1273,1276,1279,1282:
                            self.displayImage(imageName: "cloud.bolt.rain", colours: [.white,.orange])
                        default:
                            print("Invalid code")
                        }
                    }else{
                        self.setupBackgroundImage("night")
                        switch weatherResponse.current.condition.code{
                        case 1000:
                            self.displayImage(imageName: "moon.fill", colours: [.white,.orange])
                        case 1003:
                            self.displayImage(imageName: "cloud.moon", colours: [.white,.orange])
                        case 1006,1009:
                            self.displayImage(imageName: "cloud", colours: [.white,.orange])
                        case 1030,1135,1147:
                            self.displayImage(imageName: "cloud.fog", colours: [.white,.orange])
                        case 1063,1180,1186,1072,1189:
                            self.displayImage(imageName: "cloud.moon.rain", colours: [.white,.orange])
                        case 1066,1210,1213,1216,1219,1222,1225,1255,1258,1117:
                            self.displayImage(imageName: "cloud.snow", colours: [.white,.orange])
                        case 1114,1069,1204,1207,1237,1249,1252,1261,1264:
                            self.displayImage(imageName: "cloud.sleet", colours: [.white,.orange])
                        case 1087,1083,1195,1240:
                            self.displayImage(imageName: "cloud.drizzle", colours: [.white,.orange])
                        case 1086,1089,1192,1198,1201,1243,1246:
                            self.displayImage(imageName: "cloud.heavyrain", colours: [.white,.orange])
                        case 1150,1153,1168,1171:
                            self.displayImage(imageName: "cloud.moon.bolt", colours: [.white,.orange])
                        case 1273,1276,1279,1282:
                            self.displayImage(imageName: "cloud.bolt.rain", colours: [.white,.orange])
                        default:
                            print("Invalid code")
                        }
                    }
                    
                    if self.tempFlag{
                        self.tempView.text = self.fTemp
                    }else{
                        self.tempView.text = self.cTemp
                    }
                }

            }
            
            
            print("network call complete")
        }
        
        dataTask.resume()
        
    }
    
    private func parseJson(data:Data)->WeatherResponse?{
        let decoder = JSONDecoder()
        
        var weather:WeatherResponse?
        
        do{
            weather = try decoder.decode(WeatherResponse.self, from: data)
        }catch{
            print("error decoding")
        }
        return weather
    }
    
    private func getUrl(loc:String)->URL?{
        let baseURL = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "current.json"
        
        let apiKey = "0956c76178e24ba0a2f143105230911"

        guard let url = "\(baseURL)\(currentEndpoint)?key=\(apiKey)&q=\(loc)&aqi=no".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
            return nil
        }
        
        return URL(string: url)
    }
    
    private func displayImage(imageName img:String, colours colors:[UIColor]){
        let config = UIImage.SymbolConfiguration(paletteColors: colors)
        imageView.preferredSymbolConfiguration = config
        imageView.image = UIImage(systemName: img)
    }
    
}

