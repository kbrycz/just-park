// SelectablePolylineRenderer.swift

import MapKit

class SelectablePolylineRenderer: MKPolylineRenderer {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // Increase the hit-testing area
        let touchArea = self.strokePath.copy(strokingWithWidth: self.lineWidth + 10, lineCap: .round, lineJoin: .round, miterLimit: self.miterLimit)
        return touchArea.contains(point)
    }
}
