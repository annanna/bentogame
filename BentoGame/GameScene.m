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
#import "GameViewController.h"

static const uint32_t stickCategory = 0x1 << 0;
static const uint32_t foodCategory = 0x1 << 1;
static NSString* stickCategoryName = @"stick";
static NSString* foodCategoryName = @"food";

@interface GameScene () <SKPhysicsContactDelegate>
@property (nonatomic) CGRect gameFrame;
@property (nonatomic) CGRect menuFrame;
@property (nonatomic) SKSpriteNode *sticks;
@property (nonatomic) float score;
@property (nonatomic) SKLabelNode *scoreLabel;
@property (nonatomic) NSTimeInterval lastCreationTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) float time;
@property (nonatomic) SKLabelNode *timeLabel;
@property (nonatomic) Boxes *bentoBoxes;
@property (nonatomic) NSMutableArray* bentoBoxArrays;
@property (nonatomic) NSArray * foodTextures;
@property (nonatomic) SKSpriteNode* lastCaughtItem;
@property (nonatomic) UIView* menuOverlay;
@property (nonatomic) UISlider* stickSlider;
@property (nonatomic) BOOL easyMode;
@end

@implementation GameScene

float stickY = 100;
-(NSArray *)foodTextures{
    if (_foodTextures == nil){
        SKTexture *hit1 = [SKTexture textureWithImageNamed:@"circle"];
        SKTexture *hit2 = [SKTexture textureWithImageNamed:@"triangle"];
        SKTexture *hit3 = [SKTexture textureWithImageNamed:@"rectangle"];
        
        _foodTextures = @[hit1, hit2, hit3];
    }
    return _foodTextures;
}

// MARK: - Scene Setup

-(instancetype)initWithSize:(CGSize)size inEasyMode:(BOOL)easy {
    if (self == [super initWithSize:size]) {
        
        _easyMode = easy;
        
        float screenWidth = size.width;
        float screenHeight = size.height;
        _gameFrame = CGRectMake(0, 0, screenWidth*2/3, screenHeight);
        _menuFrame = CGRectMake(screenWidth*2/3, 0, screenWidth*1/3, screenHeight);
        
        self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
        self.physicsWorld.contactDelegate = self;
        
        [self createSticks];
        [self createGameLabels];
        [self createBoxes];
    }
    return self;
}

- (void) didMoveToView:(SKView *)view {
    _menuOverlay = [[UIView alloc] initWithFrame:_menuFrame];
    _menuOverlay.backgroundColor = [UIColor colorWithRed:1 green:1 blue:0.8 alpha:0.1];
    [self.view addSubview:_menuOverlay];
    
    // create slider
    CGRect frame = CGRectMake(0, CGRectGetMidY(_menuOverlay.frame), _menuFrame.size.width, 100);
    _stickSlider = [[UISlider alloc] initWithFrame:frame];
    [_stickSlider setBackgroundColor:[UIColor clearColor]];
    _stickSlider.minimumValue = 0.0;
    _stickSlider.maximumValue = 1.0;
    _stickSlider.value = 0.0;
    _stickSlider.continuous = YES;
    [_stickSlider addTarget:self action:@selector(moveSticks:) forControlEvents:UIControlEventValueChanged];
    [_menuOverlay addSubview:_stickSlider];
}

- (void)createSticks {
    
    // create sticks and place them in the bottom left corner
    _sticks = [SKSpriteNode spriteNodeWithImageNamed:@"sticks"];
    _sticks.position = CGPointMake(_sticks.frame.size.width/2, stickY);
    _sticks.name = stickCategoryName;
    _sticks.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_sticks.size.width/10 center:CGPointMake(0, -50)];
    _sticks.physicsBody.friction = 0.0f;
    _sticks.physicsBody.restitution = 1.0f;
    _sticks.physicsBody.linearDamping = 0.0f;
    _sticks.physicsBody.allowsRotation = NO;
    _sticks.physicsBody.dynamic = NO;
    
    _sticks.physicsBody.categoryBitMask = stickCategory;
    _sticks.physicsBody.contactTestBitMask = foodCategory;
    _sticks.physicsBody.collisionBitMask = 0;
    
    [self addChild:_sticks];
}

