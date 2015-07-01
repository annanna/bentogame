//
//  GameOverScene.m
//  BentoGame
//
//  Created by Anna on 01.07.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

#import "GameOverScene.h"
#import "GameScene.h"

@implementation GameOverScene

-(id)initWithSize:(CGSize)size playerWon:(BOOL)isWon withScore:(float)score {
    self = [super initWithSize:size];
    
    if (self) {
        float centerPoint = self.frame.size.width * 2/3 / 2;
        
        SKLabelNode *gameOverLabel = [SKLabelNode labelNodeWithText:@"Game Over"];
        gameOverLabel.fontSize = 42;
        gameOverLabel.position = CGPointMake(centerPoint, CGRectGetMidY(self.frame));
        if (isWon) {
            gameOverLabel.text = @"Game Won";
        }
        [self addChild:gameOverLabel];
        
        SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithText:[NSString stringWithFormat: @"You %@ %.f¥!",((isWon?@"earned":@"lost")),score]];
        scoreLabel.fontSize = 30;
        scoreLabel.position = CGPointMake(centerPoint, gameOverLabel.position.y - 150);
        [self addChild:scoreLabel];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    GameScene *breakoutGameScene = [[GameScene alloc] initWithSize:self.size];
    [self.view presentScene:breakoutGameScene];
}

@end
