//
//  GameScene.m
//  BentoGame
//
//  Created by Anna on 01.07.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

#import "GameScene.h"
#import "GameOverScene.h"
#import "Boxes.h"

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
@property (nonatomic) Boxes *bentoBoxes;
@property (nonatomic) NSArray * hitTextures;
@property (nonatomic) SKSpriteNode* lastCaughtItem;
@end

@implementation GameScene

float stickY = 100;
-(NSArray *)hitTextures{
    if (_hitTextures == nil){
        SKTexture *hit1 = [SKTexture textureWithImageNamed:@"circle"];
        SKTexture *hit2 = [SKTexture textureWithImageNamed:@"triangle"];
        SKTexture *hit3 = [SKTexture textureWithImageNamed:@"rectangle"];
        
        _hitTextures = @[hit1, hit2, hit3];
    }
    return _hitTextures;
}

CGRect screenFrame, menuFrame;

// MARK: - Scene Setup

-(id)initWithSize:(CGSize)size {
    if (self == [super initWithSize:size]) {
        
        self.bentoBoxes = [[Boxes alloc] init:4];
        
        screenFrame = CGRectMake(0, 0, size.width*2/3, size.height);
        menuFrame = CGRectMake(size.width*2/3, 0, size.width*1/3, size.height);
        
        self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
        self.physicsWorld.contactDelegate = self;
        
        // create sticks and place them in the bottom left corner
        self.sticks = [SKSpriteNode spriteNodeWithImageNamed:@"sticks"];
        self.sticks.position = CGPointMake(self.sticks.frame.size.width/2, stickY);
        self.sticks.name = stickCategoryName;
        self.sticks.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.sticks.size.width/10 center:CGPointMake(0, -50)];
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
        self.scoreLabel.position = CGPointMake(menuFrame.origin.x + 100, CGRectGetMaxY(self.frame)-100);
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
        self.timeLabel.position = CGPointMake(menuFrame.origin.x + 100, CGRectGetMaxY(self.frame)-200);
        self.timeLabel.fontColor = [UIColor whiteColor];
        self.timeLabel.fontSize = 50;
        [self addChild:self.timeLabel];
        
        [self createBoxes];
    }
    return self;
}

-(void)createBoxes {
    float boxWidth = menuFrame.size.width/3;
    float boxHeight = boxWidth * 0.75;
    
    float padding = boxWidth/3;
    
    float xLeft = menuFrame.origin.x + padding + boxWidth / 2;
    float xRight = xLeft + boxWidth + padding;
    float yBottom = padding + boxHeight / 2;
    float yTop = yBottom + boxHeight + padding;
    
    SKSpriteNode *upperLeftBox = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(boxWidth, boxHeight)];
    upperLeftBox.position = CGPointMake(xLeft, yTop);
    upperLeftBox.name = @"Box0";
    [self addChild:upperLeftBox];
    
    SKSpriteNode *upperRightBox = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(boxWidth, boxHeight)];
    upperRightBox.position = CGPointMake(xRight, yTop);
    upperRightBox.name = @"Box1";
    [self addChild:upperRightBox];
    
    SKSpriteNode *lowerLeftBox = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(boxWidth, boxHeight)];
    lowerLeftBox.position = CGPointMake(xLeft, yBottom);
    lowerLeftBox.name = @"Box2";
    [self addChild:lowerLeftBox];
    
    SKSpriteNode *lowerRightBox = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(boxWidth, boxHeight)];
    lowerRightBox.position = CGPointMake(xRight, yBottom);
    lowerRightBox.name = @"Box3";
    [self addChild:lowerRightBox];
}

// MARK: - Screen Update

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
    if (self.lastCreationTimeInterval > 2) {
        self.lastCreationTimeInterval = 0;
        [self addFood];
    }
}

