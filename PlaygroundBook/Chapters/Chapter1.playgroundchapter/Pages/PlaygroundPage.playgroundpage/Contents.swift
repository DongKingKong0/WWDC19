//#-hidden-code
import SpriteKit
import PlaygroundSupport

//#-end-hidden-code
let showDebug = /*#-editable-code*/true/*#-end-editable-code*/
//#-hidden-code

let spriteView = SKView()
spriteView.showsDrawCount = showDebug
spriteView.showsNodeCount = showDebug
spriteView.showsFPS = showDebug

let mainScene = MainScene()
mainScene.scaleMode = .aspectFit
spriteView.presentScene(mainScene)

let page = PlaygroundPage.current
page.liveView = spriteView
//#-end-hidden-code

//#-editable-code
mainScene.addCar()
mainScene.addCar()
mainScene.addCar()
mainScene.addCar()
mainScene.addCar()
//#-end-editable-code
