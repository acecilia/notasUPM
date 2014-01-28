#import "MoodleAsignaturaViewController.h"
#import "MoodleCalificacionesViewController.h"
#import "MoodleOtrasCalificacionesViewController.h"
#import "VisorWeb.h"
#import "QuartzCore/CAAnimation.h"

#define COLOR_LETRA [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:200/255.0]

@interface MoodleAsignaturaViewController ()
{
	NSArray *asignatura;
	NSMutableArray *arrayTabla;

	UIImageView *loading;
}

@end

@implementation MoodleAsignaturaViewController

@synthesize asignatura;

- (id)initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];
	if (self)
	{

	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self setNavView];

	arrayTabla = [[NSMutableArray alloc]init];
	[arrayTabla addObject:@"Calificaciones"];
	//[arrayTabla addObject:@"Guía de la asignatura"];
	[arrayTabla addObject:@"Documentos PDF"];
	[arrayTabla addObject:@"Web de la asignatura"];
}

- (void)setNavView
{
	UILabel *titulo = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
	titulo.text = [asignatura objectAtIndex:0];
	titulo.textAlignment = NSTextAlignmentCenter;
	titulo.textColor = [UIColor whiteColor];
	titulo.backgroundColor = [UIColor clearColor];
	titulo.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:20];
	self.navigationItem.titleView = titulo;

	UIImage *imagenBack = [UIImage imageNamed:@"back"];
	UIButton *botonBack =  [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
	[botonBack addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchDown];
	[botonBack setBackgroundColor:[UIColor clearColor]];
	[botonBack setBackgroundImage:imagenBack forState:UIControlStateNormal];
	[botonBack setTitle:@"" forState:UIControlStateNormal];
	UIBarButtonItem *leftBack = [[UIBarButtonItem alloc]initWithCustomView:botonBack];
	self.navigationItem.leftBarButtonItem = leftBack;

	UIButton *right = [[UIButton alloc]initWithFrame:CGRectMake(10, 12, 34,24)];
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithCustomView:right];

	self.navigationItem.rightBarButtonItem = rightButton;

}

- (void)back
{
	[self.navigationController popViewControllerAnimated:YES];
}



/*- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
  {
  if (alertView.tag == 1)
  {
  if (buttonIndex == 0)
  {
  [self.navigationController popToRootViewControllerAnimated:YES];
  }
  }
  }*/


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return arrayTabla.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

	if (cell == nil)
	{
		cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}

	cell.textLabel.text = [arrayTabla objectAtIndex:indexPath.row];
	cell.textLabel.font = [UIFont fontWithName:@"QuicksandBook-Regular" size:20];
	cell.textLabel.textColor = COLOR_LETRA;

	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40 + 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

	switch(indexPath.row)
	{
		case 0:
			{
				MoodleCalificacionesViewController *vc = [[MoodleCalificacionesViewController alloc] init];
				vc.URL = [asignatura objectAtIndex:1];
				vc.offlineFile= [asignatura objectAtIndex:0];
				[self.navigationController pushViewController:vc animated:YES];
			}
			break;
		case 1:
			{
				MoodleOtrasCalificacionesViewController *vc = [[MoodleOtrasCalificacionesViewController alloc] init];
				vc.URL = [asignatura objectAtIndex:1];
				vc.offlineFile= [asignatura objectAtIndex:0];
				[self.navigationController pushViewController:vc animated:YES];
			}
			break;
		case 2:
			{
				VisorWeb *vc = [[VisorWeb alloc] init];
				vc.URL = [asignatura objectAtIndex:1];
				vc.navViewTitle = [asignatura objectAtIndex:0];

				CATransition* transition = [CATransition animation];
				transition.duration = 0.40;
				transition.type = kCATransitionMoveIn;
				transition.subtype = kCATransitionFromBottom;
				[self.navigationController.view.layer addAnimation:transition forKey:nil];
				[self.navigationController pushViewController:vc animated:NO];
			}
			break;
		default:
			break;
	}
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