-(void)addFood {
    
    int randomVal = arc4random() % [self.hitTextures count];
    SKTexture* randomTexture = self.hitTextures[randomVal];
    SKSpriteNode* foodItem = [SKSpriteNode spriteNodeWithTexture:randomTexture];
    
    // position
    int minX = foodItem.size.width / 2;
    int maxX = screenFrame.size.width - foodItem.size.width / 2;
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

// MARK: - Actions

-(void)moveSticks:(NSNotification *)notification {
    UISlider *slider = notification.object;
    float stickWidth = self.sticks.frame.size.width;
    float newStickX = stickWidth/2 + (screenFrame.size.width - stickWidth) * slider.value;
    self.sticks.position = CGPointMake(newStickX, stickY);
}

- (UIColor *)generateNewBoxColor:(SKSpriteNode *)box index:(int)index {
    NSArray *colors = [[NSArray alloc] initWithObjects:
                       [UIColor colorWithRed:1 green:0 blue:0 alpha:1],
                       [UIColor colorWithRed:0 green:0 blue:1 alpha:1],
                       [UIColor colorWithRed:0 green:1 blue:0 alpha:1], nil];
    
    
    UIColor *boxColor = box.color;
    UIColor *itemColor = colors[index];
    
    CGFloat boxRed = 0.0, boxGreen = 0.0, boxBlue = 0.0, boxAlpha = 0.0;
    CGFloat itemRed = 0.0, itemGreen = 0.0, itemBlue = 0.0, itemAlpha = 0.0;
    
    [boxColor getRed:&boxRed green:&boxGreen blue:&boxBlue alpha:&boxAlpha];
    [itemColor getRed:&itemRed green:&itemGreen blue:&itemBlue alpha:&itemAlpha];
    
    CGFloat newRed = boxRed + itemRed;
    CGFloat newGreen = boxGreen + itemGreen;
    CGFloat newBlue = boxBlue + itemBlue;
    
    UIColor *newBoxColor = [UIColor colorWithRed:newRed green:newGreen blue:newBlue alpha:1];
    return newBoxColor;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    NSArray *nodes = [self nodesAtPoint:location];
    
    for (SKSpriteNode *node in nodes) {
        if ([node.name hasPrefix:@"Box"]) {
            
            if (self.lastCaughtItem) {
                
                
                NSString *indexString = [node.name substringWithRange:NSMakeRange(3,1)];
                int index = (int)[indexString doubleValue];
                
                int textureIndex = (int)[self.hitTextures indexOfObject:self.lastCaughtItem.texture];
                BOOL didAddFootItem = [self.bentoBoxes addFood:textureIndex atIndex:index];
                
                if (didAddFootItem) {
                    [self.lastCaughtItem removeFromParent];
                    self.lastCaughtItem = nil;
                    
                    BOOL boxIsFull = [self.bentoBoxes boxAtIndexIsFull:index];
                    if (boxIsFull) {
                        [self updateScore:1100];
                        node.color = [UIColor blackColor];
                        NSLog(@"Box %i was sold", index);
                    } else {
                        UIColor *newBoxColor = [self generateNewBoxColor:node index:textureIndex];
                        
                        node.color = newBoxColor;
                        NSLog(@"Added to box %i", index);
                    }
                } else {
                    NSLog(@"Could not be added!");
                }
            }
            
        }
    }
}

// MARK: - SKPhysicsContactDelegate

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
    if (self.lastCaughtItem) {
        [self.lastCaughtItem removeFromParent];
        [self updateScore:-300];
    }
    
    self.lastCaughtItem = foodItem;
    [foodItem removeAllActions];
}


// MARK: - Game Stuff

-(void)updateScore:(float)difference{
    self.score += difference;
    self.scoreLabel.text = [NSString stringWithFormat:@"%.f¥", self.score];
    
    if (self.score < 0) {
        self.scoreLabel.fontColor = [UIColor redColor];
    } else {
        self.scoreLabel.fontColor = [UIColor whiteColor];
    }
    
    if ((self.score < -600) || (self.time >= 120.0)) {
        BOOL gameWon = (self.score < -600) ? NO : YES;
        
        GameOverScene *gameOverScene = [[GameOverScene alloc] initWithSize:self.frame.size playerWon:gameWon withScore:self.score];
        [self.view presentScene:gameOverScene];
    }
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

@end
