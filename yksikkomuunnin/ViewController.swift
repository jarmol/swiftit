//
//  ViewController.swift
//  yksikkomuunnin
//
//  Created by Jarmo Lammi on 30.3.2015.
//  Copyright (c) 2015 Lammi. All rights reserved.
//

import UIKit

// model of conversion

class AsteMuunnos {
    
    // Celsiusaste Fahrenheitiksi
    
    func cToF(xc: NSString) -> String  {
        let x: Double = xc.doubleValue
        let y = String(format: "%5.1f", (9*x/5 + 32))
        return y
    }

// Convert Fahrenheits to Celsius
    func fToC(xc: NSString) -> String  {
        let x: Double = xc.doubleValue
        let y = String(format: "%5.1f", (5*(x - 32)/9))
        return y
    }

    // Convert Knots to km/h
    func knotsToKmph(xc: NSString) ->String  {
        let x: Double = xc.doubleValue
        let y = String(format: "%5.1f", (1.852*x))
        return y
    }
    
    // Convert km to miles
    func kmToMile(xc: NSString) -> String {
        let x: Double = xc.doubleValue
        var y: String = String(format: "%5.1f", (0.621371192*x))
        return y
    
    
    }
    
    // Convert miles to km
    func milesToKm(xc: NSString) -> String {
        let x: Double = xc.doubleValue
        var y: String = String(format: "%5.1f", (1.60934*x))
        return y
        
        
    }
} // End of class

class ViewController: UIViewController {

// Customize buttons
    func customButtons(argBut: UIButton) {
        argBut.backgroundColor = UIColor.whiteColor()
        argBut.layer.cornerRadius = 5
        argBut.layer.masksToBounds = true
    }

    func customLabels(argLab: UILabel) {
        argLab.backgroundColor = UIColor.whiteColor()
        argLab.layer.cornerRadius = 5
        argLab.layer.masksToBounds = true
    }

    
//  Convert C to F
    @IBAction func calcCtoF(sender: UIButton) {
        let work = AsteMuunnos()
        let txCopy = inputValueC.text
        let gotvalue = work.cToF(txCopy)
        tulokset.text = "\(txCopy) C = \(gotvalue) F"
        inputValueF.text = gotvalue
        customButtons(sender)
    }
    
 //   Convert F to C
    @IBAction func calcFtoC(sender: UIButton) {
        let work2 = AsteMuunnos()
        let txCopy = inputValueF.text
        let gotvalue = work2.fToC(txCopy)

        tulokset.text = "\(txCopy) F = \(gotvalue) C"
        inputValueC.text = gotvalue
        customButtons(sender)
    }

//  km to miles
    
    @IBAction func calcKmToMi(sender: UIButton) {
        let work2 = AsteMuunnos()
        let txCopy = inputValueKm.text
        let gotvalue = work2.kmToMile(txCopy)
        
        tulokset.text = "\(txCopy) km = \(gotvalue) Miles"
        inputValueMi.text = gotvalue
        customButtons(sender)
    }

//  Miles to km
    @IBAction func calcMiToKm(sender: UIButton) {
        let work2 = AsteMuunnos()
        let txCopy = inputValueMi.text
        let gotvalue = work2.milesToKm(txCopy)
        
        tulokset.text = "\(txCopy) MI = \(gotvalue) km"
        inputValueKm.text = gotvalue
        customButtons(sender)
    }
    
//  Knots to km/h
    @IBAction func calcSpeedsButton(sender: UIButton) {
        let work3 = AsteMuunnos()
        let txCopy = inputValueKnots.text
        tulokset2.text = "\(txCopy) KNOT = \(work3.knotsToKmph(txCopy)) km/h"
        
        customButtons(sender)
    }
    
    @IBOutlet weak var inputValueC: UITextField!
    @IBOutlet weak var inputValueF: UITextField!
    @IBOutlet weak var inputValueKnots: UITextField!
    @IBOutlet weak var inputValueKm: UITextField!
    @IBOutlet weak var inputValueMi: UITextField!
    
    @IBOutlet weak var tulokset: UILabel!
    
    @IBOutlet weak var tulokset2: UILabel!
    
    override func viewDidLoad() {
        tulokset.text = "Temperature"
        tulokset.textColor = UIColor.redColor()
        customLabels(tulokset)
        
        tulokset2.text = "Speed"
        customLabels(tulokset2)
        tulokset2.textColor = UIColor.blueColor()
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