- (void)createGameLabels {
    
    // create score label
    _scoreLabel = [SKLabelNode labelNodeWithText:@"0¥"];
    _scoreLabel.position = CGPointMake(CGRectGetMidX(_menuFrame), CGRectGetMaxY(self.frame)-100);
    _scoreLabel.fontColor = [UIColor whiteColor];
    _scoreLabel.fontSize = 60;
    [self addChild:_scoreLabel];
    
    // create timer
    _time = 0.0;
    SKAction *wait = [SKAction waitForDuration:1];
    SKAction *performSelector = [SKAction performSelector:@selector(updateTimer) onTarget:self];
    SKAction *sequence = [SKAction sequence:@[performSelector, wait]];
    SKAction *repeat   = [SKAction repeatActionForever:sequence];
    [self runAction:repeat];
    // ...and timer label
    _timeLabel = [SKLabelNode labelNodeWithText:@"00:00"];
    _timeLabel.position = CGPointMake(CGRectGetMidX(_menuFrame), CGRectGetMaxY(self.frame)-200);
    _timeLabel.fontColor = [UIColor whiteColor];
    _timeLabel.fontSize = 50;
    [self addChild:_timeLabel];
}

-(void)createBoxes {
    float boxWidth = _menuFrame.size.width/3;
    float boxHeight = boxWidth * 0.75;
    
    float padding = boxWidth/3;
    
    float xLeft = _menuFrame.origin.x + padding + boxWidth / 2;
    float xRight = xLeft + boxWidth + padding;
    float yBottom = padding + boxHeight / 2;
    float yTop = yBottom + boxHeight + padding;
    
    NSArray *boxPositions = [[NSArray alloc] initWithObjects:
                             [NSValue valueWithCGPoint: CGPointMake(xLeft, yTop)], //upper left
                             [NSValue valueWithCGPoint:CGPointMake(xRight, yTop)], // upper right
                             [NSValue valueWithCGPoint:CGPointMake(xLeft, yBottom)], // lower left
                             [NSValue valueWithCGPoint:CGPointMake(xRight, yBottom)], // lower right
                             nil];
    
    const int numberOfBoxes = (int)[boxPositions count];
    _bentoBoxArrays = [NSMutableArray array];
    
    for (int i=0; i<numberOfBoxes; i++) {
        SKSpriteNode *newBox = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(boxWidth, boxHeight)];
        NSValue *positionVal = [boxPositions objectAtIndex:i];
        newBox.position = [positionVal CGPointValue];
        newBox.name = [NSString stringWithFormat:@"Box%i", i];
        [self addChild:newBox];
        [_bentoBoxArrays addObject:newBox];
    }
    _bentoBoxes = [[Boxes alloc]init:numberOfBoxes];
}

-(void)addFood {
    int randomVal = arc4random() % [self.foodTextures count];
    SKTexture* randomTexture = self.foodTextures[randomVal];
    SKSpriteNode* foodItem = [SKSpriteNode spriteNodeWithTexture:randomTexture];
    
    // position
    int padding = 30;
    int minX = foodItem.size.width / 2 + padding;
    int maxX = _gameFrame.size.width - foodItem.size.width / 2 - padding;
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
        [self updateScore:-300]; // food was not caught with sticks
    }];
}

// MARK: - Screen Update
// learned at http://www.raywenderlich.com/42699/spritekit-tutorial-for-beginners

