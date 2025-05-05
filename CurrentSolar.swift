import Foundation

var lat: Double = 65.849
var lon: Double = 24.145
var tz: Double = 3.0

let pi: Double = 3.1415926535897931

// posixDays = julianDay - 2440587.5
let posixDays = 20208.291701
let tcurrent: Double = 1440*(posixDays - Double(Int(posixDays)))

func julianCentury(epochDays: Double) -> Double {
   let numberJD = 2440587.5 + epochDays
   return (numberJD - 2451545.0) / 36525.0
}

let jCent = julianCentury(epochDays: posixDays)

print("Posix Days     \(posixDays)")
print("Julian Century \(jCent)")
print("Expected       0.25327287")

// Geom. mean Sun longitude
print("Geom. mean Sun longit    \(geomMeanLong(cent: jCent)) °")
print("Expected                 38.4848994 °")

// Geom. mean anom.
print("Geom. mean anomal.       \(geomMeanAnom(cent: jCent)) °")
print("Expected                 115.112007 °")

// Eccentric. Earth Orbit
print("Eccentric. Earth orbit   \(eccOrbit(cent: jCent))")
print("Expected value           0.0166980")

// Sun eq. of centre
print("Sun equation of centre   \(sunEqOfCtr(cent: jCent))")
print("Expected value           1.7171089")

print("Sun apparent longit.     \(sunAppLong(cent: jCent)) °")
print("Expected value           40.196720 °")

print("Mean obliq. ecliptic     \(meanObliqEcliptic(cent: jCent)) °")
print("Expected value           23.435998 °")
print("Oblique corrected val.   \(obliqCorr(cent: jCent)) °")
print("Expected value           23.438548 °")
print("Sun declination angle.   \(sunDeclin(cent: jCent)) °")
print("Expected value           14.875720°")
print("Y-variable               \(yVar(cent: jCent))")
print("Expected value           0.0430317")
print("Equation of time         \(eqTime(cent: jCent))")
print("Expected value           2.780503 minutes")
print("Sunrise HA               \(haSunrise(cent: jCent, lat: lat))")
print("Expected value           128.98845")
print("Sunrise local time:    " + clocktimeFromMinutes(rawminutes: sunriseLST(cent: jCent, tz: tz, lat: lat, lon: lon)))
print("Expected time:           4:44:32")
print("Solar noon time:      " +  clocktimeFromMinutes(rawminutes: solarNoonLST(cent: jCent, tz: tz, lat: lat, lon: lon)))
print("Expected time  :        13:20:29")
print("Sunset local time:    " + clocktimeFromMinutes(rawminutes: sunsetLST(cent: jCent, tz: tz, lat: lat, lon: lon)))
print("Expected time:          21:56:27")
print("Daylight duration     " + sunlightDuration(cent: jCent, lat: lat))
print("True solar time         \(trueSolarTime(tcurrent: tcurrent, cent: jCent, lon: lon))")
print("Expected time minutes   519.55 minutes")
print("Hour angle              \(hourAngle(tcurrent: tcurrent, cent: jCent, lon: lon))")
print("Expected result         -50.112 °")
print("Solar zenith angle      \(solarZenithAngle(tcurrent: tcurrent, cent: jCent, lat: lat, lon: lon)) °")
print("Expected value          60.8016 °")
print("Solar elevation angle   \(90.0 - solarZenithAngle(tcurrent: tcurrent, cent: jCent, lat: lat, lon: lon)) °")
print("Expected value          29.1984 °")

func geomMeanLong(cent: Double) -> Double {
   let geomMeanLong = nonIntRem(x: (280.46646 + (cent * (36000.76983 + cent * 0.0003032))), y: 360.0)
   return geomMeanLong
}


func nonIntRem(x: Double, y: Double) -> Double { x - (y * Double(floor(x / y))) }


func eccOrbit(cent: Double) -> Double {
   0.016708634 - cent * (0.000042037 + 0.0000001267 * cent)
}

func geomMeanAnom(cent: Double) -> Double {
    let geomMeanAnom = nonIntRem(x: (357.52911 + cent * (35999.05029 - 0.0001537 * cent)), y: 360.0)
    return geomMeanAnom
}


func sunEqOfCtr(cent: Double) -> Double {
   let gA = geomMeanAnom(cent: cent)
   let sunEqOfCtr = sin(rad(g: gA)) * (1.914602 - cent * (0.004817 + 0.000014 * cent))
      + sin(rad(g: 2.0 * gA)) * (0.019993 - 0.000101 * cent)
      + sin(rad(g: 3.0 * gA)) * 0.000289
   return sunEqOfCtr
}


