//
//  GraphicView.swift
//  SleepAnalytics
//
//  Created by Tom Loustau on 12/02/2026.
//

import Foundation
import SwiftUI
import Charts

struct MotionGraphicView: View {
    @State var accelerometerData: [MotionModel]
    @State var zoomLevel: TimeInterval = 100
    @State var selectedValue: Date?
    var graphicH: CGFloat = 300
    var graphicW: CGFloat = 300
    var yMax: Int = 50
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.05)
                .ignoresSafeArea()
            VStack {
                
                Text("Graphique des mouvement")
                    .font(.headline)
                    .foregroundColor(Color.yellow)
                
                if accelerometerData.isEmpty {
                    ContentUnavailableView("Aucune donnée", systemImage: "chart.bar.fill")
                }
                else {
                    
                    Chart(accelerometerData, id: \.id){ measure in
//                        LineMark(
//                            x: .value("Heure", measure.date),
//                            y: .value("Moyenne", measure.meanAmplitude),
//                            series: .value("Type", "Moyenne")
//                        )
//                        
//                        .interpolationMethod(.cardinal)
//                        .foregroundStyle(Color.yellow.gradient)
                        
                        LineMark(
                            x: .value("Heure", measure.date),
                            y: .value("Max", measure.maxAmplitude),
                            series: .value("Type", "Max")
                        )
                        .interpolationMethod(.cardinal)
                        .foregroundStyle(Color.yellow)
                        
//                        LineMark(
//                            x: .value("Heure", measure.date),
//                            y: .value("Variance", measure.varianceAmplitude),
//                            series: .value("Type", "Variance")
//                        )
//                        .interpolationMethod(.cardinal)
//                        .foregroundStyle(Color.green.gradient)
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
                        AxisMarks(values: Array(stride(from: 0, through: yMax, by: yMax / 2))) {value in
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
                    .chartYScale(domain: 0...yMax)
                    .chartXVisibleDomain(length: 25000)
                    //.chartXSelection($selectedValue)
                    .chartScrollableAxes(.horizontal)
                    .padding()
                    
//                    Slider(value: $zoomLevel, in: 60...15000,
//                           step: 500)
//                    {
//                        Text("\(zoomLevel)")
//                    } minimumValueLabel: {
//                        Text("60")
//                    } maximumValueLabel: {
//                        Text("15000")
//                    }
//                    .foregroundStyle(Color.yellow)
//                    .padding()
//                    Text(zoomLevel, format: .number.precision(.fractionLength(0)))
//                        .foregroundColor(Color.yellow)
                }
            }
        }
    }
}
