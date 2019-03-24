
import SpriteKit

/// The main view
public class MainScene: SKScene {
    
    /// The default background color, should never appear on the screen
    let defaultBackgroundColor = SKColor(red: 0.0, green: 0.4, blue: 0.15, alpha: 1.0)
    
    var streetMap = StreetMap(width: 1, height: 1)
    var startPositions: [StreetNode] = []
    var cars: [SmartCarSprite] = []
    
    /// Called when scene moved to view
    override public func didMove(to view: SKView) {
        super.didMove(to: view)
        
        self.backgroundColor = defaultBackgroundColor
        
        self.streetMap = StreetMap(width: 10, height: 10)
        
        self.startPositions = self.streetMap.getStartNodes()
        
        for i in self.streetMap.sprites {
            for s in i {
                self.addChild(s.sprite)
            }
        }
    }
    
    
    public func addCar() {
        var path: Path? = nil
        var from: StreetNode?, to: StreetNode?
        
        while path == nil {
            from = self.startPositions.randomElement()
            to = self.startPositions.randomElement()
        if from != nil && to != nil && from != to {
            path = self.streetMap.shortestPath(
                from: self.streetMap.graph.getNode(x: from!.x, y: from!.y),
                to: self.streetMap.graph.getNode(x: to!.x, y: to!.y))
            }
        }
        
        let newCar = SmartCarSprite(path: path!, end: to!)
        self.cars.append(newCar)
        self.addChild(newCar.sprite)
        newCar.startMoving()
    }
}
