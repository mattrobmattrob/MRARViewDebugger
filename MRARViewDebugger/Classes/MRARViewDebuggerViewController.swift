//
//  MRARViewDebuggerViewController.swift
//  ARStreamVisualizer
//
//  Created by Matt Robinson on 9/1/17.
//  Copyright © 2017 Robinson Bros. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)

        var image : UIImage?

        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()
        }

        UIGraphicsEndImageContext()

        if let image = image, let cgImage = image.cgImage {
            self.init(cgImage: cgImage)
        } else {
            self.init()
        }
    }
}

extension SCNMaterial {
    convenience init(withColor color : UIColor) {
        self.init()
        self.diffuse.contents = color
        self.locksAmbientWithDiffuse = true
    }

    convenience init(withImage image : UIImage) {
        self.init()
        self.diffuse.contents = image
        self.locksAmbientWithDiffuse = true
    }
}

class MRARPlane : SCNPlane {
    let layer : Int

    var rect : CGRect = CGRect.zero {
        didSet(oldRect) {
            self.height = rect.height
            self.width = rect.width
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(withImage image : UIImage, withLayer layer : Int) {
        self.layer = layer

        super.init()

        materials = [SCNMaterial.init(withImage: image)]
    }
}

public class MRARViewDebuggerViewController: UIViewController, ARSCNViewDelegate {

    let DefaultLayerSeparation : Float = 0.04

    @IBOutlet var sceneView: ARSCNView!

    let childViewController : UIViewController

    var boxes : [SCNNode] = []

    public init(withViewController viewController : UIViewController) {
        self.childViewController = viewController
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibNameOrNil:nibBundleOrNil:) has not been implemented")
    }

    lazy var configuration : ARWorldTrackingConfiguration = {
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        return configuration
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()

        sceneView = ARSCNView.init(frame: view.bounds)
        view.addSubview(sceneView)

        // Set the view's delegate
        sceneView.delegate = self

        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

        // Turn off all the default lights SceneKit adds since we are handling it ourselves
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true

        sceneView.overlaySKScene = SKScene(size: self.view.bounds.size)

        // Add tap gesture to view
        addGestureRecognizers(toScene: sceneView)

        self.sceneView.scene = SCNScene();
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        sceneView.frame = view.bounds
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Run the view's session
        sceneView.session.run(configuration)
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - Gestures

    func addGestureRecognizers(toScene scene: ARSCNView) {
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTapFrom(recognizer:)))
        tapGesture.numberOfTapsRequired = 1
        scene.addGestureRecognizer(tapGesture)
    }

    @objc func handleTapFrom(recognizer : UIGestureRecognizer) {
        // Take the screen space tap coordinates and pass them to the hitTest method on the ARSCNView instance
        let tapPoint = recognizer.location(in: sceneView)
        let result = sceneView.hitTest(tapPoint, types: .existingPlaneUsingExtent)

        // If the intersection ray passes through any plane geometry they will be returned, with the planes
        // ordered by distance from the camera
        guard result.count > 0 else {
            return;
        }

        // If there are multiple hits, just pick the closest plane
        if let hitResult = result.first {
            insertViewHierarchy(hitResult)

            if let gestures = sceneView.gestureRecognizers {
                gestures.forEach({ (gesture) in
                    gesture.isEnabled = false
                })
            }
        }
    }

    func insertGeometry(_ hitResult : ARHitTestResult, node : SCNNode?, level : Int) {
        if let node = node {
            let insertionYOffset = UIApplication.shared.keyWindow!.frame.height / 2.0 / 1000
            let position = hitResult.worldTransform.columns.3
            node.position = SCNVector3Make(position.x,
                                           Float(position.y) + Float(insertionYOffset),
                                           position.z + Float(level) * DefaultLayerSeparation)

            sceneView.scene.rootNode.addChildNode(node)
            boxes.append(node)
        }
    }

