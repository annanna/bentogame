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
    if (_hasTriangle && _hasCircle && _hasRectangle) {
        [self reset];
        return YES;
    }
    return NO;
}

- (BOOL) addFood: (int)food {
    switch (food) {
        case 0:
            if (!_hasCircle) {
                _hasCircle = YES;
                return YES;
            }
            break;
        case 1:
            if (!_hasTriangle) {
                _hasTriangle = YES;
                return YES;
            }
            break;
        case 2:
            if (!_hasRectangle) {
                _hasRectangle = YES;
                return YES;
            }
            break;
        default:
            break;
    }
    return NO;
}

- (void) reset
{
    _hasCircle = NO;
    _hasTriangle = NO;
    _hasRectangle = NO;
}

@end
