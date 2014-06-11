#import "ViewController.h"
#import "ECSlidingViewController.h"
#import "MenuViewController.h"
#import "AppDelegate.h"
#import "ModelUPM.h"
#import "Animador.h"

#import "almacenamientoLocal.h"

#define COLOR_PRINCIPAL [UIColor colorWithRed:85/255.0 green:172/255.0 blue:239/255.0 alpha:1.0] //AZUL NUEVO
#define COLOR_LETRA [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:200/255.0]

#define GRIS [UIColor colorWithRed:232/255.0 green:237/255.0 blue:241/255.0 alpha:1.0]


#define MOVER 152
#define MOVER_LABELS 12

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

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    if(modelo.moodleEstaCargando != 0)
	{
        [modelo addDelegate:self];
		[self animarLoading];
	}
}

- (void)loadView
{    
	self.view= [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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

	botonLogin = [[UIButton alloc]initWithFrame:CGRectMake(topView.frame.size.width-50, topView.frame.size.height-40, 30, 30)];
	[botonLogin addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
	botonLogin.backgroundColor = [UIColor clearColor];
	[botonLogin setBackgroundImage:[UIImage imageNamed:@"login"] forState:UIControlStateNormal];
	botonLogin.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
	[topView addSubview:botonLogin];

	botonReload = [[UIButton alloc]initWithFrame:CGRectMake(topView.frame.size.width-50, 10, 30, 30)];
	[botonReload addTarget:self action:@selector(actualizar) forControlEvents:UIControlEventTouchUpInside];
	botonReload.backgroundColor = [UIColor clearColor];
	[botonReload setBackgroundImage:[UIImage imageNamed:@"reload"] forState:UIControlStateNormal];
	[botonReload setBackgroundImage:[UIImage imageNamed:@"loadingRed"] forState:UIControlStateDisabled];
	botonReload.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
	[topView addSubview:botonReload];

	botonMenu = [[UIButton alloc]initWithFrame:CGRectMake(20, 10, 30, 30)];
	[botonMenu addTarget:self action:@selector(revealMenu) forControlEvents:UIControlEventTouchUpInside];
	botonMenu.backgroundColor = [UIColor clearColor];
	[botonMenu setBackgroundImage:[UIImage imageNamed:@"menuButton"] forState:UIControlStateNormal];
	botonMenu.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
	[topView addSubview:botonMenu];

	tabla=[[UITableView alloc] initWithFrame:CGRectMake(0, topView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-topView.frame.size.height)];
	tabla.allowsSelection = NO;
    tabla.backgroundColor=[UIColor clearColor];
	tabla.delegate=self;
	tabla.dataSource=self;
	tabla.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tabla.separatorStyle = UITableViewCellSeparatorStyleNone;
    tabla.rowHeight = 100;
    tabla.sectionHeaderHeight = 40;
	[self.view addSubview:tabla];
    
    UIView* colorAzul= [[UIView alloc] initWithFrame:CGRectMake(0, 0, tabla.frame.size.width, 0)];
	colorAzul.backgroundColor=COLOR_PRINCIPAL;
    colorAzul.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    colorAzul.tag = 1;
    tabla.backgroundView = [[UIImageView alloc] init];
    [tabla.backgroundView addSubview:colorAzul];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
	[tabla addGestureRecognizer:tap];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(tabla.contentOffset.y<=0)
    {
        [tabla.backgroundView viewWithTag:1].frame = CGRectMake(0, 0, tabla.frame.size.width, -tabla.contentOffset.y);
    }
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
            
            //[modelo cargarDatosPolitecnicaVirtual];
            //[modelo cargarDatosMoodle];
            //[self animarLoading];
            
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
            [modelo addDelegate:self];
            
            //resetea la vista:
            //elimina la imagen de la topView
            NSArray *viewsToRemove = [topView subviews];
            for (UIView *v in viewsToRemove) {
                if (v.tag == 1)
                    [v removeFromSuperview];
            }
            
            labelNombre.text=@"";
            labelApellido.text=@"";
            imageView=nil;
            
            TableDataNotas = [[NSMutableArray alloc]init];
            CabeceraSeccion = [[NSMutableArray alloc]init];
            
            [tabla reloadData];
            
            [AlmacenamientoLocal eliminarTodo];
        
            nombreDeUsuario = [alertView textFieldAtIndex:0].text;
			pass = [alertView textFieldAtIndex:1].text;
            
			// Crear Model
			[modelo inicializarConUsuario:nombreDeUsuario contraseña:pass];
			[modelo cargarDatosPolitecnicaVirtual];
			[modelo inicializarMoodleConNuevaCuenta];
            
            [self bajarVista];
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

        imageView.tag = 1;
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


	/*if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]])
	{
		//self.slidingViewController.underLeftViewController  = [[MenuViewController alloc] init];
		[self.slidingViewController setUnderLeftViewController:[[MenuViewController alloc]init]];
	}*/


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
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"Cell %li",(long)indexPath.section]];

	if(cell==nil)
	{
		cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[NSString stringWithFormat:@"Cell %li",(long)indexPath.section]];
        cell.contentView.backgroundColor=[UIColor whiteColor];
        [cell setFrame:CGRectMake(0, 0, tableView.frame.size.width, tableView.rowHeight)];

		UIView *fondoTitulo = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, tableView.rowHeight/4)];
		fondoTitulo.backgroundColor=GRIS;
		[cell addSubview:fondoTitulo];
		fondoTitulo.autoresizingMask = UIViewAutoresizingFlexibleWidth;

		UILabel *titulo = [[UILabel alloc] initWithFrame:CGRectMake(8, 2, cell.frame.size.width-20, tableView.rowHeight/4)];
		titulo.font=[UIFont fontWithName:@"QuicksandBook-Regular" size:18];
		titulo.backgroundColor=[UIColor clearColor];
		[cell addSubview:titulo];
		titulo.tag=1;
		titulo.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [titulo setAdjustsFontSizeToFitWidth:YES];

		UILabel *textoDerecha = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width/3, cell.frame.size.height/4, (cell.frame.size.width*2)/3-10, (cell.frame.size.height*3)/4)];
		textoDerecha.font=[UIFont fontWithName:@"QuicksandBook-Regular" size:18];
		textoDerecha.numberOfLines = 0;
		textoDerecha.backgroundColor=[UIColor clearColor];
		[cell addSubview:textoDerecha];
		textoDerecha.tag=2;
		textoDerecha.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;

		UILabel *textoIzquierda = [[UILabel alloc] initWithFrame:CGRectMake(8, cell.frame.size.height/4, cell.frame.size.width/3 -10, (cell.frame.size.height*3)/4)];
		textoIzquierda.font=[UIFont fontWithName:@"QuicksandBook-Regular" size:22];
		textoIzquierda.backgroundColor=[UIColor clearColor];
		[cell addSubview:textoIzquierda];
		textoIzquierda.tag=3;
		textoIzquierda.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
	}

	//titulo
	((UILabel *)[cell viewWithTag:1]).text=[[[[TableDataNotas objectAtIndex: indexPath.section] objectAtIndex: indexPath.row] objectAtIndex:0]capitalizedString];


	//información adicional
	UILabel* infoAdicional=((UILabel *)[cell viewWithTag:2]);
    
    infoAdicional.font=[UIFont fontWithName:@"QuicksandBook-Regular" size:18];
    
	infoAdicional.text=[[[TableDataNotas objectAtIndex: indexPath.section] objectAtIndex: indexPath.row] objectAtIndex:2];
    
    NSString *str = infoAdicional.text;
    
    CGSize size = [str sizeWithFont:infoAdicional.font constrainedToSize:CGSizeMake(infoAdicional.frame.size.width, 10000) lineBreakMode:NSLineBreakByWordWrapping];

    while(size.height > infoAdicional.frame.size.height)
    {
        infoAdicional.font=[UIFont fontWithName:@"QuicksandBook-Regular" size:infoAdicional.font.pointSize -1];
        
        size = [str sizeWithFont:infoAdicional.font constrainedToSize:CGSizeMake(infoAdicional.frame.size.width, 10000) lineBreakMode:NSLineBreakByWordWrapping];
    }
    
 

	//nota
	UILabel* nota=((UILabel *)[cell viewWithTag:3]);

	nota.text=[[[TableDataNotas objectAtIndex: indexPath.section] objectAtIndex: indexPath.row] objectAtIndex:1];

	size = [nota.text sizeWithFont:nota.font];
	if (size.width > nota.frame.size.width)
	{
        [nota setAdjustsFontSizeToFitWidth:YES];
	}
	else
	{
        [nota setAdjustsFontSizeToFitWidth:NO];
    }

	return cell;
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


