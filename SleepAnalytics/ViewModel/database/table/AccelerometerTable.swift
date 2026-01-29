//
//  AccelerometerTable.swift
//  SleepAnalytics
//
//  Created by Tom Loustau on 28/01/2026.
//

import Foundation
import SQLite

class AccelerometerDataTable {
    
    static let shared = AccelerometerDataTable(db: Bd.shared.getDb())
    
    private var db : Connection
    
    private let tableAccelerometerData = Table("AccelerometerData")
    private let accelerometerId = Expression<Int64>("id")
    private let accelerometerAmplitude = Expression<Double>("meanAmplitude")
    private let maxAmplitude = Expression<Double>("maxAmplitude")
    private let varianceAmplitude = Expression<Double>("varianceAmplitude")
    private let idEnregistrement = Expression<Int64>("idEnregistrement")
    private let enregistrement = Table("Enregistrement")
    
    init(db: Connection){
        self.db = db
        
        let createQuery = tableAccelerometerData.create(ifNotExists: true){ table in
            table.column(accelerometerId, primaryKey: PrimaryKey.autoincrement)
            table.column(accelerometerAmplitude, defaultValue: 0)
            table.column(maxAmplitude, defaultValue: 0)
            table.column(varianceAmplitude, defaultValue: 0)
            table.column(idEnregistrement)
            table.foreignKey(idEnregistrement, references: enregistrement, idEnregistrement, delete: .cascade)
        }
        
        try! self.db.run(createQuery)
    }
    
    
    func insert(motionModel: MotionModel) -> Int64 {
        do{
            let insert = tableAccelerometerData.insert(
                self.accelerometerAmplitude <- motionModel.meanAmplitude,
                self.maxAmplitude <- motionModel.maxAmplitude,
                self.varianceAmplitude <- motionModel.varianceAmplitude,
                self.idEnregistrement <- motionModel.idEnregistrement!)
            let accelerometerId = try self.db.run(insert)
            print("insert dans la table accelerometre done ✅")
            return accelerometerId
        }catch{
            print(error)
        }
        return 0
    }
    
    func update(motionModel: MotionModel) -> Int64 {
        do{
            let updatedItem = tableAccelerometerData.filter(accelerometerId == motionModel.id!)
            
            let update = updatedItem.update(self.accelerometerId <- motionModel.id!,
                                            self.accelerometerAmplitude <- motionModel.meanAmplitude,
                                            self.maxAmplitude <- motionModel.maxAmplitude,
                                            self.varianceAmplitude <- motionModel.varianceAmplitude)
            
            let accelerometerId = try self.db.run(update)
            return Int64(accelerometerId)
        }catch{
            print(error)
        }
        return 0
    }
    
    func getIdEnregistrement() -> Int64 {
        let id: Int64 = 0
        let query = tableAccelerometerData
            .select(self.idEnregistrement)
            .order(self.idEnregistrement.desc)
            .limit(1)
        
        do{
            if let row = try db.pluck(query){
                return row[self.idEnregistrement]
            }
        } catch {
            print(error)
        }
        return id
    }
}
