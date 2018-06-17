//
//  ViewController.swift
//  AR Ruler
//
//  Created by verebes on 15/05/2018.
//  Copyright © 2018 A&D Progress. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodesArray = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    //MARK: - Detecting touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = hitTestResults.first {
                addDot(at: hitResult)
            }
        }
    }
    
    func addDot(at hitResult: ARHitTestResult) {
        let dotGeometry = SCNSphere(radius: 0.005)
        
        let dotMaterial = SCNMaterial()
        dotMaterial.diffuse.contents = UIColor.red
        
        dotGeometry.materials = [dotMaterial]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        dotNode.position = SCNVector3(
            x: hitResult.worldTransform.columns.3.x,
            y: hitResult.worldTransform.columns.3.y,
            z: hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodesArray.append(dotNode)
        
        if dotNodesArray.count == 2 {
            calculate()
        } else if dotNodesArray.count > 2{
            removeDotsAndText()
        }
    }
    
    func calculate(){
        let start = dotNodesArray[0]
        let end = dotNodesArray[1]
        
        print(start.position)
        print(end.position)
        
        //Measure distance betweeen 2 points in 3d space from pythagoras
        // distance = √((a)^2 + (b)^2 + (c)^2
        // distance = √((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2
        
        let a = end.position.x - start.position.x
        let b = end.position.y - start.position.y
        let c = end.position.z - start.position.z
        
        let distance = sqrt(pow(a, 2) + pow(b, 2) + pow(c, 2))
        
        print(abs(distance))
        updateText(text: "\(abs(distance))", atPosition: end.position)
    }
    
    func updateText(text: String, atPosition position: SCNVector3){
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        
        textGeometry.materials.first?.diffuse.contents = UIColor.red
        
        textNode = SCNNode(geometry: textGeometry)
        
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        
        textNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    func removeDotsAndText(){
        if !dotNodesArray.isEmpty {
            for dotNode in dotNodesArray {
                dotNode.removeFromParentNode()
            }
            dotNodesArray.removeAll()
            textNode.removeFromParentNode()
        }
    }

    // MARK: - ARSCNViewDelegate
    
}
