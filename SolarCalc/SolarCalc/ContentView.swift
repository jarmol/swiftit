//
//  ContentView.swift
//  SolarCalc for iPhone 17 Pro simulator
//  Using the new data modell - all data in one table
//  not using calendar base
//  Created by Jarmo Lammi on 20.10.2025.
//

import SwiftUI

// MARK: - Data Model
struct City: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
    // Use canonical TimeZone identifier (DST handled automatically by Foundation).
    let timeZoneID: String // Not used yet here!

    var timeZone: TimeZone {
        TimeZone(identifier: timeZoneID) ?? .gmt
    }
}

struct ContentView: View {
    // Bind the selection directly to a City for safety and clarity.
    @State private var selectedCity: City
    
    // Keep the cities list in one place and reuse it for both the data and default selection.
    private static let defaultCities: [City] = [
        City(name: "Helsinki",          latitude: 60.1695, longitude: 24.9354,  timeZoneID: "Europe/Helsinki"),
        City(name: "London",            latitude: 51.5074, longitude: -0.1278,  timeZoneID: "Europe/London"),
        City(name: "Stockholm",         latitude: 59.3293, longitude: 18.0686,  timeZoneID: "Europe/Stockholm"),
        City(name: "Oslo",              latitude: 59.9139, longitude: 10.7522,  timeZoneID: "Europe/Oslo"),
        City(name: "Berlin",            latitude: 52.5200, longitude: 13.4050,  timeZoneID: "Europe/Berlin"),
        City(name: "München",           latitude: 48.1380, longitude: 11.5750,  timeZoneID: "Europe/Berlin"),
        City(name: "Wien",              latitude: 48.2195, longitude: 16.3785,  timeZoneID: "Europe/Vienna"),
        City(name: "New York",          latitude: 40.7128, longitude: -74.0059,  timeZoneID: "America/New_York"),
        City(name: "Washington D.C.",   latitude: 38.9050, longitude: -77.0160, timeZoneID: "America/New_York"),
        City(name: "Anchorage Alaska",  latitude: 61.1830, longitude: -149.883, timeZoneID: "America/Anchorage"),
        City(name: "Madrid",            latitude: 40.4190, longitude: -3.6930,  timeZoneID: "Europe/Madrid"),
        City(name: "Malaga",            latitude: 36.7200, longitude: -4.4150,  timeZoneID: "Europe/Madrid"),
        City(name: "Kemi",              latitude: 65.7360, longitude: 24.5560,  timeZoneID: "Europe/Helsinki"),
        City(name: "Oulu",              latitude: 65.0140, longitude: 25.4730,  timeZoneID: "Europe/Helsinki"),
        City(name: "Rovaniemi",         latitude: 66.5020, longitude: 25.7240,  timeZoneID: "Europe/Helsinki"),
        City(name: "Utsjoki",           latitude: 69.90954, longitude: 27.0295, timeZoneID: "Europe/Helsinki"),
        City(name: "Tokyo, Japan",      latitude: 35.7000, longitude: 139.7700, timeZoneID: "Asia/Tokyo"),
        City(name: "Sydney, Australia", latitude: -33.8700, longitude: 151.2200, timeZoneID: "Australia/Sydney"),
    ]
    
    let cities: [City] = Self.defaultCities
    
    init() {
        // Default to the first city.
        _selectedCity = State(initialValue: Self.defaultCities[0])
    }
    
    // edellinen ennen var body alkua!
    
    func julianCentury(epochDays: Double) -> Double {
        let numberJD = 2440587.5 + epochDays
        return (numberJD - 2451545.0) / 36525.0
    }
    
    func geomMeanAnom(cent: Double) -> Double {
        let geomMeanAnom = fmod(
            (357.52911 + cent * (35999.05029 - 0.0001537 * cent)), 360.0)
        return geomMeanAnom
    }
    
    func sunEqOfCtr(cent: Double) -> Double {
        let gA = geomMeanAnom(cent: cent)
        let sunEqOfCtr =
        sin(rad(g: gA)) * (1.914602 - cent * (0.004817 + 0.000014 * cent))
        + sin(rad(g: 2.0 * gA)) * (0.019993 - 0.000101 * cent)
        + sin(rad(g: 3.0 * gA)) * 0.000289
        return sunEqOfCtr
    }
    
    func geomMeanLong(cent: Double) -> Double {
        let geomMeanLong = fmod(
            (280.46646 + (cent * (36000.76983 + cent * 0.0003032))), 360.0)
        return geomMeanLong
    }
    
    func sunAppLong(cent: Double) -> Double {
        // sunTL is Sun true longitude composed here
        let sunTL = sunEqOfCtr(cent: cent) + geomMeanLong(cent: cent)
        let sunAppLong = sunTL - 0.00569 - 0.00478 * sin(rad(g: (125.04 - 1934.136 * cent)))
        return sunAppLong
    }
    