-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [tabla reloadData];
}


// ModelUPM Delegate

/*- (void)modelUPMacaboDeCargarDatosExpedienteConError:(NSString *)error
{
    [modelo removeDelegate:self];
}*/

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

		UIAlertView *alerta = [[UIAlertView alloc]initWithTitle:@"ERROR DE POLITÉCNICA VIRTUAL en seccion Inicio" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alerta show];
	}
    [modelo removeDelegate:self];
    [self dejarDeAnimarLoading];
}

- (void)modelUPMacaboDeCargarDatosPersonalesconError:(NSString *)error
{
	if (error == nil)
	{
        NSArray *viewsToRemove = [topView subviews];
        for (UIView *v in viewsToRemove) {
            if (v.tag == 1)
                [v removeFromSuperview];
        }
        
        labelNombre.text=@"";
        labelApellido.text=@"";
        imageView=nil;
        
		/*if (labelNombre.text.length==0 || labelApellido.text.length==0)
		{
			labelNombre.text = [modelo getNombre];
			labelApellido.text = [modelo getApellidos];
		}

		if(imageView==nil)
		{
			[self drawImage];
		}*/
        labelNombre.text = [modelo getNombre];
        labelApellido.text = [modelo getApellidos];
        
        [self drawImage];
	}
	else
	{
		UIAlertView *alerta = [[UIAlertView alloc]initWithTitle:@"ERROR DE TOMA DE DATOS PERSONALES en seccion Inicio" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alerta show];
	}
}

/*- (void)modelUPMacaboDeCargarDatosMoodleConError:(NSString *)error
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
			UIAlertView *alerta = [[UIAlertView alloc]initWithTitle:@"ERROR DE MOODLE en seccion Inicio" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alerta show];
		}
	}
}*/


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
		}
        completion:^(BOOL finished)
         {
             botonLogin.alpha = 0;
         }];
	}
}

- (void)bajarVista
{
    if(topView.frame.origin.y==-MOVER)
	{
        [tabla setContentOffset:tabla.contentOffset animated:YES];
        botonLogin.alpha = 1;
        
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

/*- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView.contentOffset.y<0)
    {
        tabla.backgroundColor=COLOR_PRINCIPAL;
    }
    else
    {
        tabla.backgroundColor=[UIColor whiteColor];
    }
}*/

-(void) didTapOnTableView:(UIGestureRecognizer*) recognizer
{
	[self subirVista];
}



- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self subirVista];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	if (touch.view == topView && topView.frame.origin.y != 0)
	{
        [self bajarVista];
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end






