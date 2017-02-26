//
//  CalculatorModel.swift
//  Calculator
//
//  Created by Tubal Cain on 2/23/17.
//  Copyright © 2017 Will Wagers. All rights reserved.///
//
// struct: no inheritance, free initializer, lives in Stack, copy-on-write

import Foundation

struct CalculatorModel {
    
    // MARK: - Public interface
    
    /**
     
        Returns whether a binary function calculation is pending,
        ie. the first operand and operator have been saved while
        awaiting the second operand.
     
         - Returns: true if a binary function is pending; 
                    else false
     
     */
    
    var calculationPending : Bool {
        get { return (pendingBinaryFunction != nil) }   // isPartialResult()
    }
    
    /**
     
        Resets (clears) calculator to initial state.
     
     */
    
    mutating func reset() {     // clear()
        accumulator = (nil, " ")
        pendingBinaryFunction = nil
        //        internalProgram.removeAll()
    }
    
    /**
     
        Property backed by record of keypad strokes.
     
     */
    
    var description : String {
        get {
            return accumulator.description
        }
        set {
            accumulator.description += newValue + " "
        }
    }
    
    var result: Double? { get { return accumulator.xRegister } }

    /**
     
        Performs the previouisly-saved first operand and
        function with the newly entered second operand in 
        the xRegister.
     
     */
    
    mutating func performPendingBinaryFunction() {
        if (pendingBinaryFunction != nil) && (accumulator.xRegister != nil) {
            accumulator.xRegister = pendingBinaryFunction!.perform(secondOperand: accumulator.xRegister!)
        }
        pendingBinaryFunction = nil
    }
    
    /**
     
        Performs the function designated by the function key
        pressed.
         
         - Parameter functionKey: Function calculator key 
                                  pressed by the user.
     
     */
    
    mutating func performFunction(_ functionKey: String) {
        //        internalProgram.append(symbol as AnyObject)
        if let function = functions[functionKey] {
            switch function {
            case .equals:   break
            default:        description = functionKey
            }
            switch function {
            case .constant(let constant):
                accumulator.xRegister = constant
            case .equals:
                performPendingBinaryFunction()
            case .nullaryFunction(let function):
                accumulator.xRegister = function()
            case .unaryFunction(let function):
                if accumulator.xRegister != nil {
                    accumulator.xRegister = function(accumulator.xRegister!)
                }
            case .binaryFunction(let function):
                if accumulator.xRegister != nil {
                    performPendingBinaryFunction()
                    pendingBinaryFunction = PendingBinaryFunction(function: function, firstOperand: accumulator.xRegister!)
                }
            }
        }
    }
    
    /**
     
         Stores the user-entered value into the xRegister.
         
         - Parameter operand: numeric value entered by the user.
     
     */
    
    mutating func setXRegister(_ operand: Double) {
        let NUMBER_FORMATTER_ERROR = "Failed to format number"
        
        accumulator.xRegister = operand
        //        internalProgram.append(operand as AnyObject)
        if let operandString = formatter.string(from: NSNumber(value: operand)) {
            description = operandString
        }
        else { description = NUMBER_FORMATTER_ERROR }
    }

    // MARK: - Data structures
    
    /**
     
         Defines the types of calculator function which can be handled on pressing
         a function key. Functions include constant values like pi, unary functions 
         like square root, binary functions like add and subtract, and equals 
         to trigger eva;uation.
     
     */
    
    private enum Function {
        case constant(Double)
        case equals
        case nullaryFunction(() -> Double)
        case unaryFunction((Double) -> Double)
        case binaryFunction((Double, Double) -> Double)
    }
    
    /**
     
         Defines the coorespondence between function keys and their associated values and-or functions.
     
     */
    
    private var functions: Dictionary<String, Function> =
        [
            "e":    Function.constant(M_E),
            "π":    Function.constant(Double.pi),
            "=":    Function.equals,
            "rand": Function.nullaryFunction(CalculatorModel.randomNumber),
            "%":    Function.unaryFunction({ $0 / 100.0 }),
            "√":    Function.unaryFunction(sqrt),
            "x²":   Function.unaryFunction({ $0 * $0 }),
            "1/X":  Function.unaryFunction({ 1 / $0 }),
            "abs":  Function.unaryFunction(abs),
            "log":  Function.unaryFunction(log10),
            "±":    Function.unaryFunction({ -$0 }),
            "+":    Function.binaryFunction({ $0 + $1 }),
            "−":    Function.binaryFunction({ $0 - $1 }),
            "×":    Function.binaryFunction({ $0 * $1 }),
            "÷":    Function.binaryFunction({ $0 / $1 })
        ]
    
    /**
     
        Tuple associates xRegister and calculator description 
        which must be in synch.
     
     */
    
    private var accumulator: (xRegister: Double?, description: String)
    
    /**
     
        Holds PendingBinaryFunction struct if any.
     
     */
    
    private var pendingBinaryFunction: PendingBinaryFunction?
    
    /**
     
     X register plus operator.
     
     */
    
    private struct PendingBinaryFunction {
        let function:       ((Double, Double) -> Double)
        let firstOperand:   Double
        
        func perform(secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    // MARK: - Local function implementations
    
    init() {
        accumulator = (nil, " ")   // initialize tuple
    }
    
    private static func randomNumber() -> Double {
        return Double(arc4random()).truncatingRemainder(dividingBy: 1000001.0) * 0.000001
    }

}
