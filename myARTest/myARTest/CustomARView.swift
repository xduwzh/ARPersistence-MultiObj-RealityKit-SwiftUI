//
//  CustomARView.swift
//  myARTest
//
//  Created by Zhenghang Wu on 2024-06-20.
//

import Foundation
import RealityKit
import ARKit
import SwiftUI

class CustomARView: ARView{
    
    var arStatus: ARStatus

    var worldMapURL: URL = {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("worldMapURL")
        } catch {
            fatalError("Error getting world map URL from document directory.")
        }
    }()
    
    var defaultConfiguration: ARWorldTrackingConfiguration {
        let config = ARWorldTrackingConfiguration()
        config.sceneReconstruction = .mesh
        config.planeDetection = [.vertical, .horizontal]
        return config
    }

    
    init(frame: CGRect = .zero, arStatus: ARStatus) {
        self.arStatus = arStatus
        super.init(frame: frame)
    }
    
    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc required dynamic init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    func resetTrackingConfiguration() {
        let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
        //self.debugOptions = [.showFeaturePoints]
        self.session.run(defaultConfiguration, options: options)
        setUpLabelsAndButtons(text: "Move the camera around to detect surfaces", canShowSaveButton: false)
    }
    
    // MARK: - Raycast to set obj on plane
    func placeCamera() {
        guard let (camPos, camDir) = self.getCamVector() else {
            return
        }
        let rcQuery = ARRaycastQuery(
            origin: camPos, direction: camDir,
            allowing: .estimatedPlane, alignment: .any
        )
        let result = self.session.raycast(rcQuery)
        if let hit = result.first {
            //let camera = CAMERAS.first(where: { $0.id == cameraModelId })
            let virtualObjectAnchor = ARAnchor(
                name:"Camera",
                transform: hit.worldTransform
            )
            self.session.add(anchor: virtualObjectAnchor)
            
            // You have to add modelEntity through the session (didAdd anchors) func,
            // otherwise your model won't show up after you restart the app
            // unless you press the load button twice
//            let modelEntity = createSphere(radius: 0.2)
//            // Add modelEntity and anchorEntity into the scene for rendering
//            let anchorEntity = AnchorEntity(anchor: virtualObjectAnchor)
//            anchorEntity.addChild(modelEntity)
//            self.scene.addAnchor(anchorEntity)
        }
    }
    
    //Get the position and direction of the iPad's camera
    func getCamVector() -> (position: SIMD3<Float>, direciton: SIMD3<Float>)? {
        let camTransform = self.cameraTransform
        let camDirection = camTransform.matrix.columns.2
        return (camTransform.translation, -[camDirection.x, camDirection.y, camDirection.z])
    }
    
    func createSphere(radius: Float) -> ModelEntity {
        let sphere = MeshResource.generateSphere(radius: radius)
        let material = SimpleMaterial(color: .red, roughness: 0.5, isMetallic: true)

        let sphereEntity = ModelEntity(mesh: sphere, materials: [material])
        sphereEntity.generateCollisionShapes(recursive: true)

        return sphereEntity
    }
    
    // MARK: - AR Persistence
    func loadMap() {
        guard let mapData = try? Data(contentsOf: self.worldMapURL), let worldMap = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: mapData) else {
            fatalError("No ARWorldMap in archive.")
        }
        
        let configuration = defaultConfiguration
        
        let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
        configuration.initialWorldMap = worldMap
        print("Map loaded")
        
//        self.debugOptions = [.showFeaturePoints]
        self.session.run(configuration, options: options)
//        self.scene.anchors.removeAll()
        
        // ARWolrdMap contains only the ARAnchor data,
        // to restore the models, we need to turn it into AnchorEntity
        // and attach a ModelEntity to it
//        for anchor in self.session.currentFrame!.anchors{
//            if anchor.name == "Camera"{
//                let modelEntity = createSphere(radius: 0.2)
//                print("DEBUG: adding model to scene - ")
//
//                // Add modelEntity and anchorEntity into the scene for rendering
//                let anchorEntity = AnchorEntity(anchor: anchor)
//                anchorEntity.addChild(modelEntity)
//                self.scene.addAnchor(anchorEntity)
//            }
//        }
    }
    
    func saveMap() {
        self.session.getCurrentWorldMap { (worldMap, error) in
            guard let worldMap = worldMap else {
                self.setUpLabelsAndButtons(text: "Can't get current world map", canShowSaveButton: false)
                print(error!.localizedDescription)
                return
            }
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
                try data.write(to: self.worldMapURL, options: [.atomic])
                print("Map saved")
            } catch {
                fatalError("Can't save map: \(error.localizedDescription)")
            }
        }
    }
    
    func setUpLabelsAndButtons(text: String, canShowSaveButton: Bool) {
        arStatus.infoLabel = text
        arStatus.saveEnabled = canShowSaveButton
    }
    
}



extension CustomARView: ARSessionDelegate {
    
    /// - Tag: CheckMappingStatus
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        switch frame.worldMappingStatus {
        case .notAvailable:
            setUpLabelsAndButtons(text: "Map Status: Not available", canShowSaveButton: false)
        case .limited:
            setUpLabelsAndButtons(text: "Map Status: Available but has Limited features", canShowSaveButton: false)
        case .extending:
            setUpLabelsAndButtons(text: "Map Status: Actively extending the map", canShowSaveButton: false)
        case .mapped:
            setUpLabelsAndButtons(text: "Map Status: Mapped the visible Area", canShowSaveButton: true)
        }
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        let modelEntity = createSphere(radius: 0.2)
        for anchor in anchors {
            addAnchorEntityToScene(anchor: anchor)
        }
    }
    
    func addAnchorEntityToScene(anchor: ARAnchor) {
        guard anchor.name == "Camera" else {
            return
        }

        let modelEntity = createSphere(radius: 0.2)
        // Add modelEntity and anchorEntity into the scene for rendering
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(modelEntity)
        self.scene.addAnchor(anchorEntity)
    }
    
    
}