/* will be called by SpriteKit before each frame is rendered  */
-(void)update:(CFTimeInterval)currentTime {
    // Handle time delta:
    // if we drop below 60fps, we still want everything to move the same distance
    CFTimeInterval timeSinceLast = currentTime - _lastUpdateTimeInterval;
    _lastUpdateTimeInterval = currentTime;
    
    if (timeSinceLast > 1) {
        // more than a second since the last update
        timeSinceLast = 1.0 / 60.0;
        _lastUpdateTimeInterval = currentTime;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
}

/** will be called every frame with the time since the last update */
/* time since the last update is added */
/* if it is greater than a second, a food-item is added **/
-(void)updateWithTimeSinceLastUpdate:(CFTimeInterval) timeSinceLast {
    _lastCreationTimeInterval += timeSinceLast;
    if (_lastCreationTimeInterval > 2) {
        _lastCreationTimeInterval = 0;
        [self addFood];
    }
}

// MARK: - Actions

-(void)moveSticks:(UISlider *)slider {
    float stickWidth = _sticks.frame.size.width;
    // calculate new position so that stick does not leave screenFrame
    float newStickX = stickWidth/2 + (_gameFrame.size.width - stickWidth) * slider.value;
    _sticks.position = CGPointMake(newStickX, stickY);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (!_easyMode) {
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInNode:self];
        NSArray *nodes = [self nodesAtPoint:location];
        
        for (SKSpriteNode *node in nodes) {
            if ([node.name hasPrefix:@"Box"]) {
                
                if (_lastCaughtItem) {
                    
                    NSString *indexString = [node.name substringWithRange:NSMakeRange(3,1)];
                    int boxIndex = (int)[indexString doubleValue];
                    [self handleBoxPutting:_lastCaughtItem inBox:boxIndex];
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

    if (_easyMode) {
        [foodItem removeAllActions];        
        [self handleBoxPutting:foodItem inBox:-1];
        [foodItem removeFromParent];
        
    } else {
        _stickSlider.userInteractionEnabled = NO;
    
        if (!_lastCaughtItem) {
            [foodItem removeAllActions];
            _lastCaughtItem = foodItem;
        }
    }
}

// MARK: - Game Stuff

-(void)updateScore:(float)difference{
    _score += difference;
    _scoreLabel.text = [NSString stringWithFormat:@"%.f¥", _score];
    
    if (_score < 0) {
        _scoreLabel.fontColor = [UIColor redColor];
    } else {
        _scoreLabel.fontColor = [UIColor whiteColor];
    }
    
    if ((_score < -600) || (_time >= 120.0)) {
        BOOL gameWon = (_score < -600) ? NO : YES;
        _menuOverlay.hidden = YES;
        GameOverScene *gameOverScene = [[GameOverScene alloc] initWithSize:self.frame.size playerWon:gameWon withScore:_score];
        [self.view presentScene:gameOverScene];
    }
}

-(void)updateTimer {
    _time++;
    float seconds = _time;
    int minutes = floor(seconds / 60);
    for (int i=0; i<minutes; i++) {
        seconds -= 60;
    }
    
    _timeLabel.text = [NSString stringWithFormat:@"0%i:%02.f", minutes, seconds];
}

- (void)handleBoxPutting:(SKSpriteNode*)foodItem inBox:(int)boxIndex {
    int foodIndex = (int) [self.foodTextures indexOfObject:foodItem.texture];
    BOOL didAddFoodItem = NO;
    if (_easyMode) {
        boxIndex = [_bentoBoxes addFoodSomewhere:foodIndex];
        if (boxIndex >= 0) {
            didAddFoodItem = YES;
            //[self showInBox:boxIndex foodIndex:foodIndex];
        } else {
            NSLog(@"all boxes are full");
        }
    } else {
        didAddFoodItem = [_bentoBoxes addFood:foodIndex atIndex:boxIndex];
    }
    
    if (didAddFoodItem) {
        [self showInBox:boxIndex foodIndex:foodIndex];
        
        [foodItem removeFromParent];
        if (!_easyMode) {
            _stickSlider.userInteractionEnabled = YES;
            _lastCaughtItem = nil;
        }
    }
}

- (void)showInBox:(int)boxIndex foodIndex:(int)foodIndex {
    
    SKSpriteNode* box = [_bentoBoxArrays objectAtIndex:boxIndex];
    BOOL boxIsFull = [_bentoBoxes boxAtIndexIsFull:boxIndex];
    if (boxIsFull) {
        [self updateScore:1100];
        box.color = [UIColor blackColor];
        NSLog(@"Box %i was sold", boxIndex);
    } else {
        UIColor *newBoxColor = [self generateNewBoxColor:box index:foodIndex];
        box.color = newBoxColor;
    }
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

@end
