import SwiftUI
import Foundation
import Charts

struct ContentView: View {
    @State private var versMouvement = false
    @State private var versDecibel = false
    @StateObject var manager: ManagerManager = ManagerManager()
    @StateObject var enregistrementManager = EnregistrementManager()
    @State var selectionValue: EnregistrementModel?
    
    @State var accelerometerData: [MotionModel]?
    @State var noiseData: [NoiseModel]?
    @State var sleepBegin: Date?
    var body: some View {
        NavigationStack{
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.05)
                .ignoresSafeArea() // Pour remplir tout l'écran
                    
                VStack(spacing: 20){
                    if !enregistrementManager.enregistrements.isEmpty {
                        graphicButtons
                        datePicker
                    }
                    
//                    Text("amplitude \n \(manager.getAmplitude())\n \(String(describing: manager.getNoise())) db")
//                        .padding()
//                        .background(Color.gray)
//                        .cornerRadius(30)
//                        .foregroundColor(Color.white)
//                        .glassEffect(in: .rect(cornerRadius: 30))
                    
                    recordButton
                }
                
            }
        }
    }
        
    private var graphicButtons: some View {
        HStack {
            Button(action: { accelerometerData = manager.motionManager.flatData(id: selectionValue!.id, intensite: 10)
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
        .navigationTitle("Graphiques")
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.05), lineWidth: 2)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.gray.opacity(0.1)))
                .frame(width: 360, height: 180)
        )
        
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
    
    private func backgroundCard(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 20)
            .stroke(Color.gray.opacity(0.1), lineWidth: 2)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.gray.opacity(0.1)))
            .frame(width: width, height: 170)
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
