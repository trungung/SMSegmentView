//
//  SMSegmentView.swift
//
//  Created by Si MA on 03/01/2015.
//  Copyright (c) 2015 Si Ma. All rights reserved.
//

import UIKit

/*
  Keys for segment properties
*/

// This is mainly for the top/bottom margin of the imageView
public let keyContentVerticalMargin = "VerticalMargin"

// The colour when the segment is under selected/unselected
public let keySegmentOnSelectionColour = "OnSelectionBackgroundColour"
public let keySegmentOffSelectionColour = "OffSelectionBackgroundColour"

// The colour of the text in the segment for the segment is under selected/unselected
public let keySegmentOnSelectionTextColour = "OnSelectionTextColour"
public let keySegmentOffSelectionTextColour = "OffSelectionTextColour"

// The font of the text in the segment
public let keySegmentTitleFont = "TitleFont"


public enum SegmentOrganiseMode: Int {
    case SegmentOrganiseHorizontal = 0
    case SegmentOrganiseVertical
}


public protocol SMSegmentViewDelegate: class {
    func segmentView(segmentView: SMSegmentView, didSelectSegmentAtIndex index: Int)
}

public class SMSegmentView: UIView, SMSegmentDelegate {
    public weak var delegate: SMSegmentViewDelegate?
    
    var indexOfSelectedSegment = NSNotFound
    var numberOfSegments = 0
    
    public var organiseMode: SegmentOrganiseMode = SegmentOrganiseMode.SegmentOrganiseHorizontal {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public var segmentVerticalMargin: CGFloat = 5.0 {
        didSet {
            for segment in self.segments {
                segment.verticalMargin = self.segmentVerticalMargin
            }
        }
    }
    
    // Segment Separator
    public var separatorColour: UIColor = UIColor.lightGrayColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    public var separatorWidth: CGFloat = 1.0 {
        didSet {
            for segment in self.segments {
                segment.separatorWidth = self.separatorWidth
            }
            self.updateFrameForSegments()
        }
    }
    
    // Segment Colour
    public var segmentOnSelectionColour: UIColor = UIColor.darkGrayColor() {
        didSet {
            for segment in self.segments {
                segment.onSelectionColour = self.segmentOnSelectionColour
            }
        }
    }
    public var segmentOffSelectionColour: UIColor = UIColor.whiteColor() {
        didSet {
            for segment in self.segments {
                segment.offSelectionColour = self.segmentOffSelectionColour
            }
        }
    }
    
    // Segment Title Text Colour & Font
    public var segmentOnSelectionTextColour: UIColor = UIColor.whiteColor() {
        didSet {
            for segment in self.segments {
                segment.onSelectionTextColour = self.segmentOnSelectionTextColour
            }
        }
    }
    public var segmentOffSelectionTextColour: UIColor = UIColor.darkGrayColor() {
        didSet {
            for segment in self.segments {
                segment.offSelectionTextColour = self.segmentOffSelectionTextColour
            }
        }
    }
    public var segmentTitleFont: UIFont = UIFont.systemFontOfSize(17.0) {
        didSet {
            for segment in self.segments {
                segment.titleFont = self.segmentTitleFont
            }
        }
    }
    
    override public var frame: CGRect {
        didSet {
            self.updateFrameForSegments()
        }
    }
    
    private var segments: Array<SMSegment> = Array()
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.layer.masksToBounds = true
    }
    
    public init(frame: CGRect, separatorColour: UIColor, separatorWidth: CGFloat, segmentProperties: Dictionary<String, AnyObject>?) {
        self.separatorColour = separatorColour
        self.separatorWidth = separatorWidth
        
        if let margin = segmentProperties?[keyContentVerticalMargin] as? Float {
            self.segmentVerticalMargin = CGFloat(margin)
        }
        
        if let onSelectionColour = segmentProperties?[keySegmentOnSelectionColour] as? UIColor {
            self.segmentOnSelectionColour = onSelectionColour
        }
        else {
            self.segmentOnSelectionColour = UIColor.darkGrayColor()
        }
        
        if let offSelectionColour = segmentProperties?[keySegmentOffSelectionColour] as? UIColor {
            self.segmentOffSelectionColour = offSelectionColour
        }
        else {
            self.segmentOffSelectionColour = UIColor.whiteColor()
        }
        
        if let onSelectionTextColour = segmentProperties?[keySegmentOnSelectionTextColour] as? UIColor {
            self.segmentOnSelectionTextColour = onSelectionTextColour
        }
        else {
            self.segmentOnSelectionTextColour = UIColor.whiteColor()
        }
        
        if let offSelectionTextColour = segmentProperties?[keySegmentOffSelectionTextColour] as? UIColor {
            self.segmentOffSelectionTextColour = offSelectionTextColour
        }
        else {
            self.segmentOffSelectionTextColour = UIColor.darkGrayColor()
        }
        
        if let titleFont = segmentProperties?[keySegmentTitleFont] as? UIFont {
            self.segmentTitleFont = titleFont
        }
        else {
            self.segmentTitleFont = UIFont.systemFontOfSize(17.0)
        }
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.layer.masksToBounds = true
    }
    
