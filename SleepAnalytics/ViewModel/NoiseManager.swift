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
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
        try? session.setActive(true)
        
    }
    
    func recording(idEnregistrement: Int64) -> Void {
        if self.isRecording == false {
            self.recorder?.isMeteringEnabled = true
            self.recorder?.record()
            self.isRecording = true
            self.noiseData(idEnregistrement: idEnregistrement)
        }
        else {
                self.stopRecorder()
                self.isRecording = false
            }
    }
    
    func stopRecorder() -> Void {
        self.recorder?.stop()
    }
    
    func noiseData(idEnregistrement: Int64) -> Void {
        let minDb: Float = -60.0
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.recorder?.updateMeters()
            
            let db: Float = self.recorder?.averagePower(forChannel: 0) ?? 0.0
            
            self.noiseMeanMeasure = (db - minDb) * 10
            
            self.noiseMeasure = NoiseModel(id: nil, meanNoise: self.noiseMeanMeasure, maxNoise: 0.0, varianceNoise: 0.0, peaksNoise: 0.0, idEnregistrement: idEnregistrement)
            self.saveNoiseData(of: self.noiseMeasure!, idEnregistrement: idEnregistrement)
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
        return NoiseModel(id: nil, meanNoise: meanNoise, maxNoise: maxNoise, varianceNoise: varianceNoise, peaksNoise: nil, idEnregistrement: idEnregistrement)
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
}