    func meanObliqEcliptic(cent: Double) -> Double {
        23 + (26 + (21.448 - cent * (46.815 + cent * (0.00059 - cent * 0.001813))) / 60) / 60
    }
    
    func obliqCorr(cent: Double) -> Double {
        meanObliqEcliptic(cent: cent) + 0.00256 * cos(rad(g: 125.04 - 1934.136 * cent))
    }
    
    // Sun declination angle
    func sunDeclin(cent: Double) -> Double {
        deg(r: (asin(sin(rad(g: obliqCorr(cent: cent))) * sin(rad(g: sunAppLong(cent: cent))))))
    }
    
    // Y-variable
    func yVar(cent: Double) -> Double {
        return tan(rad(g: obliqCorr(cent: cent)) / 2.0) * tan(rad(g: obliqCorr(cent: cent)) / 2.0)
    }
    
    func haSunrise(cent: Double, lat: Double) -> Double {
        return deg(
            r: acos(
                cos(rad(g: 90.833))
                / (cos(rad(g: lat))
                   * cos(rad(g: sunDeclin(cent: cent))))
                - tan(rad(g: lat)) * tan(rad(g: sunDeclin(cent: cent)))))
    }
    
    func eccOrbit(cent: Double) -> Double {
        0.016708634 - cent * (0.000042037 + 0.0000001267 * cent)
    }
    
    // Equation of time
    func eqTime(cent: Double) -> Double {
        let gA: Double = geomMeanAnom(cent: cent)
        let gL: Double = geomMeanLong(cent: cent)
        let eO: Double = eccOrbit(cent: cent)
        let y: Double = yVar(cent: cent)
        let v1: Double = y * sin(2.0 * rad(g: gL))
        let v2: Double = sin(rad(g: gA))
        let eqTime: Double =
        4.0
        * deg(
            r: (v1 - 2.0 * eO * v2
                + 4.0 * eO * y * v2 * cos(2.0 * rad(g: gL))
                - 0.5 * y * y * sin(4.0 * rad(g: gL))
                - 1.25 * eO * eO * sin(2.0 * rad(g: gA))))
        return eqTime
    }
    
    func solarNoonLST(cent: Double, tz: Double, lat: Double, lon: Double) -> Double {
        720.0 - 4.0 * lon - (eqTime(cent: cent)) + tz * 60.0
    }
    
    // Sunrise given in local solar time.
    func sunriseLST(cent: Double, tz: Double, lat: Double, lon: Double) -> Double {
        solarNoonLST(cent: cent, tz: tz, lat: lat, lon: lon) - 4.0 * haSunrise(cent: cent, lat: lat)
    }
    
    // Sunset given in local solar time.
    func sunsetLST(cent: Double, tz: Double, lat: Double, lon: Double) -> Double {
        solarNoonLST(cent: cent, tz: tz, lat: lat, lon: lon) + 4.0 * haSunrise(cent: cent, lat: lat)
    }
    
    // Sunlight duration
    func sunlightDuration(cent: Double, lat: Double) -> String {
        let mins = 8 * haSunrise(cent: cent, lat: lat)
        if mins > 1440.0 {
            return "No sunset in arctic summer"
        } else {
            return timeStamp(posixMinutes: mins)
        }
    }
   
    // true solar time
    // =MOD(e2*1440+V2+4*$B$4-60*$B$5;1440)
    // e = time past midnight minutes
    // v = eq of time func eqTime(cent)
    // b4 = longit
    // b5 = tz

    func trueSolarTime(tcurrent: Double, cent: Double, lon: Double) -> Double {
        return fmod(tcurrent + eqTime(cent: cent) + 4.0 * lon, 1440)
    }
    
    func hourAngle(tcurrent: Double, cent: Double, lon: Double) -> Double {
        let tst: Double = trueSolarTime(tcurrent: tcurrent, cent: cent, lon: lon) / 4.0
        var res: Double = tst
        if tst < 0 { res = tst + 180.0 }
        if tst > 0 { res = tst - 180.0 }
        return res
    }
   
    
    
    func solarZenithAngle(tcurrent: Double, cent: Double, lat: Double, lon: Double) -> Double {
        let sins: Double = sin(rad(g: lat)) * sin(rad(g: sunDeclin(cent: cent)))
        let coss: Double =
        cos(rad(g: lat)) * cos(rad(g: sunDeclin(cent: cent)))
        * cos(rad(g: hourAngle(tcurrent: tcurrent, cent: cent, lon: lon)))
        return deg(r: acos(sins + coss))
    }
    
    func belowZero(hx: Double) -> Double {
        return -20.774 / tan(rad(g: hx)) / 3600.0
    }
    
