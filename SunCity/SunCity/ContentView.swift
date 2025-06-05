//
//  ContentView.swift
//  SunCity
//  with new menu
//  Created by Polarit on 29.5.2025.
//
// https://www.advancedswift.com/local-utc-date-format-swift/

import SwiftUI

// List of cities
let cities = [
    "Helsinki", "Stockholm", "Oslo", "Berlin", "München", "Wien", "Washington D.C.",
    "Anchorage Alaska", "Madrid", "Malaga", "Rovaniemi",
    "Utsjoki", "Cape of Good Hope", "Tierra del Fuego",
]

let zoneNames: [String] = [
    "EEST", "CEST", "CEST", "CEST", "CEST", "CEST",
    "EDT", "AKDT", "CEST", "CEST", "EEST", "EEST",
    "SAST", "ART",
]

// City info

let cityData: [[Double]] = [
    [60.1695, 24.9354, 3.0],  // EEST UTC+3
    [59.3293, 18.0686, 2.0],  // CET UTC+2
    [59.9139, 10.7522, 2.0],
    [52.5200, 13.4050, 2.0],
    [48.138, 11.575, 2.0],
    [48.2195, 16.3785, 2.0],
    [38.905, -77.016, -4.0],  // EDT UTC-4
    [61.183, -149.883, -8.0],  // AKDT UTC-8
    [40.419, -3.693, 2.0],  // CEST UTC+2
    [36.720, -4.415, 2.0],
    [66.502, 25.724, 3.0],
    [69.90954, 27.0295, 3.0],
    [-34.3514, 18.483, 2.0],  // SAST UTC+2
    [-54.80, -68.3, -3.0],  // ART UTC-3
]

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
        return clocktimeFromMinutes(rawminutes: mins)
    }
}

