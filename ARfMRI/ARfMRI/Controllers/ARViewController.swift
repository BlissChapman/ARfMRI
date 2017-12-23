//
//  ViewController.swift
//  ARfMRI
//
//  Created by Bliss Chapman on 12/22/17.
//  Copyright © 2017 Bliss Chapman. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

final class ViewController: UIViewController {

    // UI
    @IBOutlet private var sceneView: ARSCNView!

    // Geometry
    var geometryNode: SCNNode = SCNNode()

    // Gestures
    var currentAngle: Float = 0.0


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

        // Setup scene.
        setupScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    private func setupScene() {
        let scene = SCNScene()

        // Load fMRI data.
        guard let fMRIImages = loadfMRIImages(fromPath: "output-slice") else {
            print("Could not retrieve fMRIImages.")
            return
        }

        // Add each image as a slice.
        for (i, image) in fMRIImages.enumerated() {
            let planeGeometry = SCNPlane(width: 0.2, height: 0.2)
            planeGeometry.firstMaterial?.diffuse.contents = image

            let planeNode = SCNNode(geometry: planeGeometry)
            planeNode.position.z = -1.0 + Float(i) * 0.01
            scene.rootNode.addChildNode(planeNode)
        }

        // Add gesture recognizer
//        let panRecognizer = UIPanGestureRecognizer(target: self, action: Selector(("panGesture:")))
//        sceneView.addGestureRecognizer(panRecognizer)

        sceneView.scene = scene
    }

    private func loadfMRIImages(fromPath path: String) -> [UIImage]? {
        var images = [UIImage]()
        for i in 1...45 {
            let imageFileName = String(format: "\(path)%03d.jpg", i)
            guard let image = UIImage(named: imageFileName) else {
                return nil
            }
            guard var rgbaImage = RGBAImage(image: image) else {
                return nil
            }
            FMRIUtils.processImageForVolumeRendering(&rgbaImage)
            guard let processedImage = rgbaImage.toUIImage() else {
                return nil
            }
            images.append(processedImage)
        }
        return images
    }
//
//    func panGesture(sender: UIPanGestureRecognizer) {
//        let translation = sender.translation(in: sender.view!)
//        var newAngle = (Float)(translation.x)*Float.pi/180.0
//        newAngle += currentAngle
//
//        geometryNode.transform = SCNMatrix4MakeRotation(newAngle, 0, 1, 0)
//
//        if sender.state == .ended {
//            currentAngle = newAngle
//        }
//    }
}


extension ViewController: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        // Create a SceneKit plane to visualize the plane anchor using its position and extent.
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode(geometry: plane)
        planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)

        /*
         `SCNPlane` is vertically oriented in its local coordinate space, so
         rotate the plane to match the horizontal orientation of `ARPlaneAnchor`.
         */
        planeNode.eulerAngles.x = -.pi / 2

        // Make the plane visualization semitransparent to clearly show real-world placement.
        planeNode.opacity = 0.25

        /*
         Add the plane visualization to the ARKit-managed node so that it tracks
         changes in the plane anchor as plane estimation continues.
         */
        node.addChildNode(planeNode)
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        print(error.localizedDescription)
    }

    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        print("session was interrupted")
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        print("session interruption ended")
    }
}