    func belowEightyFive(hx: Double) -> Double {
        let v1: Double = tan(rad(g: hx))
        let v2: Double = pow(tan(rad(g: hx)), 3.0)
        let v3: Double = pow(tan(rad(g: hx)), 5.0)
        let v: Double = ((58.1 / v1) - (0.07 / v2) + (8.6e-5 / v3)) / 3600.0
        
        return v
    }
    
    func belowFive(hx: Double) -> Double {
        let v: Double =
        (1735.0 - 518.2 * hx + 103.4 * pow(hx, 2.0)
         - 12.79 * pow(hx, 3.0) + 0.711 * pow(hx, 4.0)) / 3600.0
        
        return v
    }
    
    func atmosRefract(tcurrent: Double, cent: Double, lat: Double, lon: Double) -> Double {
        let h = 90.0 - solarZenithAngle(tcurrent: tcurrent, cent: cent, lat: lat, lon: lon)
        
        let res =
        if h < -0.575 { belowZero(hx: h) } else if h <= 5.0 {
            belowFive(hx: h)
        } else if h <= 85.0 {
            belowEightyFive(hx: h)
        } else { 0.0 }
        
        return res
    }
    
    func calcAzimuth(hourAngle: Double, zenith: Double, sunDeclin: Double, latit: Double) -> Double {
        let radZenith = rad(g: zenith)
        let radLatit = rad(g: latit)
        let radS = rad(g: sunDeclin)
        
        let numerator = sin(radLatit) * cos(radZenith) - sin(radS)
        let denominator = cos(radLatit) * sin(radZenith)
        
        let acosValue = acos(numerator / denominator)
        let degreesValue = acosValue * 180 / .pi
        if hourAngle > 0 {
            return fmod(degreesValue + 180, 360)
        } else {
            return fmod(540 - degreesValue, 360)
        }
    }
    
    func rad(g: Double) -> Double {
        .pi * g / 180.0
    }
    
    func deg(r: Double) -> Double {
        180.0 * r / .pi
    }
  

