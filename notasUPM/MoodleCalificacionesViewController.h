#import <UIKit/UIKit.h>
#import "ModelUPM.h"

@interface MoodleCalificacionesViewController : UITableViewController <ModelUPMDelegate, UIWebViewDelegate, UIAlertViewDelegate>

@property(strong, nonatomic) NSString *URL;
@property(strong, nonatomic) NSString *offlineFile;
@end



