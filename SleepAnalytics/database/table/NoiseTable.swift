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
    private let meanNoise = Expression<Float64>("meanNoise")
    private let maxNoise = Expression<Float64>("maxNoise")
    private let varianceNoise = Expression<Float64>("varianceNoise")
    private let peaksNoise = Expression<Float64>("peaksNoise")
    private let date = Expression<Date>("date")
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
            table.column(date)
            table.column(idEnregistrement)
            table.foreignKey(idEnregistrement, references: enregistrement,
                             idEnregistrement, delete: .cascade)
        }
        
        try! self.db.run(createQuery)
    }
    
    func insert(noiseModel: NoiseModel) -> Int64 {
        do {
            let insert = tableNoise.insert(
                self.meanNoise <- Float64(noiseModel.meanNoise),
                self.maxNoise <- Float64(noiseModel.maxNoise),
                self.varianceNoise <- Float64(noiseModel.varianceNoise),
                //self.peaksNoise <- Double(noiseModel.peaksNoise),
                self.date <- Date(),
                self.idEnregistrement <- Int64(noiseModel.idEnregistrement)
            )
            let noiseId = try self.db.run(insert)
            return noiseId
        } catch {
            print(error)
        }
        return 0
    }
    
    func selectByEnregistrement(idEnregistrement: Int) -> [NoiseModel] {
        var result: [NoiseModel] = []
        let query = self.tableNoise.filter(self.idEnregistrement == Int64(idEnregistrement))
        for row in try! db.prepare(query) {
            let model = NoiseModel(id: row[self.noiseId],
                                   meanNoise: Float(row[self.meanNoise]),
                                   maxNoise: Float(row[self.maxNoise]),
                                   varianceNoise: Float(row[self.varianceNoise]),
                                   peaksNoise: 0,
                                   date: row[self.date],
                                   idEnregistrement: 0)
            result.append(model)
        }
        return result
    }
}


