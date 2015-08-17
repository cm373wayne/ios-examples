//
//  ViewController.h
//  HelloMainProj
//
//  Created by macmini03 on 2015/8/12.
//  Copyright (c) 2015年 macmini03. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>

#import "CorePlot-CocoaTouch.h"


typedef CGRect CGNSRect;
typedef UIView PlotGalleryNativeView;

@interface ViewController : UIViewController<CPTPlotDataSource>

@property (nonatomic, readwrite, strong) NSArray *plotData;

@end

