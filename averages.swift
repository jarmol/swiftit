import Foundation

func average(array: [Double]) -> (avg: Double, n: Int) {
  var xSum = array[0]

  for value in array[1..<array.count] {
    xSum += value
  }

  let n: Int = array.count
  let avg = xSum / Double(n)
  return (avg, n)
}

func minMax(array: [Double]) -> (min: Double, max: Double) {
    var min = array[0]
    var max = array[0]
    for value in array[1..<array.count] {
        if value < min {
            min = value
        } else if value > max {
            max = value
        }
    }
    return (min, max)
}


let dataBuffer =
  [
    0.8, 6.7, 5.3, 1.6, -2.2, 1.7, 1.2, 2.7, -1.5, -5.1, -3.6, -0.2, 2.9, 3.4, 5.4, 5.9, 5.7, 3.0,
    4.9, 4.0, 2.0, 3.0, 2.0, 1.8, 2.3, -0.4,1.5,3.2
  ]

let resultsTuple = average(array: dataBuffer)
let avgStr = String(format: "%5.3f", resultsTuple.avg)

let minmaxTuple = minMax(array: dataBuffer)
let finalMin = minmaxTuple.min
let finalMax = minmaxTuple.max

print("\u{1b}[107m")
print("\u{1b}[94m" + "\u{1b}[1m")
print("April 2025 Temperatures" + "\u{1b}[22m")
print("Average temperature " + avgStr + " °C")
print("Minimum of temperature \(finalMin) °C")
print("Maximum of temperature \(finalMax) °C")
print("Number of days is \(resultsTuple.n)")
print("Data Table: \(dataBuffer)")

/*
print("\u{1b}[92m" + "green")
print("\u{1b}[91m" + "red")
print("\u{1b}[93m" + "yellow")
print("\u{1b}[94m" + "blue")
print("\u{1b}[97m" + "white")
print("\u{1b}[30m" + "black")
print("\u{1b}[44m" + "bluebg")
print("\u{1b}[107m" + "whitebg")
print("\u{1b}[40m" + "blackbg")
*/
// Try this here:
// https://www.mycompiler.io/view/HWLePbH4zLf
// https://www.mycompiler.io/view/J464uosz46v
// https://www.mycompiler.io/view/CJ79W5kPdt6
