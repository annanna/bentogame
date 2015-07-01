//
//  GameViewController.m
//  BentoGame
//
//  Created by Anna on 01.07.15.
//  Copyright (c) 2015 Anna Muenster. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;
    
    // Create and configure the scene.
    GameScene *scene = [GameScene sceneWithSize:skView.frame.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
    
    CGRect menuFrame = CGRectMake(self.view.frame.size.width * 2/3, 0, self.view.frame.size.width * 1/3, self.view.frame.size.height);
    UIView *menuOverlay = [[UIView alloc] initWithFrame:menuFrame];
    menuOverlay.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    [self.view addSubview:menuOverlay];
    
    
    // create slider
    CGRect frame = CGRectMake(0, CGRectGetMidY(menuOverlay.frame), menuOverlay.frame.size.width, 100);
    UISlider *slider = [[UISlider alloc] initWithFrame:frame];
    [slider setBackgroundColor:[UIColor clearColor]];
    slider.minimumValue = 0.0;
    slider.maximumValue = 1.0;
    slider.value = 0.0;
    slider.continuous = YES;
    [slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [menuOverlay addSubview:slider];
}

- (void)sliderChanged:(UISlider*)slider {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SliderChanged" object:slider];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
