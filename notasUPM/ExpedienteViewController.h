#import <UIKit/UIKit.h>
#import "ModelUPM.h"

@interface ExpedienteViewController : UITableViewController < UITableViewDataSource, UITableViewDelegate, ModelUPMDelegate>

@property int numeroExpediente;
@property (nonatomic,retain) NSString* tituloBarra;
@end


