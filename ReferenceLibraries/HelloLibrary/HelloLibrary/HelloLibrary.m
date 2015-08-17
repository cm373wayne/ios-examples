//
//  HelloLibrary.m
//  HelloLibrary
//
//  Created by macmini03 on 2015/8/12.
//  Copyright (c) 2015年 macmini03. All rights reserved.
//

#import "HelloLibrary.h"

@implementation HelloLibrary

+ (NSString *)helloFunc{
    NSString *string1 = [NSString stringWithFormat:@"A string: %@, a float: %1.2f",
                         @"試用次數已滿", 31415.9265];
    return string1;
}

@end
