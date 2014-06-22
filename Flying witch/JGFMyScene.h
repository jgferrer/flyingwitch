//
//  JGFMyScene.h
//  Flying witch
//

//  Copyright (c) 2014 José Gabriel Ferrer. All rights reserved.
//

#import "Common.h"
#import <AVFoundation/AVFoundation.h>
#import <SpriteKit/SpriteKit.h>
#import "JGFStar.h"

#define TIME 1.5

@interface JGFMyScene : SKScene <SKPhysicsContactDelegate>

@property (nonatomic) SKSpriteNode *bg1;
@property (nonatomic) SKSpriteNode *bg2;
@property (nonatomic) SKSpriteNode* backgroundImageNode;
@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;

@property (strong, nonatomic) SKLabelNode *scoreLabel;
@property (assign) double score;

@property (nonatomic) SKSpriteNode *player;
@property (nonatomic) NSArray* playerFlyingFrames;

@property (nonatomic) SKSpriteNode *enemy;
@property (nonatomic) NSArray* enemyFlyingFrames;

@property (nonatomic) NSArray* starAnimatedFrames;
@property (nonatomic) int numberOfStars;

@property (nonatomic) float BG_VEL;

@property (nonatomic) NSTimeInterval timeSinceLast;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;


@end
