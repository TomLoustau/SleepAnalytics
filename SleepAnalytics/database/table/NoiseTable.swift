//
//  NoiseTable.swift
//  SleepAnalytics
//
//  Created by Tom Loustau on 29/01/2026.
//

import Foundation
import SQLite

class NoiseTable {
    static let shared = NoiseTable(db: Bd.shared.getDb())
    
    private var db: Connection
    
    private let tableNoise = Table("NoiseTable")
    private let noiseId = Expression<Int64>("id")
    private let meanNoise = Expression<Double>("meanNoise")
    private let maxNoise = Expression<Double>("maxNoise")
    private let varianceNoise = Expression<Double>("varianceNoise")
    private let peaksNoise = Expression<Double>("peaksNoise")
    private let idEnregistrement = Expression<Int64>("idEnregistrement")
    private let enregistrement = Table("Enregistrement")
    
    init(db: Connection){
        self.db = db
        
        let createQuery = tableNoise.create(ifNotExists: true){ table in
            table.column(noiseId, primaryKey: PrimaryKey.autoincrement)
            table.column(self.meanNoise, defaultValue: 0.0)
            table.column(maxNoise, defaultValue: 0.0)
            table.column(varianceNoise, defaultValue: 0.0)
            table.column(peaksNoise, defaultValue: 0.0)
            table.column(idEnregistrement)
            table.foreignKey(idEnregistrement, references: enregistrement,
                             idEnregistrement, delete: .cascade)
        }
        
        try! self.db.run(createQuery)
    }
    
    func insert(noiseModel: NoiseModel) -> Int64 {
        do {
            let insert = tableNoise.insert(
                self.meanNoise <- Double(noiseModel.meanNoise),
                self.maxNoise <- Double(noiseModel.maxNoise),
                self.varianceNoise <- Double(noiseModel.varianceNoise),
                //self.peaksNoise <- Double(noiseModel.peaksNoise)
                self.idEnregistrement <- noiseModel.idEnregistrement
            )
            let noiseId = try self.db.run(insert)
            print("insert dans la table noise done ✅")
            return noiseId
        } catch {
            print(error)
        }
        return 0
    }
}


