#import "ViewController.h"
#import "ECSlidingViewController.h"
#import "MenuViewController.h"
#import "AppDelegate.h"
#import "ModelUPM.h"

#define COLOR_PRINCIPAL [UIColor colorWithRed:85/255.0 green:172/255.0 blue:239/255.0 alpha:1.0] //AZUL NUEVO
#define COLOR_LETRA [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:200/255.0]

#define GRIS [UIColor colorWithRed:232/255.0 green:237/255.0 blue:241/255.0 alpha:1.0]


#define MOVER 152
#define MOVER_LABELS 12

#define ALTURA_CELDA 100

#define modoDebug NO  ////////////////////MODO DEGUB///////////////////////////////


@interface ViewController ()
{
	UIView *topView;
	UILabel *labelNombre;
	UILabel *labelApellido;
	UITableView *tabla;
	UIButton *botonLogin;
	UIButton *botonReload;
	UIButton *botonMenu;

	NSString *nombreDeUsuario;
	NSString *pass;

	CGPoint puntoTocado;
	CGPoint puntoArrastrado;

	NSMutableArray *TableDataNotas;
	NSMutableArray *CabeceraSeccion;

	ModelUPM *modelo;
	AppDelegate *appDelegate;

	UIImageView *imageView;
}

@end

@implementation ViewController


- (void)loadView
{
	self.view= [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	topView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.view.backgroundColor=[UIColor whiteColor];

	topView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
	topView.backgroundColor=COLOR_PRINCIPAL;
	topView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:topView];

	labelNombre = [[UILabel alloc] initWithFrame:CGRectMake(20, 145,topView.frame.size.width-40, 20)];
	labelNombre.textColor = [UIColor whiteColor];
	labelNombre.font = [UIFont fontWithName:@"QuicksandBook-Regular" size:18];
	labelNombre.backgroundColor=[UIColor clearColor];
	labelNombre.lineBreakMode = NSLineBreakByWordWrapping;
	labelNombre.textAlignment=NSTextAlignmentCenter;
	labelNombre.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
	[topView addSubview:labelNombre];

	labelApellido = [[UILabel alloc] initWithFrame:CGRectMake(20, 165,topView.frame.size.width-40, 20)];
	labelApellido.textColor = [UIColor whiteColor];
	labelApellido.font = [UIFont fontWithName:@"QuicksandBook-Regular" size:18];
	labelApellido.backgroundColor=[UIColor clearColor];
	labelApellido.lineBreakMode = NSLineBreakByWordWrapping;
	labelApellido.textAlignment=NSTextAlignmentCenter;
	labelApellido.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
	[topView addSubview:labelApellido];

	botonLogin = [[UIButton alloc]initWithFrame:CGRectMake(topView.frame.size.width-40, topView.frame.size.height-40, 30, 30)];
	[botonLogin addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
	botonLogin.backgroundColor = [UIColor clearColor];
	[botonLogin setBackgroundImage:[UIImage imageNamed:@"login"] forState:UIControlStateNormal];
	botonLogin.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
	[topView addSubview:botonLogin];

	botonReload = [[UIButton alloc]initWithFrame:CGRectMake(topView.frame.size.width-40, 10, 30, 30)];
	[botonReload addTarget:self action:@selector(actualizar) forControlEvents:UIControlEventTouchUpInside];
	botonReload.backgroundColor = [UIColor clearColor];
	[botonReload setBackgroundImage:[UIImage imageNamed:@"loading2"] forState:UIControlStateNormal];
	[botonReload setBackgroundImage:[UIImage imageNamed:@"loadingRed"] forState:UIControlStateDisabled];
	botonReload.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
	[topView addSubview:botonReload];

	botonMenu = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 30, 30)];
	[botonMenu addTarget:self action:@selector(revealMenu) forControlEvents:UIControlEventTouchUpInside];
	botonMenu.backgroundColor = [UIColor clearColor];
	[botonMenu setBackgroundImage:[UIImage imageNamed:@"menuButton"] forState:UIControlStateNormal];
	botonMenu.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
	[topView addSubview:botonMenu];

	tabla=[[UITableView alloc] initWithFrame:CGRectMake(0, topView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-topView.frame.size.height)];
	tabla.allowsSelection = NO;
	tabla.delegate=self;
	tabla.dataSource=self;
	tabla.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:tabla];

	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
	[tabla addGestureRecognizer:tap];

}




