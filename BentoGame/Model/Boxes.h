//
//  Boxes.h
//  BentoGame
//
//  Created by Anna on 01.07.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Boxes : NSObject
- (instancetype)init:(int)boxCount;
- (BOOL)addFood:(int)foodItem atIndex:(int)index;
- (int)addFoodSomewhere:(int)foodItem;
- (BOOL)boxAtIndexIsFull:(int)index;
@end
