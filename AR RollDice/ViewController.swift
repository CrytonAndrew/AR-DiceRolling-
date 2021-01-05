//
//  ViewController.swift
//  AR RollDice
//
//  Created by Cryton Sibanda on 2020/06/12.
//  Copyright © 2020 Cryton Sibanda. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var diceArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration  = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration)
    }
    
    //MARK: -  Dice rendering methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            //This converts a touch made in 2D space into a touch for 3D space
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            if let hitResult = results.first {
                    addDice(atLocation: hitResult)
                }
            }
    }
    
    
    func addDice(atLocation location: ARHitTestResult) {
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
          if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
                diceNode.position = SCNVector3(
                  location.worldTransform.columns.3.x,
                  location.worldTransform.columns.3.y + diceNode.boundingSphere.radius ,
                  location.worldTransform.columns.3.z)
              
              diceArray.append(diceNode)
              sceneView.scene.rootNode.addChildNode(diceNode)
              roll(dice: diceNode)
            }
    }
    
    //Inner workings of rolling the dice
    //These are rotations for the dice - X and Z axis matter and Y axis does not change the top num
    func roll(dice: SCNNode) {
          let x = Float(arc4random_uniform(4))
          let z = Float(arc4random_uniform(4))
          let randomX = Float (x + 1) * (Float.pi/2)
          let randomZ = Float(z + 1) * (Float.pi/2)
          
          //Run as an animation
          //Multiply randomX and Z by 10 makes the rotation more realistic
          dice.runAction(
              SCNAction.rotateBy(
              x: CGFloat(randomX * 10),
              y: 0,
              z: CGFloat(randomZ * 10),
              duration: 0.8))
    }
    

    
    func rollAll(){
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    //Roll dices when refresh button is pressed
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    @IBAction func removeDices(_ sender: UIBarButtonItem) {
       if !diceArray.isEmpty {
         for dice in diceArray {
            dice.removeFromParentNode()
            }
        }
    }
    
    //Roll dices when device shaken
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    //MARK: -  ARSCNViewDelegateMethods
    
    //Method for detecting a horizontal or vertical surface
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            let planeAnchor = anchor as! ARPlaneAnchor
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            
            //Radiants - 1PI = 180
            //We are rotating the plane anchor by 90 as it is vertical
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            plane.materials = [gridMaterial]
            
            planeNode.geometry = plane
            
            self.sceneView.scene.rootNode.addChildNode(node)
            
        }
        else {
            return
        }
    }
}


        //Creating the moon code
//        let sphere = SCNSphere(radius: 0.2)
//        let material = SCNMaterial()
//        material.diffuse.contents = UIImage(named: "art.scnassets/Moon_Texture.jpg")
//        sphere.materials = [material]
//        let node = SCNNode()
//        node.position = SCNVector3(x: 0, y: 0.1, z: -0.5)
//        node.geometry = sphere
//        sceneView.scene.rootNode.addChildNode(node)
