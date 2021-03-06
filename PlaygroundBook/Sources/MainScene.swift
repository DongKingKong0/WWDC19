
import SpriteKit

public enum SpawnCar {
    case never, sixteenFrames, oncePerSecond, twoSeconds, onLeave
}

/// The main view
public class MainScene: SKScene {
    
    /// The default background color, should never appear on the screen
    let defaultBackgroundColor = SKColor(red: 0.0, green: 0.4, blue: 0.15, alpha: 1.0)
    
    var streetMap = StreetMap(width: 1, height: 1)
    var startPositions: [StreetNode] = []
    var cars: [SmartCarSprite] = []
    
    var frameCount = 0
    
    public var spawnCars: SpawnCar = .never
    public var carType: CarType = .small
    
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
    
    
    override public func update(_ currentTime: TimeInterval) {
        frameCount += 1
        
        for car in self.cars {
            if car.arrived {
                if self.spawnCars == .onLeave {
                    self.addCar()
                }
                if let index = self.cars.index(of: car) {
                    self.cars.remove(at: index)
                    car.sprite.removeFromParent()
                }
                continue
            }
            
            car.setTimer(currentTime)
            
            var driving = true
            
            for c in self.cars where c != car {
                if car.sprite.intersects(c.sprite) && car.timer < c.timer {
                    driving = false
                }
            }
            
            car.driving = driving
        }
        
        switch self.spawnCars {
        case .sixteenFrames:
            if frameCount % 16 == 0 {
                addCar()
            }
        case .oncePerSecond:
            if frameCount % 60 == 0 {
                addCar()
            }
        case .twoSeconds:
            if frameCount % 120 == 0 {
                addCar()
            }
        default:
            break
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
        
        let newCar = SmartCarSprite(path: path!, end: to!, type: self.carType)
        self.cars.append(newCar)
        self.addChild(newCar.sprite)
        newCar.startMoving()
    }
}
