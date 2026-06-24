//
//  NoiseGraficView.swift
//  SleepAnalytics
//
//  Created by Tom Loustau on 12/02/2026.
//

import Foundation
import Charts
import SwiftUI

struct NoiseGraphicView: View {
    @State var noiseData: [NoiseModel]
    @State var zoomLevel: TimeInterval = 560
    var graphicH: CGFloat = 300
    var graphicW: CGFloat = 300
    var yMax: Float? {
        noiseData.max(by: { $0.maxNoise < $1.maxNoise })?.maxNoise
    }
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.05)
                .ignoresSafeArea()
            VStack {
                
                Text("Graphique des déibels")
                    .font(.headline)
                    .foregroundColor(Color.yellow)
                
                if noiseData.isEmpty {
                    ContentUnavailableView("Aucune donnée", systemImage: "chart.bar.fill")
                }
                else {
                    Chart(noiseData, id: \.id){ measure in
                        LineMark(
                            x: .value("Heure", measure.date),
                            y: .value("Max", measure.maxNoise),
                            series: .value("Type", "Max")
                        )
                        .interpolationMethod(.cardinal)
                        .foregroundStyle(Color.yellow)
                    }
                    .frame(height: graphicH)
                    .frame(width: graphicW)
                    .clipped()
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .hour, count : 1)) { value in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel{
                                if let date = value.as(Date.self) {
                                    let hour = Calendar.current.component(.hour, from: date)
                                    Text("\(hour)h")
                                        .foregroundColor(Color.yellow)
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(values: Array(stride(from: 0, through: yMax!, by: yMax! / 5))) {value in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel{
                                if let value = value.as(Int.self) {
                                    Text("\(value)")
                                        .foregroundColor(Color.yellow)
                                }
                            }
                        }
                    }
                    .chartYScale(domain: 0...yMax!)
                    .chartXVisibleDomain(length: 25000)
                    .chartScrollableAxes(.horizontal)
                    .padding()
                }
            }
        }
    }
}
