//
//  NoiseModel.swift
//  SleepAnalytics
//
//  Created by Tom Loustau on 29/01/2026.
//

import Foundation

struct NoiseModel {
    let id: Int64?
    let meanNoise: Float
    let maxNoise: Float
    let varianceNoise: Float
    let peaksNoise: Float?
    let date: Date
    let idEnregistrement: Int64
}
