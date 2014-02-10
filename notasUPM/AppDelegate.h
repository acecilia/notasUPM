#import <UIKit/UIKit.h>
#import "ModelUPM.h"
#import "Descargador.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *MoodleNC;
@property (strong, nonatomic) UINavigationController *SelectorNC;
@property (strong, nonatomic) UINavigationController *ContactoNC;

@property (strong, nonatomic) ModelUPM *modelo;
@property (readwrite, nonatomic) BOOL yaCargoModelo;
@end



