#import "MoodleViewController.h"
#import "MoodleAsignaturaViewController.h"
#import "ECSlidingViewController.h"
#import "MenuViewController.h"
#import "AppDelegate.h"
#import "ModelUPM.h"

#define COLOR_LETRA [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:200/255.0]

@interface MoodleViewController ()
{
	NSString *URL;

	NSMutableArray *arrayAsignaturas;

	ModelUPM *modelo;
	UIButton* botonReload;
}

@end

@implementation MoodleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self)
	{

	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	// Unselect the selected row if any
	NSIndexPath*    selection = [self.tableView indexPathForSelectedRow];
	if (selection) {
		[self.tableView deselectRowAtIndexPath:selection animated:YES];
	}

	if(modelo.moodleEstaCargando == 0)
	{
		[self dejarDeAnimarLoading];
	}
	else
	{
		[self animarLoading];
	}
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	[self setNavTitleView];

	AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
	modelo = appDelegate.modelo;
	//modelo.delegate = self;
	[modelo addDelegate:self];

	arrayAsignaturas = [modelo getAsignaturas];
	[self.tableView reloadData];
}

- (void)setNavTitleView
{
	UILabel *titulo = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];

	titulo.text = @"Mis Cursos";
	titulo.textAlignment = NSTextAlignmentCenter;
	titulo.textColor = [UIColor whiteColor];
	titulo.backgroundColor = [UIColor clearColor];
	titulo.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:20];
	self.navigationItem.titleView = titulo;

	botonReload = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
	[botonReload addTarget:self action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
	botonReload.backgroundColor = [UIColor clearColor];
	[botonReload setBackgroundImage:[UIImage imageNamed:@"loading2"] forState:UIControlStateNormal];
	[botonReload setBackgroundImage:[UIImage imageNamed:@"loadingRed"] forState:UIControlStateDisabled];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:botonReload];


	UIButton* botonMenu = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
	[botonMenu addTarget:self action:@selector(revealMenu) forControlEvents:UIControlEventTouchUpInside];
	botonMenu.backgroundColor = [UIColor clearColor];
	[botonMenu setBackgroundImage:[UIImage imageNamed:@"menuButton"] forState:UIControlStateNormal];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:botonMenu];
}


// UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return arrayAsignaturas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ID"];

	if (cell == nil)
	{
		cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ID"];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

		cell.textLabel.numberOfLines = 2;
	}

	NSArray *asignatura = [arrayAsignaturas objectAtIndex:indexPath.row];
	cell.textLabel.text = [asignatura objectAtIndex:0];
	cell.textLabel.font = [UIFont fontWithName:@"QuicksandBook-Regular" size:20];
	cell.textLabel.textColor = COLOR_LETRA;

	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(!UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
	{
		return 70;
	}
	else
	{
		return 50;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	MoodleAsignaturaViewController *moodleAsignatura=[[MoodleAsignaturaViewController alloc]init];
	moodleAsignatura.asignatura = [[NSArray alloc]initWithArray:[arrayAsignaturas objectAtIndex:indexPath.row]];

	[self.navigationController pushViewController:moodleAsignatura animated:YES];
}


- (void)revealMenu
{
	[self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)configurarSlideView
{
	if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]])
	{
		self.slidingViewController.underLeftViewController  = [[MenuViewController alloc] init];
	}
}


- (void)animarLoading
{
	[botonReload setEnabled:NO];

	CABasicAnimation *rotationAnimation;
	rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	rotationAnimation.repeatCount = 1000;
	rotationAnimation.duration = 1;
	rotationAnimation.cumulative = YES;
	rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 * 1 * 1 ];
	rotationAnimation.removedOnCompletion = NO;
	[botonReload.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)dejarDeAnimarLoading
{
	[botonReload setEnabled:YES];
	[botonReload.layer removeAllAnimations];
}


- (void)reload
{
	[modelo addDelegate:self];
	[modelo cargarDatosMoodle];
	[self animarLoading];
}


// ModelUPM Delegate

- (void)modelUPMacaboDeCargarDatosMoodleConError:(NSString *)error
{
	if (error == nil)
	{
		arrayAsignaturas = [modelo getAsignaturas];
		[self.tableView reloadData];
	}
	else
	{
		UIAlertView *alerta = [[UIAlertView alloc]initWithTitle:@"ERROR DE MOODLE en página principal" message:error delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alerta show];
	}
	[modelo removeDelegate:self];
	[self dejarDeAnimarLoading];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

@end




