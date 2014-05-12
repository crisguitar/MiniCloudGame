//
//  MyScene.m
//  SKTextures
//
//  Created by Cris Pinto on 10/21/13.
//  Copyright (c) 2013 Cris Pinto. All rights reserved.
//

#import "GameScene.h"
#import "MenuScene.h"

static const uint32_t cloudCategory    =  0x1 << 0;
static const uint32_t obstacleCategory =  0x1 << 1;

@interface GameScene() {
    
    BOOL _isCloudDeformed;
    int _obstaclesCount;
    BOOL _gameOver;
    SKSpriteNode *_background;
    SKSpriteNode *_character;
    NSArray *_characterMovementFrames;
}


@end

@implementation GameScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        
        self.physicsWorld.contactDelegate = self;
        self.physicsWorld.gravity = CGVectorMake(0.0f, -2.0f);
    }
    return self;
}

-(void)didMoveToView:(SKView *)view
{
    _obstaclesCount = 0;
    _isCloudDeformed = NO;
    _gameOver = NO;
    
    [self setupScene];
}

-(void)setupScene
{
    [self generateBackground];
    [self generateTop];
    [self setupCharacterFrames];
    [self generateCharacter];
    [self generateObstacle];
}

-(SKSpriteNode *)spriteWithColor:(UIColor *)bgColor size:(CGSize)size
{
    SKSpriteNode *skNode = [SKSpriteNode spriteNodeWithColor:bgColor size:size];
    SKSpriteNode *noise = [SKSpriteNode spriteNodeWithImageNamed:@"Noise"];
    [noise setBlendMode:SKBlendModeScreen];
    [skNode addChild:noise];
    return skNode;
    
}

-(UIColor *)randomColorWithValue:(int)value
{
    return [UIColor colorWithRed:[self randomNumberBetween:value and:255]/255.0 green:[self randomNumberBetween:value and:255]/255.0 blue:[self randomNumberBetween:value and:255]/255.0 alpha:1.0];
}

-(void)generateBackground
{
    [_background removeFromParent];
    _background = [self spriteWithColor:[self randomColorWithValue:200] size:self.frame.size];
    _background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    _background.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0, self.frame.size.height) toPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
    _background.physicsBody.dynamic = YES;
    _background.physicsBody.affectedByGravity = NO;
    _background.zPosition = -1;
    [self addChild:_background];
}

-(void)generateTop
{
    SKSpriteNode *top = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithWhite:0 alpha:0] size:CGSizeMake(self.frame.size.width, 10)];
    top.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height);
    top.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width, 10)];
    top.physicsBody.dynamic = NO;
    top.physicsBody.affectedByGravity = NO;
    
    [self addChild:top];
    
    // temporary bottom
    SKSpriteNode *bottom = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithWhite:0 alpha:0] size:CGSizeMake(self.frame.size.width, 10)];
    bottom.position = CGPointMake(CGRectGetMidX(self.frame), 10);
    bottom.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bottom.size];
    bottom.physicsBody.dynamic = NO;
    bottom.physicsBody.affectedByGravity = NO;
    
    [self addChild:bottom];
    
}

-(void)generateCharacter
{
    [_character removeFromParent];
    //_character = [SKSpriteNode spriteNodeWithImageNamed:@"character"];
    _character = [SKSpriteNode spriteNodeWithTexture:_characterMovementFrames[0]];
    _character.name = @"character";
    _character.position = CGPointMake(100, self.frame.size.height - 125);
    _character.zPosition = 100;
    _character.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_character.size];
    _character.physicsBody.categoryBitMask = cloudCategory;
    _character.physicsBody.collisionBitMask = obstacleCategory;
    _character.physicsBody.contactTestBitMask = obstacleCategory;
    _character.physicsBody.usesPreciseCollisionDetection = YES;
    _character.physicsBody.dynamic = YES;
    _character.physicsBody.affectedByGravity = YES;
    [self addChild:_character];
}

