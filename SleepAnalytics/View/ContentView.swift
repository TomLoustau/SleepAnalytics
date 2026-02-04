import SwiftUI
import Foundation

struct ContentView: View {
    @StateObject var manager: ManagerManager = ManagerManager()
    var body: some View {
        NavigationStack{
            ZStack {
                        // Définir la couleur d'arrière-plan
                        Color.gray // Couleur unie
                            .ignoresSafeArea() // Étend la couleur sur toute la vue (même sous la barre de statut)
                    
                VStack(spacing: 20){
                    Text("amplitude \n \(manager.getAmplitude())\n \(String(describing: manager.getNoise())) db")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(50)
                        .foregroundColor(Color.orange)
                    
                    
                    Button(action: { manager.startSession() }){
                        Text(manager.textRecordButton)
                            .padding()
                            .background(manager.colorButton)
                            .cornerRadius(10)
                            .foregroundColor(Color.white)
                    }
                
                }
            }
        }
    }
        
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
