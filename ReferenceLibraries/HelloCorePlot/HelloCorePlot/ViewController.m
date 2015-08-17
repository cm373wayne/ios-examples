//
//  ViewController.m
//  HelloCorePlot
//
//  Created by macmini03 on 2015/8/13.
//  Copyright (c) 2015年 macmini03. All rights reserved.
//

#import "ViewController.h"

#import "CorePlot-CocoaTouch.h"

static const NSTimeInterval oneDay = 24 * 60 * 60;

@interface ViewController ()


@end

@implementation ViewController

@synthesize plotData;

-(void)addGraph:(CPTGraph *)graph toHostingView:(CPTGraphHostingView *)hostingView
{
    [self generateData];
    if ( hostingView ) {
        hostingView.hostedGraph = graph;
    }
}

-(CGFloat)titleSize
{
    CGFloat size;
    
    
    size = 24.0;
    
    return size;
}

-(void)generateData
{
    if ( !self.plotData ) {
        NSMutableArray *newData = [NSMutableArray array];
        for ( NSUInteger i = 0; i < 30; i++ ) {
            NSTimeInterval x = oneDay * i;
            
            double rOpen  = 3.0 * arc4random() / (double)UINT32_MAX + 1.0;
            double rClose = (arc4random() / (double)UINT32_MAX - 0.5) * 0.125 + rOpen;
            double rHigh  = MAX( rOpen, MAX(rClose, (arc4random() / (double)UINT32_MAX - 0.5) * 0.5 + rOpen) );
            double rLow   = MIN( rOpen, MIN(rClose, (arc4random() / (double)UINT32_MAX - 0.5) * 0.5 + rOpen) );
            
            [newData addObject:
             @{ @(CPTTradingRangePlotFieldX): @(x),
                @(CPTTradingRangePlotFieldOpen): @(rOpen),
                @(CPTTradingRangePlotFieldHigh): @(rHigh),
                @(CPTTradingRangePlotFieldLow): @(rLow),
                @(CPTTradingRangePlotFieldClose): @(rClose) }
             ];
        }
        
        self.plotData = newData;
    }
}

