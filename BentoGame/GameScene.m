//
//  GameScene.m
//  BentoGame
//
//  Created by Anna on 01.07.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

#import "GameScene.h"


@interface GameScene ()
@property (nonatomic) NSTimeInterval lastCreationTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@end

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    
    
    /* Setup your scene here */
}

-(void)addFood {
    
    NSArray *foodObjects = [NSArray arrayWithObjects:@"circle", @"rectangle", @"triangle", nil];
    int randomVal = arc4random() % 3;
    
    
    // Create sprite
    SKSpriteNode *foodItem = [SKSpriteNode spriteNodeWithImageNamed:foodObjects[randomVal]];
    
    // position
    int minX = foodItem.size.width / 2;
    int maxX = self.frame.size.width - foodItem.size.width / 2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    
    foodItem.position = CGPointMake(actualX, self.frame.size.height + foodItem.size.height/2);
    [self addChild:foodItem];
    
    
    // speed
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int actualDuration = (arc4random() & (maxDuration - minDuration)) + minDuration;
    
    // actions
    SKAction *actionMove = [SKAction moveTo:CGPointMake(actualX, -foodItem.size.height/2) duration:actualDuration];
    SKAction *actionMoveDone = [SKAction removeFromParent];
    [foodItem runAction:[SKAction sequence:@[actionMove, actionMoveDone]] completion:^{
        NSLog(@"out of screen");
    }];    
}

-(void)updateWithTimeSinceLastUpdate:(CFTimeInterval) timeSinceLast {
    self.lastCreationTimeInterval += timeSinceLast;
    if (self.lastCreationTimeInterval > 1) {
        self.lastCreationTimeInterval = 0;
        [self addFood];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    // Handle time delta:
    // if we drop below 60fps, we still want everything to move the same distance
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    
    if (timeSinceLast > 1) {
        // more than a second since the last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
}

@end
