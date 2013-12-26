#import <UIKit/UIKit.h>
#import "ModelUPM.h"

@interface MoodleWebViewViewController : UIViewController <ModelUPMDelegate, NSURLConnectionDataDelegate>
@property(strong, nonatomic) NSString *URL;
@property(strong, nonatomic) NSString *offlineFile;
@property(strong, nonatomic) NSString *navViewTitle;

@end




