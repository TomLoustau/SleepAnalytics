import SwiftUI

struct ContentView: View {
    @StateObject var motionManager = MotionManager()
    var body: some View {
        VStack(spacing: 20){
            //Text("x : \(motionManager.x)")
            //Text("y : \(motionManager.y)")
            //Text("z : \(motionManager.z)")
            Text("amplitude \n \(motionManager.amplitude)")
                .padding()
                .background(Color.black)
                .cornerRadius(50)
                .foregroundColor(Color.orange)
            
            Button(action: { motionManager.accelerometerData() }){
                    Text("lancer l'accéleromètre")
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(10)
                    .foregroundColor(Color.white)
            }
            
            Button(action: { motionManager.stopAccelerometer() }){
                Text("stopper l'accéleromètre")
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(10)
                    .foregroundColor(Color.white)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
