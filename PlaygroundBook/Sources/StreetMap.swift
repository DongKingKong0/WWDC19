
import Foundation
import SpriteKit

public enum StreetType {
    case empty, deadEnd, curve, straight, branch, crossroad
}

enum StreetConnectionType {
    case grass, street
}


struct StreetSpriteType {
    let type: StreetType
    let rotation: Int
}


public struct StreetNode: Equatable {
    let x: Int, y: Int
    let direction: Direction?
    public static func == (left: StreetNode, right: StreetNode) -> Bool {
        return left.x == right.x && left.y == right.y
    }
}

struct StreetConnection {
    let from: StreetNode
    let to: StreetNode
}

public class StreetMap: NSObject {
    let width: Int, height: Int
    var nodes: [[StreetNode]]
    var connections: [StreetConnection]
    var graph: GridGraph
    public var sprites: [[StreetSprite]]
    
    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
        self.graph = GridGraph(width: 1, height: 1)
        self.nodes = Array(repeating: Array(repeating: StreetNode(x: 0, y: 0, direction: nil), count: self.height), count: self.width)
        self.connections = []
        self.sprites = Array(repeating: Array(repeating: StreetSprite(type: .empty, startSprite: nil), count: self.height), count: self.width)
        
        super.init()
        
        self.generateRandomStreetMap()
    }
    
    
    private func generateRandomStreetMap() {
        for x in 0 ... self.width - 1 {
            for y in 0 ... self.height - 1 {
                var direction: Direction? = nil
                if (x == 0 || y == 0 || x == self.width - 1 || y == self.height - 1) && randomBool() {
                    if y == 0 {
                        direction = .south
                    } else if x == 0 {
                        direction = .west
                    } else if y == self.height - 1 {
                        direction = .north
                    } else if x == self.width - 1 {
                        direction = .east
                    }
                }
                
                self.nodes[x][y] = StreetNode(x: x, y: y, direction: direction)
                
                if x > 0 && randomBool() {
                    self.addConnection(from: self.nodes[x - 1][y], to: self.nodes[x][y])
                }
                if y > 0 && randomBool() {
                    self.addConnection(from: self.nodes[x][y - 1], to: self.nodes[x][y])
                }
            }
        }
        self.generateGraph()
        self.generateSprites()
    }
    
    private func addConnection(from: StreetNode, to: StreetNode) {
        self.connections.append(StreetConnection(from: from, to: to))
    }
    
    
    private func generateGraph() {
        self.graph = GridGraph(width: self.width, height: self.height)
        
        for connection in self.connections {
            let node1 = self.graph.getNode(x: connection.from.x, y: connection.from.y)
            let node2 = self.graph.getNode(x: connection.to.x, y: connection.to.y)
            self.graph.addConnection(node1: node1, node2: node2)
        }
    }
    
    
    private func generateSprites() {
        for i in nodes {
            for node in i {
                var nodeConnections: [StreetConnectionType] = [.grass, .grass, .grass, .grass]
                for connection in connections {
                    let otherNode: StreetNode
                    
                    if connection.from == node {
                        otherNode = connection.to
                    } else if connection.to == node {
                        otherNode = connection.from
                    } else {
                        continue
                    }
                    
                    if otherNode.y > node.y {
                        nodeConnections[0] = .street
                        
                    } else if otherNode.x > node.x {
                        nodeConnections[1] = .street
                        
                    } else if otherNode.y < node.y {
                        nodeConnections[2] = .street
                        
                    } else if otherNode.x < node.x {
                        nodeConnections[3] = .street
                    }
                }
                
                if let startDirection = node.direction {
                    switch startDirection {
                    case .north:
                        nodeConnections[0] = .street
                    case .east:
                        nodeConnections[1] = .street
                    case .south:
                        nodeConnections[2] = .street
                    case .west:
                        nodeConnections[3] = .street
                    }
                }
                
                let streetType = self.getStreetType(from: nodeConnections)
                
                let sprite = StreetSprite(type: streetType.type, startSprite: node.direction)
                sprite.position = CGPoint(x: (Double(node.x) + 0.5) * 0.1, y: (Double(node.y) + 0.5) * 0.1)
                sprite.rotation = Double(streetType.rotation) * Double.pi / -2
                
                self.sprites[node.x][node.y] = sprite
            }
        }
    }
    
    private func getStreetType(from nodeConnections: [StreetConnectionType]) -> StreetSpriteType {
        var connectionCount = 0
        var firstConnection = -1
        var lastEmpty = nodeConnections[3] == .grass
        
        for (i, connection) in nodeConnections.enumerated() {
            if (connection == .street) {
                if firstConnection == -1 && lastEmpty {
                    firstConnection = i
                }
                connectionCount += 1
            }
            
            lastEmpty = connection == .grass
        }
        
        let type: StreetType
        var rotation = Int(arc4random_uniform(4))
        
        switch connectionCount {
        case 0:
            type = .empty
        case 1:
            type = .deadEnd
            rotation = firstConnection
        case 2:
            let oppositeConnection = (firstConnection + 2) % 4
            if nodeConnections[oppositeConnection] == .street {
                type = .straight
            } else {
                type = .curve
            }
            rotation = firstConnection
        case 3:
            type = .branch
            rotation = firstConnection
        default:
            type = .crossroad
            break
        }
        
        return StreetSpriteType(type: type, rotation: rotation)
    }
    
    
    public func getStartNodes() -> [StreetNode] {
        var startNodes = [StreetNode]()
        
        for i in self.nodes {
            for node in i {
                if node.direction != nil {
                    startNodes.append(node)
                }
            }
        }
        
        return startNodes
    }
    
    
    public func shortestPath(from startNode: Node, to endNode: Node) -> Path? {
        var path = self.graph.shortestPath(from: startNode, to: endNode)
        if path != nil {
            var startNode = Node(x: 0, y: 0), endNode = Node(x: 0, y: 0)
            
            if path!.node.x == 0 {
                startNode = Node(x: -1, y: path!.node.y)
            } else if path!.node.y == 0 {
                startNode = Node(x: path!.node.x, y: -1)
            } else if path!.node.x == self.width - 1 {
                startNode = Node(x: self.width, y: path!.node.y)
            } else if path!.node.y == self.width - 1 {
                startNode = Node(x: path!.node.x, y: self.height)
            }
            
            var nextPath: Path? = path
            var lastPath: Path? = nil
            while nextPath != nil {
                if nextPath?.previousPath == nil {
                    lastPath = nextPath
                }
                nextPath = nextPath?.previousPath
            }
            
            if lastPath!.node.x == 0 {
                endNode = Node(x: -1, y: lastPath!.node.y)
            } else if lastPath!.node.y == 0 {
                endNode = Node(x: lastPath!.node.x, y: -1)
            } else if lastPath!.node.x == self.width - 1 {
                endNode = Node(x: self.width, y: lastPath!.node.y)
            } else if lastPath!.node.y == self.width - 1 {
                endNode = Node(x: lastPath!.node.x, y: self.height)
            }
            
            lastPath?.previousPath = Path(
                to: endNode,
                previousPath: nil)
            
            path = Path(
                to: startNode,
                previousPath: path)
        }
        
        self.graph.reset()
        
        return path
    }
}


/// Street generation only
func randomBool() -> Bool {
    let value = arc4random_uniform(3)
    return value != 0
}
