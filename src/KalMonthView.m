/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import <CoreGraphics/CoreGraphics.h>
#import "KalMonthView.h"
#import "KalTileView.h"
#import "KalView.h"
#import "KalDate.h"
#import "UIViewAdditions.h"
#import "NSDateAdditions.h"

extern const CGSize kTileSize;

@implementation KalMonthView

@synthesize numWeeks, disablePastDates, minDate, maxDate, disableWeekends;

- (id)initWithFrame:(CGRect)frame
{
  if ((self = [super initWithFrame:frame])) {
    self.opaque = NO;
    self.clipsToBounds = YES;
    for (int i=0; i<6; i++) {
      for (int j=0; j<7; j++) {
        CGRect r = CGRectMake(j*kTileSize.width, i*kTileSize.height, kTileSize.width, kTileSize.height);
        [self addSubview:[[[KalTileView alloc] initWithFrame:r] autorelease]];
      }
    }
  }
  return self;
}

- (void)setMinDate:(NSDate *)min maxDate:(NSDate*)max
{
	self.minDate = min;
	self.maxDate = max;
}

- (void)showDates:(NSArray *)mainDates leadingAdjacentDates:(NSArray *)leadingAdjacentDates trailingAdjacentDates:(NSArray *)trailingAdjacentDates
{
	int tileNum = 0;

	NSArray *dates[] = { leadingAdjacentDates, mainDates, trailingAdjacentDates };
  
	for (int i=0; i<3; i++)
	{
		for (KalDate *d in dates[i])
		{
			KalTileView *tile = [self.subviews objectAtIndex:tileNum];
			[tile resetState];
			tile.date = d;
			tile.type = dates[i] != mainDates
                    ? KalTileTypeAdjacent
                    : [d isToday] ? KalTileTypeToday : KalTileTypeRegular;

			tileNum++;

			if (disablePastDates && [d compare:[KalDate dateFromNSDate:[self currentDate]]] == NSOrderedAscending)
			{
				tile.disabled = YES;
			}

			if (self.minDate != nil && [d compare:[KalDate dateFromNSDate:self.minDate]] == NSOrderedAscending)
			{
				tile.disabled = YES;
			}

			if (self.maxDate != nil && [d compare:[KalDate dateFromNSDate:self.maxDate]] == NSOrderedDescending)
			{
				tile.disabled = YES;
			}

			if (self.disableWeekends)
			{
				NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
				NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[d NSDate]];
				int weekday = [comps weekday];

				// Saturday or Sunday
				if (weekday == 1 || weekday == 7)
				{
					tile.disabled = YES;
				}
			}
		}
	}

	numWeeks = ceilf(tileNum / 7.f);

	[self sizeToFit];
	[self setNeedsDisplay];
}

- (NSDate*)currentDate
{
	NSCalendar *cal = [NSCalendar currentCalendar];

	NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];

	return [cal dateFromComponents:components];
}

- (void)drawRect:(CGRect)rect
{
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGContextDrawTiledImage(ctx, (CGRect){CGPointZero,kTileSize}, [[UIImage imageNamed:@"Kal.bundle/kal_tile.png"] CGImage]);
}

- (KalTileView *)firstTileOfMonth
{
  KalTileView *tile = nil;
  for (KalTileView *t in self.subviews) {
    if (!t.belongsToAdjacentMonth) {
      tile = t;
      break;
    }
  }
  
  return tile;
}

- (BOOL)monthContainsDate:(KalDate*)date
{
	for (KalTileView *t in self.subviews)
	{
		if ([t.date isEqual:date])
		{
			return YES;
			break;
		}
	}

	return NO;
}

- (KalTileView *)tileForDate:(KalDate *)date
{
  KalTileView *tile = nil;
  for (KalTileView *t in self.subviews) {
    if ([t.date isEqual:date]) {
      tile = t;
      break;
    }
  }
  NSAssert1(tile != nil, @"Failed to find corresponding tile for date %@", date);
  
  return tile;
}

- (void)sizeToFit
{
  self.height = 1.f + kTileSize.height * numWeeks;
}

- (void)markTilesForDates:(NSArray *)dates
{
  for (KalTileView *tile in self.subviews)
    tile.marked = [dates containsObject:tile.date];
}

- (void)disableTilesForDates:(NSArray *)dates
{
	for (KalTileView *tile in self.subviews)
	{
		if (!tile.disabled)
		{
			tile.disabled = [dates containsObject:tile.date];
		}
	}
}

- (void)dealloc
{
	[minDate release];
	[maxDate release];

	[super dealloc];
}

@end
