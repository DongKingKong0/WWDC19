
import Foundation

public class Node: NSObject {
    var visited: Bool = false
    var connections: [Connection] = []
    let x: Int, y: Int
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

public class Connection: NSObject {
    let to: Node
    init(to node: Node) {
        self.to = node
    }
}

public class Path: NSObject {
    public var node: Node
    public var previousPath: Path?

    public init(to node: Node, previousPath path: Path? = nil) {
        self.node = node
        self.previousPath = path
    }
}

public class Graph: NSObject {
    var nodes: [Node] = []
    
    public func add(node: Node) {
        nodes.append(node)
    }
    
    public func addConnection(node1: Node, node2: Node) {
        node1.connections.append(Connection(to: node2))
        node2.connections.append(Connection(to: node1))
    }
    
    
    public func shortestPath(from startNode: Node, to endNode: Node) -> Path? {
        var knownPaths: [Path] = []
        
        knownPaths.append(Path(to: startNode))
        
        while !knownPaths.isEmpty {
            let nextPath = knownPaths.removeFirst()
            guard !nextPath.node.visited else {
                continue
            }
            
            if nextPath.node === endNode {
                return nextPath
            }
            
            nextPath.node.visited = true
            
            for connection in nextPath.node.connections where !connection.to.visited {
                knownPaths.append(Path(to: connection.to, previousPath: nextPath))
            }
        }
        
        return nil
    }
    
    
    public func reset() {
        for node in nodes {
            node.visited = false
        }
    }
}


public class GridGraph: Graph {
    let width: Int, height:Int
    
    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
        
        super.init()
        
        for x in 0 ... self.width - 1 {
            for y in 0 ... self.height - 1 {
                self.add(node: Node(x: x, y: y))
            }
        }
    }
    
    
    public func getNode(x: Int, y: Int) -> Node {
        return self.nodes[x * self.height + y]
    }
}
