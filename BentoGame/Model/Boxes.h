//
//  Boxes.h
//  BentoGame
//
//  Created by Anna on 01.07.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Boxes : NSObject
- (id)init:(int)boxCount;
- (BOOL)addFood:(int)foodItem atIndex:(int)index;
- (BOOL)boxAtIndexIsFull:(int)index;
@property (nonatomic) int archivedBoxes;
@end
