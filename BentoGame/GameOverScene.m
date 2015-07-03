//
//  GameOverScene.m
//  BentoGame
//
//  Created by Anna on 01.07.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

#import "GameOverScene.h"
#import "GameStartScene.h"

@implementation GameOverScene

-(instancetype)initWithSize:(CGSize)size playerWon:(BOOL)isWon withScore:(float)score {
    self = [super initWithSize:size];
    
    if (self) {
        SKLabelNode *gameOverLabel = [SKLabelNode labelNodeWithText:@"Game Over"];
        gameOverLabel.fontSize = 42;
        gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        if (isWon) {
            gameOverLabel.text = @"Game Won";
        }
        [self addChild:gameOverLabel];
        
        SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithText:[NSString stringWithFormat: @"You %@ %.f¥!",((isWon?@"earned":@"lost")),score]];
        scoreLabel.fontSize = 30;
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), gameOverLabel.position.y - 150);
        [self addChild:scoreLabel];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    GameStartScene *startGameScene = [GameStartScene sceneWithSize:self.size];
    [self.view presentScene:startGameScene];
}

@end