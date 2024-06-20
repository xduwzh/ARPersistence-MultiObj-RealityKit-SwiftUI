//
//  MenuUI.swift
//  myARTest
//
//  Created by Zhenghang Wu on 2024-06-20.
//

import Foundation
import SwiftUI

struct MenuUI: View {
    
    @EnvironmentObject var arStatus: ARStatus
    
    var body: some View {
        VStack{
            Text(arStatus.infoLabel)
            HStack {
                Spacer()
                Button("Place"){
                    arStatus.placedObj = true
                }
                Spacer()
                Button("Save"){
                    arStatus.savePressed = true
                }.disabled(!arStatus.saveEnabled)
                Spacer()
                Button("Load"){
                    arStatus.loadPressed = true
                }/*.disabled(!arStatus.loadEnabled)*/
                Spacer()
                Button("Reset"){
                    arStatus.resetPressed = true
                }
                Spacer()
            }
            
        }
        
    }
}
