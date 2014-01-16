#import "MoodleViewController.h"
#import "MoodleAsignaturaViewController.h"
#import "ECSlidingViewController.h"
#import "MenuViewController.h"
#import "AppDelegate.h"
#import "ModelUPM.h"

#import "AlmacenamientoLocal.h"

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

	if(modelo.moodleEstaCargando != 0)
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
	[botonReload setBackgroundImage:[UIImage imageNamed:@"reload"] forState:UIControlStateNormal];
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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"Eliminar";
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray* asignaturasEliminadas = [AlmacenamientoLocal leer:@"asignaturasEliminadas.plist"];
        if (asignaturasEliminadas == nil)
        {
            asignaturasEliminadas = [[NSMutableArray alloc] init];
        }
        [asignaturasEliminadas addObject:[arrayAsignaturas objectAtIndex:indexPath.row]];
        [AlmacenamientoLocal eliminar: [[arrayAsignaturas objectAtIndex:indexPath.row] objectAtIndex:0]];
        
        [arrayAsignaturas removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        [AlmacenamientoLocal escribir: asignaturasEliminadas:@"asignaturasEliminadas.plist"];
        [AlmacenamientoLocal escribir: arrayAsignaturas:@"asignaturas.plist"];
    }
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.navigationController.view removeGestureRecognizer:self.slidingViewController.panGesture];
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];
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
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = 1;
    animationGroup.repeatCount = HUGE_VALF;
    animationGroup.removedOnCompletion=NO;
    
	CABasicAnimation *rotationAnimation;
	rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	//rotationAnimation.repeatCount = INFINITY;
	rotationAnimation.duration = 1;
	//rotationAnimation.cumulative = YES;
	rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 * 1 * 1 ];
	rotationAnimation.removedOnCompletion = NO;
	//[botonReload.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.fromValue = @1.0;
    scale.toValue = @0.85;
    //scale.repeatCount = INFINITY;
	scale.duration = 0.5;
	//scale.cumulative = YES;
    scale.autoreverses = YES;
    scale.removedOnCompletion = NO;
    scale.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    animationGroup.animations = @[scale,rotationAnimation];
    [botonReload.layer addAnimation:animationGroup forKey:@"pulse"];
}

- (void)dejarDeAnimarLoading
{
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.toValue = @0.1;
    //scale.autoreverses=YES;
    scale.delegate = self;
    scale.duration = 0.5;
    scale.cumulative = YES;
    scale.removedOnCompletion = NO;
    scale.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [botonReload.layer addAnimation:scale forKey:@"scaleFinal"];
    
    //Es necesario repetir la animacion scale2 para que no se produzcan cosas raras
    CABasicAnimation *scale2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale2.fromValue = @0.1;
    scale2.toValue = @1.0;
    //scale2.autoreverses=YES;
    scale2.beginTime = CACurrentMediaTime()+scale.duration;
    scale2.duration = 0.5;
    scale2.cumulative = YES;
    scale2.removedOnCompletion = NO;
    scale2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [botonReload.layer addAnimation:scale2 forKey:@"scaleFinal2"];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    if(theAnimation == [botonReload.layer animationForKey:@"scaleFinal"])
    {
        [botonReload.layer removeAllAnimations];
        CABasicAnimation *scale2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scale2.fromValue = @0.1;
        scale2.toValue = @1.0;
        //scale2.autoreverses=YES;
        //scale2.beginTime = CACurrentMediaTime()+scale.duration;
        scale2.duration = 0.5;
        scale2.cumulative = YES;
        scale2.removedOnCompletion = NO;
        scale2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [botonReload.layer addAnimation:scale2 forKey:@"scaleFinal2"];
        
        CABasicAnimation *rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.duration = 0.5;
        //rotationAnimation.beginTime = CACurrentMediaTime()+scale.duration;
        rotationAnimation.delegate = self;
        rotationAnimation.fromValue = [NSNumber numberWithFloat: -M_PI];
        rotationAnimation.toValue = [NSNumber numberWithFloat: 0];
        rotationAnimation.removedOnCompletion = NO;
        rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [botonReload.layer addAnimation:rotationAnimation forKey:@"rotationAnimation2"];
        }
    else if(theAnimation == [botonReload.layer animationForKey:@"rotationAnimation2"])
    {
        [botonReload.layer removeAllAnimations];
        [botonReload setEnabled:YES];
    }
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
		UIAlertView *alerta = [[UIAlertView alloc]initWithTitle:@"ERROR DE MOODLE en página principal" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
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