-(void)setupView
{
    CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame: [self view].bounds];
    
    [[self view] addSubview:hostingView];
    
    
    // If you make sure your dates are calculated at noon, you shouldn't have to
    // worry about daylight savings. If you use midnight, you will have to adjust
    // for daylight savings time.
    NSDate *refDate = [NSDate dateWithTimeIntervalSinceReferenceDate:oneDay / 2.0];
    
    CGRect bounds = hostingView.bounds;
    
    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:bounds];
    
    [self addGraph:newGraph toHostingView:hostingView];
    
    
    CPTMutableLineStyle *borderLineStyle = [CPTMutableLineStyle lineStyle];
    borderLineStyle.lineColor              = [CPTColor whiteColor];
    borderLineStyle.lineWidth              = 2.0;
    newGraph.plotAreaFrame.borderLineStyle = borderLineStyle;
    newGraph.plotAreaFrame.paddingTop      = self.titleSize * CPTFloat(0.5);
    newGraph.plotAreaFrame.paddingRight    = self.titleSize * CPTFloat(0.5);
    newGraph.plotAreaFrame.paddingBottom   = self.titleSize * CPTFloat(1.25);
    newGraph.plotAreaFrame.paddingLeft     = self.titleSize * CPTFloat(1.5);
    newGraph.plotAreaFrame.masksToBorder   = NO;
    
    
    [newGraph applyTheme:[CPTTheme themeNamed:kCPTStocksTheme]];
    
    
    // Axes
    CPTXYAxisSet *xyAxisSet = (CPTXYAxisSet *)newGraph.axisSet;
    CPTXYAxis *xAxis        = xyAxisSet.xAxis;
    xAxis.majorIntervalLength   = CPTDecimalFromDouble(oneDay);
    xAxis.minorTicksPerInterval = 0;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = refDate;
    xAxis.labelFormatter        = timeFormatter;
    
    
    CPTLineCap *lineCap = [[CPTLineCap alloc] init];
    lineCap.lineStyle    = xAxis.axisLineStyle;
    lineCap.lineCapType  = CPTLineCapTypeSweptArrow;
    lineCap.size         = CGSizeMake( self.titleSize * CPTFloat(0.5), self.titleSize * CPTFloat(0.625) );
    lineCap.fill         = [CPTFill fillWithColor:xAxis.axisLineStyle.lineColor];
    xAxis.axisLineCapMax = lineCap;
    
    
    CPTXYAxis *yAxis = xyAxisSet.yAxis;
    yAxis.orthogonalCoordinateDecimal = CPTDecimalFromDouble(-0.5 * oneDay);
    
    // Line plot with gradient fill
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] initWithFrame:newGraph.bounds];
    dataSourceLinePlot.identifier    = @"Data Source Plot";
    dataSourceLinePlot.title         = @"Close Values";
    dataSourceLinePlot.dataLineStyle = nil;
    dataSourceLinePlot.dataSource    = self;
    [newGraph addPlot:dataSourceLinePlot];
    
    
    CPTColor *areaColor       = [CPTColor colorWithComponentRed:CPTFloat(1.0) green:CPTFloat(1.0) blue:CPTFloat(1.0) alpha:CPTFloat(0.6)];
    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
    areaGradient.angle = -90.0;
    CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
    dataSourceLinePlot.areaFill      = areaGradientFill;
    dataSourceLinePlot.areaBaseValue = CPTDecimalFromDouble(0.0);
    
    areaColor                         = [CPTColor colorWithComponentRed:CPTFloat(0.0) green:CPTFloat(1.0) blue:CPTFloat(0.0) alpha:CPTFloat(0.6)];
    areaGradient                      = [CPTGradient gradientWithBeginningColor:[CPTColor clearColor] endingColor:areaColor];
    areaGradient.angle                = -90.0;
    areaGradientFill                  = [CPTFill fillWithGradient:areaGradient];
    dataSourceLinePlot.areaFill2      = areaGradientFill;
    dataSourceLinePlot.areaBaseValue2 = CPTDecimalFromDouble(5.0);
    
    CPTMutableShadow *whiteShadow = [CPTMutableShadow shadow];
    whiteShadow.shadowOffset     = CGSizeMake(2.0, -2.0);
    whiteShadow.shadowBlurRadius = 4.0;
    whiteShadow.shadowColor      = [CPTColor whiteColor];
    
    // OHLC plot
    CPTMutableLineStyle *whiteLineStyle = [CPTMutableLineStyle lineStyle];
    whiteLineStyle.lineColor = [CPTColor whiteColor];
    whiteLineStyle.lineWidth = 1.0;
    CPTTradingRangePlot *ohlcPlot = [[CPTTradingRangePlot alloc] initWithFrame:newGraph.bounds];
    ohlcPlot.identifier = @"OHLC";
    ohlcPlot.lineStyle  = whiteLineStyle;
    CPTMutableTextStyle *whiteTextStyle = [CPTMutableTextStyle textStyle];
    whiteTextStyle.color     = [CPTColor whiteColor];
    ohlcPlot.labelTextStyle  = whiteTextStyle;
    ohlcPlot.labelOffset     = 0.0;
    ohlcPlot.barCornerRadius = 3.0;
    ohlcPlot.barWidth        = 15.0;
    ohlcPlot.increaseFill    = [CPTFill fillWithColor:[CPTColor greenColor]];
    ohlcPlot.decreaseFill    = [CPTFill fillWithColor:[CPTColor redColor]];
    ohlcPlot.dataSource      = self;
    ohlcPlot.delegate        = self;
    ohlcPlot.plotStyle       = CPTTradingRangePlotStyleCandleStick;
    ohlcPlot.shadow          = whiteShadow;
    ohlcPlot.labelShadow     = whiteShadow;
    [newGraph addPlot:ohlcPlot];
    
    // Add legend
    newGraph.legend                    = [CPTLegend legendWithGraph:newGraph];
    newGraph.legend.textStyle          = xAxis.titleTextStyle;
    newGraph.legend.fill               = newGraph.plotAreaFrame.fill;
    newGraph.legend.borderLineStyle    = newGraph.plotAreaFrame.borderLineStyle;
    newGraph.legend.cornerRadius       = 5.0;
    newGraph.legend.swatchCornerRadius = 5.0;
    newGraph.legendAnchor              = CPTRectAnchorBottom;
    newGraph.legendDisplacement        = CGPointMake( 0.0, self.titleSize * CPTFloat(3.0) );
    
    // Set plot ranges
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-0.5 * oneDay) length:CPTDecimalFromDouble(oneDay * 10)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(0) length:CPTDecimalFromInteger(4)];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return self.plotData.count;
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSDecimalNumber *num = [NSDecimalNumber zero];
    
    if ( [plot.identifier isEqual:@"Data Source Plot"] ) {
        switch ( fieldEnum ) {
            case CPTScatterPlotFieldX:
                num = self.plotData[index][@(CPTTradingRangePlotFieldX)];
                break;
                
            case CPTScatterPlotFieldY:
                num = self.plotData[index][@(CPTTradingRangePlotFieldClose)];
                break;
                
            default:
                break;
        }
    }
    else {
        num = self.plotData[index][@(fieldEnum)];
    }
    return num;
}


@end

