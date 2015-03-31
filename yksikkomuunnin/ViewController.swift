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
    var tulos: String = "Tulos"
    
    // Celsiusaste Fahrenheitiksi
    
    func cToF(xc: NSString) -> String  {
        let x: Double = xc.doubleValue
        let y = String(format: "%5.1f", (9*x/5 + 32))
        return y
    }

// Convert Fahrenheits to Celsius
    func fToC(xc: NSString) -> String  {
        let x: Double = xc.doubleValue
        let y = String(format: "%5.0f", (5*(x - 32)/9))
        return y
    }

    // Convert Knots to km/h
    func knotsToKmph(xc: NSString) ->String  {
        let x: Double = xc.doubleValue
        let y = String(format: "%5.0f", (1.852*x))
        return y
    }
} // End of class

class ViewController: UIViewController {

    @IBAction func celsius(sender: UITextField) {
        let work = AsteMuunnos()
        tulokset.text = "C -> F: " + work.cToF(sender.text)
    }
    
    @IBAction func fahrenheit(sender: UITextField) {
        let work2 = AsteMuunnos()
        tulokset.text = "F -> C: " + work2.fToC(sender.text)
    }
    
    @IBAction func calcSpeedsButton(sender: UIButton) {
        let work3 = AsteMuunnos()
        tulokset2.text = "KNOT -> km/h: " + work3.knotsToKmph(inputValueKnots.text)
    }
    
    @IBOutlet weak var inputValueKnots: UITextField!
    
    @IBOutlet weak var tulokset: UILabel!
    
    @IBOutlet weak var tulokset2: UILabel!
    
    override func viewDidLoad() {
        tulokset.text = "Temperature"
        tulokset2.text = "Speed"
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