    // MARK: - ARSCNViewDelegate

    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // This visualization covers only detected planes.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        // Create a SceneKit plane to visualize the node using its position and extent.
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        plane.materials = [SCNMaterial.init(withColor: UIColor.magenta.withAlphaComponent(0.5))];

        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)

        // SCNPlanes are vertically oriented in their local coordinate space.
        // Rotate it to match the horizontal orientation of the ARPlaneAnchor.
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)

        // ARKit owns the node corresponding to the anchor, so make the plane a child node.
        node.addChildNode(planeNode)
    }

    // MARK: - Subview Tree Traversal

    func insertViewHierarchy(_ hitResult : ARHitTestResult) {
        let visualizedView : UIView = childViewController.view!
        let node = traverseViewTreeGenerateNode(view: visualizedView, withScale: CGPoint.init(x: 1/1000.0, y: 1/1000.0))
        insertGeometry(hitResult, node: node, level: 0)
    }

    func traverseViewTreeGenerateNode(view : UIView, withScale scale : CGPoint) -> SCNNode {
        // create root node
        let node = nodeFrom(view: view, withScale: scale, withLayer: 0)

        // create recursive child nodes
        let childNodes = generateNodesFrom(view: view, layer: 1, withScale: scale)

        // add all children nodes to the root parent node
        childNodes.forEach({ (childNode) in
            add(childNode: childNode, inParentNode: node)
        })

        return node
    }

    func add(childNode : SCNNode, inParentNode parentNode : SCNNode) {
        parentNode.addChildNode(childNode)

        if let parentPlane = parentNode.geometry as? MRARPlane {
            // place child node in parent node (https://koenig-media.raywenderlich.com/uploads/2016/03/CoordinateSystem-602x500.png)
            //   handle translation from `UIView` coordinate system to SceneKit coordinate system
            if let plane = childNode.geometry as? MRARPlane {
                let planeRect = plane.rect
                let xPosition : Float = Float(planeRect.origin.x + planeRect.width/2 - parentPlane.width/2)
                let yPosition : Float = Float(parentPlane.height/2 - planeRect.height/2 - planeRect.origin.y)

                childNode.position = SCNVector3Make(xPosition, yPosition, Float(plane.layer - parentPlane.layer) * DefaultLayerSeparation)
            }
        }
    }

    func generateNodesFrom(view : UIView, layer : Int, withScale scale : CGPoint) -> [SCNNode] {
        var nodes : [SCNNode] = []

        for view in view.subviews {
            // create node for current subview
            let node = nodeFrom(view: view, withScale: scale, withLayer: layer)
            nodes.append(node)

            // place all children another level deep
            let childLayer = layer + 1

            // continue traversal down subview tree
            let childNodes = generateNodesFrom(view: view, layer: childLayer, withScale: scale)

            // add all children nodes to parent node
            childNodes.forEach({ (childNode) in
                add(childNode: childNode, inParentNode: node)
            })
        }

        return nodes
    }

    func nodeFrom(view : UIView, withScale scale : CGPoint, withLayer layer : Int) -> SCNNode {
        let viewFrame = view.frame
        let newViewRect = CGRect(x: viewFrame.origin.x * scale.x,
                                 y: viewFrame.origin.y * scale.y,
                                 width: viewFrame.width * scale.x,
                                 height: viewFrame.height * scale.y)

        var node : SCNNode?

        // special handling for `UIImageView` classes
        if let viewAsImageView = view as? UIImageView, let image = viewAsImageView.image {
            let viewShape = MRARPlane(withImage: image, withLayer: layer)
            viewShape.rect = newViewRect

            node = SCNNode.init(geometry: viewShape)
        } else {
            // create copy of view and then remove the subviews to avoid imaging the subviews (https://stackoverflow.com/a/13756101/856336)
            let viewCopy = NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: view))

            if let viewToImagine = viewCopy as? UIView {
                viewToImagine.subviews.forEach { view in
                    view.isHidden = true
                }

                let viewImage = UIImage.init(view: viewToImagine)

                let viewShape = MRARPlane(withImage: viewImage, withLayer: layer)
                viewShape.rect = newViewRect

                return SCNNode.init(geometry: viewShape)
            }
        }

        return node ?? SCNNode()
    }
}
