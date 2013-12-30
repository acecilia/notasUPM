#import "MoodleCalificacionesViewController.h"
#import "QuartzCore/CAAnimation.h"
#import "AlmacenamientoLocal.h"
#import "AppDelegate.h"

#define AZUL [UIColor colorWithRed:39/255.0 green:130/255.0 blue:191/255.0 alpha:1.0]
#define GRIS_OSCURO [UIColor colorWithRed:110/255.0 green:184/255.0 blue:236/255.0 alpha:1.0]
#define GRIS [UIColor colorWithRed:232/255.0 green:237/255.0 blue:241/255.0 alpha:1.0]
#define COLOR_PRINCIPAL [UIColor colorWithRed:85/255.0 green:172/255.0 blue:239/255.0 alpha:1.0] //AZUL NUEVO
#define URL_MOODLE_LOGIN @"https://moodle.upm.es/titulaciones/oficiales/login/login.php"

#define ALTURA_CELDA 100
#define ALTURA_CABECERA 44

@interface MoodleCalificacionesViewController ()
{
	UIWebView *miWebView;

	NSMutableArray *arrayCalificacionesSeparadas;

	UIButton *botonReload;

	ModelUPM *modelo;
}

@end

@implementation MoodleCalificacionesViewController

@synthesize URL, offlineFile;

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

	AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
	modelo = appDelegate.modelo;
	//modelo.delegate = self;
	[modelo addDelegate:self];

	URL =  [URL stringByReplacingOccurrencesOfString:@"course/view.php?" withString:@"grade/report/user/index.php?"];

	[self setNavView];

	[self animarLoading];
	self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
	miWebView = [[UIWebView alloc]init];
	miWebView.delegate = self;

	if(modelo.moodleEstaCargando == 0)
	{
		[miWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URL]]];
	}

	arrayCalificacionesSeparadas=[AlmacenamientoLocal leer:[offlineFile stringByAppendingString:@"/Calificaciones.plist"]];
	[self.tableView reloadData];

	//Para DEBUG
	/*miWebView.frame = CGRectMake(0, 240, 160, 240);
	  miWebView.scalesPageToFit=YES;
	  [self.view insertSubview: miWebView atIndex: 10];*/
}

- (void)setNavView
{
	UILabel *titulo = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];

	titulo.text = @"Calificaciones";
	titulo.textAlignment = NSTextAlignmentCenter;
	titulo.textColor = [UIColor whiteColor];
	titulo.backgroundColor = [UIColor clearColor];
	titulo.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:20];
	self.navigationItem.titleView = titulo;

	UIImage *imagenBack = [UIImage imageNamed:@"back"];
	UIButton *botonBack = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
	[botonBack addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchDown];
	[botonBack setBackgroundColor:[UIColor clearColor]];
	[botonBack setBackgroundImage:imagenBack forState:UIControlStateNormal];
	[botonBack setTitle:@"" forState:UIControlStateNormal];
	UIBarButtonItem *leftBack = [[UIBarButtonItem alloc]initWithCustomView:botonBack];
	self.navigationItem.leftBarButtonItem = leftBack;

	botonReload = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
	[botonReload addTarget:self action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
	botonReload.backgroundColor = [UIColor clearColor];
	[botonReload setBackgroundImage:[UIImage imageNamed:@"loading2"] forState:UIControlStateNormal];
	[botonReload setBackgroundImage:[UIImage imageNamed:@"loadingRed"] forState:UIControlStateDisabled];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:botonReload];

}





- (void)back
{
	[self.navigationController popViewControllerAnimated:YES];
	[modelo removeDelegate:self];
}

