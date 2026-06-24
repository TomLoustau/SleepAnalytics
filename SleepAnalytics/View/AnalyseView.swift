//
//  SwiftUIView.swift
//  SleepAnalytics
//
//  Created by Tom Loustau on 23/06/2026.
//
import SwiftUI
import Foundation
import Charts

struct AnalyseView: View {
    @State private var versMouvement = false
    @State private var versDecibel = false
    @StateObject var manager: ManagerManager = ManagerManager()
    @StateObject var enregistrementManager = EnregistrementManager()
    @State var selectionValue: EnregistrementModel?
    @State var accelerometerData: [MotionModel]?
    @State var noiseData: [NoiseModel]?
    @State var sleepBegin: Date?
    let flatIntensity: Int = 100
    
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.05)
                .ignoresSafeArea()
            
            VStack(spacing: 20){
                Text("Analyse de votre nuit")
                    .foregroundColor(Color.yellow)
                
                graphicButtons
            }
        }
    }
    
    private var graphicButtons: some View {
        HStack {
            Button(action: { accelerometerData = manager.motionManager.flatData(id: selectionValue!.id, intensite: flatIntensity)
                versMouvement = true }) {
                    VStack(spacing: 0){
                        Image("graphique")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 130, height: 130)
                        Text("Graphique des mouvements")
                            .foregroundColor(Color.yellow)
                            .font(.system(size: 10))
                        
                    }
                }
                .padding(20)
                .background(
                   backgroundCard(width: 170)
                )
                .navigationDestination(isPresented: $versMouvement){
                    MotionGraphicView(accelerometerData: accelerometerData ?? [], selectedValue: selectionValue?.date)
                }
                
            
            
            Button(action: { noiseData = manager.noiseManager.getNoiseDataById(idEnregistrement: selectionValue!.id)
                versDecibel = true }) {
                    VStack(spacing: 0){
                        Image("graphique")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 130, height: 130)
                        Text("Graphique des decibels")
                            .foregroundColor(Color.yellow)
                            .font(.system(size: 10))
                        
                    }
                }
                .padding(20)
                .background(
                    backgroundCard(width: 170)
                )
                .navigationDestination(isPresented: $versDecibel){
                    NoiseGraphicView(noiseData: noiseData ?? [])
                }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.05), lineWidth: 2)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.gray.opacity(0.1)))
                .frame(width: 360, height: 180)
        )
        
    }
    
    private func backgroundCard(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 20)
            .stroke(Color.gray.opacity(0.1), lineWidth: 2)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.gray.opacity(0.1)))
            .frame(width: width, height: 170)
    }
}

#Preview {
    AnalyseView()
}
