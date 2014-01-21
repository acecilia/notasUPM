#import <UIKit/UIKit.h>

@interface Animador : NSObject

+ (void) animarBoton:(UIButton *)boton;
+ (void) dejarDeAnimarBoton:(UIButton *)boton conDelegate:(id) delegate;

@end

