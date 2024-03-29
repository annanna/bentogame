//
//  Boxes.m
//  BentoGame
//
//  Created by Anna on 01.07.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

#import "Boxes.h"
#import "BentoBox.h"

@interface Boxes()
@property (nonatomic) NSMutableArray* boxes;
@end

@implementation Boxes


- (instancetype)init:(int)boxCount
{
    self = [super init];
    if (self) {
        self.boxes = [[NSMutableArray alloc]init];
        for (int i=0; i<boxCount; i++) {
            [self.boxes addObject:[[BentoBox alloc]init]];
        }
    }
    return self;
}

- (BOOL)addFood:(int)foodItem atIndex:(int)index{
    BentoBox* box = [self.boxes objectAtIndex:index];
    BOOL wasInserted = [box addFood:foodItem];
    return wasInserted;
}

- (BOOL)boxAtIndexIsFull:(int)index {
    BentoBox* box = [self.boxes objectAtIndex:index];
    BOOL boxIsFullNow = [box isFull];
    
    return boxIsFullNow;
}

- (int)addFoodSomewhere:(int)foodItem {
    
    for (int i=0; i<_boxes.count; i++) {
        BentoBox* box = _boxes[i];
        BOOL wasInserted = [box addFood:foodItem];
        if (wasInserted) {
            return i;
        }
    }
    return -1;
}

@end
