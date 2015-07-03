//
//  GameOverScene.h
//  BentoGame
//
//  Created by Anna on 01.07.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameOverScene : SKScene
-(instancetype)initWithSize:(CGSize)size playerWon:(BOOL)isWon withScore:(float)score;
@end
