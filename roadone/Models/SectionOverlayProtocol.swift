// SectionOverlayProtocol.swift

import MapKit

protocol SectionOverlayProtocol: MKOverlay {
    var section: Section? { get }
}
