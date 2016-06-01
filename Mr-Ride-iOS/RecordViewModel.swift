//
//  RecordViewModel.swift
//  Mr-Ride-iOS
//
//  Created by Lin Yi-Cheng on 2016/5/31.
//  Copyright © 2016年 Lin Yi-Cheng. All rights reserved.
//

import Foundation

//
//  CalorieCalculator.swift
//  Mr-Ride
//
//  Created by howard hsien on 2016/5/30.
//  Copyright © 2016年 AppWorks School Hsien. All rights reserved.
//

import Foundation

class DataCalCulatingModel {
    
    private var kCalPerKm_Hour : Dictionary <Exercise,Double> = [
        .Bike : 0.4
    ]
    
    enum Exercise {
        case Bike
    }
    
    // unit
    // speed : km/h
    // weight: kg
    // time: hr
    // return : kcal
    func kiloCalorieBurned(exerciseType: Exercise, speed: Double, weight: Double, time:Double) -> Double{
        if let kCalUnit = kCalPerKm_Hour[exerciseType]{
            return speed * weight * time * kCalUnit
        }
        else{
            return 0.0
        }
    }
    
    func calculatePolylineDistance(path: [CLLocation]) -> Double {
        var distance = 0.0
        for spot in 0 ..< (path.count - 1) {
            let sectionDistance = path[spot].distanceFromLocation(path[(spot + 1)])
            distance += sectionDistance
        }
        
        return distance
    }
    
//    func updateTime(startTime: NSTimeInterval)-> String {
//       
//        let currentTime = NSDate.timeIntervalSinceReferenceDate()
//    
//        //Find the difference between current time and start time.
//    
//        var elapsedTime: NSTimeInterval = currentTime - startTime
//        //calculate the hours in elapsed time.
//        let hours = UInt8(elapsedTime / 360.0)
//    
//        elapsedTime -= (NSTimeInterval(hours) * 360)
//        //calculate the minutes in elapsed time.
//    
//        let minutes = UInt8(elapsedTime / 60.0)
//    
//        elapsedTime -= (NSTimeInterval(minutes) * 60)
//    
//        //calculate the seconds in elapsed time.
//    
//        let seconds = UInt8(elapsedTime)
//    
//        elapsedTime -= NSTimeInterval(seconds)
//    
//        //find out the fraction of milliseconds to be displayed.
//    
//        let fraction = UInt8(elapsedTime * 100)
//    
//        //add the leading zero for minutes, seconds and millseconds and store them as string constants
//        let strHours = String(format: "%02d", hours)
//        let strMinutes = String(format: "%02d", minutes)
//        let strSeconds = String(format: "%02d", seconds)
//        let strFraction = String(format: "%02d", fraction)
//    
//        //concatenate minuets, seconds and milliseconds as assign it to the UILabel
//        let text = "\(strHours):\(strMinutes):\(strSeconds).\(strFraction)"
//        return text
//        
//    }
}

//var startTime = NSTimeInterval()
//var timer = NSTimer()
//var pause = false
//
//func locationManager(manager: CLLocationManager, didUpdateLocations locations:[CLLocation]){
//    //need to check TimeStamp
//    //NSTime for not checking the location so many times so that we can save space in core data
//    // 三軸感應來算速度
//}
//

//
//
