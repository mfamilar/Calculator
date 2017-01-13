//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Marc FAMILARI on 1/9/17.
//  Copyright © 2017 Marc FAMILARI. All rights reserved.
//

import Foundation


class CalculatorBrain {
    
    private var accumulator = 0.0
    private var description = ""
    private var specialChar = false
    private var reset = false
    
    func setOperand(operand: Double) {
        accumulator = operand
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π"     : Operation.Constant(M_PI),
        "e"     : Operation.Constant(M_E),
        "±"     : Operation.UnaryOperation({ -$0 }),
        "√"     : Operation.UnaryOperation(sqrt),
        "cos"   : Operation.UnaryOperation(cos),
        "sin"   : Operation.UnaryOperation(sin),
        "tan"   : Operation.UnaryOperation(tan),
        "×"     : Operation.BinaryOperation({ $0 * $1 }),
        "+"     : Operation.BinaryOperation({ $0 + $1 }),
        "-"     : Operation.BinaryOperation({ $0 - $1 }),
        "÷"     : Operation.BinaryOperation({ $0 / $1 }),
        "="     : Operation.Equals,
        "C"     : Operation.Clear
    ]
    
    var isPartialResult: Bool {
        if pending != nil {
            return true
        }
        return false
    }
    
    func cleanDisplay(symbol: String) -> Bool {
        if let constant = operations[symbol] {
            switch constant {
            case .Clear:
                return true
            default:
                break
            }
        }
        return false
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
        case Clear
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
        
    }
    
    private func  clearAccumulator () -> Double {
        return 0.0
    }
    
    private func handleSpecialChar (constant: CalculatorBrain.Operation) {
        switch constant {
        case .UnaryOperation, .Constant:
            specialChar = true
        default:
            specialChar = false
        }
    }
    
    private func performDescription(constant: CalculatorBrain.Operation, symbol: String) {
        if reset && specialChar == true {
            description = " "
            reset = false
        }
        switch constant {
        case .Constant:
            description += symbol
        case .UnaryOperation:
            if isPartialResult == false {
                description = symbol + "(" + description + ")"
            } else {
                description += symbol + "(" + String(accumulator) + ")"
            }
        case .BinaryOperation:
            if specialChar == false {
                description += String(accumulator) + symbol
            } else {
                description += symbol
            }
        case .Equals:
            if specialChar == false {
                description += String(accumulator)
                reset = true
            }
        case .Clear:
            description = " "
        }
        handleSpecialChar(constant: constant)
    }
    
    func performOperation(symbol: String) {
        if let constant = operations[symbol] {
            performDescription(constant: constant, symbol: symbol)
            switch constant {
            case .Constant(let value):
                accumulator = value
            case .UnaryOperation(let foo):
                accumulator = foo(accumulator)
            case .BinaryOperation(let function):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equals:
                executePendingBinaryOperation()
            case .Clear:
                accumulator = clearAccumulator()
                pending = nil
            }
        }
    }
    var result: Double {
        get {
            return accumulator
        }
    }
    
    var history: String {
        get {
            return description
        }
    }
}
