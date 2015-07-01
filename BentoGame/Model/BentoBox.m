//
//  BentoBox.m
//  BentoGame
//
//  Created by Anna on 01.07.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

#import "BentoBox.h"

@interface BentoBox()
@property (nonatomic) BOOL hasCircle;
@property (nonatomic) BOOL hasTriangle;
@property (nonatomic) BOOL hasRectangle;
@end

@implementation BentoBox


- (BOOL) isFull
{
    if (self.hasTriangle && self.hasCircle && self.hasRectangle) {
        return YES;
    }
    return NO;
}

- (BOOL) addFood: (int)food {
    switch (food) {
        case 0:
            if (!self.hasCircle) {
                self.hasCircle = YES;
                return YES;
            }
            break;
        case 1:
            if (!self.hasTriangle) {
                self.hasTriangle = YES;
                return YES;
            }
            break;
        case 2:
            if (!self.hasRectangle) {
                self.hasRectangle = YES;
                return YES;
            }
            break;
        default:
            break;
    }
    return NO;
}

@end
