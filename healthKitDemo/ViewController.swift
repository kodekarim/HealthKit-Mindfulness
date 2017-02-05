//
//  ViewController.swift
//  healthKitDemo
//
//  Created by Abdul on 04/02/17.
//  Copyright © 2017 Kayoti. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var healthBtn: UIButton!
    
    var startTime = TimeInterval()
    var timer:Timer = Timer()
    let healthStore = HKHealthStore()
    var endTime: Date!
    var alarmTime: Date!
    
    
    @IBAction func startAct(_ sender: Any) {
        alarmTime = Date()
        if (!timer.isValid) {
            let aSelector : Selector = #selector(ViewController.updateTime)
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
            startTime = Date.timeIntervalSinceReferenceDate
        }
    }
    
    @IBAction func stopAct(_ sender: Any) {
        endTime = Date()
        self.saveMindfullAnalysis()
        //self.retrieveSleepAnalysis()
        timer.invalidate()
    }
    
    func updateTime() {
        let currentTime = Date.timeIntervalSinceReferenceDate
        
        //Find the difference between current time and start time.
        var elapsedTime: TimeInterval = currentTime - startTime
        
        // print(elapsedTime)
        //  print(Int(elapsedTime))
        
        //calculate the minutes in elapsed time.
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (TimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        let seconds = UInt8(elapsedTime)
        elapsedTime -= TimeInterval(seconds)
        
        //find out the fraction of milliseconds to be displayed.
        let fraction = UInt8(elapsedTime * 100)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        
        //concatenate minuets, seconds and milliseconds as assign it to the UILabel
        timerLabel.text = "\(strMinutes):\(strSeconds):\(strFraction)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        healthBtn.isHidden = !HKHealthStore.isHealthDataAvailable()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func activateHealthKit(_ sender: Any) {
        let typestoRead = Set([
            HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.mindfulSession)!
            ])
        
        let typestoShare = Set([
            HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.mindfulSession)!
            ])
        
        self.healthStore.requestAuthorization(toShare: typestoShare, read: typestoRead) { (success, error) -> Void in
            if success == false {
                print("solve this error\(error)")
                NSLog(" Display not allowed")
            }
            if success == true {
                print("dont worry everything is good\(success)")
                NSLog(" Integrated SuccessFully")
            }
        }
    }
    
    
    func saveMindfullAnalysis() {
        
        // alarmTime and endTime are NSDate objects
        if let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession) {
            
            // we create our new object we want to push in Health app
            let mindfullSample = HKCategorySample(type:mindfulType, value: 0, start: self.alarmTime, end: self.endTime)
            
            // at the end, we save it
            healthStore.save(mindfullSample, withCompletion: { (success, error) -> Void in
                
                if error != nil {
                    // something happened
                    return
                }
                
                if success {
                    print("My new data was saved in HealthKit")
                    
                } else {
                    // something happened again
                }
                
            })
        
        }
        
    }

}

