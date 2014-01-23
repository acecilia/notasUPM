#import "InitViewController.h"
#import "ViewController.h"
#import "MenuViewController.h"

@interface InitViewController ()
{
}
@end

@implementation InitViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self)
	{

	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    [[NSThread currentThread] setName:@"hilo initViewController"];

	self.topViewController = [[ViewController alloc]init];
	self.underLeftViewController = [[MenuViewController alloc]init];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleDefault;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

@end




