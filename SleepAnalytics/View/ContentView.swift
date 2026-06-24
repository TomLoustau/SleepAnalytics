import SwiftUI
import Foundation
import Charts

struct ContentView: View {
    @State private var versAnalyse = false
    @StateObject var manager: ManagerManager = ManagerManager()
    @StateObject var enregistrementManager = EnregistrementManager()
    @State var selectionValue: EnregistrementModel?
    
    @State var accelerometerData: [MotionModel]?
    @State var noiseData: [NoiseModel]?
    @State var sleepBegin: Date?
    
    let textAnalyseBtn = "Accéder à l'analyse"
    var body: some View {
        NavigationStack{
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.05)
                .ignoresSafeArea() // Pour remplir tout l'écran
                    
                VStack(spacing: 20){
                    if !enregistrementManager.enregistrements.isEmpty {
                        datePicker
                    }
                    
//                    Text("amplitude \n \(manager.getAmplitude())\n \(String(describing: manager.getNoise())) db")
//                        .padding()
//                        .background(Color.gray)
//                        .cornerRadius(30)
//                        .foregroundColor(Color.white)
//                        .glassEffect(in: .rect(cornerRadius: 30))
                    analyseBtn
                    recordButton
                }
                
            }
        }
    }
    
    private var analyseBtn: some View {
        Button(action: { accelerometerData = manager.motionManager.flatData(id: selectionValue!.id, intensite: 10)
            versAnalyse = true }) {
                Text(textAnalyseBtn)
        }
            .navigationDestination(isPresented: $versAnalyse){
                AnalyseView(selectionValue: selectionValue)
            }
            .padding()
            .glassEffect()
            .foregroundColor(Color.yellow)
    }
    
    private var datePicker: some View {
            Picker("Sélectionne la nuit", selection: $selectionValue) {
                ForEach(enregistrementManager.enregistrements, id: \.id) { enregistrement in
                    let jour = enregistrement.date.formatted(.dateTime.weekday(.wide).locale(Locale(identifier: "fr_FR")))
                    let mois = enregistrement.date.formatted(.dateTime.month(.wide).locale(Locale(identifier: "fr_FR")))
                    let date = enregistrement.date.formatted(.dateTime.day())
                    Text("\(jour) \(date) \(mois)").tag(Optional(enregistrement))
                        .foregroundColor(Color.yellow)
                }
            }
            .pickerStyle(.wheel)
            .onAppear {
                selectionValue = enregistrementManager.enregistrements.first
            }
            .onChange(of: selectionValue){
                accelerometerData = manager.motionManager.flatData(id: selectionValue!.id, intensite: 10)
            }
        }
    
//    public var sleepDuration: some View {
//        if accelerometerData != nil {
//            let sleepDuration = manager.motionManager.getSleepDuration(measures: accelerometerData!)
//            Text("\(sleepDuration)")
//        }
//        else {
//            Text("idhazipf")
//        }
//    }
    
    private var recordButton: some View {
        Button(manager.textRecordButton) {
            manager.startSession()
        }
        .padding()
        .foregroundColor(Color.yellow)
        .glassEffect()
    }
    
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
