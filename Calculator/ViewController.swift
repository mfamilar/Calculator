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
    
    private var userIsInTheMiddleOfTyping = false
    private var floating = false
    private var clearHistory = true

    private func handleHistory() {
        if clearHistory {
            history.text = " "
            clearHistory = false
        }
    }
    
    private func addInHistoryField (toAdd: String) {
        if let textCurrentlyInHistory = history.text {
            history.text = textCurrentlyInHistory + toAdd
        }
    }
    
    private func handleFloating (digit: String) {
        if digit == "." {
            floating = true
        }
    }
    
    @IBAction private func touchDigit(sender: UIButton) {
        handleHistory()
        if let digit = sender.currentTitle {
            if floating && digit == "." {
                return
            }
            handleFloating(digit: digit)
            if userIsInTheMiddleOfTyping {
                if let textCurrentlyInDisplay = display.text {
                    display.text = textCurrentlyInDisplay + digit
                }
                addInHistoryField(toAdd: digit)
            } else {
                display.text = digit
                addInHistoryField(toAdd: digit)
                userIsInTheMiddleOfTyping = true
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
        floating = false
        handleHistory()
        if userIsInTheMiddleOfTyping {
            brain.setOperand(operand: displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            clearHistory = brain.clearHistoryOrNot(symbol: mathematicalSymbol)
            addInHistoryField(toAdd: mathematicalSymbol)
            if brain.cleanDisplayOrNot(symbol: mathematicalSymbol) {
                display.text = "0"
                handleHistory()
            }
            brain.performOperation(symbol: mathematicalSymbol)
        }
        displayValue = brain.result
        if clearHistory {
            addInHistoryField(toAdd: String(displayValue))
        }
        
    }
}

