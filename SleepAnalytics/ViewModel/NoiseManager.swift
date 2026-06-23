//
//  NoiseManager.swift
//  SleepAnalytics
//
//  Created by Tom Loustau on 30/01/2026.
//

import Foundation
import AVFoundation
import Combine
import SwiftUI

class NoiseManager: NSObject, ObservableObject{
    private let bd: Bd = Bd.shared
    private let noiseTable: NoiseTable
    private let session: AVAudioSession = AVAudioSession.sharedInstance()
    private var noiseMeasures: [NoiseModel] = []
    private var noiseMeasure: NoiseModel?
    private var enregistrementTable: EnregistrementTable
    @Published var noiseMeanMeasure: Float = 0.0
    @Published var isRecording: Bool = false
    @Published var recorder: AVAudioRecorder?
    
    let tempPath = NSTemporaryDirectory().appending("temp_audio.m4a")
    
    let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatAppleLossless),
            AVSampleRateKey: 8000.0, // Basse fréquence pour économiser la batterie
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
        ]
    
    override init(){
        self.enregistrementTable = EnregistrementTable(db: self.bd.getDb())
        self.noiseTable = NoiseTable(db: self.bd.getDb())
        let url = URL(fileURLWithPath: tempPath)
        super.init()
        self.setupRecorder()
        do {
            self.recorder = try AVAudioRecorder(url: url, settings: self.settings)
        }
        catch {
            print("Erreur setup micro : \(error)")
        }
    }
    
    func setupRecorder(){
        
        // Configuration
        try? self.session.setCategory(.playAndRecord, mode: .measurement, options: [.mixWithOthers, .defaultToSpeaker])
        try? self.session.setActive(true)
        
    }
    
    func recording(idEnregistrement: Int64) -> Void {
        if self.isRecording == false {
            try? self.session.setActive(true)
            self.recorder?.isMeteringEnabled = true
            self.recorder?.record()
            self.isRecording = true
            self.noiseData(idEnregistrement: idEnregistrement)
        }
        else {
            self.recorder?.isMeteringEnabled = false
            self.isRecording = false
            self.recorder?.stop()
            try? self.session.setActive(false)
            print("Stop recording")
        }
    }
    
    
    func noiseData(idEnregistrement: Int64) -> Void {
        let minDb: Float = -80.0
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if self.isRecording {
                self.recorder?.updateMeters()
                
                let db: Float = self.recorder?.averagePower(forChannel: 0) ?? 0.0
                
                self.noiseMeanMeasure = (db - minDb) * 10
                
                if self.noiseMeanMeasure <= 0 { self.noiseMeanMeasure = 0.1 }
                
                self.noiseMeasure = NoiseModel(id: nil, meanNoise: self.noiseMeanMeasure, maxNoise: 0.0, varianceNoise: 0.0, peaksNoise: 0.0, date: Date(), idEnregistrement: idEnregistrement)
                self.saveNoiseData(of: self.noiseMeasure!, idEnregistrement: idEnregistrement)
            }
            else {
                timer.invalidate()
            }
        }
    }
    
    func saveNoiseData(of data: NoiseModel, idEnregistrement: Int64) -> Void {
        self.noiseMeasures.append(data)
        
        if self.noiseMeasures.count == 300 {
            self.insertNoisesDb(noises: self.noiseMeasures, idEnregistrement: idEnregistrement)
            self.noiseMeasures = []
        }
    }
    
    func variance(of numbers: [Float]) -> Float? {
        guard !numbers.isEmpty else { return nil }
        
        let mean = numbers.reduce(0, +) / Float(numbers.count)
        
        let sumOfSquaredDifferences = numbers.map { pow($0 - mean, 2) }.reduce(0, +)
        
        return sumOfSquaredDifferences / Float(numbers.count)
    }
    
    func mean(of amplitudes: [Float]) -> Float {
        return amplitudes.reduce(0, +) / Float(amplitudes.count)
    }
    
    func createNoiseModel(noises: [Float], idEnregistrement: Int64) -> NoiseModel{
        let meanNoise: Float = self.mean(of: noises)
        let maxNoise: Float = noises.max() ?? 0.0
        let varianceNoise: Float = self.variance(of: noises) ?? 0.0
        return NoiseModel(id: nil, meanNoise: meanNoise, maxNoise: maxNoise, varianceNoise: varianceNoise, peaksNoise: nil, date: Date(), idEnregistrement: idEnregistrement)
    }
    
    
    func cleanNoiseMeasures(noiseMeasures: [NoiseModel], idEnregistrement: Int64) -> [NoiseModel]{
        let bufferLen: Int = 30
        var index: Int = 0
        var lstNoise: [Float] = []
        var newNoiseMeasure: [NoiseModel] = []
        
        for _ in 0..<(noiseMeasures.count / bufferLen) {
            for i in index..<(index + bufferLen) {
                lstNoise.append(noiseMeasures[i].meanNoise)
            }
            newNoiseMeasure.append(self.createNoiseModel(noises: lstNoise, idEnregistrement: idEnregistrement))
            lstNoise = []
            index += bufferLen
        }
        
        return newNoiseMeasure
    }
    
    func insertNoisesDb(noises: [NoiseModel], idEnregistrement: Int64) -> Void {
        let cleanNoiseMeasures = self.cleanNoiseMeasures(noiseMeasures: noises, idEnregistrement: idEnregistrement)
        for measure in cleanNoiseMeasures {
            var _ = self.noiseTable.insert(noiseModel: measure)
        }
    }
    
    func getNoiseDataById(idEnregistrement: Int) -> [NoiseModel] {
        let noises = self.noiseTable.selectByEnregistrement(idEnregistrement: idEnregistrement)
        return flatData(noises: noises, intensite: 10)
    }
    
    func flatData(noises: [NoiseModel], intensite: Int) -> [NoiseModel] {
        return stride(from: intensite, to: noises.count, by: intensite).map { i in
            let plage = noises[(i-intensite)..<i]
            
            let moyenneMean = plage.map { $0.meanNoise }.reduce(0, +) / Float(intensite)
            let moyenneMax = plage.map { $0.maxNoise }.reduce(0, +) / Float(intensite)
            let moyenneVariance = plage.map { $0.varianceNoise }.reduce(0, +) / Float(intensite)
            let date = noises[i - (intensite/2)].date
            let idEnregistrement = 0
            
            return NoiseModel(
                id: nil,
                meanNoise: moyenneMean,
                maxNoise: moyenneMax,
                varianceNoise: moyenneVariance,
                peaksNoise: nil,
                date: date,
                idEnregistrement: Int64(idEnregistrement)
            )
        }
    }
}
