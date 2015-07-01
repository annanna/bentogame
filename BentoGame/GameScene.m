//
//  GameScene.m
//  BentoGame
//
//  Created by Anna on 01.07.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

#import "GameScene.h"
#import "GameOverScene.h"

static const uint32_t stickCategory = 0x1 << 0;
static const uint32_t foodCategory = 0x1 << 1;
static NSString* stickCategoryName = @"stick";
static NSString* foodCategoryName = @"food";

@interface GameScene () <SKPhysicsContactDelegate>
@property (nonatomic) SKSpriteNode *sticks;
@property (nonatomic) float score;
@property (nonatomic) SKLabelNode *scoreLabel;
@property (nonatomic) NSTimeInterval lastCreationTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) float time;
@property (nonatomic) SKLabelNode *timeLabel;
@property (nonatomic) float actualScreenWidth;
@end

@implementation GameScene

float stickY = 100;

-(id)initWithSize:(CGSize)size {
    if (self == [super initWithSize:size]) {
        
        self.actualScreenWidth = size.width * 2/3;
        self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
        self.physicsWorld.contactDelegate = self;
        
        // create sticks and place them in the bottom left corner
        self.sticks = [SKSpriteNode spriteNodeWithImageNamed:@"sticks"];
        self.sticks.position = CGPointMake(self.sticks.frame.size.width/2, stickY);
        self.sticks.name = stickCategoryName;
        self.sticks.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.sticks.size];
        self.sticks.physicsBody.friction = 0.0f;
        self.sticks.physicsBody.restitution = 1.0f;
        self.sticks.physicsBody.linearDamping = 0.0f;
        self.sticks.physicsBody.allowsRotation = NO;
        self.sticks.physicsBody.dynamic = NO;
        
        self.sticks.physicsBody.categoryBitMask = stickCategory;
        self.sticks.physicsBody.contactTestBitMask = foodCategory;
        self.sticks.physicsBody.collisionBitMask = 0;
        
        [self addChild:self.sticks];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveSticks:) name:@"SliderChanged" object:nil];
        
        
        // create score label
        self.scoreLabel = [SKLabelNode labelNodeWithText:@"0¥"];
        self.scoreLabel.position = CGPointMake(self.actualScreenWidth + 100, CGRectGetMaxY(self.frame)-100);
        self.scoreLabel.fontColor = [UIColor whiteColor];
        self.scoreLabel.fontSize = 60;
        [self addChild:self.scoreLabel];
        
        // create timer
        self.time = 0.0;
        SKAction *wait = [SKAction waitForDuration:1];
        SKAction *performSelector = [SKAction performSelector:@selector(updateTimer) onTarget:self];
        SKAction *sequence = [SKAction sequence:@[performSelector, wait]];
        SKAction *repeat   = [SKAction repeatActionForever:sequence];
        [self runAction:repeat];
        // ...and timer label
        self.timeLabel = [SKLabelNode labelNodeWithText:@"00:00"];
        self.timeLabel.position = CGPointMake(self.actualScreenWidth + 100, CGRectGetMaxY(self.frame)-200);
        self.timeLabel.fontColor = [UIColor whiteColor];
        self.timeLabel.fontSize = 50;
        [self addChild:self.timeLabel];
    }
    return self;
}

-(void)didBeginContact:(SKPhysicsContact*)contact {
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & stickCategory) != 0 && (secondBody.categoryBitMask & foodCategory) != 0) {
        [self stick:(SKSpriteNode *) firstBody.node didCollideWithFood:(SKSpriteNode *) secondBody.node];
    }
}

-(void)stick:(SKSpriteNode *)stick didCollideWithFood:(SKSpriteNode *)foodItem {
    NSLog(@"kollidiert");
    [foodItem removeFromParent];
}

-(void)addFood {
    
    NSArray *foodObjects = [NSArray arrayWithObjects:@"circle", @"rectangle", @"triangle", nil];
    int randomVal = arc4random() % 3;
    
    
    // Create sprite
    SKSpriteNode *foodItem = [SKSpriteNode spriteNodeWithImageNamed:foodObjects[randomVal]];
    
    // position
    int minX = foodItem.size.width / 2;
    int maxX = self.actualScreenWidth - foodItem.size.width / 2;
    int actualX = (arc4random() % (maxX - minX)) + minX;
    
    foodItem.position = CGPointMake(actualX, self.frame.size.height + foodItem.size.height/2);
    foodItem.name = foodCategoryName;
    foodItem.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:foodItem.size];
    foodItem.physicsBody.dynamic = YES;
    foodItem.physicsBody.categoryBitMask = foodCategory;
    foodItem.physicsBody.contactTestBitMask = stickCategory;
    foodItem.physicsBody.collisionBitMask = 0;
    
    [self addChild:foodItem];
    
    
    // speed
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int actualDuration = (arc4random() & (maxDuration - minDuration)) + minDuration;
    
    // actions
    SKAction *actionMove = [SKAction moveTo:CGPointMake(actualX, -foodItem.size.height/2) duration:actualDuration];
    SKAction *actionMoveDone = [SKAction removeFromParent];
    [foodItem runAction:[SKAction sequence:@[actionMove, actionMoveDone]] completion:^{
        [self updateScore:-300];
    }];    
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

-(void)updateWithTimeSinceLastUpdate:(CFTimeInterval) timeSinceLast {
    self.lastCreationTimeInterval += timeSinceLast;
    if (self.lastCreationTimeInterval > 1) {
        self.lastCreationTimeInterval = 0;
        [self addFood];
    }
}

-(void)updateScore:(float)difference{
    self.score += difference;
    self.scoreLabel.text = [NSString stringWithFormat:@"%.f¥", self.score];
    
    /*if ((self.score < -600) || (self.time >= 120.0)) {
        BOOL gameWon = (self.score < -600) ? NO : YES;
        
        GameOverScene *gameOverScene = [[GameOverScene alloc] initWithSize:self.frame.size playerWon:gameWon];
        [self.view presentScene:gameOverScene];
    }*/
}

-(void)updateTimer {
    self.time++;
    float seconds = self.time;
    int minutes = floor(seconds / 60);
    for (int i=0; i<minutes; i++) {
        seconds -= 60;
    }
    
    self.timeLabel.text = [NSString stringWithFormat:@"0%i:%02.f", minutes, seconds];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
}

-(void)moveSticks:(NSNotification *)notification {
    UISlider *slider = notification.object;
    float stickWidth = self.sticks.frame.size.width;
    float newStickX = stickWidth/2 + (self.actualScreenWidth - stickWidth) * slider.value;
    self.sticks.position = CGPointMake(newStickX, stickY);
}



@end