- (void)viewDidLoad
{
	[super viewDidLoad];

	appDelegate = [[UIApplication sharedApplication]delegate];
	modelo = appDelegate.modelo;
	//modelo.delegate = self;
	[modelo addDelegate:self];

	TableDataNotas = [[NSMutableArray alloc]init];
	CabeceraSeccion = [[NSMutableArray alloc]init];

	nombreDeUsuario = @"";
	pass = @"";
	imageView=nil;



	[self recuperar];

	if (nombreDeUsuario.length == 0 || pass.length == 0)
	{
		[self login];
	}
	else
	{
		if (!appDelegate.yaCargoModelo)
		{
			// Si se ejecuta la app por primera vez crea el modelo
			[modelo inicializarConUsuario:nombreDeUsuario contraseña:pass];
			[modelo cargarDatosMoodle];
			[modelo cargarDatosPolitecnicaVirtual];
			[self animarLoading];

			//ya se ha cargado el modelo por primera vez
			appDelegate.yaCargoModelo = YES;
		}
		else
		{
			if ([modelo.webViewPolitecnicaVirtual isLoading])
			{
				[self animarLoading];
			}
		}

		//carga offline
		[self drawImage];
		labelNombre.text = [modelo getNombre];
		labelApellido.text = [modelo getApellidos];
		TableDataNotas = [modelo getConvocatorias];
		CabeceraSeccion = [modelo getSections];

		[tabla reloadData];
	}

	[self configurarSlideView];

	if(modoDebug)
	{
		[self.view addSubview:modelo.webViewPolitecnicaVirtual];
		[self.view addSubview:modelo.webViewMoodle];
	}
}

- (void)login
{
	UIAlertView *alertLogin = [[UIAlertView alloc]initWithTitle:@"LOGIN" message:nil delegate:self cancelButtonTitle:@"CANCELAR" otherButtonTitles:@"OK", nil];
	[alertLogin setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
	[alertLogin textFieldAtIndex:0].placeholder = @"Correo UPM";
	[alertLogin textFieldAtIndex:1].placeholder = @"Contraseña";
	alertLogin.tag = 1;
	[alertLogin show];

	[alertLogin textFieldAtIndex:0].text = nombreDeUsuario;
	[alertLogin textFieldAtIndex:1].text = pass;
}


// UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 1)
	{
		if (buttonIndex == 1)
		{
			nombreDeUsuario = [alertView textFieldAtIndex:0].text;
			pass = [alertView textFieldAtIndex:1].text;

			// Crear Model
			[modelo inicializarConUsuario:nombreDeUsuario contraseña:pass];
			[modelo cargarDatosPolitecnicaVirtual];
			[modelo cargarDatosMoodle];

			[self animarLoading];

			[self guardar];
		}
		else if (buttonIndex == 0)
		{
			[alertView dismissWithClickedButtonIndex:0 animated:YES];
		}
	}
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
	BOOL enableOKButton = NO;

	if (alertView.tag == 1)
	{

		if ([alertView isVisible])
		{
			if ([alertView textFieldAtIndex:0].text.length == 0 || [alertView textFieldAtIndex:1].text.length == 0)
			{
				enableOKButton = NO;
			}
			else
			{
				enableOKButton = YES;
			}
		}
		else
		{
			if ((nombreDeUsuario.length == 0 || pass.length == 0))
			{
				enableOKButton = NO;
			}
			else
			{
				enableOKButton = YES;
			}
		}
	}

	return enableOKButton;
}



