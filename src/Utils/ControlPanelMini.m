//
//  ControlPanelMini.m
//  mySingPage
//
//  Created by wonliao on 13/1/22.
//  Copyright (c) 2013年 wonliao. All rights reserved.
//

#import "ControlPanelMini.h"
#import <QuartzCore/QuartzCore.h>

@implementation ControlPanelMini

@synthesize button = _button;


- (id) init {
    self = [super init];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (id)initWithWidth:(CGFloat)width {
    return [self initWithFrame:CGRectMake(0.0, 0.0, width, 66.0)];
}

- (id)initWithTitle:(NSString *)title detail:(NSString *)detail icon:(UIImage *)icon
{
    CGFloat defaultWidth = 300.0;
    //CGFloat detailHeight = [[self detail] sizeWithFont:[_detailLabel font] constrainedToSize:CGSizeMake(defaultWidth-120.0, maxHeight-78.0) lineBreakMode:[_detailLabel lineBreakMode]].height;
    //if (detailHeight < 20)
    //     detailHeight = 20.0;
    CGFloat notifHeight = 66.0;
    self = [self initWithFrame:CGRectMake(0.0, 0.0, defaultWidth, notifHeight)];
    if (self) {
        [_titleLabel setText:title];
        [_detailLabel setText:detail];
        [_iconView setImage:icon];
    }
    return self;
}

- (void) setupSubviews {
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
    self.color = [UIColor blackColor];
    //縮圖初始
    _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 6.0, 56.0, 56.0)];
    _iconView.clipsToBounds = YES;
    _iconView.layer.cornerRadius = 8.0;
    _iconView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_iconView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(90.0, 10.0, self.frame.size.width-120.0, 24.0)];
    _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.shadowColor = [UIColor blackColor];
    _titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    _titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    [self addSubview:_titleLabel];
    
    _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(90.0, 38.0, self.frame.size.width-120.0, 20.0)];
    _detailLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _detailLabel.backgroundColor = [UIColor clearColor];
    _detailLabel.textColor = [UIColor lightGrayColor];
    _detailLabel.shadowColor = [UIColor blackColor];
    _detailLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    _detailLabel.font = [UIFont boldSystemFontOfSize:13.0];
    _detailLabel.numberOfLines = 0;
    [self addSubview:_detailLabel];
    
    UIImage *buttonUpImage = [UIImage imageNamed:@"pause.png"];
    UIImage *buttonDownImage = [UIImage imageNamed:@"pause.png"];
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(260.0, 10.0, buttonUpImage.size.width,
                              buttonUpImage.size.height);
    [button setBackgroundImage:buttonUpImage
                      forState:UIControlStateNormal];
    [button setBackgroundImage:buttonDownImage
                      forState:UIControlStateHighlighted];
    [button.titleLabel setFont:[UIFont systemFontOfSize:13]];
    //[button setTitle:@"暫停" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pauseButtonTapped:)
     forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
}

