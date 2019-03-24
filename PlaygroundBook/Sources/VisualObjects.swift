
import SpriteKit

public enum CarType {
    case normal, small
}


public enum Direction: Int {
    case north, east, south, west
}

enum RelativeDirection {
    case forward, right, left
}

struct CarPosition {
    let x: Double, y: Double
    let rotation: Double
}


public class SpriteEntity: NSObject {
    public var position: CGPoint {
        didSet {
            self.sprite.position = self.position
        }
    }
    public var rotation: Double {
        didSet {
            let action = SKAction.rotate(toAngle: CGFloat(self.rotation), duration: 0)
            self.sprite.run(action)
        }
    }
    let size: CGSize
    let texture: SKTexture
    public var sprite: SKSpriteNode
    
    public init(size: CGSize, textureNamed texture: String) {
        self.texture = SKTexture(imageNamed: texture)
        self.size = size
        
        self.sprite = SKSpriteNode(texture: self.texture, size: self.size)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.position = CGPoint(x: 0.5, y: 0.5)
        self.rotation = 0
    }
}


public class StreetSprite: SpriteEntity {
    public let startSprite: Direction?
    public init(type: StreetType, startSprite s: Direction?) {
        let texture = getStreetTexture(from: type)
        self.startSprite = s
        super.init(size: CGSize(width: 0.1, height: 0.1), textureNamed: texture)
    }
}


public class CarSprite: SpriteEntity {
    public init(type: CarType) {
        let texture = getCarTexture(from: type)
        super.init(size: CGSize(width: 0.0234375, height: 0.0375), textureNamed: texture)
    }
}

public class SmartCarSprite: CarSprite {
    let speed: Double
    let path: Path
    let endNode: StreetNode
    var arrived: Bool
    var direction: Direction
    var turning: Bool
    
    public var driving: Bool {
        didSet {
            self.sprite.isPaused = !self.driving
        }
    }
    
    public init(path: Path, end: StreetNode) {
        self.speed = 1
        self.path = path
        self.endNode = end
        self.arrived = false
        self.direction = .north
        self.driving = true
        self.turning = false
        super.init(type: .small)
        
        //self.sprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.sprite.size.width * 0.1, height: self.sprite.size.height), center: CGPoint(x: 0, y: 1))
    }
    
    
    /*public func checkForObstacles() {
        
    }*/
    
    
    public func startMoving() {
        if let previousPath = self.path.previousPath {
            self.direction = getDirection(
                from: CGPoint(x: self.path.node.x, y: self.path.node.y),
                to: CGPoint(x: previousPath.node.x, y: previousPath.node.y))
            let carPosition = getCarPosition(from: self.direction)
            self.position = CGPoint(
                x: (Double(self.path.node.x) + carPosition.x) * 0.1,
                y: (Double(self.path.node.y) + carPosition.y) * 0.1)
            
            self.move(from: self.path, to: previousPath)
        } else {
            arrived = true
        }
    }
    
