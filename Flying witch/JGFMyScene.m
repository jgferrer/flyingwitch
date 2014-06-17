//
//  JGFMyScene.m
//  Flying witch
//
//  Created by José Gabriel Ferrer on 01/06/14.
//  Copyright (c) 2014 José Gabriel Ferrer. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "JGFMyScene.h"
#import "JGFStar.h"

@interface JGFMyScene() <SKPhysicsContactDelegate>
{
    NSTimeInterval _dt;
}

@end

@implementation JGFMyScene

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        
        _BG_VEL = (TIME*60);
        self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
        self.physicsWorld.contactDelegate = self;
        /* Setup your scene here */
        
        [self initalizingScrollingBackground];
        [self initializeScoreCounter];
        [self initializePlayer];
        [self initializeEnemy];
        [self createStar];
        
    }
    return self;
}

#pragma mark HUD
-(void)initializeScoreCounter{
    SKSpriteNode *scoreStar = [[SKSpriteNode alloc] initWithImageNamed:@"scoreStar.png"];
    scoreStar.position = CGPointMake(self.frame.size.width - 50, 35);
    [self addChild:scoreStar];
    
    self.score = 0;
    self.scoreLabel = [[SKLabelNode alloc] initWithFontNamed:@"STHeitiSC-Medium"];
    self.scoreLabel.fontSize = 20;
    self.scoreLabel.fontColor = [UIColor blackColor];
    self.scoreLabel.position = CGPointMake(self.frame.size.width - 50, 22);
    [self addChild:self.scoreLabel];
    self.scoreLabel.text = [NSString stringWithFormat:@"%3.0f",self.score];

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
-(void)createStar{
    JGFStar *starObj = [[JGFStar alloc] init];
    [self addChild:starObj.star];
}

-(void)moveAndCreateStars{
    _numberOfStars = 0;
    [self enumerateChildNodesWithName:@"star" usingBlock:^(SKNode *node, BOOL *stop) {
        node.position = CGPointMake(node.position.x-(_BG_VEL/45), node.position.y);
        if (node.position.x<-10) {
            [node removeFromParent];
        }
        _numberOfStars = _numberOfStars +1;
    }];
    if (_numberOfStars < 2 && [self childNodeWithName:@"star"].position.x < 250) {
        [self createStar];
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
    
    [self moveEnemy];
    [self moveAndCreateStars];
    [self moveBackground];
    
}

#pragma mark - Touch Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{

}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{

}

#pragma mark Utils
-(int)getRandomNumberBetween:(int)from to:(int)to {
    return (int)from + arc4random() % (to-from+1);
}

#pragma mark Collisions Delegate

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

- (void)player:(SKSpriteNode *)player didCollideWithEnemy:(SKSpriteNode *)enemy
{
    [enemy removeFromParent];
}

- (void)player:(SKSpriteNode *)player didCollideWithStar:(SKSpriteNode *)star
{
    [self runAction:[SKAction playSoundFileNamed:@"starcollect.mp3" waitForCompletion:NO]];
    self.score = self.score + 1;
    self.scoreLabel.text = [NSString stringWithFormat:@"%3.0f",self.score];
    [star removeFromParent];
}



@end
