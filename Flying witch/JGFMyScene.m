//
//  JGFMyScene.m
//  Flying witch
//
//  Created by José Gabriel Ferrer on 01/06/14.
//  Copyright (c) 2014 José Gabriel Ferrer. All rights reserved.
//

#import "JGFMyScene.h"
#import "SKBlade.h"

#define TIME 1.5

@interface JGFMyScene() <SKPhysicsContactDelegate>
{
    NSTimeInterval _dt;
    float bottomScrollerHeight;
}
@property (nonatomic) SKSpriteNode* bg1;
@property (nonatomic) SKSpriteNode* bg2;


@property (nonatomic) SKSpriteNode* backgroundImageNode;
@property (nonatomic) SKSpriteNode* player;
@property (nonatomic) NSArray* playerFlyingFrames;

@property (nonatomic) float BG_VEL;

@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@end

@implementation JGFMyScene
{
    // This will help us to easily access our blade
    SKBlade *blade;
    
    // This will help us to update the position of the blade
    CGPoint _delta;
}

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        
        _BG_VEL = (TIME*60);
        
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
    _bg1 = [SKSpriteNode spriteNodeWithImageNamed:@"background.png"];
    _bg1.anchorPoint = CGPointZero;
    _bg1.position = CGPointMake(0, 0);
    [self addChild:_bg1];
    
    _bg2 = [SKSpriteNode spriteNodeWithImageNamed:@"background.png"];
    _bg2.anchorPoint = CGPointZero;
    _bg2.position = CGPointMake(_bg1.size.width-1, 0);
    [self addChild:_bg2];
}

- (void)moveBackground
{
    _bg1.position = CGPointMake(_bg1.position.x-(_BG_VEL/60), _bg1.position.y);
    _bg2.position = CGPointMake(_bg2.position.x-(_BG_VEL/60), _bg2.position.y);
    
    if (_bg1.position.x < -_bg1.size.width){
        _bg1.position = CGPointMake(_bg2.position.x + _bg2.size.width, _bg1.position.y);
    }
    
    if (_bg2.position.x < -_bg2.size.width) {
        _bg2.position = CGPointMake(_bg1.position.x + _bg1.size.width, _bg2.position.y);
    }
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
    
    // Here we add the _delta value to our blade position
    blade.position = CGPointMake(blade.position.x + _delta.x, blade.position.y + _delta.y);
    
    // it's important to reset _delta at this point,
    // we are telling our blade to only update his position when touchesMoved is called
    _delta = CGPointZero;
    
    [self moveBackground];
    
}

#pragma mark - SKBlade Functions

// This will help us to initialize our blade
- (void)presentBladeAtPosition:(CGPoint)position
{
    blade = [[SKBlade alloc] initWithPosition:position
                                   TargetNode:self
                                        Color:[UIColor whiteColor]];
    
    [self addChild:blade];
}

// This will help us to remove our blade and reset the _delta value
- (void)removeBlade
{
    _delta = CGPointZero;
    [blade removeFromParent];
}

#pragma mark - Touch Events

// initialize the blade at touch location

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint _touchLocation = [[touches anyObject] locationInNode:self];
    [self presentBladeAtPosition:_touchLocation];
}

// _delta value will help us later to properly update our blade position,
// We calculate the diference between currentPoint and previousPosition and store that value in _delta

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint _currentPoint = [[touches anyObject] locationInNode:self];
    CGPoint _previousPoint = [[touches anyObject] previousLocationInNode:self];
    
    _delta = CGPointMake(_currentPoint.x - _previousPoint.x, _currentPoint.y - _previousPoint.y);
}

// Remove the Blade if the touches have been cancelled or ended

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self removeBlade];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self removeBlade];
}


@end
