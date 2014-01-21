#import "ExpedienteViewController.h"
#import "ECSlidingViewController.h"
#import "MenuViewController.h"
#import "AppDelegate.h"
#import "ModelUPM.h"
#import "SelectorDeExpediente.h"

#define COLOR_LETRA [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:200/255.0]
#define COLOR_PRINCIPAL [UIColor colorWithRed:85/255.0 green:172/255.0 blue:239/255.0 alpha:1.0] //AZUL NUEVO

@interface SelectorDeExpediente ()
{
    
    NSMutableArray *arrayExpediente;
	ModelUPM *modelo;
	UIButton* botonReload;
}

@end

@implementation SelectorDeExpediente

- (id)initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];
	if (self) {}
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
    
	if([modelo.webViewPolitecnicaVirtual isLoading])
	{
		[self animarLoading];
	}
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
	self.navigationController.view.backgroundColor=[UIColor whiteColor];
    
	[self setNavTitleView];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
	AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
	modelo = appDelegate.modelo;
	[modelo addDelegate:self];
    
    self.tableView.backgroundColor=[UIColor whiteColor];
    
	arrayExpediente = [modelo getExpediente];
    
    if(arrayExpediente == nil)
    {
        arrayExpediente = [[NSMutableArray alloc]init];
    }
    
	[self.tableView reloadData];
}

- (void)setNavTitleView
{
	[self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
	UILabel *titulo = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    
	titulo.text = @"Expediente";
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
	return arrayExpediente.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ID"];

    cell = [tableView dequeueReusableCellWithIdentifier:@"pdf"];
    
	if (cell == nil)
	{
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"pdf"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UILabel *texto = [[UILabel alloc] init];
        texto.backgroundColor=[UIColor clearColor];
        texto.font = [UIFont fontWithName:@"QuicksandBook-Regular" size:20];
        texto.textColor = COLOR_LETRA;
        texto.numberOfLines = 0;
        texto.lineBreakMode = NSLineBreakByWordWrapping;
        [cell addSubview:texto];
        texto.tag=1;
        texto.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	}
    
    ((UILabel *)[cell viewWithTag:1]).frame=CGRectMake(10, 15, cell.frame.size.width- 20-10-10, cell.frame.size.height-30);
    ((UILabel *)[cell viewWithTag:1]).text= [[arrayExpediente objectAtIndex:indexPath.row]objectAtIndex:0];
    
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *str = @"";
	CGSize size = [str sizeWithFont:[UIFont fontWithName:@"QuicksandBook-Regular" size:20] constrainedToSize:CGSizeMake(280, 999) lineBreakMode:NSLineBreakByWordWrapping];
    
    str = [[arrayExpediente objectAtIndex:indexPath.row]objectAtIndex:0];
    
    if(!UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
    {
        size = [str sizeWithFont:[UIFont fontWithName:@"QuicksandBook-Regular" size:20] constrainedToSize:CGSizeMake([[UIScreen mainScreen] applicationFrame].size.width- 20-10-10, 999) lineBreakMode:NSLineBreakByWordWrapping];
    }
    else
    {
        size = [str sizeWithFont:[UIFont fontWithName:@"QuicksandBook-Regular" size:20] constrainedToSize:CGSizeMake([[UIScreen mainScreen] applicationFrame].size.height- 20-10-10, 999) lineBreakMode:NSLineBreakByWordWrapping];
    }
    
	return size.height + 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	ExpedienteViewController *vc = [[ExpedienteViewController alloc] init];
    vc.numeroExpediente= indexPath.row;
    vc.tituloBarra = [[arrayExpediente objectAtIndex:indexPath.row]objectAtIndex:0];
    
	[self.navigationController pushViewController:vc animated:YES];
}

- (void)revealMenu
{
	[self.slidingViewController anchorTopViewTo:ECRight];
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
    
	[modelo cargarDatosPolitecnicaVirtual];
	[self animarLoading];
}


// ModelUPM Delegate


- (void)modelUPMacaboDeCargarDatosExpedienteConError:(NSString *)error
{
	if (error == nil)
	{
		arrayExpediente = [modelo getExpediente];
		[self.tableView reloadData];
	}
	else
	{
        if (![error isEqualToString:@"Se ha producido un error, seguramente debido a una actualización de Politécnica Virtual. Acceda a través del navegador o inténtelo de nuevo más tarde. Disculpe las molestias."])
        {
            UIAlertView *alerta = [[UIAlertView alloc]initWithTitle:@"ERROR DE POLITÉCNICA VIRTUAL en el expediente" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alerta show];
        }
	}
	[modelo removeDelegate:self];
	[self dejarDeAnimarLoading];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

@end