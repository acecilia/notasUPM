#import <UIKit/UIKit.h>
#import "ModelUPM.h"
#import "moodleNSObject.h"
#import "Descargador.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) NSString *user;
@property (strong, nonatomic) NSString *pass;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *MoodleNC;
@property (strong, nonatomic) UINavigationController *SelectorNC;
@property (strong, nonatomic) UINavigationController *ContactoNC;

@property (strong, nonatomic) ModelUPM *modelo;
@property (strong, nonatomic) MoodleNSObject *moodleNSObject;
@property (readwrite, nonatomic) BOOL yaCargoModelo;

@end