func trueSolarTime(tcurrent: Double, cent: Double, lon: Double) -> Double {
    tcurrent + eqTime(cent: cent) + 4.0 * lon
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

func clocktimeFromMinutes(rawminutes: Double) -> String {
    // Converts minutes to normal clocktime
    let rawhours: Double = rawminutes / 60.0
    let rawseconds: Double = 60.0 * rawminutes
    let hours = Int(rawhours)
    let minutes = Int(rawminutes) % 60
    let seconds = Int(rawseconds) % 60
    return
        (" " + twoDigitsTimes(digit: hours) + ":"
        + twoDigitsTimes(digit: minutes) + ":"
        + twoDigitsTimes(digit: seconds))
}

func twoDigitsTimes(digit: Int) -> String {
    let ts = if digit > 9 { String(digit) } else { "0" + String(digit) }
    return ts
}

struct ContentView: View {
    // Valittu kaupunki
    @State private var selectedCity: String = "Helsinki"

    var body: some View {
        let now = Date()
        let posixDays = Double(now.timeIntervalSince1970) / (3600 * 24)
        let jCent = julianCentury(epochDays: posixDays)
        let tcurrent: Double = 1440 * (posixDays - Double(Int(posixDays)))
        let midsummerLat = 89.16718 - sunDeclin(cent: jCent)
        let midwinterLat: Double = 90.833 - abs(sunDeclin(cent: jCent))
        //   let date = Date()
        VStack {
            Text("Suncalculator")
                .font(.title.bold())
                .foregroundStyle(.green)
            Text("City \(selectedCity)")
                .bold()
                .foregroundStyle(.green)

        }
        VStack {
            // Alasvetovalikko
            Picker("Select a city!", selection: $selectedCity) {
                ForEach(cities, id: \.self) { city in
                    Text(city).tag(city)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .bold(true)
            .padding()
        }
        .frame(width: 300, height: 30)
        .padding()

        let rownr = cities.firstIndex(of: selectedCity)!
        let lat = cityData[rownr][0]
        let lon = cityData[rownr][1]
        let tz = cityData[rownr][2]
        let tzName = zoneNames[rownr]
        let tutc = if tz < 0.0 { "UTC" } else { "UTC+" }
        let myLoc = Date().anotherTimeZoneDate(name: tzName)
        let zen = solarZenithAngle(tcurrent: tcurrent, cent: jCent, lat: lat, lon: lon)
        let el1 = 90.0 - zen
        let refr = atmosRefract(tcurrent: tcurrent, cent: jCent, lat: lat, lon: lon)

        VStack {
            Text("Local time : \(myLoc) \(tzName) (\(tutc + String(tz)))")
                .font(.largeTitle)
        }

        VStack {
            HStack {
                Divider()
                Text("   ")
                Text(
                    String(
                        format: "Latitude %7.3f° Longitude %7.3f° Time Zone %4.1f h", lat, lon, tz)
                )
                .background(Color.white)
                .foregroundColor(.blue)
                .padding(2)
                .border(.black)
                .frame(maxWidth: .infinity, alignment: .leadingLastTextBaseline)
            }
        }
        VStack {
            HStack {
                Divider()
                Text("   ")
                Text("Date and Your local time now:\n\(now)")
                    .background(Color.white)
                    .foregroundColor(.blue)
                    .padding(2)
                    .border(.black)
                    .frame(maxWidth: .infinity, alignment: .leadingLastTextBaseline)
            }
        }
        VStack {
            HStack {
                Divider()
                Text(" ")

                Divider()
                Text(String(format: "Solar declination    %10.4f °", sunDeclin(cent: jCent)))
                    .foregroundStyle(.blue)
                    .background(Color.white)
                    .padding(2)
                    .border(.black)
                    .frame(maxWidth: .infinity, alignment: .leadingLastTextBaseline)
            }
        }
        VStack {
            HStack {
                Divider()
                Text(" ")
                Divider()
                if lat < midsummerLat && sunDeclin(cent: jCent) > 0.0 {
                    Text(
                        "Sunrise local time:   "
                            + clocktimeFromMinutes(
                                rawminutes: sunriseLST(cent: jCent, tz: tz, lat: lat, lon: lon))
                    )
                    .bold()
                    .foregroundStyle(.black)
                    .background(.yellow)
                    .padding(2)
                    .border(.black)
                    .frame(maxWidth: .infinity, alignment: .leadingLastTextBaseline)
                } else if sunDeclin(cent: jCent) > 0.0 && lat > midsummerLat {
                    Text("It's now Arctic midsummer at this latitude,\n Sun visible all day!")
                } else if sunDeclin(cent: jCent) < 0.0 && lat > midwinterLat {
                    Text("It's arctic winter now and Sun is all day below horizon!")
                }
            }
        }
        // TODO: if lat < (-90.0 + declin - 0.833) && declin > 0 {Text("Winter in antarctic areas")}
        VStack {
            HStack {
                Divider()
                Text(" ")

                Divider()
                Text(
                    "Solar noon time:      "
                        + clocktimeFromMinutes(
                            rawminutes: solarNoonLST(cent: jCent, tz: tz, lat: lat, lon: lon))
                )
                .foregroundStyle(.blue)
                .background(Color.white)
                .padding(2)
                .border(.black)
                .frame(maxWidth: .infinity, alignment: .leadingLastTextBaseline)
            }
            if lat < midsummerLat {
                VStack {
                    HStack {
                        Divider()
                        Text(" ")

                        Divider()
                        Text(
                            "Sunset local time:    "
                                + clocktimeFromMinutes(
                                    rawminutes: sunsetLST(cent: jCent, tz: tz, lat: lat, lon: lon))
                        )
                        .bold()
                        .foregroundStyle(.black)
                        .background(.yellow)
                        .padding(2)
                        .border(.black)
                        .frame(maxWidth: .infinity, alignment: .leadingLastTextBaseline)
                    }
                }
                VStack {
                    HStack {
                        Divider()
                        Text(" ")

                        Divider()
                        Text(("Daylight duration     " + sunlightDuration(cent: jCent, lat: lat)))
                            .background(.blue)
                            .foregroundStyle(.white)
                            .padding(2)
                            .border(.black)
                            .frame(maxWidth: .infinity, alignment: .leadingLastTextBaseline)
                    }
                }
            } else {
                Text("There is no Sunset during the arctic midsummer!")
            }

        }
        VStack {
            HStack {
                Divider()
                Text("   ")
                VStack {
                    HStack {
                        Divider()
                        Text(String(format: "Solar elevation       %.3f°", el1))
                            .foregroundStyle(.blue)
                    }
                    Text((String(format: "Atmospheric refract. %.3f °", refr)))
                        .foregroundStyle(.blue)
                    Text(String(format: "Solar elev, refr. corr. %.3f °", (el1 + refr)))
                        .foregroundStyle(.blue)
                    let hrA = hourAngle(tcurrent: tcurrent, cent: jCent, lon: lon)
                    let sunDecl = sunDeclin(cent: jCent)
                    let result: Double = calcAzimuth(
                        hourAngle: hrA, zenith: zen, sunDeclin: sunDecl, latit: lat)
                    let azimuthS = String(format: "Azimuth angle  *)    %.3f °", result)
                    Text(azimuthS)
                        .foregroundStyle(.blue)
                }
                .background(Color.white)
                .padding(5)
                .border(.gray)
                .frame(maxWidth: .infinity, alignment: .leadingLastTextBaseline)
            }
        }

        VStack {
            HStack {
                Divider()
                Text("   ")
                Text(
                    """
                    *) Azimuth angle is the direction where the
                       Sun is seen on the current time:\nN =   0°, E =  90°, S = 180°\nW = 270°, N = 360°
                    """
                )
                .background(Color.white)
                .foregroundStyle(.blue)
                .padding(4)
                .border(.gray)
                .frame(maxWidth: .infinity, minHeight: 80, alignment: .leadingLastTextBaseline)
                Divider()
            }
            VStack {
                Text("**Thank you**")
                    .foregroundColor(.green)
                Text("*for your interest*")
                Text(
                    "Look at the source   [code](https://raw.githubusercontent.com/jarmol/swiftit/refs/heads/master/SunCity/SunCity/ContentView.swift) in GitHub"
                )
                Divider()
            }

            Text("© 2025 Jarmo Lammi")
                .foregroundStyle(.blue)
                .background(Color.white)
                .padding(4)

        }
    }
}

#Preview {
    ContentView()
}

extension Date {
    func anotherTimeZoneDate(name: String) -> String {
        let dtf = DateFormatter()
        dtf.timeZone = TimeZone(abbreviation: name)
        dtf.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dtf.string(from: self)
    }
}