- (void) drawImage
{
	UIImage *image = [modelo getFoto];

	if(image!=nil && imageView==nil)
	{
		// Pillar foto del Model
		imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, image.size.width*0.6, image.size.width*0.6)];

		imageView.center = CGPointMake(topView.frame.size.width/2, topView.frame.size.height/2 - 15);
		[imageView setAutoresizingMask:(UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin)];
		[imageView setContentMode:UIViewContentModeScaleAspectFit];
		[imageView setImage:image];
		[imageView setBackgroundColor:[UIColor whiteColor]];

		[self addRoundMask:imageView];

		[topView addSubview:imageView];
	}
}


- (void)addRoundMask:(UIImageView *)imageView1
{
	// Get the Layer of any view
	CALayer *lyr = [imageView1 layer];
	lyr.shouldRasterize=YES;  //evita que todo se enlentezca cuando aparece la imagen en topView. baja la resolucion de la imagen
	lyr.rasterizationScale = [[UIScreen mainScreen] scale]; //evita que todo se enlentezca cuando aparece la imagen en topView. vuelve a subir la resolucion de la imagen
	[lyr setBorderWidth:1.0f]; 
	[lyr setMasksToBounds:YES];
	[lyr setCornerRadius:imageView1.frame.size.width/2];

	// You can even add a border
	[lyr setBorderWidth:3.0];
	[lyr setBorderColor:[[UIColor whiteColor] CGColor]];
}

- (UIImage *)imageBlackAndWhite:(UIImage *)imagen
{
	CIImage *beginImage = [CIImage imageWithCGImage:imagen.CGImage];

	CIImage *blackAndWhite = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, beginImage, @"inputBrightness", [NSNumber numberWithFloat:0.0], @"inputContrast", [NSNumber numberWithFloat:1.1], @"inputSaturation", [NSNumber numberWithFloat:0.0], nil].outputImage;
	CIImage *output = [CIFilter filterWithName:@"CIExposureAdjust" keysAndValues:kCIInputImageKey, blackAndWhite, @"inputEV", [NSNumber numberWithFloat:0.7], nil].outputImage;

	CIContext *context = [CIContext contextWithOptions:nil];
	CGImageRef cgiimage = [context createCGImage:output fromRect:output.extent];
	UIImage *newImage = [UIImage imageWithCGImage:cgiimage];

	CGImageRelease(cgiimage);

	return newImage;
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


- (void)actualizar
{
	[modelo addDelegate:self];
	[self animarLoading];

	// Volver a cargar Model
	[modelo cargarDatosPolitecnicaVirtual];

	// [self drawImage];
}

- (void)revealMenu
{
	[self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)configurarSlideView
{
	self.view.layer.shadowOpacity = 0.75f;
	self.view.layer.shadowRadius = 10.0f;
	self.view.layer.shadowColor = [UIColor blackColor].CGColor;


	if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]])
	{
		//self.slidingViewController.underLeftViewController  = [[MenuViewController alloc] init];
		[self.slidingViewController setUnderLeftViewController:[[MenuViewController alloc]init]];
	}


	[self.view addGestureRecognizer:self.slidingViewController.panGesture];
}


- (void)guardar
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:nombreDeUsuario forKey:@"kNomreUsuario"];
	[userDefaults setObject:pass forKey:@"kPass"];
	[userDefaults synchronize];
}

- (void)recuperar
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	nombreDeUsuario = [userDefaults objectForKey:@"kNomreUsuario"];
	pass = [userDefaults objectForKey:@"kPass"];
}


// UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [TableDataNotas count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return ([[TableDataNotas objectAtIndex: section] count]);
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"Cell %i",indexPath.section]];
	NSString * cadena=@"";

	if(cell==nil)
	{
		cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[NSString stringWithFormat:@"Cell %i",indexPath.section]];

		UIView *fondoTitulo = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, ALTURA_CELDA/4)];
		fondoTitulo.backgroundColor=GRIS;
		[cell addSubview:fondoTitulo];
		fondoTitulo.autoresizingMask = UIViewAutoresizingFlexibleWidth;

		UILabel *titulo = [[UILabel alloc] initWithFrame:CGRectMake(5, 2, cell.frame.size.width-10, ALTURA_CELDA/4)];
		titulo.font=[UIFont fontWithName:@"QuicksandBook-Regular" size:18];
		titulo.backgroundColor=[UIColor clearColor];
		[cell addSubview:titulo];
		titulo.tag=1;
		titulo.autoresizingMask = UIViewAutoresizingFlexibleWidth;

		UILabel *textoDerecha = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width/3, ALTURA_CELDA/4, (cell.frame.size.width*2)/3-10, (ALTURA_CELDA*3)/4)];
		textoDerecha.font=[UIFont fontWithName:@"QuicksandBook-Regular" size:18];
		textoDerecha.numberOfLines = 0;
		textoDerecha.lineBreakMode = NSLineBreakByWordWrapping;
		textoDerecha.backgroundColor=[UIColor clearColor];
		[cell addSubview:textoDerecha];
		textoDerecha.tag=2;
		textoDerecha.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;

		UILabel *textoIzquierda = [[UILabel alloc] initWithFrame:CGRectMake(5, ALTURA_CELDA/4, cell.frame.size.width/3 -10, (ALTURA_CELDA*3)/4)];
		textoIzquierda.font=[UIFont fontWithName:@"QuicksandBook-Regular" size:22];
		textoIzquierda.backgroundColor=[UIColor clearColor];
		[cell addSubview:textoIzquierda];
		textoIzquierda.tag=3;
		textoIzquierda.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
	}

	//titulo
	((UILabel *)[cell viewWithTag:1]).text=[[[[TableDataNotas objectAtIndex: indexPath.section] objectAtIndex: indexPath.row] objectAtIndex:0]capitalizedString];


	//información adicional
	cadena=[cadena stringByAppendingString:[[[TableDataNotas objectAtIndex: indexPath.section] objectAtIndex: indexPath.row] objectAtIndex:2]];

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

	nota.text=[[[TableDataNotas objectAtIndex: indexPath.section] objectAtIndex: indexPath.row] objectAtIndex:1];

	size = [nota.text sizeWithFont:nota.font];
	if (size.width > nota.bounds.size.width) 
	{
		nota.adjustsFontSizeToFitWidth=YES;
	}
	else
	{
		nota.adjustsFontSizeToFitWidth=NO;
	}



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

	header.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
	header.layer.shadowOpacity = .20f;
	header.layer.shadowRadius = 1.0f;
	header.layer.masksToBounds = NO;
	header.layer.shouldRasterize = YES;
	header.layer.rasterizationScale = [UIScreen mainScreen].scale;

	UILabel *titulo = [[UILabel alloc]initWithFrame:CGRectMake(0, 2, [UIScreen mainScreen].bounds.size.width, 40)];

	[titulo setTextColor:[UIColor whiteColor]];
	[titulo setBackgroundColor:[UIColor clearColor]];
	[titulo setTextAlignment:NSTextAlignmentCenter];
	[titulo setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:18]];
	[titulo setText:[CabeceraSeccion objectAtIndex:section]];
	titulo.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;

	[header addSubview:titulo];

	return header;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [CabeceraSeccion objectAtIndex:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 40;
}


// ModelUPM Delegate

- (void)modelUPMacaboDeCargarDatosExpedienteConError:(NSString *)error
{
	[modelo removeDelegate:self];
	[self dejarDeAnimarLoading];
}