// 暫停鈕 功能
- (IBAction)pauseButtonTapped:(id)sender
{
    UIImage *buttonUpImage = [UIImage imageNamed:@"playback.png"];
    UIImage *buttonDownImage = [UIImage imageNamed:@"playback.png"];
    [button setBackgroundImage:buttonUpImage
                      forState:UIControlStateNormal];
    [button setBackgroundImage:buttonDownImage
                      forState:UIControlStateHighlighted];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PauseSong" object:self];
    
    // 將 按鈕 換為 播放鈕功能
    [button removeTarget:self action:@selector(pauseButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(playButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

// 播放鈕 功能
- (IBAction)playButtonTapped:(id)sender
{
    UIImage *buttonUpImage = [UIImage imageNamed:@"pause.png"];
    UIImage *buttonDownImage = [UIImage imageNamed:@"pause.png"];
    [button setBackgroundImage:buttonUpImage
                      forState:UIControlStateNormal];
    [button setBackgroundImage:buttonDownImage
                      forState:UIControlStateHighlighted];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlaySong" object:self];
    
    // 將 按鈕 換為 暫停鈕功能
    [button removeTarget:self action:@selector(playButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(pauseButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}


- (void) setColor:(UIColor *)color {
     _color = nil;
    _color = color ;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    UIColor* border = [_color colorWithAlphaComponent:0.3];
    UIColor* topColor = [self lightenColor:border value:0.37];
    UIColor* midColor = [self lightenColor:border value:0.1];
    UIColor* bottomColor = [self lightenColor:border value:0.12];
    
    NSArray* newGradientColors = [NSArray arrayWithObjects:
                                  (id)topColor.CGColor,
                                  (id)midColor.CGColor,
                                  (id)border.CGColor,
                                  (id)border.CGColor,
                                  (id)bottomColor.CGColor, nil];
    CGFloat newGradientLocations[] = {0, 0.500, 0.501, 0.66, 1};
    
    CGGradientRelease(_gradient);
    _gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)newGradientColors, newGradientLocations);
    CGColorSpaceRelease(colorSpace);
    
    [self setNeedsDisplay];
}

- (UIColor *) color {
    return _color;
}

- (void) setIcon:(UIImage *)icon {
    if (_iconView) {
        [_iconView setImage:icon];
    }
}
- (UIImage *) icon {
    return [_iconView image];
}

- (void) setTitle:(NSString *)title {
    [_titleLabel setText:title];
}
- (NSString *)title {
    return [_titleLabel text];
}

- (void) setDetail:(NSString *)detail {
    [_detailLabel setText:detail];
    //[self updateHeight];
}
- (NSString*)detail {
    return [_detailLabel text];
}

- (void) setWidth:(CGFloat)width {
    CGRect f = self.frame;
    f.size.width = width;
    [self setFrame:f];
    //[self updateHeight];
}
- (void) setHeight:(CGFloat)height {
    CGRect f = self.frame;
    f.size.height = height;
    [self setFrame:f];
    //[self updateHeight];
}
- (CGFloat) width {
    return self.bounds.size.width;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor* border = [_color colorWithAlphaComponent:0.6];
    
    //// Shadow Declarations
    UIColor* shadow = [self lightenColor:border value:0.65];
    CGSize shadowOffset = CGSizeMake(0, 2);
    CGFloat shadowBlurRadius = 0;
    UIColor* shadow2 = [[UIColor clearColor] colorWithAlphaComponent:0.1];
    CGSize shadow2Offset = CGSizeMake(0.0, 2.0);
    CGFloat shadow2BlurRadius = 4.0;
    
    //// Rounded Rectangle Drawing
    UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(4.5, 2.5, rect.size.width-8.0, rect.size.height-4.0) cornerRadius: 4];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadow2Offset, shadow2BlurRadius, shadow2.CGColor);
    CGContextSetFillColorWithColor(context, shadow2.CGColor);
    [roundedRectanglePath fill];
    [roundedRectanglePath addClip];
    CGContextDrawLinearGradient(context, _gradient, CGPointMake(0.0, 2.5), CGPointMake(0.0, rect.size.height-5.5), 0);
    
    ////// Rounded Rectangle Inner Shadow
    CGRect roundedRectangleBorderRect = CGRectInset([roundedRectanglePath bounds], -shadowBlurRadius, -shadowBlurRadius);
    roundedRectangleBorderRect = CGRectOffset(roundedRectangleBorderRect, -shadowOffset.width, -shadowOffset.height);
    roundedRectangleBorderRect = CGRectInset(CGRectUnion(roundedRectangleBorderRect, [roundedRectanglePath bounds]), -1, -1);
    
    UIBezierPath* roundedRectangleNegativePath = [UIBezierPath bezierPathWithRect: roundedRectangleBorderRect];
    [roundedRectangleNegativePath appendPath: roundedRectanglePath];
    roundedRectangleNegativePath.usesEvenOddFillRule = YES;
    
    CGContextSaveGState(context);
    {
        CGFloat xOffset = shadowOffset.width + round(roundedRectangleBorderRect.size.width);
        CGFloat yOffset = shadowOffset.height;
        CGContextSetShadowWithColor(context,
                                    CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                    shadowBlurRadius,
                                    shadow.CGColor);
        
        [roundedRectanglePath addClip];
        CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(roundedRectangleBorderRect.size.width), 0);
        [roundedRectangleNegativePath applyTransform: transform];
        [[UIColor grayColor] setFill];
        [roundedRectangleNegativePath fill];
    }
    CGContextRestoreGState(context);
    
    CGContextRestoreGState(context);
    
    [border setStroke];
    roundedRectanglePath.lineWidth = 1;
    [roundedRectanglePath stroke];
}



- (UIColor *)lightenColor:(UIColor *)oldColor value:(float)value {
    int   totalComponents = CGColorGetNumberOfComponents(oldColor.CGColor);
    bool  isGreyscale     = totalComponents == 2 ? YES : NO;
    
    CGFloat* oldComponents = (CGFloat *)CGColorGetComponents(oldColor.CGColor);
    CGFloat newComponents[4];
   
    if (isGreyscale) {
        newComponents[0] = oldComponents[0]+value > 1.0 ? 1.0 : oldComponents[0]+value;
        newComponents[1] = oldComponents[0]+value > 1.0 ? 1.0 : oldComponents[0]+value;
        newComponents[2] = oldComponents[0]+value > 1.0 ? 1.0 : oldComponents[0]+value;
        newComponents[3] = oldComponents[1];
    } else {
        newComponents[0] = oldComponents[0]+value > 1.0 ? 1.0 : oldComponents[0]+value;
        newComponents[1] = oldComponents[1]+value > 1.0 ? 1.0 : oldComponents[1]+value;
        newComponents[2] = oldComponents[2]+value > 1.0 ? 1.0 : oldComponents[2]+value;
        newComponents[3] = oldComponents[3];
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef newColor = CGColorCreate(colorSpace, newComponents);
	CGColorSpaceRelease(colorSpace);
    
	UIColor *retColor = [UIColor colorWithCGColor:newColor];
	CGColorRelease(newColor);
    
    return retColor;
}



@end