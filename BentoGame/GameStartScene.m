//
//  GameStartScene.m
//  BentoGame
//
//  Created by Anna on 03.07.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

#import "GameStartScene.h"
#import "GameScene.h"

@implementation GameStartScene

-(id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    
    if (self) {
        SKLabelNode *gameLabel = [SKLabelNode labelNodeWithText:@"Bentogame"];
        gameLabel.fontSize = 50;
        gameLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 100);
        [self addChild:gameLabel];
        
        SKLabelNode *easyGameLabel = [SKLabelNode labelNodeWithText:@"Start Easy Game"];
        easyGameLabel.fontSize = 30;
        easyGameLabel.position = CGPointMake(CGRectGetMidX(self.frame), gameLabel.position.y - 150);
        easyGameLabel.name = @"easy";
        [self addChild:easyGameLabel];
        
        SKLabelNode *easyGameExplanationLabel = [SKLabelNode labelNodeWithText:@"(Sushi will be put automatically in boxes.)"];
        easyGameExplanationLabel.fontSize = 20;
        easyGameExplanationLabel.position = CGPointMake(CGRectGetMidX(self.frame), easyGameLabel.position.y - 50);
        easyGameExplanationLabel.name = @"hard";
        [self addChild:easyGameExplanationLabel];
        
        SKLabelNode *hardGameLabel = [SKLabelNode labelNodeWithText:@"Start Advanced Game"];
        hardGameLabel.fontSize = 30;
        hardGameLabel.position = CGPointMake(CGRectGetMidX(self.frame), easyGameExplanationLabel.position.y - 100);
        hardGameLabel.name = @"hard";
        [self addChild:hardGameLabel];
        
        SKLabelNode *hardGameExplanationLabel = [SKLabelNode labelNodeWithText:@"(Put Sushi in boxes by tapping on the box. If it has space, it will go in!)"];
        hardGameExplanationLabel.fontSize = 20;
        hardGameExplanationLabel.position = CGPointMake(CGRectGetMidX(self.frame), hardGameLabel.position.y - 50);
        hardGameExplanationLabel.name = @"hard";
        [self addChild:hardGameExplanationLabel];

    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"easy"] || [node.name isEqualToString:@"hard"]) {
        BOOL easyMode = [node.name isEqualToString:@"easy"];
        GameScene *gameScene = [[GameScene alloc] initWithSize:self.size inEasyMode:easyMode];
        [self.view presentScene:gameScene];
    }
}

@end