    func localTime(for date: Date, in timeZoneID: String) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(identifier: timeZoneID)
        f.dateFormat = "HH:mm:ss ZZZZ"
        return f.string(from: date)
    }
    
    func timeStamp(posixMinutes: TimeInterval) -> String {
        let posixSeconds: TimeInterval = posixMinutes * 60
        let date = Date(timeIntervalSince1970: posixSeconds)

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

    return formatter.string(from: date)
    }

    var body: some View {
        // New picker menu - var body alkuun
        ScrollView {
            // Dropdown menu bound to City (Hashable)
            Picker("Select a city!", selection: $selectedCity) {
                ForEach(cities, id: \.self) { city in
                    Text(city.name).tag(city)
                }
            }
            .pickerStyle(.menu)
            .bold()
            .padding(.bottom, 8)
            
            let city = selectedCity
            let secondsFromGMT = city.timeZone.secondsFromGMT(for: Date())
            let hoursFromGMT = Double(secondsFromGMT) / 3600.0
            
            let now = Date()
            let posixDays = Double(now.timeIntervalSince1970) / (3600 * 24)
            let jCent = julianCentury(epochDays: posixDays)
            let tcurrent: Double = 1440 * (posixDays - Double(Int(posixDays)))
            let midsummerLat: Double = 89.16718 - sunDeclin(cent: jCent)
            let midwinterLat: Double = 90.833 - abs(sunDeclin(cent: jCent))
            
            let lat: Double = city.latitude
            let lon: Double = city.longitude
            let tz: Double = hoursFromGMT
            let zen: Double = solarZenithAngle(tcurrent: tcurrent, cent: jCent, lat: lat, lon: lon)
            let el1: Double = 90.0 - zen
            let refr: Double = atmosRefract(tcurrent: tcurrent, cent: jCent, lat: lat, lon: lon)
            let hrA: Double = hourAngle(tcurrent: tcurrent, cent: jCent, lon: lon)
            let sunDecl: Double = sunDeclin(cent: jCent)
            let result: Double = calcAzimuth(
                hourAngle: hrA, zenith: zen, sunDeclin: sunDecl, latit: lat)
            let azimuthS = String(format: "☉ Azimuth angle  *)    %.3f °", result)
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading) {
                        Text("Suncalculator")
                        Text(" \(city.name)")
                            .font(.title)
                            .foregroundStyle(.green)
                    }
                    
                    Text("Helsinki: \(localTime(for: now, in: "Europe/Helsinki"))")
                    switch city.name {
                        case "London":
                        Text("London: \(localTime(for: now, in: "Europe/London"))")
                    case "Stockholm":
                        Text("Stockholm: \(localTime(for: now, in: "Europe/Stockholm"))")
                    case "Berlin":
                        Text("Berlin: \(localTime(for: now, in: "Europe/Berlin"))")
                    case "Washington D.C.":
                        Text("Washington: \(localTime(for: now, in: "America/New_York"))")
                    case "New York":
                        Text("New York: \(localTime(for: now, in: "America/New_York"))")
                    case "Tokyo, Japan":
                        Text("Tokyo: \(localTime(for: now, in: "Asia/Tokyo"))")
                    case "Sydney, Australia":
                        Text("Sydney: \(localTime(for: now, in: "Australia/Sydney"))")
                    default:
                        Text(" ")
                    }
                    HStack {
                        Divider()
                        Text("Latitude " +
                             String(
                                format: " %7.3f° Longitude %7.3f°", lat, lon)
                        )
                    }
                    
                    HStack {
                        Divider()
                        Text("   ")
                        Text("Date and Your local time now:\n\(now)")
                            .background(Color.white)
                            .foregroundColor(.blue)
                            .padding(2)
                            .border(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    HStack {
                        Divider()
                        Text(" ")
                        Divider()
                        Text(String(format: "Solar declination    %10.4f °", sunDecl))
                            .foregroundStyle(.blue)
                            .background(Color.white)
                            .padding(2)
                            .border(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    HStack {
                        Divider()
                        Text(" ")
                        Divider()
                        Group {
                            if lat < midsummerLat {
                                Text(
                                    "Sunrise local time:   "
                                    + timeStamp(posixMinutes: sunriseLST(cent: jCent, tz: tz, lat: lat, lon: lon))
                                )
                                .bold()
                                .foregroundStyle(.black)
                                .background(.yellow)
                                .padding(2)
                                .border(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            } else if sunDecl > 0.0 && lat > midsummerLat {
                                Text("It's now Arctic midsummer at this latitude,\n Sun visible all day!")
                            } else if sunDecl < 0.0 && lat > midwinterLat {
                                Text("It's arctic winter now and Sun is all day below horizon!")
                            }
                        }
                    }
                    
                    HStack {
                        Divider()
                        Text(" ")
                        Divider()
                        Text(
                            "Solar noon time:      "
                            + timeStamp(posixMinutes: solarNoonLST(cent: jCent, tz: tz, lat: lat, lon: lon))
                        )
                        .foregroundStyle(.blue)
                        .background(Color.white)
                        .padding(2)
                        .border(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    if lat < midsummerLat {
                        HStack {
                            Divider()
                            Text(" ")
                            
                            Divider()
                            Text(
                                "Sunset local time:    "
                                + timeStamp(posixMinutes: sunsetLST(cent: jCent, tz: tz, lat: lat, lon: lon))
                            )
                            .bold()
                            .foregroundStyle(.black)
                            .background(.yellow)
                            .padding(2)
                            .border(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        HStack {
                            Divider()
                            Text(" ")
                            Divider()
                            Text(("Daylight duration     " + sunlightDuration(cent: jCent, lat: lat)))
                                .background(.blue)
                                .foregroundStyle(.white)
                                .padding(2)
                                .border(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    } else {
                        Text("There is no Sunset during the arctic midsummer!")
                    }
                    
                    HStack {
                        Divider()
                        Text("   ")
                        VStack(alignment: .leading) {
                            HStack {
                                Text(String(format: "☉ Solar elevation       %.3f°", el1))
                                    .foregroundStyle(.blue)
                            }
                            Text((String(format: "☉ Atmospheric refract. %.3f °", refr)))
                                .foregroundStyle(.blue)
                            Text(String(format: "☉ Solar elev, refr. corr. %.3f °", (el1 + refr)))
                                .foregroundStyle(.blue)
                            
                            Text(azimuthS)
                                .foregroundStyle(.blue)

                        }
                        .background(Color.white)
                        .padding(5)
                        .border(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    HStack {
                        Divider()
                        Text("   ")
                        Text(
                        """
                        *) Azimuth angle is the direction where the
                           Sun is seen on the current time:
                        N =   0°, E =  90°, S = 180°
                        W = 270°, N = 360°
                        """
                        )
                        .background(Color.white)
                        .foregroundStyle(.blue)
                        .padding(4)
                        .border(.gray)
                        .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
                        Divider()
                    }
                    
                    VStack {
                        Text("**Thank you**")
                            .foregroundColor(.green)
                        Text("*for your interest*")
                        Text(
                            "Look at the source   [code](https://github.com/jarmol/swiftit/blob/master/SolarCalc/SolarCalc/ContentView.swift) in GitHub"
                        )
                        Divider()
                    }
                    
                    Text("© 2025 Jarmo Lammi")
                        .foregroundStyle(.blue)
                        .background(Color.white)
                        .padding(4)
                }
                .padding()
            }
            
            
        }
        
    }
}
       

    #Preview {
        ContentView()
    }