    public func addSegmentWithTitle(title: String?, onSelectionImage: UIImage?, offSelectionImage: UIImage?) {
        
        let segment = SMSegment(separatorWidth: self.separatorWidth, verticalMargin: self.segmentVerticalMargin, onSelectionColour: self.segmentOnSelectionColour, offSelectionColour: self.segmentOffSelectionColour, onSelectionTextColour: self.segmentOnSelectionTextColour, offSelectionTextColour: self.segmentOffSelectionTextColour, titleFont: self.segmentTitleFont)
        segment.index = self.segments.count
        self.segments.append(segment)
        self.updateFrameForSegments()
        
        segment.delegate = self
        segment.title = title
        segment.onSelectionImage = onSelectionImage
        segment.offSelectionImage = offSelectionImage
        
        self.addSubview(segment)
        
        self.numberOfSegments = self.segments.count
    }
    
    public func updateFrameForSegments() {
        if self.segments.count == 0 {
            return
        }
        
        let count = self.segments.count
        if count > 1 {
            if self.organiseMode == SegmentOrganiseMode.SegmentOrganiseHorizontal {
                let segmentWidth = (self.frame.size.width - self.separatorWidth*CGFloat(count-1)) / CGFloat(count)
                var originX: CGFloat = 0.0
                for segment in self.segments {
                    segment.frame = CGRect(x: originX, y: 0.0, width: segmentWidth, height: self.frame.size.height)
                    originX += segmentWidth + self.separatorWidth
                }
            }
            else {
                let segmentHeight = (self.frame.size.height - self.separatorWidth*CGFloat(count-1)) / CGFloat(count)
                var originY: CGFloat = 0.0
                for segment in self.segments {
                    segment.frame = CGRect(x: 0.0, y: originY, width: self.frame.size.width, height: segmentHeight)
                    originY += segmentHeight + self.separatorWidth
                }
            }
        }
        else {
            self.segments[0].frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height)
        }
        
        self.setNeedsDisplay()
    }
    
    // MARK: SMSegment Delegate
    public func selectSegment(segment: SMSegment) {
        if self.indexOfSelectedSegment != NSNotFound {
            let previousSelectedSegment = self.segments[self.indexOfSelectedSegment]
            previousSelectedSegment.setSelected(false)
        }
        self.indexOfSelectedSegment = segment.index
        segment.setSelected(true)
        self.delegate?.segmentView(self, didSelectSegmentAtIndex: segment.index)
    }
    
    // MARK: Actions
    public func selectSegmentAtIndex(index: Int) {
        assert(index >= 0 && index < self.segments.count, "Index at \(index) is out of bounds")
        self.selectSegment(self.segments[index])
    }
    
    public func deselectSegment() {
        if self.indexOfSelectedSegment != NSNotFound {
            let segment = self.segments[self.indexOfSelectedSegment]
            segment.setSelected(false)
            self.indexOfSelectedSegment = NSNotFound
        }
    }
    
    // MARK: Drawing Segment Separators
    override public func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        self.drawSeparatorWithContext(context)
    }
    
    public func drawSeparatorWithContext(context: CGContextRef) {
        CGContextSaveGState(context)
        
        if self.segments.count > 1 {
            var path = CGPathCreateMutable()
            
            if self.organiseMode == SegmentOrganiseMode.SegmentOrganiseHorizontal {
                var originX: CGFloat = self.segments[0].frame.size.width + self.separatorWidth/2.0
                for index in 1..<self.segments.count {
                    CGPathMoveToPoint(path, nil, originX, 0.0)
                    CGPathAddLineToPoint(path, nil, originX, self.frame.size.height)
                    
                    originX += self.segments[index].frame.width + self.separatorWidth
                }
            }
            else {
                var originY: CGFloat = self.segments[0].frame.size.height + self.separatorWidth/2.0
                for index in 1..<self.segments.count {
                    CGPathMoveToPoint(path, nil, 0.0, originY)
                    CGPathAddLineToPoint(path, nil, self.frame.size.width, originY)
                    
                    originY += self.segments[index].frame.height + self.separatorWidth
                }
            }
            
            CGContextAddPath(context, path)
            CGContextSetStrokeColorWithColor(context, self.separatorColour.CGColor)
            CGContextSetLineWidth(context, self.separatorWidth)
            CGContextDrawPath(context, kCGPathStroke)
        }
        
        CGContextRestoreGState(context)
    }
}
