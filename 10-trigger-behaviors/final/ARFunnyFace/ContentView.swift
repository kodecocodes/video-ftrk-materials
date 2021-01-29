/// Copyright (c) 2021 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import ARKit
import SwiftUI
import RealityKit

var arView: ARView!

struct ContentView : View {
  @State var currentProp: Prop = .robot
  
  var body: some View {
    ZStack(alignment: .bottom) {
      ARViewContainer(currentProp: $currentProp).edgesIgnoringSafeArea(.all)
      PropChooser(currentProp: $currentProp)
    }
  }
}

struct ARViewContainer: UIViewRepresentable {
  @Binding var currentProp: Prop
  
  func makeUIView(context: Context) -> ARView {
    arView = ARView(frame: .zero)
    arView.session.delegate = context.coordinator
    return arView
  }
  
  func updateUIView(_ uiView: ARView, context: Context) {
    uiView.scene.anchors.removeAll()
    
    let arConfiguration = ARFaceTrackingConfiguration()
    uiView.session.run(arConfiguration, options: [.resetTracking, .removeExistingAnchors])
    
    var anchor: RealityKit.HasAnchoring
    switch currentProp {
    case .fancyHat:
      anchor = try! Experience.loadFancyHat()
    case .glasses:
      anchor = try! Experience.loadGlasses()
    case .mustache:
      anchor = try! Experience.loadMustache()
    case .eyeball:
      anchor = try! Experience.loadEyeball()
    case .robot:
      anchor = try! Experience.loadRobot()
    }
    uiView.scene.addAnchor(anchor)
  }
  
  func makeCoordinator() -> ARDelegateHandler {
    ARDelegateHandler(self)
  }
  
  class ARDelegateHandler: NSObject, ARSessionDelegate {
    
    var arViewContainer: ARViewContainer
    var doneSparking = true
    
    init(_ control: ARViewContainer) {
      arViewContainer = control
      super.init()
    }
    
    func eyeballLook(at point: simd_float3) {
      guard let eyeball = arView.scene.findEntity(named: "Eyeball")
      else { return }
      
      eyeball.look(at: point, from: eyeball.position, upVector: SIMD3<Float>(0, 1, -1), relativeTo: eyeball.parent)
    }
    
    func deg2Rad(_ value: Float) -> Float {
      return value * .pi / 180
    }
    
    func makeRedLight() -> PointLight {
      let redLight = PointLight()
      redLight.light.color = .red
      redLight.light.intensity = 100_000
      return redLight
    }
    
    func animateRobot(faceAnchor: ARFaceAnchor) {
      guard let robot = arView.scene.anchors.first(where: { $0 is Experience.Robot }) as? Experience.Robot
      else { return }
      
      let blendShapes = faceAnchor.blendShapes
      guard
        let jawOpen = blendShapes[.jawOpen]?.floatValue,
        let eyeBlinkLeft = blendShapes[.eyeBlinkLeft]?.floatValue,
        let eyeBlinkRight = blendShapes[.eyeBlinkRight]?.floatValue,
        let browInnerUp = blendShapes[.browInnerUp]?.floatValue,
        let browLeft = blendShapes[.browDownLeft]?.floatValue,
        let browRight = blendShapes[.browDownRight]?.floatValue
      else { return }
      
      if doneSparking && jawOpen > 0.7 && browInnerUp < 0.5 {
        doneSparking = false
        
        let lightL = makeRedLight()
        let lightR = makeRedLight()
        robot.eyeL?.addChild(lightL)
        robot.eyeR?.addChild(lightR)
        
        robot.notifications.spark.post()
        
        robot.actions.sparkingEnded.onAction = { _ in
          lightL.removeFromParent()
          lightR.removeFromParent()
          self.doneSparking = true
        }
      }
      
      robot.eyeLidL?.orientation = simd_mul(
        simd_quatf(
          angle: deg2Rad( -120 + (90 * eyeBlinkLeft) ),
          axis: [1, 0, 0]),
        simd_quatf(
          angle: deg2Rad( (90 * browLeft) - (30 * browInnerUp) ),
          axis: [0, 0, 1])
      )
      
      robot.eyeLidR?.orientation = simd_mul(
        simd_quatf(
          angle: deg2Rad( -120 + (90 * eyeBlinkRight) ),
          axis: [1, 0, 0]),
        simd_quatf(
          angle: deg2Rad( (-90 * browRight) - (-30 * browInnerUp) ),
          axis: [0, 0, 1])
      )
      
      robot.jaw?.orientation = simd_quatf(
        angle: deg2Rad( -100 + (60 * jawOpen) ),
        axis: [1, 0, 0]
      )
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
      guard let faceAnchor = anchors.first(where: { $0 is ARFaceAnchor }) as? ARFaceAnchor else { return }
      eyeballLook(at: faceAnchor.lookAtPoint)
      
      animateRobot(faceAnchor: faceAnchor)
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
