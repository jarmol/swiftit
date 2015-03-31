//
//  ViewController.swift
//  yksikkomuunnin
//
//  Created by Raija Lammi on 30.3.2015.
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

    
    
    func fToC(xc: NSString) -> String  {
        let x: Double = xc.doubleValue
        let y = String(format: "%5.0f", (5*(x - 32)/9))
        return y
    }
}




class ViewController: UIViewController {

    @IBAction func celsius(sender: UITextField) {
        let work = AsteMuunnos()
        tulokset.text = "C -> F: " + work.cToF(sender.text)
    }

    
    @IBAction func fahrenheit(sender: UITextField) {
        let work2 = AsteMuunnos()
        work2.tulos = "F -> C: " + work2.fToC(sender.text)
        tulokset.text = work2.tulos
        
    }
    
    
    @IBOutlet weak var tulokset: UILabel!
    
    
    override func viewDidLoad() {
        tulokset.text = "00.0"
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

