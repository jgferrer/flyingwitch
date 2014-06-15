//
//  JGFMyScene.m
//  Flying witch
//
//  Created by José Gabriel Ferrer on 01/06/14.
//  Copyright (c) 2014 José Gabriel Ferrer. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "JGFMyScene.h"
#import "SKBlade.h"

#define TIME 1.5

static const uint32_t playerCategory   = 0x1 << 0;
static const uint32_t enemyCategory    = 0x1 << 1;
static const uint32_t starCategory     = 0x1 << 2;

@interface JGFMyScene() <SKPhysicsContactDelegate>
{
    NSTimeInterval _dt;
    float bottomScrollerHeight;
}

@property (nonatomic) SKSpriteNode *bg1;
@property (nonatomic) SKSpriteNode *bg2;
@property (nonatomic) SKSpriteNode* backgroundImageNode;
@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;

@property (nonatomic) SKSpriteNode *player;
@property (nonatomic) NSArray* playerFlyingFrames;

@property (nonatomic) SKSpriteNode *enemy;
@property (nonatomic) NSArray* enemyFlyingFrames;

//@property (nonatomic) SKSpriteNode *star;
@property (nonatomic) NSArray* starAnimatedFrames;
@property (nonatomic) int numberOfStars;

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
        self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
        self.physicsWorld.contactDelegate = self;
        /* Setup your scene here */
        [self initalizingScrollingBackground];
        [self initializePlayer];
        [self initializeEnemy];
        [self initializeStar];
        
    }
    return self;
}

#pragma mark Player

-(void)initializePlayer
{
    NSMutableArray *flyingFrames = [NSMutableArray array];
    SKTextureAtlas *playerAnimatedAtlas = [SKTextureAtlas atlasNamed:@"witch"];
    NSUInteger numImages = playerAnimatedAtlas.textureNames.count;
    for (int i=0; i < numImages/2; i++) {
        NSString *textureName = [NSString stringWithFormat:@"%d", i];
        SKTexture *temp = [playerAnimatedAtlas textureNamed:textureName];
        [flyingFrames addObject:temp];
    }
    _playerFlyingFrames = flyingFrames;
    
    SKTexture *temp = _playerFlyingFrames[0];
    _player = [SKSpriteNode spriteNodeWithTexture:temp];
    
    _player.position = CGPointMake(30, CGRectGetMidY(self.frame));
    
    _player.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_player.size.width/2 -5];
    _player.physicsBody.dynamic = YES;
    _player.physicsBody.usesPreciseCollisionDetection = YES;
    _player.physicsBody.categoryBitMask = playerCategory;
    _player.physicsBody.collisionBitMask = enemyCategory | starCategory;
    _player.physicsBody.contactTestBitMask = enemyCategory | starCategory;
    _player.name = @"player";
    
    
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

#pragma mark Background

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

    // Música!
    NSError *error;
    NSURL *backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"background" withExtension:@"mp3"];
    self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    self.backgroundMusicPlayer.numberOfLoops = -1;
    [self.backgroundMusicPlayer prepareToPlay];
    self.backgroundMusicPlayer.volume = 0.25;
    [self.backgroundMusicPlayer play];
    
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

#pragma mark Enemy

-(void)initializeEnemy{
    NSMutableArray *flyingFrames = [NSMutableArray array];
    SKTextureAtlas *enemyAnimatedAtlas = [SKTextureAtlas atlasNamed:@"enemy"];
    NSUInteger numImages = enemyAnimatedAtlas.textureNames.count;
    for (int i=0; i < numImages; i++) {
        NSString *textureName = [NSString stringWithFormat:@"%d", i];
        SKTexture *temp = [enemyAnimatedAtlas textureNamed:textureName];
        [flyingFrames addObject:temp];
    }
    _enemyFlyingFrames = flyingFrames;
    
    SKTexture *temp = _enemyFlyingFrames[0];
    _enemy = [SKSpriteNode spriteNodeWithTexture:temp];
    
    _enemy.position = CGPointMake(500, CGRectGetMidY(self.frame));
    
    _enemy.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_enemy.size.width/2];
    _enemy.physicsBody.dynamic = YES;
    _enemy.physicsBody.categoryBitMask = enemyCategory;
    _enemy.physicsBody.collisionBitMask = playerCategory;
    _enemy.physicsBody.contactTestBitMask = playerCategory;
    _enemy.physicsBody.affectedByGravity = NO;
    
    [self addChild:_enemy];
    [self flyingEnemy];
}

-(void)moveEnemy{
    _enemy.position = CGPointMake(_enemy.position.x-(_BG_VEL/45), _enemy.position.y);
}

