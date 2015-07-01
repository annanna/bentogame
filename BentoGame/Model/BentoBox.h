//
//  BentoBox.h
//  BentoGame
//
//  Created by Anna on 01.07.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BentoBox : NSObject
- (BOOL) addFood: (int)food;
- (BOOL) isFull;
@end
