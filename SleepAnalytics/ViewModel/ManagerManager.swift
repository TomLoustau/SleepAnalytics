//
//  ManageManager.swift
//  SleepAnalytics
//
//  Created by Tom Loustau on 04/02/2026.
//

import Foundation
import Combine
import SwiftUI
import AVFAudio

class ManagerManager: ObservableObject {
    @Published var motionManager: MotionManager = MotionManager()
    @Published var noiseManager: NoiseManager = NoiseManager()
    @Published var textRecordButton: String = "Lancer l'enregistrement"
    @Published var colorButton: Color = Color.green
    private let bd: Bd = Bd.shared
    private let enregistrementTable : EnregistrementTable
    private var idEnregistrement: Int64 = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.enregistrementTable = EnregistrementTable(db: bd.getDb())
        
        motionManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        noiseManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    func startSession() -> Void {
        if self.colorButton == Color.green {
            self.colorButton = Color.red
            self.textRecordButton = "Stopper l'enregistrement"
            self.idEnregistrement = self.enregistrementTable.insert()
            self.motionManager.accelerometerData(idEnregistrement: self.idEnregistrement)
            self.noiseManager.recording(idEnregistrement: self.idEnregistrement)
        }
        else{
            self.colorButton = Color.green
            self.textRecordButton = "Lancer l'enregistrement"
            self.motionManager.stopAccelerometer()
            self.noiseManager.recorder?.stop()
        }
    }
    
    func getAmplitude() -> Double {
        return self.motionManager.amplitude
    }
    
    func getNoise() -> Float {
        return self.noiseManager.noiseMeanMeasure
    }
    
}
