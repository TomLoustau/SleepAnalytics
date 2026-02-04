//
//  Accelerometre.swift
//  SleepAnalytics
//
//  Created by Tom Loustau on 27/01/2026.
//

import Foundation
import CoreMotion
import Combine

class MotionManager: ObservableObject{
    private let motionManager = CMMotionManager()
    private let bd: Bd = Bd.shared
    private let accelerometerTable : AccelerometerDataTable
    private let enregistrementTable : EnregistrementTable
    private var x: Double = 0.0
    private var y: Double = 0.0
    private var z: Double = 0.0
    @Published var id: Int64?
    @Published var motionMeasure: MotionModel
    @Published var motionMeasures: [MotionModel] = []
    @Published var amplitude: Double = 0.0
    @Published var varianceAmplitude: Double = 0.0
    @Published var maxAmplitude: Double = 0.0
    
    init(){
        self.motionMeasure = MotionModel(id: 0, meanAmplitude: 0.0, maxAmplitude: 0.0, varianceAmplitude: 0.0, date: Date(), idEnregistrement: 0)
        self.accelerometerTable = AccelerometerDataTable(db: self.bd.getDb())
        self.enregistrementTable = EnregistrementTable(db: self.bd.getDb())
    }
    
    func accelerometerData(idEnregistrement: Int64) -> Void{
        guard motionManager.isAccelerometerAvailable else { return }
        
        motionManager.accelerometerUpdateInterval = 0.5
        motionManager.startAccelerometerUpdates(to : .main){ [weak self] (data, error) in
            guard let data = data, let self = self else { return }
            self.x = data.acceleration.x
            self.y = data.acceleration.y
            self.z = data.acceleration.z
            self.amplitude = getAmplitude(x: self.x, y: self.y, z: self.z)
            self.motionMeasure = MotionModel(id: nil, meanAmplitude: self.amplitude, maxAmplitude: 0.0, varianceAmplitude: 0.0, date: Date(), idEnregistrement: idEnregistrement)
            self.saveMotionData(idEnregistrement: idEnregistrement)
        }
    }
    
    func getAmplitude(x: Double, y: Double, z: Double) -> Double {
        let tempAmp: Double = (sqrt((x*x) + (y*y) + (z*z)) - 1) * 1000
        return sqrt(tempAmp * tempAmp) // Valeur absolue
    }
    
    func stopAccelerometer() -> Void{
        guard motionManager.isAccelerometerActive else { return }
        motionManager.stopAccelerometerUpdates()
    }
    
    func variance(of numbers: [Double]) -> Double? {
        guard !numbers.isEmpty else { return nil }
        
        let mean = numbers.reduce(0, +) / Double(numbers.count)
        
        let sumOfSquaredDifferences = numbers.map { pow($0 - mean, 2) }.reduce(0, +)
        
        return sumOfSquaredDifferences / Double(numbers.count)
    }
    
    func mean(of amplitudes: [Double]) -> Double {
        return amplitudes.reduce(0, +) / Double(amplitudes.count)
    }
    
    func createMotionModel(amplitudes: [Double], idEnregistrement: Int64) -> MotionModel {
        let meanAmp: Double = self.mean(of: amplitudes)
        let maxAmp: Double = amplitudes.max() ?? 0.0
        let varAmp: Double = self.variance(of: amplitudes) ?? 0.0
        return MotionModel(id: nil, meanAmplitude: meanAmp, maxAmplitude: maxAmp, varianceAmplitude: varAmp, date: Date(), idEnregistrement: idEnregistrement)
    }
    
    func saveMotionData(idEnregistrement: Int64) -> Void{
        self.motionMeasures.append(self.motionMeasure)
        if self.motionMeasures.count == 300 {
            self.insertMeasuresDb(motionMeasures: self.motionMeasures, idEnregistrement: idEnregistrement)
            self.motionMeasures = []
        }
    }
    
    func meanMeasure(motionMeasures: [MotionModel], idEnregistrement: Int64) -> [MotionModel]{
        let bufferLen = 30
        var index = 0
        var lstAmp: [Double] = []
        var newMotionMeasures: [MotionModel] = []

        for _ in 0..<(motionMeasures.count / bufferLen){
            for i in index..<(index + bufferLen) {
                lstAmp.append(motionMeasures[i].meanAmplitude)
            }
            newMotionMeasures.append(self.createMotionModel(amplitudes: lstAmp, idEnregistrement: idEnregistrement))
            lstAmp = []
            index += bufferLen
        }
        return newMotionMeasures
    }
    
    func insertMeasuresDb(motionMeasures: [MotionModel], idEnregistrement: Int64){
        let meanMotionMeasures = self.meanMeasure(motionMeasures: motionMeasures, idEnregistrement: idEnregistrement)
        for measure in meanMotionMeasures{
            self.id = self.accelerometerTable.insert(motionModel: measure)
        }
    }
}


