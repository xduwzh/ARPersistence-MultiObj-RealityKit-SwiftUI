//
//  ContentView.swift
//  ARPersistence-Realitykit
//
//  Created by hgp on 1/15/21.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    @StateObject private var arStatus = ARStatus()

    var body: some View {
        VStack {
            ARViewContainer()
                .environmentObject(arStatus)
                .edgesIgnoringSafeArea(.all)
            MenuUI()
                .environmentObject(arStatus)
           
        }
    }
}

struct ARViewContainer: UIViewRepresentable {

    @EnvironmentObject var arStatus: ARStatus

    func makeUIView(context: Context) -> CustomARView {
        
        let arView = CustomARView(arStatus: arStatus)
        // Pass in @EnvironmentObject
        
        // Read in any already saved map to see if we can load one.

        arView.session.run(arView.defaultConfiguration)
        arView.session.delegate = arView
        //if arView.worldMapURL
        // Prevent the screen from being dimmed after a while as users will likely
        // have long periods of interaction without touching the screen or buttons.
//        UIApplication.shared.isIdleTimerDisabled = true
        
        return arView
    }
    
    func updateUIView(_ uiView: CustomARView, context: Context) {
        if arStatus.placedObj{
            arStatus.placedObj = false
            uiView.placeCamera()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                
//            }
        }
        
        if arStatus.savePressed{
            arStatus.savePressed = false
            uiView.saveMap()
        }
        
        if arStatus.loadPressed{
            arStatus.loadPressed = false
            uiView.loadMap()
        }
        
        if arStatus.resetPressed{
            arStatus.resetPressed = false
            uiView.resetTrackingConfiguration()
        }
    }

}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
