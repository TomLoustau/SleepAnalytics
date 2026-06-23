//
//  EnregistrementManager.swift
//  SleepAnalytics
//
//  Created by Tom Loustau on 05/02/2026.
//

import Foundation
import Combine

class EnregistrementManager: ObservableObject {
    private var date: Date
    private let bd: Bd = Bd.shared
    private let enregistrementTable: EnregistrementTable
    private let accelerometerTable: AccelerometerDataTable
    @Published var enregistrements: [EnregistrementModel] = []
    @Published var enregistrementsId: [Int] = []
    
    init(){
        self.date = Date()
        self.enregistrementTable = EnregistrementTable(db: self.bd.getDb())
        self.accelerometerTable = AccelerometerDataTable(db: self.bd.getDb())
        self.enregistrements = accelerometerTable.selectAllEnregistrement()
        self.enregistrementsId = enregistrementTable.selectId()
    }
}
