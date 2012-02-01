/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import <UIKit/UIKit.h>

@class KalTileView, KalDate;

@interface KalMonthView : UIView
{
	NSUInteger numWeeks;
	BOOL disablePastDates;
	BOOL disableWeekends;
	NSDate *minDate;
	NSDate *maxDate;
	NSDate *dueDate;
}

@property (nonatomic) NSUInteger numWeeks;
@property (nonatomic, assign) BOOL disablePastDates;
@property (nonatomic, assign) BOOL disableWeekends;
@property (nonatomic, copy) NSDate *minDate;
@property (nonatomic, copy) NSDate *maxDate;
@property (nonatomic, copy) NSDate *dueDate;

- (id)initWithFrame:(CGRect)rect; // designated initializer
- (void)showDates:(NSArray *)mainDates leadingAdjacentDates:(NSArray *)leadingAdjacentDates trailingAdjacentDates:(NSArray *)trailingAdjacentDates;
- (KalTileView *)firstTileOfMonth;
- (KalTileView *)tileForDate:(KalDate *)date;
- (void)markTilesForDates:(NSArray *)dates;
- (NSDate*)currentDate;
- (void)disableTilesForDates:(NSArray *)dates;
- (void)setMinDate:(NSDate *)min maxDate:(NSDate*)max;
- (BOOL)monthContainsDate:(KalDate*)date;

@end
