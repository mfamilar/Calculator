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
    @IBOutlet private weak var history: UILabel!
    
    private var userIsInTheMiddleOfTypingANumber = false
    private var equalSpotted = false

    @IBAction private func touchDigit(sender: UIButton) {
        if let digit = sender.currentTitle {
            if userIsInTheMiddleOfTypingANumber {
                if let textCurrentlyInDisplay = display.text {
                    if textCurrentlyInDisplay.range(of: ".") == nil || digit != "." {
                        display.text = textCurrentlyInDisplay + digit
                    }
                }
            } else {
                display.text = digit
                userIsInTheMiddleOfTypingANumber = true
                if equalSpotted {
                    equalSpotted = false
                    brain.reset = true
                }
            }
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
        if userIsInTheMiddleOfTypingANumber {
            brain.setOperand(operand: displayValue)
            userIsInTheMiddleOfTypingANumber = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathematicalSymbol)
            
        }
        displayValue = brain.result
        history.text! = brain.history
        if brain.isPartialResult {
            history.text! += "..."
        } else if history.text != " " {
            history.text! += "="
            equalSpotted = true
        }
    }
}

