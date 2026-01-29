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
    @Published var idEnregistrement: Int64?
    let filePath: String = "/Users/tomloustau/Desktop/Bureau/CodePlaisir/BaseSwift/SleepAnalytics/SleepAnalytics/data.csv"
    
    init(){
        self.motionMeasure = MotionModel(id: 0, meanAmplitude: 0.0, maxAmplitude: 0.0, varianceAmplitude: 0.0, date: Date(), idEnregistrement: 0)
        self.accelerometerTable = AccelerometerDataTable(db: self.bd.getDb())
        self.enregistrementTable = EnregistrementTable(db: self.bd.getDb())
    }
    
    func accelerometerData(){
        guard motionManager.isAccelerometerAvailable else { return }
        motionManager.accelerometerUpdateInterval = 0.05
        self.idEnregistrement = self.enregistrementTable.insert(motionModel: motionMeasure)
        motionManager.startAccelerometerUpdates(to : .main){ [weak self] (data, error) in
            guard let data = data, let self = self else { return }
            self.x = data.acceleration.x
            self.y = data.acceleration.y
            self.z = data.acceleration.z
            self.amplitude = (sqrt((x*x) + (y*y) + (z*z)) - 1) * 1000
            self.amplitude = sqrt(self.amplitude * self.amplitude)
            self.motionMeasure = MotionModel(id: nil, meanAmplitude: self.amplitude, maxAmplitude: 0.0, varianceAmplitude: 0.0, date: Date(), idEnregistrement: self.idEnregistrement)
            self.motionMeasures.append(self.motionMeasure)
            if self.motionMeasures.count == 300 {
                self.insertMeasuresDb(motionMeasures: self.motionMeasures)
                self.motionMeasures = []
            }
        }
    }
    
    func stopAccelerometer(){
        guard motionManager.isAccelerometerActive else { return }
        motionManager.stopAccelerometerUpdates()
    }
    
    func variance(of numbers: [Double]) -> Double? {
        guard !numbers.isEmpty else { return nil }
        
        let mean = numbers.reduce(0, +) / Double(numbers.count)
        
        let sumOfSquaredDifferences = numbers.map { pow($0 - mean, 2) }.reduce(0, +)
        
        return sumOfSquaredDifferences / Double(numbers.count)
    }
    
    func meanMeasure(motionMeasures: [MotionModel]) -> [MotionModel]{
        let bufferLen = 30
        var tempSum = 0.0
        var tempMean = 0.0
        var beginIndex = 0
        var endIndex = 30
        var lstAmp: [Double] = []
        var newMotionMeasures: [MotionModel] = []
        print(motionMeasures.count)
        for _ in 0..<(motionMeasures.count / bufferLen){
            print(endIndex)
            for i in beginIndex..<endIndex {
                lstAmp.append(motionMeasures[i].meanAmplitude)
                tempSum += motionMeasures[i].meanAmplitude
                if motionMeasures[i].meanAmplitude > self.maxAmplitude {
                    self.maxAmplitude = motionMeasures[i].meanAmplitude
                }
            }
            tempMean = tempSum / Double(bufferLen)
            self.varianceAmplitude = self.variance(of: lstAmp)!
            self.motionMeasure = MotionModel(id: nil, meanAmplitude: tempMean, maxAmplitude: self.maxAmplitude, varianceAmplitude: self.varianceAmplitude, date: Date(), idEnregistrement: self.idEnregistrement)
            newMotionMeasures.append(self.motionMeasure)
            tempSum = 0.0
            self.maxAmplitude = 0
            lstAmp = []
            beginIndex += 30
            endIndex += 30
        }
        return newMotionMeasures
    }
    
    func insertMeasuresDb(motionMeasures: [MotionModel]){
        let meanMotionMeasures = self.meanMeasure(motionMeasures: motionMeasures)
        for measure in meanMotionMeasures{
            self.id = self.accelerometerTable.insert(motionModel: measure)
        }
    }
}


