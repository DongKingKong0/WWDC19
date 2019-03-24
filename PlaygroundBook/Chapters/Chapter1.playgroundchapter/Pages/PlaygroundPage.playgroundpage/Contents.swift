/*:
 # WWDC19 Traffic Simulator
 This is a playground intended to simulate how traffic would work in a similar street map in real life.
 
 All streets are randomly generated. Each cycle is unique.
 
 Every car gets a start and destination point randomly assigned and traveles there, while trying to avoid crashing into other cars (the first car to be at a crossroad will proceed first).
 
 ## Options for car spawning
 * `.never`: Don't spawn new cars
 * `.oncePerSecond`: Spawn one car per second
 * `.onLeave`: Spawn one new car for each car that leaves the screen
 * `.sixteenFrames`: Spawn one car every 16 frames
 * `.twoSeconds`: Spawn one car every two seconds
 */
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

mainScene.spawnCars = /*#-editable-code*/.never/*#-end-editable-code*/

mainScene.carType = /*#-editable-code*/.small/*#-end-editable-code*/

// enter start car count
for _ in 0 ... /*#-editable-code*/<#T##number of cars##Int#>/*#-end-editable-code*/ {
    mainScene.addCar()
}

/*:
 ## Possible textures:
 ![empty](street_preview/street0.png)
 ![dead end](street_preview/street1.png)
 ![curve](street_preview/street2.png)
 ![straight](street_preview/street3.png)
 ![branch thing](street_preview/street4.png)
 ![crossroad](street_preview/street5.png)
 
 Source Code on [GitHub](https://github.com/DongKingKong0/WWDC19)
 */
