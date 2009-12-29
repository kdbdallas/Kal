/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "KalTileView.h"
#import "KalPrivate.h"

extern const CGSize kTileSize;

@implementation KalTileView

@synthesize date, selected=isSelected, highlighted=isHighlighted, marked=isMarked, type;

- (id)initWithFrame:(CGRect)frame
{
  if ((self = [super initWithFrame:frame])) {
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
    origin = frame.origin;
    [self resetState];
  }
  return self;
}

- (void)drawRect:(CGRect)rect
{
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGFloat fontSize = 24.f;
  UIFont *font = [UIFont boldSystemFontOfSize:fontSize];
  UIColor *shadowColor = nil;
  UIColor *textColor = nil;
  UIImage *markerImage = nil;
  CGContextSelectFont(ctx, [font.fontName cStringUsingEncoding:NSUTF8StringEncoding], fontSize, kCGEncodingMacRoman);
      
  CGContextTranslateCTM(ctx, 0, kTileSize.height);
  CGContextScaleCTM(ctx, 1, -1);
  
  if ([self isToday] && self.selected) {
    [[[UIImage imageNamed:@"kal_tiletoday_selected.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] drawInRect:CGRectMake(0, -1, kTileSize.width+1, kTileSize.height+1)];
    textColor = [UIColor whiteColor];
    shadowColor = [UIColor blackColor];
    markerImage = [UIImage imageNamed:@"kal_markertoday.png"];
  } else if ([self isToday] && !self.selected) {
    [[[UIImage imageNamed:@"kal_tiletoday.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] drawInRect:CGRectMake(0, -1, kTileSize.width+1, kTileSize.height+1)];
    textColor = [UIColor whiteColor];
    shadowColor = [UIColor blackColor];
    markerImage = [UIImage imageNamed:@"kal_markertoday.png"];
  } else if (self.selected) {
    [[[UIImage imageNamed:@"kal_tile_selected.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0] drawInRect:CGRectMake(0, -1, kTileSize.width+1, kTileSize.height+1)];
    textColor = [UIColor whiteColor];
    shadowColor = [UIColor blackColor];
    markerImage = [UIImage imageNamed:@"kal_marker_selected.png"];
  } else if (self.belongsToAdjacentMonth) {
    textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"kal_tile_disabled_text_fill.png"]];
    shadowColor = nil;
    markerImage = [UIImage imageNamed:@"kal_marker_disabled.png"];
  } else {
    textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"kal_tile_text_fill.png"]];
    shadowColor = [UIColor whiteColor];
    markerImage = [UIImage imageNamed:@"kal_marker.png"];
  }
  
  if (self.marked)
    [markerImage drawInRect:CGRectMake(21.f, 5.f, 4.f, 5.f)];
  
  NSUInteger n = [self.date cc_day];
  NSString *dayText = [NSString stringWithFormat:@"%lu", (unsigned long)n];
  const char *day = [dayText cStringUsingEncoding:NSUTF8StringEncoding];
  CGSize textSize = [dayText sizeWithFont:font];
  CGFloat textX, textY;
  textX = roundf(0.5f * (kTileSize.width - textSize.width));
  textY = 6.f + roundf(0.5f * (kTileSize.height - textSize.height));
  if (shadowColor) {
    [shadowColor setFill];
    CGContextShowTextAtPoint(ctx, textX, textY, day, n >= 10 ? 2 : 1);
    textY += 1.f;
  }
  [textColor setFill];
  CGContextShowTextAtPoint(ctx, textX, textY, day, n >= 10 ? 2 : 1);
  
  if (self.highlighted) {
    [[UIColor colorWithWhite:0.25f alpha:0.3f] setFill];
    CGContextFillRect(ctx, CGRectMake(0.f, 0.f, kTileSize.width, kTileSize.height));
  }
}

- (void)resetState
{
  // realign to the grid
  CGRect frame = self.frame;
  frame.origin = origin;
  frame.size = kTileSize;
  self.frame = frame;
  
  [date release];
  date = nil;
  type = KalTileTypeRegular;
  isHighlighted = NO;
  isSelected = NO;
  isMarked = NO;
}

- (void)setDate:(NSDate *)aDate
{
  if (date == aDate)
    return;

  [date release];
  date = [aDate retain];

  [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected
{
  if (isSelected == selected)
    return;

  // workaround since I cannot draw outside of the frame in drawRect:
  if (![self isToday]) {
    CGRect rect = self.frame;
    if (selected) {
      rect.origin.x--;
      rect.size.width++;
      rect.size.height++;
    } else {
      rect.origin.x++;
      rect.size.width--;
      rect.size.height--;
    }
    self.frame = rect;
  }
  
  isSelected = selected;
  [self setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)highlighted
{
  if (isHighlighted == highlighted)
    return;
  
  isHighlighted = highlighted;
  [self setNeedsDisplay];
}

- (void)setType:(KalTileType)tileType
{
  if (type == tileType)
    return;
  
  // workaround since I cannot draw outside of the frame in drawRect:
  CGRect rect = self.frame;
  if (tileType == KalTileTypeToday) {
    rect.origin.x--;
    rect.size.width++;
    rect.size.height++;
  } else {
    rect.origin.x++;
    rect.size.width--;
    rect.size.height--;
  }
  self.frame = rect;
  
  type = tileType;
  [self setNeedsDisplay];
}

- (void)setMarked:(BOOL)marked
{
  if (isMarked == marked)
    return;
  
  isMarked = marked;
  [self setNeedsDisplay];
}

- (BOOL)isToday { return type == KalTileTypeToday; }

- (BOOL)belongsToAdjacentMonth { return type == KalTileTypeAdjacent; }

- (void)dealloc
{
  [date release];
  [dayLabel release];
  [backgroundView release];
  [markerView release];
  [super dealloc];
}


@end