-(void)flyingEnemy
{
    //This is our general runAction method to make our bear walk.
    [_enemy runAction:[SKAction repeatActionForever:
                       [SKAction animateWithTextures:_enemyFlyingFrames
                                        timePerFrame:0.07f
                                              resize:NO
                                             restore:YES]] withKey:@"FlyingInPlaceEnemy"];
    return;
}


#pragma mark Star
-(void)initializeStar{
    
    SKSpriteNode *star;
    NSMutableArray *animatedFrames = [NSMutableArray array];
    SKTextureAtlas *starAnimatedAtlas = [SKTextureAtlas atlasNamed:@"star"];
    NSUInteger numImages = starAnimatedAtlas.textureNames.count;
    for (int i=0; i < numImages; i++) {
        NSString *textureName = [NSString stringWithFormat:@"%d", i];
        SKTexture *temp = [starAnimatedAtlas textureNamed:textureName];
        [animatedFrames addObject:temp];
    }
    
    _starAnimatedFrames = animatedFrames;
    
    SKTexture *temp = _starAnimatedFrames[0];
    star = [SKSpriteNode spriteNodeWithTexture:temp];
    
    int x = [self getRandomNumberBetween:self.frame.size.width+50 to:self.frame.size.width+150];
    
    int y = [self getRandomNumberBetween:self.frame.size.height-225 to:self.frame.size.height-20];
    
    star.position = CGPointMake(x, y);
    
    star.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:star.size.width/2 - 3];
    star.physicsBody.dynamic = YES;
    star.physicsBody.categoryBitMask = starCategory;
    star.physicsBody.collisionBitMask = playerCategory;
    star.physicsBody.contactTestBitMask = playerCategory;
    star.physicsBody.affectedByGravity = NO;
    star.name = @"star";
    
    [self addChild:star];
    [self animatedStar:star];
    
}

-(void)moveStars{
    _numberOfStars = 0;
    [self enumerateChildNodesWithName:@"star" usingBlock:^(SKNode *node, BOOL *stop) {
        node.position = CGPointMake(node.position.x-(_BG_VEL/45), node.position.y);
        if (node.position.x<-10) {
            [node removeFromParent];
        }
        _numberOfStars = _numberOfStars +1;
    }];
    if (_numberOfStars < 2 && [self childNodeWithName:@"star"].position.x < 250) {
        [self initializeStar];
    }
}

-(void)animatedStar:(SKSpriteNode *)star{
    //This is our general runAction method to make our bear walk.
    [star runAction:[SKAction repeatActionForever:
                       [SKAction animateWithTextures:_starAnimatedFrames
                                        timePerFrame:0.07f
                                              resize:NO
                                             restore:YES]] withKey:@"AnimatedStar"];
    return;
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
    [self moveEnemy];
    [self moveStars];
    [self moveBackground];
    
}

#pragma mark - SKBlade Functions

// This will help us to initialize our blade
- (void)presentBladeAtPosition:(CGPoint)position
{
    blade = [[SKBlade alloc] initWithPosition:position
                                   TargetNode:self
                                        Color:[UIColor whiteColor]];
    
    [blade enablePhysicsWithCategoryBitmask:enemyCategory
                         ContactTestBitmask:playerCategory
                           CollisionBitmask:playerCategory];
    blade.physicsBody.dynamic = YES;
    
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
    [self removeBlade];
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

#pragma mark Utils
-(int)getRandomNumberBetween:(int)from to:(int)to {
    return (int)from + arc4random() % (to-from+1);
}

#pragma mark Collisions

- (void)player:(SKSpriteNode *)player didCollideWithEnemy:(SKSpriteNode *)enemy
{
    //Remove pillar if collision is detected and continue to play
    [enemy removeActionForKey:@"FlyingInPlaceEnemy"];
    [enemy removeFromParent];
}

- (void)player:(SKSpriteNode *)player didCollideWithStar:(SKSpriteNode *)star
{
    //Remove pillar if collision is detected and continue to play
    //[enemyCol removeActionForKey:@"FlyingInPlaceEnemy"];
    [self runAction:[SKAction playSoundFileNamed:@"starcollect.mp3" waitForCompletion:NO]];
    [star removeFromParent];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & playerCategory) != 0 &&
        (secondBody.categoryBitMask & enemyCategory) != 0)
    {
        [self player:(SKSpriteNode *) firstBody.node didCollideWithEnemy:(SKSpriteNode *) secondBody.node];
    }
    if ((firstBody.categoryBitMask & playerCategory) != 0 &&
        (secondBody.categoryBitMask & starCategory) != 0)
    {
        [self player:(SKSpriteNode *) firstBody.node didCollideWithStar:(SKSpriteNode *) secondBody.node];
    }
}



@end
