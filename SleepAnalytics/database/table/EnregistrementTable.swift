//
//  Enregistrement.swift
//  SleepAnalytics
//
//  Created by Tom Loustau on 28/01/2026.
//

import Foundation
import SQLite

class EnregistrementTable {
    
    static let shared = EnregistrementTable(db: Bd.shared.getDb())
    
    private var db : Connection
    
    private let tableEnregistrement = Table("Enregistrement")
    private let enregistrementId = Expression<Int64>("id")
    private let enregistrementDate = Expression<Date>("dateEnregistrement")
    
    init(db: Connection){
        self.db = db
        
        let createQuery = tableEnregistrement.create(ifNotExists: true){ table in
            table.column(enregistrementId, primaryKey: PrimaryKey.autoincrement)
            table.column(enregistrementDate)
        }
        
        try! self.db.run(createQuery)
    }
    
    
    func insert() -> Int64 {
        do{
            let insert = tableEnregistrement.insert(
                self.enregistrementDate <- Date())
            let enregistrementId = try self.db.run(insert)
            print("insert dans la table enregistrement done ✅")
            return enregistrementId
        }catch{
            print(error)
        }
        return 0
    }
    
    func update(motionModel: MotionModel) -> Int64 {
        do{
            let updatedItem = tableEnregistrement.filter(self.enregistrementId == motionModel.idEnregistrement!)
            
            let update = updatedItem.update(self.enregistrementId <- motionModel.idEnregistrement!,
                                            self.enregistrementDate <- motionModel.date)
            
            let enregistrementId = try self.db.run(update)
            return Int64(enregistrementId)
        }catch{
            print(error)
        }
        return 0
    }
}
