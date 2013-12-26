#import <UIKit/UIKit.h>
#import "ModelUPM.h"

@interface VisorWeb : UIViewController <ModelUPMDelegate, UIWebViewDelegate>
@property(strong, nonatomic) NSString *URL;
@property(strong, nonatomic) NSString *navViewTitle;

@end




