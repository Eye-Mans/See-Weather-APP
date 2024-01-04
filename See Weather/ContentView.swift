//
//  ContentView.swift
//  See Weather
//
//  Created by Lalu Iman Abdullah on 03/01/24.
//

import SwiftUI
import CoreLocation

// Define the ContentView struct, which represents the main view
struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var weatherData: WeatherData?
    
    var body: some View {
        VStack {
            Image("cloud")
                .resizable()
                .frame(width: 200, height: 200)
                .padding(.top, 70)
            // Display weather information if available
            if let weatherData = weatherData {
                Text("\(Int(weatherData.temperature))°c")
                    .foregroundColor(.white)
                    .font(.system(size: 120, weight: .semibold))
                    .padding()
                
                VStack {
                    Text("\(weatherData.locationName)")
                        .foregroundColor(.yellow)
                        .font(.system(size: 40)).bold()
                    Text("\(weatherData.condition)")
                        .padding(.top, 10)
                        .font(.system(size: 30)).bold()
                        .foregroundColor(.white)
                }
                Spacer()
            } else {
                // Display a progress view while weather data is being fetched
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.cyan, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .onAppear {
            // Request location when the view appears
            locationManager.requestLocation()
        }
        .onReceive(locationManager.$location) { location in
            // Fetch weather data when the location is updated
            guard let location = location else { return }
            fetchWeatherData(for: location)
        }
    }
    
    // Fetch weather data for the given location
    private func fetchWeatherData(for location: CLLocation) {
        let apiKey = "Api from weathermap"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&units=metric&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        // Make a network request to fetch weather data
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                
                DispatchQueue.main.async {
                    // Update the weatherData state with fetched data
                    weatherData = WeatherData(locationName: weatherResponse.name, temperature: weatherResponse.main.temp, condition: weatherResponse.weather.first?.description ?? "")
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
}

