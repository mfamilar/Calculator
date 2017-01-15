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
    private var description = " "
    private var keepOn = true
    
    func setOperand(operand: Double) {
        accumulator = operand
        keepOn = false
        if isPartialResult == false {
            description = " "
        }
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
    
    private var isPartialResult: Bool {
        get {
            if pending != nil {
                return true
            }
            return false
        }
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
    
    private func clear() {
        accumulator = 0.0
        pending = nil
        description = " "
    }
    
    private func unaryDescscription(symbol: String) {
        if keepOn == false {
            description += symbol + "(" + String(accumulator) + ")"
        }
        else if keepOn == true  && description != " " {
            description = symbol + "(" + description + ")"
        }
    }
    
    private func binaryDescription(symbol: String) {
        if keepOn == false {
            description += String(accumulator) + symbol
        } else {
            description += symbol
        }
    }
    
    private func equalDescription(symbol: String) {
        if keepOn == false {
            description += String(accumulator)
        } else if keepOn == true && checkLastCharIsABinary() {
            description += String(accumulator)
        }
    }
    
    private func checkLastCharIsABinary() -> Bool {
        let lastChar = description[description.index(before: description.endIndex)]
        if let ret: Operation = operations[String(lastChar)] {
            if case .BinaryOperation = ret {
                return true
            }
        }
        return false
    }
    
    
    func performOperation(symbol: String) {
        if let constant = operations[symbol] {
            switch constant {
            case .Constant(let value):
                description += symbol
                accumulator = value
            case .UnaryOperation(let foo):
                unaryDescscription(symbol: symbol)
                accumulator = foo(accumulator)
            case .BinaryOperation(let function):
                binaryDescription(symbol: symbol)
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equals:
                equalDescription(symbol: symbol)
                executePendingBinaryOperation()
            case .Clear:
                clear()
            }
            keepOn = true
        }
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
    var history: String {
        get {
            if isPartialResult {
                return description + "..."
            } else if description != " " {
                return description + "="
            }
            return description
        }
    }
}
