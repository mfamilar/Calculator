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
            }
        }
    }
    
    private var tmpProgram: CalculatorBrain.PropertyList?
    
    @IBAction private func setValue(sender: UIButton) {
        if var variable = sender.currentTitle {
            variable.remove(at: variable.startIndex)
            if variable != "" {
                if let _ = Double(display.text!) {
                    tmpProgram = brain.program
                    brain.variableValues[variable] = displayValue
                    brain.refreshPropertyList(oldList: tmpProgram!, variable: variable)
                    displayValue = brain.result
                }
                
            }
        }
    }
    
    @IBAction private func getValue(sender: UIButton) {
        if let variable = sender.currentTitle {
            brain.setOperand(variableName: variable)
            if let nb = brain.variableValues[variable] { displayValue = nb }
            else { displayValue = 0.0 }
        }
    }
   
    
    private var savedProgram: CalculatorBrain.PropertyList?
    
    @IBAction private func save() {
        savedProgram = brain.program
    }
    
    @IBAction private func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
            history.text! = brain.history
        }
    }
    
    
     @IBAction private func backspace() {
        if var textCurrentlyInDisplay = display.text {
            if textCurrentlyInDisplay.characters.count > 1 {
                textCurrentlyInDisplay = textCurrentlyInDisplay.substring(to: textCurrentlyInDisplay.index(before: textCurrentlyInDisplay.endIndex))
            } else {
                textCurrentlyInDisplay = "0"
            }
            display.text = textCurrentlyInDisplay
            brain.setOperand(operand: displayValue)
        }
    }
    
    private var displayValue : Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = brain.percentFormatter(doubleToConvertInString: newValue)
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction private func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            if display.text != "." {
                brain.setOperand(operand: displayValue)
            }
            userIsInTheMiddleOfTypingANumber = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathematicalSymbol)
        }
        displayValue = brain.result
        history.text! = brain.history
    }
}