- (void)cogerCalificacionesMoodle
{
    //separa directamente las calificaciones ya que las almacena en un array en vez de en un NSString
	arrayCalificacionesSeparadas = [[NSMutableArray alloc]init];

	int numFilas = [[miWebView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('tbody')[0].getElementsByTagName('tr').length;"]intValue];

	for (int i = 0; i < numFilas ; i++)
	{
		int numColumnas = [[miWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"document.getElementsByTagName('tbody')[0].getElementsByTagName('tr')[%d].getElementsByTagName('td').length;", i]]intValue];


		// Coger titulo calificacion
		NSString *titulo = @"";

		titulo = [miWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"document.getElementsByTagName('tbody')[0].getElementsByTagName('tr')[%d].getElementsByTagName('th')[0].innerText;", i]];

		NSMutableArray *fila = [[NSMutableArray alloc]init];

		if (titulo.length != 0)
		{
			[fila addObject:titulo];
		}
        if(numColumnas>1)
        {
            for (int j = 0; j < numColumnas; j++)
            {
                NSString *celda;

                // Coger celdas
                celda = [miWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"document.getElementsByTagName('tbody')[0].getElementsByTagName('tr')[%d].getElementsByTagName('td')[%d].innerText;", i, j]];
                
                if(celda.length==0)
                {
                    celda = @"-";
                }

                if (celda != nil)
                {
                    //cada vez que coge una celda comprueba si el nombre de la columna es el de calificaciones o el de rango
                    //de calificaciones. Si es calficaciones añade el valor en la posición 1 (ya que en la 0 esta el título
                    // y si es el rango lo añade en la posición 2
                    
                        NSString *identificador = [miWebView stringByEvaluatingJavaScriptFromString:
                                         [NSString stringWithFormat:@"document.getElementsByTagName('thead')[0].getElementsByTagName('tr')[0].getElementsByTagName('th')[%d].id", j+1]];
                        
                        if([identificador isEqualToString:@"grade"])
                        {
                            while ([fila count]<1)
                            {
                                [fila addObject:@""];
                            }
                            [fila addObject:celda];
                        }
                        else if([identificador isEqualToString:@"range"])
                        {
                            while ([fila count]<2)
                            {
                                [fila addObject:@""];
                            }
                            [fila addObject:celda];
                        }
                }
            }
        }

		if (fila.count > 0)
		{
			[arrayCalificacionesSeparadas addObject:fila];
		}
	}
	if([arrayCalificacionesSeparadas count]==0)
	{
		UIAlertView *alerta = [[UIAlertView alloc]initWithTitle:@"ERROR" message:@"Esta asignatura no dispone de calificaciones" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		alerta.tag = 2;
		[alerta show];
	}
    
	[AlmacenamientoLocal escribir: arrayCalificacionesSeparadas:[offlineFile stringByAppendingString:@"/Calificaciones.plist"]];
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
	[miWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URL]]];
	[self animarLoading];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	if([webView.request.URL.absoluteString isEqualToString:URL_MOODLE_LOGIN])
	{ 
		if(modelo.moodleEstaCargando == NO)
		{
			[modelo cargarDatosMoodle];
		}
	}

	if([webView.request.URL.absoluteString isEqualToString:URL])
	{
		//modelo.delegate = nil;
		//[modelo removeDelegate:self];
		[self cogerCalificacionesMoodle];
		[self.tableView reloadData];
		[self dejarDeAnimarLoading];
	}
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	UIAlertView *alerta;

	if ([webView isLoading])
		[webView stopLoading];

	if (error.code != NSURLErrorNotConnectedToInternet)
	{
		NSString *descripcionError = [error localizedDescription];
		alerta = [[UIAlertView alloc]initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"Se ha producido un error en la conexión: %@", descripcionError] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		alerta.tag = 4;
		[alerta show];
	}

	[self dejarDeAnimarLoading];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return arrayCalificacionesSeparadas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;

	if (((NSArray *)[arrayCalificacionesSeparadas objectAtIndex:indexPath.row]).count >1)
	{
		cell = [tableView dequeueReusableCellWithIdentifier:@"calificacion"];
	}
	else
	{
		cell = [tableView dequeueReusableCellWithIdentifier:@"cabecera"];
	}

	if (cell == nil)
	{
		if (((NSArray *)[arrayCalificacionesSeparadas objectAtIndex:indexPath.row]).count >1)
		{
			cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"calificacion"];

			UIView *fondoTitulo = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, ALTURA_CELDA/4)];
			fondoTitulo.backgroundColor=GRIS;
			[cell addSubview:fondoTitulo];
			fondoTitulo.autoresizingMask = UIViewAutoresizingFlexibleWidth;

			UILabel *titulo = [[UILabel alloc] initWithFrame:CGRectMake(5, 2, cell.frame.size.width-10, ALTURA_CELDA/4)];
			titulo.font=[UIFont fontWithName:@"QuicksandBook-Regular" size:18];
			titulo.backgroundColor=[UIColor clearColor];
			[cell addSubview:titulo];
			titulo.tag=1;
			titulo.autoresizingMask = UIViewAutoresizingFlexibleWidth;

			UILabel *nota = [[UILabel alloc] initWithFrame:CGRectMake(5, ALTURA_CELDA/4+5, cell.frame.size.width/2-5, (ALTURA_CELDA*3)/4)];
			nota.font=[UIFont fontWithName:@"QuicksandBook-Regular" size:55];
			nota.backgroundColor=[UIColor clearColor];
			[cell addSubview:nota];
			nota.tag=2;
			nota.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            
            UIView *separador = [[UIView alloc] initWithFrame:CGRectMake(cell.frame.size.width/2, ALTURA_CELDA/4, 1, (ALTURA_CELDA*3)/4)];
			separador.backgroundColor=GRIS;
			[cell addSubview:separador];
			fondoTitulo.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            
            UILabel *maximo = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width/2 + 5 +1, ALTURA_CELDA/4 + 5, cell.frame.size.width/2-5, (ALTURA_CELDA*3)/4)];
			maximo.font=[UIFont fontWithName:@"QuicksandBook-Regular" size:55];
			maximo.backgroundColor=[UIColor clearColor];
			[cell addSubview:maximo];
			maximo.tag=3;
			maximo.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		}
		else
		{
			cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cabecera"];

			UIView *fondoTitulo = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, ALTURA_CABECERA)];
			fondoTitulo.backgroundColor = COLOR_PRINCIPAL;
			[cell addSubview:fondoTitulo];
			fondoTitulo.autoresizingMask = UIViewAutoresizingFlexibleWidth;

			UILabel *titulo = [[UILabel alloc] initWithFrame:CGRectMake(5, 2, cell.frame.size.width-10, ALTURA_CABECERA-2)];
			titulo.font=[UIFont fontWithName:@"QuicksandBold-Regular" size:18];
			titulo.backgroundColor=[UIColor clearColor];
			titulo.textColor = [UIColor whiteColor];
			[cell addSubview:titulo];
			titulo.tag=1;
			titulo.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		}

	}

	if (((NSMutableArray *)[arrayCalificacionesSeparadas objectAtIndex:indexPath.row]).count > 1)
	{
		((UILabel *)[cell viewWithTag:1]).text=[[arrayCalificacionesSeparadas objectAtIndex:indexPath.row]objectAtIndex:0];
        
        UILabel* nota = ((UILabel *)[cell viewWithTag:2]);
        nota.text=[[arrayCalificacionesSeparadas objectAtIndex:indexPath.row]objectAtIndex:1];
        CGSize size = [nota.text sizeWithFont:nota.font];
        if (size.width > nota.bounds.size.width)
        {
            nota.adjustsFontSizeToFitWidth=YES;
        }
        else
        {
            nota.adjustsFontSizeToFitWidth=NO;
        }
        
        if (((NSMutableArray *)[arrayCalificacionesSeparadas objectAtIndex:indexPath.row]).count > 2)
        {
            UILabel* maximo = ((UILabel *)[cell viewWithTag:3]);
            maximo.text=[[arrayCalificacionesSeparadas objectAtIndex:indexPath.row]objectAtIndex:2];
            size = [maximo.text sizeWithFont:nota.font];
            if (size.width > maximo.bounds.size.width)
            {
                maximo.adjustsFontSizeToFitWidth=YES;
            }
            else
            {
                maximo.adjustsFontSizeToFitWidth=NO;
            }
        }
	}
	else
	{
		((UILabel *)[cell viewWithTag:1]).text=[[[arrayCalificacionesSeparadas objectAtIndex:indexPath.row]objectAtIndex:0]uppercaseString];
	}

	return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat altura = ALTURA_CABECERA;

	if (((NSMutableArray *)[arrayCalificacionesSeparadas objectAtIndex:indexPath.row]).count > 1)
	{
		altura = ALTURA_CELDA;
	}

	return altura;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

// ModelUPM Delegate
- (void)modelUPMacaboDeCargarDatosMoodleConError:(NSString *)error
{
	if (error == nil)
	{
		[miWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URL]]];
	}
	else
	{
		UIAlertView *alerta = [[UIAlertView alloc]initWithTitle:@"ERROR DE MOODLE en calificaciones" message:error delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alerta show];

		[self dejarDeAnimarLoading];
	}
	[modelo removeDelegate:self];
}

@end





