//
//  CalculatorVC.swift
//  Calculator
//
//  Created by Tubal Cain on 2/23/17.
//  Copyright © 2017 Will Wagers. All rights reserved.
//

import UIKit

internal var formatter = NumberFormatter()

class CalculatorVC: UIViewController {
    
    // MARK: - Actions
    
    @IBAction fileprivate func backspacePressed(_ button: UIButton) {
        if entryInProgress {
            let s = display.text!.characters.dropLast()
            if s.count > 0 {
                display.text = String(s)
            } else {
                display.text = "0"
            }
        }
    }
    
    @IBAction fileprivate func clearPressed(_ button: AnyObject) {
        resetCalculator()
    }
    
    @IBAction func digitKeyPressed(_ digitKey: UIButton) {
        if entryInProgress {
            if digitKey.currentTitle == DECIMAL_POINT {
                if (display.text?.contains(DECIMAL_POINT))! {
                    return  // disallow multiple decimal points
                }
            }
            display.text = display.text! + digitKey.currentTitle!
        } else {
            if !model.calculationPending {
                resetCalculator()
            }
            display.text = digitKey.currentTitle!
        }
        entryInProgress = true
    }
    
    @IBAction func functionKeyPressed(_ functionKey: UIButton) {
        if entryInProgress {
            model.setXRegister(displayValue)
            entryInProgress = false
        }
        model.performFunction(functionKey.currentTitle!)
        if model.result != nil {
            displayValue = model.result!
        }
        history.text = model.description + (model.calculationPending ? ELLIPSIS_SIGN : EQUALS_SIGN)
    }

    
    @IBAction func loadMpressed(_ button: UIButton) {
        //        model.setOperand(MEMORY_KEY)
        //        performOp(sender)
        //        displayValue = model.result
    }

    @IBAction func storeMpressed(_ button: UIButton) {
        //        model.variableValues[MEMORY_KEY] = displayValue
        //        displayValue = model.result
    }

    // MARK: - Outlets
    
    @IBOutlet weak var display: UILabel!    // Calculator one line display
    @IBOutlet weak var history: UILabel!    // Calculator history record
    
    // MARK: - Constants and variables
    
    private let MEMORY_KEY      = "M"
    private let DECIMAL_POINT   = "."
    private let ELLIPSIS_SIGN   = "…"
    private let EQUALS_SIGN     = "="
    
    /// Binary function awaiting second operand.
    private var entryInProgress = false
    
    private var model = CalculatorModel()
    
    /**
     
        Reset both the calculator model and display.
     
     */
    
    private func resetCalculator() {
        model.reset()
        displayValue = 0.0
        history.text = " "      // model.description
        entryInProgress = false
        //        model.variableValues[M] = 0.0
    }
    
    /**
     
        Property backed by display.text.
     
     */
    
    private var displayValue: Double { // convenient computed property
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(formatter.string(from: newValue as NSNumber? ?? 0.0)!)
        }
    }

    // MARK: - Delegate methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // M testing code
//        model.setOperand(MEMORY_KEY)
//        model.variableValues[MEMORY_KEY] = 0.0
//        model.setOperand("X")
//        model.variableValues["X"] = 35.0
        
        formatter.numberStyle = .decimal        // init numeric formatter
        formatter.maximumFractionDigits = 6
        formatter.locale = Locale.current
    }
    
}