- (void)modelUPMacaboDeCargarDatosTablonDeNotasConError:(NSString *)error
{
	if (error == nil)
	{
		TableDataNotas = [modelo getConvocatorias];
		CabeceraSeccion = [modelo getSections];

		[tabla reloadData];
		[self subirVista];
	}
	else
	{

		UIAlertView *alerta = [[UIAlertView alloc]initWithTitle:@"ERROR DE POLITÉCNICA VIRTUAL en seccion Inicio" message:error delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alerta show];
		[self dejarDeAnimarLoading];
	}
}

- (void)modelUPMacaboDeCargarDatosPersonalesconError:(NSString *)error
{
	if (error == nil)
	{ 
		if (labelNombre.text.length==0 || labelApellido.text.length==0)
		{
			labelNombre.text = [modelo getNombre];
			labelApellido.text = [modelo getApellidos];
		}

		if(imageView==nil)
		{
			[self drawImage];
		}
	}
	else
	{
		UIAlertView *alerta = [[UIAlertView alloc]initWithTitle:@"ERROR DE TOMA DE DATOS PERSONALES en seccion Inicio" message:error delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alerta show];
	}
}

- (void)modelUPMacaboDeCargarDatosMoodleConError:(NSString *)error
{
	if (error == nil)
	{

	}
	else
	{

		if ([error isEqualToString:@"No está conectado a Internet"])
		{

		}
		else
		{
			UIAlertView *alerta = [[UIAlertView alloc]initWithTitle:@"ERROR DE MOODLE en seccion Inicio" message:error delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alerta show];
		}
	}
}


- (void)subirVista
{
	if(topView.frame.origin.y==0)
	{
		[UIView animateWithDuration:0.3  animations:^(void)
		{
			topView.center = CGPointMake(topView.center.x, topView.center.y - MOVER);
			botonLogin.center = CGPointMake(botonLogin.center.x, botonLogin.center.y + MOVER);
			botonReload.center = CGPointMake(botonReload.center.x, botonReload.center.y + MOVER);
			botonMenu.center = CGPointMake(botonMenu.center.x, botonMenu.center.y + MOVER);
			labelNombre.center = CGPointMake(labelNombre.center.x, labelNombre.center.y + MOVER_LABELS);
			labelApellido.center = CGPointMake(labelApellido.center.x, labelApellido.center.y + MOVER_LABELS);
			[tabla setFrame:CGRectMake(0, tabla.frame.origin.y
					- MOVER, tabla.frame.size.width, tabla.frame.size.height + MOVER)];
		}];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (topView.frame.origin.y == 0 && scrollView.tracking==YES)
	{
		[self subirVista];
	}
	else if(topView.frame.origin.y==0 && scrollView.contentOffset.y!=0)
	{
		[scrollView setContentOffset:scrollView.contentOffset animated:YES];
	}
}

-(void) didTapOnTableView:(UIGestureRecognizer*) recognizer {
	[self subirVista];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	if (touch.view == topView && topView.frame.origin.y != 0)
	{
		[UIView animateWithDuration:0.3  animations:^(void)
		{
			topView.center = CGPointMake(topView.center.x, topView.center.y + MOVER);
			botonLogin.center = CGPointMake(botonLogin.center.x, botonLogin.center.y - MOVER);
			botonMenu.center = CGPointMake(botonMenu.center.x, botonMenu.center.y - MOVER);
			botonReload.center = CGPointMake(botonReload.center.x, botonReload.center.y - MOVER);
			labelNombre.center = CGPointMake(labelNombre.center.x, labelNombre.center.y - MOVER_LABELS);
			labelApellido.center = CGPointMake(labelApellido.center.x, labelApellido.center.y - MOVER_LABELS);
			[tabla setFrame:CGRectMake(0, tabla.frame.origin.y + MOVER, tabla.frame.size.width, tabla.frame.size.height)];
		}
completion:^(BOOL finished)
	   {
		   [tabla setFrame:CGRectMake(0, tabla.frame.origin.y, tabla.frame.size.width, tabla.frame.size.height - MOVER)];
	   }];
	}
}


-(UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleDefault;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end





