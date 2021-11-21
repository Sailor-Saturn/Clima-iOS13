

import Foundation
import CoreLocation
protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}
struct WeatherManager {
    let url = "https://api.openweathermap.org/data/2.5/weather?appid=2ce9e2cfcc8c05dd27853f58210fed8b&units=metric"
    var delegate: WeatherManagerDelegate?

    func fetchWeather(cityName: String){
        let urlString = "\(url)&q=\(cityName)"
        
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, url, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func fetchWeather(_ lat: CLLocationDegrees,_ lon: CLLocationDegrees) {
        let urlString = "\(url)&lat=\(lat)&lon=\(lon)"
        
        performRequest(with: urlString)
    }
}