- (void)setupCharacterFrames
{
    NSMutableArray *movementFrames = [NSMutableArray array];
    SKTextureAtlas *characterAtlas = [SKTextureAtlas atlasNamed:@"character_move"];
    int numImages = characterAtlas.textureNames.count;
    for (int i=1; i <= numImages; i++) {
        NSString *textureName = [NSString stringWithFormat:@"character_%d", i];
        SKTexture *texture = [characterAtlas textureNamed:textureName];
        [movementFrames addObject:texture];
    }
    _characterMovementFrames = movementFrames;
}

-(void)generateObstacle
{
    SKSpriteNode *obstacle = [[SKSpriteNode alloc] initWithImageNamed:@"rainbow"];
    obstacle.name = @"obstacle";
    obstacle.position = CGPointMake((arc4random() % 400) + self.frame.size.width, [self randomNumberBetween:20 and:self.size.height - 20]);
    obstacle.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:(obstacle.size.width/2)];
    obstacle.physicsBody.categoryBitMask = obstacleCategory;
    obstacle.physicsBody.collisionBitMask = cloudCategory;
    obstacle.physicsBody.contactTestBitMask = cloudCategory;
    obstacle.physicsBody.dynamic = YES;
    obstacle.physicsBody.affectedByGravity = NO;
    
    float scale = [self randomNumberBetween:1 and:4] / 2.0;
    obstacle.size = CGSizeMake(obstacle.size.width * scale, obstacle.size.height * scale);
    
    SKAction *changeColor = [SKAction  colorizeWithColor:[self randomColorWithValue:60] colorBlendFactor:1 duration:0.1];
    SKAction *moveLeft = [SKAction moveByX: -[self randomNumberBetween:30 and:50] y:0 duration:0.2];
    
    [self addChild:obstacle];
    _obstaclesCount++;
    
    [obstacle runAction:changeColor];
    [obstacle runAction:[SKAction repeatActionForever:moveLeft]];
    
}

-(int)randomNumberBetween:(int)lowest and:(int)highest {
    return lowest + arc4random() % (highest - lowest);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    _character.physicsBody.affectedByGravity = NO;
    [_character.physicsBody setVelocity:CGVectorMake(0, 0)];
    SKAction *stretch = [SKAction scaleYTo:1.1 duration:0.3];
    SKAction *stretchBack = [SKAction scaleYTo:1 duration:0.5];
    [_character runAction:[SKAction sequence:@[stretch, stretchBack]]];
    [_character.physicsBody applyForce:CGVectorMake(0, 300)];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _character.physicsBody.affectedByGravity = YES;
}


// contact detection will not be used, so yeah...
-(void)didBeginContact:(SKPhysicsContact *)contact
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
    // check contact
    if ((firstBody.categoryBitMask & cloudCategory) != 0 && (secondBody.collisionBitMask & cloudCategory) != 0)
    {
        
        // NSLog(@"CONTACT!!!");
    }
}

- (void)spawnObstacles {
    
    if (_obstaclesCount < 7) {
        [self generateObstacle];
    }
}

- (void)removeObstacleWhenNotVisible {
    [self enumerateChildNodesWithName:@"obstacle" usingBlock:^(SKNode *node, BOOL *stop) {
        
        SKSpriteNode *theNode = (SKSpriteNode *)node;
        
        if (theNode.position.x + theNode.size.width < 0) {
            [node removeFromParent];
            _obstaclesCount--;
        }
    }];
}

-(void)checkGameOver
{
    if (!_gameOver && _character.position.x < 0) {
        NSLog(@"Game Over!!");
        _gameOver = YES;
        [self showGameOver];
    }
    
}

-(void)showGameOver
{
    SKTransition *transition = [SKTransition doorsCloseHorizontalWithDuration:1];
    transition.pausesIncomingScene = YES;
    MenuScene *menuScene = [[MenuScene alloc] initWithSize:self.size];
    [self.scene.view presentScene:menuScene transition:transition];
}

-(void)update:(CFTimeInterval)currentTime {
    
    /* Called before each frame is rendered */
    [self spawnObstacles];
    [self removeObstacleWhenNotVisible];
    [self checkGameOver];
    
}

@end
