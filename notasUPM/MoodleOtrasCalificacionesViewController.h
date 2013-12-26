#import <UIKit/UIKit.h>
#import "ModelUPM.h"
#import "Descargador.h"

@interface MoodleOtrasCalificacionesViewController : UITableViewController <DescargadorDelegate, ModelUPMDelegate, UIWebViewDelegate, UIAlertViewDelegate>

@property(strong, nonatomic) NSString *URL;
@property(strong, nonatomic) NSString *offlineFile;
@end



