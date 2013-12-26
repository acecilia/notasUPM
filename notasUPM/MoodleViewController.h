#import <UIKit/UIKit.h>
#import "ModelUPM.h"

@interface MoodleViewController : UITableViewController < UITableViewDataSource, UITableViewDelegate, ModelUPMDelegate>
{
	UIImageView *loading;
	UIButton *reload;
}

@end


