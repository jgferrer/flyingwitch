//
//  JGFMyScene.m
//  Flying witch
//
//  Created by José Gabriel Ferrer on 01/06/14.
//  Copyright (c) 2014 José Gabriel Ferrer. All rights reserved.
//

#import "JGFMyScene.h"

#define TIME 1.5
#define MINIMUM_PILLER_HEIGHT 50.0f
#define GAP_BETWEEN_TOP_AND_BOTTOM_PILLER 100.0f

#define UPWARD_PILLER @"Upward_Green_Pipe"
#define Downward_PILLER @"Downward_Green_Pipe"

static inline CGPoint CGPointAdd(const CGPoint a, const CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a, const CGFloat b)
{
    return CGPointMake(a.x * b, a.y * b);
}

@interface JGFMyScene() <SKPhysicsContactDelegate>
{
    NSTimeInterval _dt;
    float bottomScrollerHeight;
}
@property (nonatomic) SKSpriteNode* backgroundImageNode;
@property (nonatomic) SKSpriteNode* player;
@property (nonatomic) NSArray* playerFlyingFrames;

@property (nonatomic) float BG_VEL;

@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@end

@implementation JGFMyScene
{}

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        
        _BG_VEL = (TIME * 60);
        
        /* Setup your scene here */
        [self initalizingScrollingBackground];
        
        [self initializePlayer];
        
    }
    return self;
}

-(void)initializePlayer
{
    NSMutableArray *flyingFrames = [NSMutableArray array];
    SKTextureAtlas *playerAnimatedAtlas = [SKTextureAtlas atlasNamed:@"witch"];
    int numImages = playerAnimatedAtlas.textureNames.count;
    for (int i=0; i < numImages/2; i++) {
        NSString *textureName = [NSString stringWithFormat:@"%d", i];
        SKTexture *temp = [playerAnimatedAtlas textureNamed:textureName];
        [flyingFrames addObject:temp];
    }
    _playerFlyingFrames = flyingFrames;
    
    SKTexture *temp = _playerFlyingFrames[0];
    _player = [SKSpriteNode spriteNodeWithTexture:temp];
    
    //_player.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    _player.position = CGPointMake(30, CGRectGetMidY(self.frame));
    
    [self addChild:_player];
    [self flyingPlayer];
}


-(void)flyingPlayer
{
    //This is our general runAction method to make our bear walk.
    [_player runAction:[SKAction repeatActionForever:
                      [SKAction animateWithTextures:_playerFlyingFrames
                                       timePerFrame:0.07f
                                             resize:NO
                                            restore:YES]] withKey:@"FlyingInPlacePlayer"];
    return;
}

-(void)initalizingScrollingBackground
{
    for (int i = 0; i < 2; i++)
    {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"background.png"];
        bottomScrollerHeight = bg.size.height;
        bg.position = CGPointMake(i * bg.size.width, 0);
        bg.anchorPoint = CGPointZero;
        bg.name = @"bg";
        
        [self addChild:bg];
    }
}

- (void)moveBackground
{
    [self enumerateChildNodesWithName:@"bg" usingBlock: ^(SKNode *node, BOOL *stop)
     {
         SKSpriteNode * bg = (SKSpriteNode *) node;
         CGPoint bgVelocity = CGPointMake(-_BG_VEL, 0);
         CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity,_dt);
         bg.position = CGPointAdd(bg.position, amtToMove);
         
         //Checks if bg node is completely scrolled of the screen, if yes then put it at the end of the other node
         if (bg.position.x <= -bg.size.width)
         {
             bg.position = CGPointMake(bg.position.x + bg.size.width*2,
                                       bg.position.y);
         }
         
         [bg removeFromParent];
         [self addChild:bg];        //Ordering is not possible. so this is a hack
         _player.zPosition = bg.zPosition + 1;
     }];
}

- (void)update:(NSTimeInterval)currentTime
{
    if (self.lastUpdateTimeInterval)
    {
        _dt = currentTime - _lastUpdateTimeInterval;
    }
    else
    {
        _dt = 0;
    }
    //CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    
    [self moveBackground];
    
}

@end