func sunAppLong(cent: Double) -> Double {
// sunTL is Sun true longitude composed here
    let sunTL = sunEqOfCtr(cent: cent) + geomMeanLong(cent: cent)
    let sunAppLong = sunTL - 0.00569 - 0.00478 * sin(rad(g: (125.04 - 1934.136 * cent)))
    return sunAppLong
}

func meanObliqEcliptic(cent: Double) -> Double {
   23 + (26 + (21.448 - cent * (46.815 + cent * (0.00059 - cent * 0.001813)))/60)/60
}

   
func obliqCorr(cent: Double) -> Double {
    meanObliqEcliptic(cent: cent) + 0.00256 * cos(rad(g: 125.04 - 1934.136 * cent))
}

// Sun declination angle
func sunDeclin(cent: Double) -> Double {
    deg(r: (asin(sin(rad(g: obliqCorr(cent: cent))) * sin(rad(g: sunAppLong(cent: cent))))))
}

// Y-variable
func yVar(cent: Double)  -> Double {
    return  tan(rad(g: obliqCorr(cent: cent)) / 2.0) * tan(rad(g: obliqCorr(cent: cent))/2.0)
}

// Equation of time
func eqTime(cent: Double)  -> Double {
   let gA : Double = geomMeanAnom(cent: cent)
   let gL : Double = geomMeanLong(cent: cent)
   let eO : Double = eccOrbit(cent: cent)
   let y  : Double = yVar(cent: cent)
   let v1 : Double = y * sin(2.0 * rad(g: gL))
   let v2 : Double = sin(rad(g: gA))
let eqTime : Double =
   4.0 * deg(r: (v1 - 2.0 * eO * v2
     + 4.0 * eO * y * v2 * cos(2.0*rad(g: gL))
     - 0.5 * y * y * sin(4.0 * rad(g: gL))
     - 1.25 * eO * eO * sin(2.0 * rad(g: gA))))
   return eqTime
}

func haSunrise(cent: Double, lat: Double) -> Double {
    return  deg(r: acos(cos(rad(g: 90.833))/(cos(rad(g: lat))
    * cos(rad(g: sunDeclin(cent: cent))))
    - tan(rad(g: lat)) * tan(rad(g: sunDeclin(cent: cent)))))
}


// Sunrise given in local solar time.
func sunriseLST(cent: Double, tz: Double, lat: Double, lon: Double) -> Double {
     solarNoonLST(cent: cent, tz: tz, lat: lat, lon: lon) - 4.0 * haSunrise(cent: cent, lat: lat)
}

func solarNoonLST(cent: Double, tz: Double, lat: Double, lon: Double) -> Double {
    720.0 - 4.0 * lon - (eqTime(cent: cent)) + tz * 60.0
}


// Sunset given in local solar time.
func sunsetLST(cent: Double, tz: Double, lat: Double, lon: Double) -> Double {
     solarNoonLST(cent: cent, tz: tz, lat: lat, lon: lon) + 4.0 * haSunrise(cent: cent, lat: lat)
}

// Sunlight duration
func sunlightDuration(cent: Double, lat: Double) -> String {
     let mins = 8 * haSunrise(cent: cent, lat: lat)
     return clocktimeFromMinutes(rawminutes: mins)
}


func clocktimeFromMinutes(rawminutes: Double) -> String {
// Converts minutes to normal clocktime
let rawhours: Double = rawminutes/60.0
let rawseconds: Double = 60.0*rawminutes

let hours = Int(rawhours)
let minutes = Int(rawminutes) % 60
let seconds = Int(rawseconds) % 60

return  "  " + String(hours) + ":" + String(minutes)  + ":" + String(seconds)
}


func trueSolarTime(tcurrent: Double, cent: Double, lon: Double) -> Double {
    tcurrent + eqTime(cent: cent) + 4.0 * lon
}


func hourAngle(tcurrent: Double, cent: Double, lon: Double) -> Double {
    let tst: Double = trueSolarTime(tcurrent: tcurrent, cent: cent, lon: lon) / 4.0
    var res: Double = tst
    if tst < 0 {res = tst + 180.0}
    if tst > 0 {res = tst - 180.0}
    return res
}


func solarZenithAngle(tcurrent: Double, cent: Double, lat: Double, lon: Double) -> Double {
    let sins: Double = sin(rad(g: lat)) * sin(rad(g: sunDeclin(cent: cent)))
    let coss: Double = cos(rad(g: lat)) * cos(rad(g: sunDeclin(cent: cent)))
      * cos(rad(g: hourAngle(tcurrent: tcurrent, cent: cent, lon: lon)))
    return deg(r: acos(sins + coss))
}


func rad(g: Double) -> Double {
    pi * g / 180.0
}

func deg(r: Double) -> Double {
   180.0 * r / pi
}
