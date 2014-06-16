//
//  JGFMyScene.h
//  Flying witch
//

//  Copyright (c) 2014 José Gabriel Ferrer. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#define TIME 1.5

static const uint32_t playerCategory   = 0x1 << 0;
static const uint32_t enemyCategory    = 0x1 << 1;
static const uint32_t starCategory     = 0x1 << 2;

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

@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;

@end
