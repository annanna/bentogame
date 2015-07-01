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


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.boxes = [[NSMutableArray alloc]init];
        self.archivedBoxes = 0;
    }
    return self;
}

- (BOOL)addFood:(int)foodItem {
    for (BentoBox *box in self.boxes) {
        BOOL wasInserted = [box addFood:foodItem];
        if (wasInserted) {
            BOOL boxIsFullNow = [box isFull];
            if (boxIsFullNow) {
                [self archiveBox:box];
                return YES;
            }
            return NO;
        }
    }
    BentoBox *newBox = [[BentoBox alloc]init];
    [newBox addFood:foodItem];
    [self.boxes addObject:newBox];
    
    return false;
}

- (void)archiveBox:(BentoBox *)box {
    self.archivedBoxes++;
    [self.boxes removeObject:box];
    NSLog(@"full box");
}


@end
