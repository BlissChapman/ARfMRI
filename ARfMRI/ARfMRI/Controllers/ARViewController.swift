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

    @IBOutlet private var sceneView: SCNView!

    private let voxelSize: CGFloat = 1.0

    private var fmriVoxels: [[[Pixel]]] = [] {
        didSet {
            let scene = SCNScene()

            for z in 0..<fmriVoxels.count {
                for y in 0..<(fmriVoxels.first?.count ?? 0) {
                    for x in 0..<(fmriVoxels.first?.first?.count ?? 0) {
                        let voxel = fmriVoxels[z][y][x]
                        if voxel.alpha == 0 {
                            // skip entirely transparent voxels
                            continue
                        }

                        let voxelTexture = SCNMaterial()
                        voxelTexture.diffuse.contents = voxel.toUIColor()

                        let voxelGeometry = SCNBox(width: voxelSize, height: voxelSize, length: voxelSize, chamferRadius: voxelSize/10)
                        voxelGeometry.widthSegmentCount = 1
                        voxelGeometry.heightSegmentCount = 1
                        voxelGeometry.lengthSegmentCount = 1
                        voxelGeometry.firstMaterial = voxelTexture

                        let voxelNode = SCNNode(geometry: voxelGeometry)
                        voxelNode.position.x = Float(x)*Float(voxelSize)
                        voxelNode.position.y = Float(y)*Float(voxelSize)
                        voxelNode.position.z = Float(z)*Float(voxelSize)

                        scene.rootNode.addChildNode(voxelNode)
                    }
                }
            }

            sceneView.scene = scene
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSceneView()

        // Load data
        guard let fmriSlices = loadFMRISlices(fromPath: "math_vs_baseline") else {
            print("Could not retrieve fMRIImages.")
            return
        }

        // Process data for volume rendering
        fmriVoxels = FMRIUtils.processSlicesForVolumeRendering(fmriSlices)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
//        let configuration = ARWorldTrackingConfiguration()
//        configuration.planeDetection = .horizontal

        // Run the view's session
//        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
//        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    private func setupSceneView() {
        // Set the view's delegate
//        sceneView.delegate = self
        sceneView.allowsCameraControl = true

        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

        sceneView.backgroundColor = .white
        sceneView.autoenablesDefaultLighting = true
    }

    private func loadFMRISlices(fromPath path: String) -> [RGBAImage]? {
        var images = [RGBAImage]()
        for i in 0...45 {
            let imageFileName = String(format: "\(path)%03d.jpg", i)
            guard let image = UIImage(named: imageFileName) else {
                return nil
            }
            guard let rgbaImage = RGBAImage(image: image) else {
                return nil
            }
            images.append(rgbaImage)
        }
        return images
    }
}

/*
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
*/
