//
//  bd.swift
//  SleepAnalytics
//
//  Created by Tom Loustau on 28/01/2026.
//

import Foundation
import SQLite

class Bd{
    static let shared = Bd()
    
    private let db : Connection
    
    init(){
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        db = try! Connection("\(path)/SleepAnalysis.db")
    }
    
    func getDb() -> Connection {
        
        return self.db
    }
    
}
