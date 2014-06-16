//
//  JGFViewController.m
//  Flying witch
//
//  Created by José Gabriel Ferrer on 01/06/14.
//  Copyright (c) 2014 José Gabriel Ferrer. All rights reserved.
//

#import "JGFViewController.h"
#import "JGFMyScene.h"

@interface JGFViewController ()

@end

@implementation JGFViewController


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    //skView.showsFPS = YES;
    //skView.showsNodeCount = YES;
    //skView.showsPhysics = YES;
    
    // Create and configure the scene.
    SKScene * scene = [JGFMyScene sceneWithSize:CGSizeMake(skView.bounds.size.width,skView.bounds.size.height)];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
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

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


@end
