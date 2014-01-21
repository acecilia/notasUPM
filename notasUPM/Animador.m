#import "Animador.h"


@interface Animador ()
{
}
@end

@implementation Animador

+ (void) animarBoton:(UIButton *)boton
{
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = 1;
    animationGroup.repeatCount = HUGE_VALF;
    animationGroup.removedOnCompletion=NO;
    
	CABasicAnimation *rotationAnimation;
	rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	//rotationAnimation.repeatCount = INFINITY;
	rotationAnimation.duration = 1;
	//rotationAnimation.cumulative = YES;
	rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 * 1 * 1 ];
	rotationAnimation.removedOnCompletion = NO;
	//[botonReload.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.fromValue = @1.0;
    scale.toValue = @0.85;
    //scale.repeatCount = INFINITY;
	scale.duration = 0.5;
	//scale.cumulative = YES;
    scale.autoreverses = YES;
    scale.removedOnCompletion = NO;
    scale.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    animationGroup.animations = @[scale,rotationAnimation];
    [boton.layer addAnimation:animationGroup forKey:@"pulse"];
}

+ (void) dejarDeAnimarBoton:(UIButton *)boton conDelegate:(id)delegate
{
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.toValue = @0.1;
    //scale.autoreverses=YES;
    scale.delegate = delegate;
    scale.duration = 0.5;
    scale.cumulative = YES;
    scale.removedOnCompletion = NO;
    scale.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [boton.layer addAnimation:scale forKey:@"scaleFinal"];
    
    //Es necesario repetir la animacion scale2 para que no se produzcan cosas raras
    CABasicAnimation *scale2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale2.fromValue = @0.1;
    scale2.toValue = @1.0;
    //scale2.autoreverses=YES;
    scale2.beginTime = CACurrentMediaTime()+scale.duration;
    scale2.duration = 0.5;
    scale2.cumulative = YES;
    scale2.removedOnCompletion = NO;
    scale2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [boton.layer addAnimation:scale2 forKey:@"scaleFinal2"];
}



@end






