//
// Created by David Martinez on 18/08/2018.
//

import CoreGraphics

typealias CGLine = (start: CGPoint, end: CGPoint)

extension CGPoint {

    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }

    static func * (left: CGFloat, right: CGPoint) -> CGPoint {
        return CGPoint(x: left*right.x, y: left*right.y)
    }

    static func * (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x * right.x, y: left.y * right.y)
    }

    /**
    Normalize the distance into [-1, 1] coordinate system
    */
    func normalizedDistanceForSize(_ size: CGSize) -> CGPoint {
        // multiplies by 2 because coordinate system is (-1,1)
        let x = 2 * (self.x / size.width)
        let y = 2 * (self.y / size.height)
        return CGPoint(x: x, y: y)
    }

    /**
    Calculate the distance between two points
    */
    func distanceTo(_ point: CGPoint) -> CGFloat {
        return sqrt(pow(point.x - self.x, 2) + pow(point.y - self.y, 2))
    }

    /**
    The scalar projection from a vector "w" from another "v" is calculated as follow:
                 w * v
        result = ----- * v
                 v * v
    where all "*" represent scalar products
    - Parameter vector: Represents the vector on which 'self' will be projected
    */
    func scalarProjection(over vector: CGPoint) -> CGPoint {
        let A = self.scalarProduct(vector) // w * v
        let B = vector.scalarProduct(vector) // v * v
        let r = A / B
        return CGPoint(x: vector.x * r, y: vector.y * r)
    }

    /**
    Calculate the scalar product between two vectors "v" and "w" like:
        result = v * w => (v1, v2) * (w1, w2) => v1*w1 + v2*w2
    */
    func scalarProduct(_ point: CGPoint) -> CGFloat {
        return (self.x * point.x) + (self.y * point.y)
    }

    /**
     Return the vector module based on:
        v (x, y) = sqrt(x^2 + y^2)
     */
    var vectorModule: CGFloat {
        return sqrt(self.x * self.x + self.y * self.y)
    }

    /**
    Calculate the intersection between the lines given
    - Returns the intersection point or nil if the lines no intersects between them (parallel lines)
    */
    static func intersectionBetweenLines(_ line1: CGLine, line2: CGLine) -> CGPoint? {
        let (p1,p2) = line1
        let (p3,p4) = line2

        var d = (p4.y - p3.y) * (p2.x - p1.x) - (p4.x - p3.x) * (p2.y - p1.y)
        var ua = (p4.x - p3.x) * (p1.y - p4.y) - (p4.y - p3.y) * (p1.x - p3.x)
        var ub = (p2.x - p1.x) * (p1.y - p3.y) - (p2.y - p1.y) * (p1.x - p3.x)
        if (d < 0) {
            ua = -ua; ub = -ub; d = -d
        }

        if d != 0 {
            return CGPoint(x: p1.x + ua / d * (p2.x - p1.x), y: p1.y + ua / d * (p2.y - p1.y))
        }
        return nil
    }
}

