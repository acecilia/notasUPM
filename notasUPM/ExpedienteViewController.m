#import "ExpedienteViewController.h"
#import "ECSlidingViewController.h"
#import "MenuViewController.h"
#import "AppDelegate.h"
#import "ModelUPM.h"
#import "Animador.h"

#define COLOR_LETRA [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:200/255.0]
#define COLOR_PRINCIPAL [UIColor colorWithRed:85/255.0 green:172/255.0 blue:239/255.0 alpha:1.0] //AZUL NUEVO
#define GRIS [UIColor colorWithRed:232/255.0 green:237/255.0 blue:241/255.0 alpha:1.0]
#define GRIS_OSCURO [UIColor colorWithRed:215/255.0 green:222/255.0 blue:228/255.0 alpha:1.0]
#define VERDE [UIColor colorWithRed:75/255.0 green:241/255.0 blue:170/255.0 alpha:1.0]
#define ALTURA_CELDA 100

@interface ExpedienteViewController ()
{
	NSString *URL;

	NSMutableArray *arrayExpediente;

	ModelUPM *modelo;
	UIButton* botonReload;
}

@end

@implementation ExpedienteViewController
@synthesize numeroExpediente,tituloBarra;

- (id)init
{
	self = [super init];
	if (self)
    {
    	AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
        modelo = appDelegate.modelo;
        [modelo addDelegate:self];
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
    
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
	if([modelo.webViewPolitecnicaVirtual isLoading])
	{
		[self animarLoading];
	}
}

-(void) loadView
{
    [super loadView];
    
    [self setNavTitleView];
    
    self.navigationController.view.backgroundColor=[UIColor whiteColor];
    
    UIView* colorAzul= [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
	colorAzul.backgroundColor=COLOR_PRINCIPAL;
    colorAzul.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    colorAzul.tag = 1;
    self.tableView.backgroundView = [[UIImageView alloc] init];
    [self.tableView.backgroundView addSubview:colorAzul];
    
	self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.backgroundColor=[UIColor whiteColor];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(self.tableView.contentOffset.y<=0)
    {
        [self.tableView.backgroundView viewWithTag:1].frame = CGRectMake(0, 0, self.tableView.frame.size.width, -self.tableView.contentOffset.y);
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self.navigationController.navigationBar setShadowImage:nil];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
	arrayExpediente = [modelo getExpediente:numeroExpediente];
	[self.tableView reloadData];
}

- (void)setNavTitleView
{
	UILabel *titulo = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];

	titulo.text = tituloBarra;
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


	/*UIButton* botonMenu = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
	[botonMenu addTarget:self action:@selector(revealMenu) forControlEvents:UIControlEventTouchUpInside];
	botonMenu.backgroundColor = [UIColor clearColor];
	[botonMenu setBackgroundImage:[UIImage imageNamed:@"menuButton"] forState:UIControlStateNormal];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:botonMenu];*/
    
    UIImage *imagenBack = [UIImage imageNamed:@"back"];
	UIButton *botonBack = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
	[botonBack addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchDown];
	[botonBack setBackgroundColor:[UIColor clearColor]];
	[botonBack setBackgroundImage:imagenBack forState:UIControlStateNormal];
	[botonBack setTitle:@"" forState:UIControlStateNormal];
	UIBarButtonItem *leftBack = [[UIBarButtonItem alloc]initWithCustomView:botonBack];
	self.navigationItem.leftBarButtonItem = leftBack;
}

- (void)back
{
	[self.navigationController popViewControllerAnimated:YES];
	[modelo removeDelegate:self];
}


// UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [arrayExpediente count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return ([[arrayExpediente objectAtIndex: section] count]-2);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"Cell %li",(long)indexPath.section]];
	NSString * cadena=@"";

	if(cell==nil)
	{
		cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[NSString stringWithFormat:@"Cell %li",(long)indexPath.section]];
        cell.contentView.backgroundColor=[UIColor whiteColor];

		UIView *fondoTitulo = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, ALTURA_CELDA/4)];
		fondoTitulo.backgroundColor=GRIS;
		[cell addSubview:fondoTitulo];
		fondoTitulo.autoresizingMask = UIViewAutoresizingFlexibleWidth;

		UILabel *titulo = [[UILabel alloc] initWithFrame:CGRectMake(8, 2, cell.frame.size.width-15, ALTURA_CELDA/4)];
		titulo.font=[UIFont fontWithName:@"QuicksandBook-Regular" size:18];
		titulo.backgroundColor=[UIColor clearColor];
		[cell addSubview:titulo];
		titulo.tag=1;
		titulo.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        titulo.adjustsFontSizeToFitWidth = YES;

		UILabel *textoDerecha = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width/3, ALTURA_CELDA/4, (cell.frame.size.width*2)/3-10, (ALTURA_CELDA*3)/4)];
		textoDerecha.font=[UIFont fontWithName:@"QuicksandBook-Regular" size:18];
		textoDerecha.numberOfLines = 0;
		textoDerecha.lineBreakMode = NSLineBreakByWordWrapping;
		textoDerecha.backgroundColor=[UIColor clearColor];
        //textoDerecha.textAlignment = NSTextAlignmentCenter;
		[cell addSubview:textoDerecha];
		textoDerecha.tag=2;
		textoDerecha.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;

		UILabel *textoIzquierda = [[UILabel alloc] initWithFrame:CGRectMake(8, ALTURA_CELDA/4, cell.frame.size.width/3 -10, (ALTURA_CELDA*3)/4)];
		textoIzquierda.font=[UIFont fontWithName:@"QuicksandBook-Regular" size:22];
		textoIzquierda.backgroundColor=[UIColor clearColor];
		[cell addSubview:textoIzquierda];
		textoIzquierda.tag=3;
		textoIzquierda.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
	}

	//titulo
	((UILabel *)[cell viewWithTag:1]).text=[[[arrayExpediente objectAtIndex: indexPath.section] objectAtIndex: indexPath.row+2] objectAtIndex:0];

	//información adicional
	cadena=[cadena stringByAppendingString:@"Créditos: "];
	cadena=[cadena stringByAppendingString:[[[arrayExpediente objectAtIndex: indexPath.section] objectAtIndex: indexPath.row+2] objectAtIndex:1]];
	cadena=[cadena stringByAppendingString:@"\nPeriodo: " ];
	cadena=[cadena stringByAppendingString:[[[arrayExpediente objectAtIndex: indexPath.section] objectAtIndex: indexPath.row+2] objectAtIndex:2]];
	cadena=[cadena stringByAppendingString:@" " ];
	cadena=[cadena stringByAppendingString:[[[arrayExpediente objectAtIndex: indexPath.section] objectAtIndex: indexPath.row+2] objectAtIndex:3]];

	UILabel* infoAdicional=((UILabel *)[cell viewWithTag:2]);
	infoAdicional.text=cadena;
	cadena=@"";

	CGSize size = [infoAdicional.text sizeWithFont:infoAdicional.font];
	if (size.width > infoAdicional.bounds.size.width) 
	{
		infoAdicional.adjustsFontSizeToFitWidth=YES;
	}
	else
	{
		infoAdicional.adjustsFontSizeToFitWidth=NO;
	}

	//nota
	UILabel* nota=((UILabel *)[cell viewWithTag:3]);
	nota.text=[[[arrayExpediente objectAtIndex: indexPath.section] objectAtIndex: indexPath.row+2] objectAtIndex:4];

	size = [nota.text sizeWithFont:nota.font];
	if (size.width > nota.bounds.size.width) 
	{
		nota.adjustsFontSizeToFitWidth=YES;
	}
	else
	{
		nota.adjustsFontSizeToFitWidth=NO;
	}
    
    cell.backgroundColor = [UIColor redColor];


	return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return ALTURA_CELDA;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
	[header setBackgroundColor:COLOR_PRINCIPAL];

    //header.layer.shadowPath = [UIBezierPath bezierPathWithRect:header.bounds].CGPath;
	header.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
	header.layer.shadowOpacity = .20f;
	header.layer.shadowRadius = 1.0f;
	header.layer.masksToBounds = NO;
	header.layer.shouldRasterize = YES;
	header.layer.rasterizationScale = [UIScreen mainScreen].scale;

	NSString* cadena=@"";

	UILabel *tituloIzquierda = [[UILabel alloc]initWithFrame:CGRectMake(8, 2, [UIScreen mainScreen].bounds.size.width-18, 40)];

	[tituloIzquierda setTextColor:[UIColor whiteColor]];
	[tituloIzquierda setBackgroundColor:[UIColor clearColor]];
	[tituloIzquierda setTextAlignment:NSTextAlignmentLeft];
	[tituloIzquierda setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:20]];
	cadena=[cadena stringByAppendingString:[[arrayExpediente objectAtIndex: section] objectAtIndex: 0]];
	[tituloIzquierda setText:cadena];
	tituloIzquierda.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;

	[header addSubview:tituloIzquierda];

	UILabel *tituloDerecha = [[UILabel alloc]initWithFrame:CGRectMake(10, 2, [UIScreen mainScreen].bounds.size.width-18, 40)];

	[tituloDerecha setTextColor:VERDE];
	[tituloDerecha setBackgroundColor:[UIColor clearColor]];
	[tituloDerecha setTextAlignment:NSTextAlignmentRight];
	[tituloDerecha setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:20]];
	cadena=@"Media: ";
	cadena=[cadena stringByAppendingString:[[arrayExpediente objectAtIndex: section] objectAtIndex:1]];
	[tituloDerecha setText:cadena];
	tituloDerecha.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;

	[header addSubview:tituloDerecha];

	return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 40;
}

- (void)revealMenu
{
	[self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)animarLoading
{
    [botonReload setEnabled:NO];
    [Animador animarBoton:botonReload];
}

- (void)dejarDeAnimarLoading
{
    [Animador dejarDeAnimarBoton:botonReload conDelegate:self];
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
		arrayExpediente = [modelo getExpediente:numeroExpediente];
        if ([self isViewLoaded])
        {
            [self.tableView reloadData];
        }
	}
	else
	{
        UIAlertView *alerta = [[UIAlertView alloc]initWithTitle:@"ERROR DE POLITÉCNICA VIRTUAL en el expediente" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alerta show];
	}
	[modelo removeDelegate:self];
	[self dejarDeAnimarLoading];
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