    private func move(from: Path, to destination: Path) {
        let newDirection = getDirection(
            from: CGPoint(x: from.node.x, y: from.node.y),
            to: CGPoint(x: destination.node.x, y: destination.node.y))
        let carPosition = getCarPosition(from: self.direction)
        
        let relativeDirection = self.getRelativeDirection(from: self.direction, to: newDirection)
        
        if relativeDirection == .forward {
            turning = false
        } else {
            turning = true
        }
        
        self.direction = newDirection
        self.rotation = carPosition.rotation
        self.position = CGPoint(
            x: (Double(from.node.x) + carPosition.x) * 0.1,
            y: (Double(from.node.y) + carPosition.y) * 0.1)
        
        let action = self.getMoveAction(in: relativeDirection)
        
        self.sprite.run(action, completion: {() -> Void in
            if (destination.previousPath != nil) {
                self.move(from: destination, to: destination.previousPath!)
            } else {
                self.arrived = true
            }
        })
    }
    
    
    private func getRelativeDirection(from direction: Direction, to nextDirection: Direction) -> RelativeDirection {
        if nextDirection.rawValue == direction.rawValue {
            return .forward
        } else if nextDirection.rawValue == direction.rawValue + 1 || (nextDirection == .north && direction == .west) {
            return .right
        } else {
            return .left
        }
    }
    
    
    private func getMoveAction(in direction: RelativeDirection) -> SKAction {
        let action: SKAction
        switch direction {
        case .forward:
            let amount = 0.1
            let vector: CGVector
            switch self.direction {
            case .north:
                vector = CGVector(dx: 0, dy: amount)
            case .east:
                vector = CGVector(dx: amount, dy: 0)
            case .south:
                vector = CGVector(dx: 0, dy: -amount)
            case .west:
                vector = CGVector(dx: -amount, dy: 0)
            }
            
            action = SKAction.move(by: vector, duration: self.speed)
            
        case .right:
            let flipped = self.direction == .north || self.direction == .south
            let path = getCurve(at: CGPoint(x: 0, y: 0), rotation: CGFloat(-self.rotation) + CGFloat.pi / 2, radius: 0.03, steps: 16, clockwise: true, flipped: flipped)
            
            action = SKAction.follow(path, asOffset: true, orientToPath: true, duration: Double.pi / 2 * 0.3 * self.speed)
            
        case .left:
            let flipped = self.direction == .east || self.direction == .west
            let path = getCurve(at: CGPoint(x: 0, y: 0), rotation: CGFloat(-self.rotation) - CGFloat.pi / 2, radius: 0.067, steps: 16, clockwise: false, flipped: flipped)
            
            action = SKAction.follow(path, asOffset: true, orientToPath: true, duration: Double.pi / 2 * 0.7 * self.speed)
        }
        return action
    }
    
    private func getCurve(at position: CGPoint, rotation: CGFloat, radius: CGFloat, steps: Int, clockwise: Bool, flipped: Bool) -> CGPath {
        let path = UIBezierPath()
        path.move(to: position)
        
        var x = position.x
        var y = position.y
        var rot = rotation
        
        if flipped {
            rot += CGFloat.pi
        }
        
        for _ in 0 ... steps {
            let factor = CGFloat.pi * radius / 2 / CGFloat(steps)
            x += cos(rot) * factor
            y += sin(rot) * factor
            
            if clockwise {
                rot -= CGFloat.pi / 2 / CGFloat(steps)
            } else {
                rot += CGFloat.pi / 2 / CGFloat(steps)
            }
            
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return path.cgPath
    }
}


func getStreetTexture(from type: StreetType) -> String {
    switch type {
    case .empty:
        return "street/street0.png"
    case .deadEnd:
        return "street/street1.png"
    case .curve:
        return "street/street2.png"
    case .straight:
        return "street/street3.png"
    case .branch:
        return "street/street4.png"
    case .crossroad:
        return "street/street5.png"
    }
}

func getCarTexture(from type: CarType) -> String {
    switch type {
    case .normal:
        return "car/car0.png"
    case .small:
        return "car/car1.png"
    }
}


func getDirection(from start: CGPoint, to end: CGPoint) -> Direction {
    if start.y < end.y {
        return .north
    } else if start.x < end.x {
        return .east
    } else if start.y > end.y {
        return .south
    } else {
        return .west
    }
}

func getCarPosition(from direction: Direction) -> CarPosition {
    switch direction {
    case .north:
        return CarPosition(x: 0.7, y: 0.0, rotation: 0)
    case .east:
        return CarPosition(x: 0.0, y: 0.3, rotation: Double.pi / -2)
    case .south:
        return CarPosition(x: 0.3, y: 1.0, rotation: Double.pi)
    case .west:
        return CarPosition(x: 1.0, y: 0.7, rotation: Double.pi / 2)
    }
}
