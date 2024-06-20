//
//  ARStatus.swift
//  myARTest
//
//  Created by Zhenghang Wu on 2024-06-20.
//

import Foundation

class ARStatus: ObservableObject {
    @Published var placedObj = false
    @Published var saveEnabled = false
    @Published var loadEnabled = false
    @Published var infoLabel: String = "Default text"
    @Published var savePressed = false
    @Published var loadPressed = false
    @Published var resetPressed = false
}
