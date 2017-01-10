//
//  ViewController.swift
//  Calculator
//
//  Created by Marc FAMILARI on 1/4/17.
//  Copyright © 2017 Marc FAMILARI. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var display: UILabel!
    
    @IBOutlet weak var history: UILabel!
    
    private var userIsIntTheMiddleOfTyping = false
//        private var clearHistory = true
    
    
    @IBAction private func touchDigit(sender: UIButton) {
//        if clearHistory {
//            history.text = ""
//            clearHistory = false
//        }
        if let digit = sender.currentTitle {
            if userIsIntTheMiddleOfTyping {
                if let textCurrentlyInDisplay = display.text {
                    display.text = textCurrentlyInDisplay + digit
                }
//                if let textCurrentlyInHistory = history.text {
//                    history.text = textCurrentlyInHistory + digit
//                }
                
            } else {
                display.text = digit
//                if let textCurrentlyInHistory = history.text {
//                    history.text = textCurrentlyInHistory + digit
//                }
            }
            userIsIntTheMiddleOfTyping = true
        }
    }
    
    private var displayValue : Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction private func performOperation(sender: UIButton) {
        if userIsIntTheMiddleOfTyping {
            brain.setOperand(operand: displayValue)
            userIsIntTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
//            if let textCurrentlyInHistory = history.text {
//                history.text = textCurrentlyInHistory + mathematicalSymbol
//            }
            if mathematicalSymbol == "AC" {
                display.text = "0"
            }
            brain.performOperation(symbol: mathematicalSymbol)
//            clearHistory = brain.clearHistoryOrNot(symbol: mathematicalSymbol)
        }
        displayValue = brain.result
//        if clearHistory {
//            if let textCurrentlyInHistory = history.text {
//                history.text = textCurrentlyInHistory + String(displayValue)
//            }
//        }
        
    }
}

