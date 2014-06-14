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

static const uint32_t blockCategory = 0x1 <<0;
static const uint32_t  playerCategory = 0x1 <<1;

@interface JGFMyScene() <SKPhysicsContactDelegate>
{
    NSTimeInterval _dt;
    float bottomScrollerHeight;
}

@property (nonatomic) SKSpriteNode* backgroundImageNode;
@property (nonatomic) NSArray* playerFlyingFrames;

@property (nonatomic) float BG_VEL;

@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@end

@implementation JGFMyScene
{
    // This will help us to easily access our blade
    SKBlade *blade;
    SKSpriteNode *bg1;
    SKSpriteNode *bg2;
    SKSpriteNode *player;
    SKSpriteNode *enemy;
    
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
    player = [SKSpriteNode spriteNodeWithTexture:temp];
    
    //_player.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    player.position = CGPointMake(30, CGRectGetMidY(self.frame));
    
    player.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:player.size.width/2];
    player.physicsBody.dynamic = YES;
    player.physicsBody.usesPreciseCollisionDetection = YES;
    player.physicsBody.categoryBitMask = playerCategory;
    player.physicsBody.collisionBitMask = blockCategory;
    player.physicsBody.contactTestBitMask = 0;
    player.name = @"player";
    
    
    [self addChild:player];
    [self flyingPlayer];
}


-(void)flyingPlayer
{
    //This is our general runAction method to make our bear walk.
    [player runAction:[SKAction repeatActionForever:
                      [SKAction animateWithTextures:_playerFlyingFrames
                                       timePerFrame:0.07f
                                             resize:NO
                                            restore:YES]] withKey:@"FlyingInPlacePlayer"];
    return;
}

-(void)initalizingScrollingBackground
{
    bg1 = [SKSpriteNode spriteNodeWithImageNamed:@"background.png"];
    bg1.anchorPoint = CGPointZero;
    bg1.position = CGPointMake(0, 0);
    [self addChild:bg1];
    
    bg2 = [SKSpriteNode spriteNodeWithImageNamed:@"background.png"];
    bg2.anchorPoint = CGPointZero;
    bg2.position = CGPointMake(bg1.size.width-1, 0);
    [self addChild:bg2];
}

- (void)moveBackground
{
    bg1.position = CGPointMake(bg1.position.x-(_BG_VEL/60), bg1.position.y);
    bg2.position = CGPointMake(bg2.position.x-(_BG_VEL/60), bg2.position.y);
    
    if (bg1.position.x < -bg1.size.width){
        bg1.position = CGPointMake(bg2.position.x + bg2.size.width, bg1.position.y);
    }
    
    if (bg2.position.x < -bg2.size.width) {
        bg2.position = CGPointMake(bg1.position.x + bg1.size.width, bg2.position.y);
    }
}

#pragma mark Enemy

-(void)initializeEnemy{
    enemy = [[SKSpriteNode alloc] initWithImageNamed:@"enemy.png"];
    enemy.position = CGPointMake(400, CGRectGetMidY(self.frame));
    
    enemy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:(CGSizeMake(enemy.size.width, enemy.size.height))];
    enemy.physicsBody.dynamic = YES;
    enemy.physicsBody.categoryBitMask = blockCategory;
    enemy.physicsBody.contactTestBitMask = playerCategory;
    enemy.physicsBody.collisionBitMask = 0;
    enemy.physicsBody.affectedByGravity = NO;
    
    [self addChild:enemy];
    
}

-(void)moveEnemy{
    enemy.position = CGPointMake(enemy.position.x-(_BG_VEL/85), enemy.position.y);
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
    [self moveBackground];
    
}

#pragma mark - SKBlade Functions

// This will help us to initialize our blade
- (void)presentBladeAtPosition:(CGPoint)position
{
    blade = [[SKBlade alloc] initWithPosition:position
                                   TargetNode:self
                                        Color:[UIColor whiteColor]];
    
    [blade enablePhysicsWithCategoryBitmask:blockCategory
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

#pragma mark Collisions

- (void)pillar:(SKSpriteNode *)pillar didCollideWithBird:(SKSpriteNode *)bird
{
    //Remove pillar if collision is detected and continue to play
    [pillar removeFromParent];
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
    
    if ((firstBody.categoryBitMask & blockCategory) != 0 &&
        (secondBody.categoryBitMask & playerCategory) != 0)
    {
        [self pillar:(SKSpriteNode *) firstBody.node didCollideWithBird:(SKSpriteNode *) secondBody.node];
    }
}



@end
