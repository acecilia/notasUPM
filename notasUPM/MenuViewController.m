#import "MenuViewController.h"
#import "ECSlidingViewController.h"
#import "MoodleViewController.h"
#import "ContactoViewController.h"
#import "SelectorDeExpediente.h"
#import "MoodleAsignaturaViewController.h"
#import "ViewController.h"
#import "AppDelegate.h"

#define COLOR_PRINCIPAL [UIColor colorWithRed:85/255.0 green:172/255.0 blue:239/255.0 alpha:1.0] //AZUL NUEVO

#define ALTURA_CELDA 60

@interface MenuViewController ()
{
    UINavigationController *MoodleNC;
    UINavigationController *SelectorNC;
    UINavigationController *ContactoNC;
}
@end

@implementation MenuViewController

@synthesize menu, iconos;


- (void)viewDidLoad
{
	[super viewDidLoad];

	UIImageView* fondo= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fondoAzul2"]];
	[self.tableView setBackgroundView:fondo];

	self.menu = [NSArray arrayWithObjects:@"Inicio", @"Moodle", @"Expediente",@"Contacto", nil];
	self.iconos = [NSArray arrayWithObjects:@"resumen", @"moodle",@"expediente",@"contacto", nil];

	[self.slidingViewController setAnchorRightRevealAmount:220.0f];
	self.slidingViewController.underLeftWidthLayout = ECFullWidth;

	////////////loadView
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollEnabled = NO;
    
    MoodleViewController* MoodleVC = [[MoodleViewController alloc] init];
    SelectorDeExpediente* SelectorVC = [[SelectorDeExpediente alloc] init];
    ContactoViewController* ContactoVC = [[ContactoViewController alloc] init];
    
    MoodleNC=[[UINavigationController alloc] initWithRootViewController:MoodleVC];
    MoodleNC.view.layer.shadowOpacity = 0.75f;
    MoodleNC.view.layer.shadowRadius = 10.0f;
    MoodleNC.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    
    SelectorNC=[[UINavigationController alloc] initWithRootViewController:SelectorVC];
    SelectorNC.view.layer.shadowOpacity = 0.75f;
    SelectorNC.view.layer.shadowRadius = 10.0f;
    SelectorNC.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    
    ContactoNC=[[UINavigationController alloc] initWithRootViewController:ContactoVC];
    ContactoNC.view.layer.shadowOpacity = 0.75f;
    ContactoNC.view.layer.shadowRadius = 10.0f;
    ContactoNC.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    appDelegate.MoodleNC = MoodleNC;
    appDelegate.SelectorNC = SelectorNC;
    appDelegate.ContactoNC = ContactoNC;
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.menu.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
		cell.backgroundColor = [UIColor clearColor];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;

		/*modifica el color de celda seleccionada
		  UIView *bgColorView = [[UIView alloc] init];
		  bgColorView.backgroundColor = [UIColor greenColor];
		//bgColorView.layer.cornerRadius = 7;
		//bgColorView.layer.masksToBounds = YES;
		[cell setSelectedBackgroundView:bgColorView];*/

		/*UILabel *borde = [[UILabel alloc] initWithFrame:CGRectMake(ALTURA_CELDA/2-20, 10, cell.frame.size.width, ALTURA_CELDA-20)];
		borde.layer.shouldRasterize = YES;
		borde.layer.rasterizationScale = [UIScreen mainScreen].scale;
		borde.backgroundColor=[UIColor clearColor];
		[borde.layer setBorderWidth:0.5];
		[borde.layer setMasksToBounds:NO];
		[borde.layer setCornerRadius:20];
		[borde.layer setBorderColor:[[UIColor whiteColor] CGColor]];


		[cell addSubview:borde];
		borde.tag=3;
		borde.autoresizingMask = UIViewAutoresizingFlexibleWidth;*/

		UIImageView* imagen= [[UIImageView alloc]initWithFrame:CGRectMake(ALTURA_CELDA/2-15, ALTURA_CELDA/2-15, 30, 30)];
		[cell addSubview:imagen];
		imagen.tag=1;

		UILabel *texto = [[UILabel alloc] initWithFrame:CGRectMake(ALTURA_CELDA, 1, cell.frame.size.width-ALTURA_CELDA, ALTURA_CELDA)];
		texto.font=[UIFont fontWithName:@"QuicksandBold-Regular" size:17];
		texto.backgroundColor=[UIColor clearColor];
		texto.textColor = [UIColor whiteColor];
		[cell addSubview:texto];
		texto.tag=2;
		texto.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	}

	((UILabel *)[cell viewWithTag:2]).text=[[NSString stringWithFormat:@"%@", [self.menu objectAtIndex:indexPath.row]]uppercaseString];
	((UIImageView *)[cell viewWithTag:1]).image = [UIImage imageNamed:[iconos objectAtIndex:indexPath.row]];

	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    [UIView animateWithDuration:0.3  animations:^(void)
     {
         [tableView cellForRowAtIndexPath:indexPath].center=CGPointMake( [tableView cellForRowAtIndexPath:indexPath].center.x + self.view.frame.size.width, [tableView cellForRowAtIndexPath:indexPath].center.y);
     }];

	UIViewController *newTopViewController;
	switch(indexPath.row)
	{
		case 0:
			{
				newTopViewController=[[ViewController alloc] init];
			}
			break;
		case 1:
			{
				/*UITableViewController *VC = [[MoodleViewController alloc] init];
				UINavigationController *NC=[[UINavigationController alloc] initWithRootViewController:MoodleVC];
				NC.view.layer.shadowOpacity = 0.75f;
				NC.view.layer.shadowRadius = 10.0f;
				NC.view.layer.shadowColor = [UIColor blackColor].CGColor;
                
                [NC.view addGestureRecognizer:self.slidingViewController.panGesture];*/
                [MoodleNC.view addGestureRecognizer:self.slidingViewController.panGesture];
				newTopViewController=MoodleNC;
			}
			break;
		case 2:
			{
				/*UITableViewController *VC = [[SelectorDeExpediente alloc] init];
				UINavigationController *NC=[[UINavigationController alloc] initWithRootViewController:SelectorVC];
				NC.view.layer.shadowOpacity = 0.75f;
				NC.view.layer.shadowRadius = 10.0f;
				NC.view.layer.shadowColor = [UIColor blackColor].CGColor;
				[NC.view addGestureRecognizer:self.slidingViewController.panGesture];*/
                [SelectorNC.view addGestureRecognizer:self.slidingViewController.panGesture];
				newTopViewController=SelectorNC;
			}
			break;
		case 3:
			{
				/*UITableViewController *VC = [[ContactoViewController alloc] init];
				UINavigationController *NC=[[UINavigationController alloc] initWithRootViewController:ContactoVC];
				NC.view.layer.shadowOpacity = 0.75f;
				NC.view.layer.shadowRadius = 10.0f;
				NC.view.layer.shadowColor = [UIColor blackColor].CGColor;
				[NC.view addGestureRecognizer:self.slidingViewController.panGesture];*/
                /*while (ContactoNC.view.gestureRecognizers.count) {
                    [ContactoNC.view removeGestureRecognizer:[ContactoNC.view.gestureRecognizers objectAtIndex:0]];
                }*/
                
                [ContactoNC.view addGestureRecognizer:self.slidingViewController.panGesture];
				newTopViewController=ContactoNC;
			}
			break;
		default:
			break;
	}

	[self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:
		^{
			CGRect frame = self.slidingViewController.topViewController.view.frame;
			self.slidingViewController.topViewController = newTopViewController;
			self.slidingViewController.topViewController.view.frame = frame;

			[self.slidingViewController resetTopViewWithAnimations:(void(^)())nil onComplete:
				^{
					[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
                    [tableView cellForRowAtIndexPath:indexPath].center=CGPointMake( [tableView cellForRowAtIndexPath:indexPath].center.x - self.view.frame.size.width, [tableView cellForRowAtIndexPath:indexPath].center.y);
				}];
		}];

}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return ALTURA_CELDA;
}



- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end





