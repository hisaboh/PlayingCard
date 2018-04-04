//
//  PlayingCardView.swift
//  PlayingCard
//
//  Created by 牧野 壽永 on 2018/04/03.
//  Copyright © 2018年 牧野 壽永. All rights reserved.
//

import UIKit

@IBDesignable
class PlayingCardView: UIView {
    @IBInspectable
    var rank: Int = 12 { didSet { setNeedsDisplay(); setNeedsLayout() }}
    @IBInspectable
    var suit: String = "♥️" { didSet { setNeedsDisplay(); setNeedsLayout() }}
    @IBInspectable
    var isFaceUp: Bool = true { didSet { setNeedsDisplay(); setNeedsLayout() }}

    var faceCardScale: CGFloat = SizeRatio.faceCardImageSizeToBoundsSize {
        didSet { setNeedsDisplay() }
    }

    @objc func adjustFaceCardScale(byHandlingGestureRecognizedBy recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            faceCardScale *= recognizer.scale
            recognizer.scale = 1.0
        default:
            break
        }
    }
    
    private func centeredAttribbutedString(_ string: String, fontSize: CGFloat) -> NSAttributedString {
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString(string: string, attributes: [.paragraphStyle: paragraphStyle, .font: font])
    }
    
    private var cornerString: NSAttributedString {
        return centeredAttribbutedString(rankString + "\n" + suit, fontSize: cornerFontSize)
    }
    
    private lazy var upperLeftCornerLabel: UILabel = createCornerLabel()
    private lazy var lowerRightCornerLabel: UILabel = createCornerLabel()

    private func createCornerLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        addSubview(label)
        return label
    }
    
    private func configureCornerLabel(_ label: UILabel) {
        label.attributedText = cornerString
        label.frame.size = CGSize.zero
        label.sizeToFit()
        label.isHidden = !isFaceUp
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsDisplay()
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureCornerLabel(upperLeftCornerLabel)
        upperLeftCornerLabel.frame.origin = bounds.offsetBy(dx: cornerOffset, dy: cornerOffset).origin

        configureCornerLabel(lowerRightCornerLabel)
        lowerRightCornerLabel.transform = CGAffineTransform.identity
            .translatedBy(x: lowerRightCornerLabel.frame.width, y: lowerRightCornerLabel.frame.height)
            .rotated(by: CGFloat.pi)
        lowerRightCornerLabel.frame.origin = CGRect(x: bounds.maxX, y: bounds.maxY, width: 0.0, height: 0.0).offsetBy(dx: -cornerOffset, dy: -cornerOffset).offsetBy(dx: -lowerRightCornerLabel.frame.width, dy: -lowerRightCornerLabel.frame.height).origin
    }
    
    private func drawPips() {
        let pipsPerRowForRank = [
            [0], [1], [1,1], [1,1,1], [2,2], [2,1,2], [2,2,2], [2,1,2,2],[2,2,2,2],[2,2,1,2,2], [2,2,2,2,2]
        ]
        
        func createPipString(thatFits pipRect: CGRect) -> NSAttributedString {
            let maxVerticalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.count, $0) })
            let maxHorizontalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.max() ?? 0, $0) })
            let verticalPipRowSpacing = pipRect.size.height / maxVerticalPipCount
            let attemptedPipString = centeredAttribbutedString(suit, fontSize: verticalPipRowSpacing)
            let probablyOkayPipStringFontSize = verticalPipRowSpacing / (attemptedPipString.size().height / verticalPipRowSpacing)
            let probablyOkayPipString = centeredAttribbutedString(suit, fontSize: probablyOkayPipStringFontSize)
            if probablyOkayPipString.size().width > pipRect.size.width / maxHorizontalPipCount {
                return centeredAttribbutedString(suit, fontSize: probablyOkayPipStringFontSize / (probablyOkayPipString.size().width / (pipRect.size.width / maxHorizontalPipCount)))
            } else {
                return probablyOkayPipString
            }
        }
        
        if pipsPerRowForRank.indices.contains(rank) {
            let pipsPerRow = pipsPerRowForRank[rank]
            var pipRect = bounds.insetBy(dx: cornerOffset, dy: cornerOffset).insetBy(dx: cornerString.size().width, dy: cornerString.size().height)
            let pipString = createPipString(thatFits: pipRect)
            let pipRowSpacing = pipRect.size.height / CGFloat(pipsPerRow.count)
            pipRect.size.height = pipString.size().height
            pipRect.origin.y += (pipRowSpacing - pipRect.size.height) / 2
            for pipCount in pipsPerRow {
                switch pipCount {
                case 1:
                    pipString.draw(in: pipRect)
                case 2:
                    pipString.draw(in: pipRect.leftHalf)
                    pipString.draw(in: pipRect.rightHalf)
                default:
                    break
                }
                pipRect.origin.y += pipRowSpacing
            }
        }
    }

    override func draw(_ rect: CGRect) {
        let roundRect = UIBezierPath(roundedRect: bounds, cornerRadius: 16.0)
        roundRect.addClip()
        UIColor.white.setFill()
        roundRect.fill()
        
        if isFaceUp {
            if let faceCardImage = UIImage(named: rankString+suit, in: Bundle(for: self.classForCoder), compatibleWith: traitCollection) {
                faceCardImage.draw(in: bounds.zoom(by:  faceCardScale))
            } else {
                drawPips()
            }
        } else {
            if let cardBackImage = UIImage(named: "cardback", in: Bundle(for: self.classForCoder), compatibleWith: traitCollection) {
                cardBackImage.draw(in: bounds)
            }
        }
    }

}

extension PlayingCardView {
    private struct SizeRatio {
        static let cornerFontSizeToBoundsHeight: CGFloat = 0.085
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
        static let cornerOffsetToCornerRadius: CGFloat = 0.33
        static let faceCardImageSizeToBoundsSize: CGFloat = 0.60
    }
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    private var cornerOffset: CGFloat {
        return cornerRadius * SizeRatio.cornerOffsetToCornerRadius
    }
    private var cornerFontSize: CGFloat {
        return bounds.size.height * SizeRatio.cornerFontSizeToBoundsHeight
    }
    private var rankString: String {
        switch rank {
        case 1: return "A"
        case 2...10: return String(rank)
        case 11: return "J"
        case 12: return "Q"
        case 13: return "K"
        default: return "?"
        }
    }
}

extension CGRect {
    func zoom(by ratio: CGFloat) -> CGRect {
        var rect = CGRect(origin: self.origin, size: self.size)
        rect.size.width = rect.size.width * ratio
        rect.size.height = rect.size.height * ratio
        rect.origin.x = rect.origin.x + (self.size.width - rect.size.width) / 2
        rect.origin.y = rect.origin.y + (self.size.height - rect.size.height) / 2
        return rect
    }
    
    var leftHalf: CGRect { return CGRect(origin: self.origin, size: CGSize(width: self.size.width / 2, height: self.size.height)) }
    var rightHalf: CGRect { return CGRect(origin: CGPoint(x: self.origin.x + (self.size.width / 2), y: self.origin.y), size: CGSize(width: self.size.width / 2, height: self.size.height)) }
}
