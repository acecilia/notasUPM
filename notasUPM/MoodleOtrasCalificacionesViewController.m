#import "MoodleOtrasCalificacionesViewController.h"
#import "MoodleWebViewViewController.h"
#import "AlmacenamientoLocal.h"
#import "QuartzCore/CAAnimation.h"
#import "AppDelegate.h"

#define COLOR_LETRA [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:200/255.0]
#define GRIS [UIColor colorWithRed:232/255.0 green:237/255.0 blue:241/255.0 alpha:1.0]

#define URL_MOODLE_LOGIN @"https://moodle.upm.es/titulaciones/oficiales/login/login.php"

@interface MoodleOtrasCalificacionesViewController ()
{
	UIWebView *miWebView;

	NSString *nombreDeUsuario;
	NSString *pass;

	NSMutableArray *arrayPDF;
	NSMutableArray *arraynombrePDF;

	UIButton *botonReload;

	ModelUPM *modelo;
	Descargador* descargador;
	UIAlertView *alertaDescargarTodo;
}

@end

@implementation MoodleOtrasCalificacionesViewController

@synthesize URL,offlineFile;

- (id)initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];
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
	if (selection) 
	{
		[self.tableView deselectRowAtIndexPath:selection animated:YES];
	}

	[self.tableView reloadData];
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
	modelo = appDelegate.modelo;
	//modelo.delegate = self;

	[self setNavView];
	[self animarLoading];

	miWebView = [[UIWebView alloc]init];
	miWebView.delegate = self;

	if(modelo.moodleEstaCargando == 0)
	{
		[miWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URL]]];
	}
	else
	{
		[modelo addDelegate:self];
	}

	arrayPDF =[AlmacenamientoLocal leer:[offlineFile stringByAppendingString:@"/PDFs.plist"]];

	[self.tableView reloadData];
}




/*- (void)buscarPDFs
  {
  NSString * nombrePDF,*URLPDF,*textoTag, *tipoDoc;

  arrayPDF=[[NSMutableArray alloc]init];

  int numTags = [[miWebView stringByEvaluatingJavaScriptFromString:@"document.getElementsByClassName('topics')[0].getElementsByTagName('a').length;"]intValue];

  for (int i = 0; i < numTags; i++)
  {
  textoTag = [miWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByClassName('topics')[0].getElementsByTagName('a')[%d].getElementsByTagName('img')[0].src;", i]];

//textoTag = [miWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByClassName('activity resource modtype_resource')[i].getElementsByTagName('a')[0].getElementsByTagName('img')[0].src;", i]];

//textoTag = [miWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByClassName('activity label modtype_label')[0].getElementsByTagName('a')[%d].getElementsByTagName('img')[0].src;", i]];



if ([textoTag rangeOfString:@"pdf"].location != NSNotFound || [textoTag rangeOfString:@"document"].location != NSNotFound)
{//aqui hay que ir especificando los diferentes tipos de documentos y la forma de previsualizarlos
if([textoTag rangeOfString:@"pdf"].location != NSNotFound)
{
tipoDoc=@".pdf";

nombrePDF= [miWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByClassName('topics')[0].getElementsByTagName('a')[%d].innerText;", i]];
nombrePDF =  [nombrePDF stringByReplacingOccurrencesOfString:@"Archivo" withString:@""];
nombrePDF =  [nombrePDF stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
nombrePDF=[nombrePDF stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

URLPDF = [miWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByClassName('topics')[0].getElementsByTagName('a')[%d].getAttribute('onclick');", i]];
NSArray *obteniendoURL = [URLPDF componentsSeparatedByString:@"\'"];

if([obteniendoURL count]>=2)
{
URLPDF=[obteniendoURL objectAtIndex:1];
}
else
{
URLPDF = [miWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByClassName('topics')[0].getElementsByTagName('a')[%d].getAttribute('href');", i]];
}

[arrayPDF addObject:[NSArray arrayWithObjects:nombrePDF, URLPDF, tipoDoc, nil]];
}
} 
}
[AlmacenamientoLocal escribir: arrayPDF:[offlineFile stringByAppendingString:@"/PDFs.plist"]];

}*/



- (void)buscarPDFs
{
	NSString * nombrePDF,*URLPDF,*textoTag, *tipoDoc, *tag;
	//NSString *textoSeccion, *nombreEntregable;

	arrayPDF=[[NSMutableArray alloc]init];

	int numTags = [[miWebView stringByEvaluatingJavaScriptFromString:@"document.getElementsByClassName('topics')[0].getElementsByTagName('*').length;"]intValue];

	for (int i = 0; i < numTags; i++)
	{
		tag =  [miWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByClassName('topics')[0].getElementsByTagName('*')[%d].tagName;", i]];

		if ([tag isEqualToString:@"A"])
		{
			textoTag = [miWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByClassName('topics')[0].getElementsByTagName('*')[%d].getElementsByTagName('img')[0].src;", i]];

			if ([textoTag rangeOfString:@"pdf"].location != NSNotFound || [textoTag rangeOfString:@"document"].location != NSNotFound)
			{//aqui hay que ir especificando los diferentes tipos de documentos y la forma de previsualizarlos
				if([textoTag rangeOfString:@"pdf"].location != NSNotFound)
				{
					tipoDoc=@".pdf";

					nombrePDF= [miWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByClassName('topics')[0].getElementsByTagName('*')[%d].innerText;", i]];
					nombrePDF =  [nombrePDF stringByReplacingOccurrencesOfString:@"Archivo" withString:@""];
					nombrePDF =  [nombrePDF stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
					nombrePDF=[nombrePDF stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

					URLPDF = [miWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByClassName('topics')[0].getElementsByTagName('*')[%d].getAttribute('onclick');", i]];
					NSArray *obteniendoURL = [URLPDF componentsSeparatedByString:@"\'"];

					if([obteniendoURL count]>=2)
					{
						URLPDF=[obteniendoURL objectAtIndex:1];
					}
					else
					{
						URLPDF = [miWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByClassName('topics')[0].getElementsByTagName('*')[%d].getAttribute('href');", i]];
					}

					[arrayPDF addObject:[NSArray arrayWithObjects:nombrePDF, URLPDF, tipoDoc, nil]];
				}
			}
			/*else if ([textoTag rangeOfString:@"icon"].location != NSNotFound)
			  {
			  nombreEntregable=[miWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByClassName('topics')[0].getElementsByTagName('*')[%d].innerText;", i]];

			  if(nombreEntregable.length>0)
			  [arrayPDF addObject:[NSArray arrayWithObjects:nombreEntregable, nil]];
			  }*/
		}
		/*else if ([tag isEqualToString:@"P"])
		  {
		  textoSeccion= [miWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByClassName('topics')[0].getElementsByTagName('*')[%d].innerText;", i]];
		  if(textoSeccion.length>0)
		  [arrayPDF addObject:[NSArray arrayWithObjects:textoSeccion, nil]];
		  }*/
	}
	[AlmacenamientoLocal escribir: arrayPDF:[offlineFile stringByAppendingString:@"/PDFs.plist"]];

}





- (void)setNavView
{
	UILabel *titulo = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];

	titulo.text = @"Documentos PDF";
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
	[miWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URL]]];
	[self animarLoading];

}

- (void)download
{
	[self animarLoading];

	descargador = [[Descargador alloc]init];
	descargador.delegate = self;

	alertaDescargarTodo = [[UIAlertView alloc]initWithTitle:@"Descargando PDFs" message:[[NSString stringWithFormat:@"%d/", 0] stringByAppendingString:[NSString stringWithFormat:@"%d", [arrayPDF count]]] delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles: nil];

	alertaDescargarTodo.tag = 13;

	[alertaDescargarTodo show];

	/*UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];

	// Adjust the indicator so it is up a few pixels from the bottom of the alert
	indicator.center = CGPointMake(alertaDescargarTodo.bounds.size.width / 2, alertaDescargarTodo.bounds.size.height - 50);
	[indicator startAnimating];
	[alertaDescargarTodo addSubview:indicator];*/

	[descargador descargarTodo:arrayPDF:offlineFile];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	if([webView.request.URL.absoluteString isEqualToString:URL_MOODLE_LOGIN])
	{ 
		[modelo addDelegate:self];
		if(modelo.moodleEstaCargando == NO)
		{
			[modelo cargarDatosMoodle];
		}
	} 

	if([webView.request.URL.absoluteString isEqualToString:URL])
	{ 
		[self buscarPDFs];
		if([arrayPDF count]==0)
		{
			UIAlertView *alerta = [[UIAlertView alloc]initWithTitle:@"ERROR" message:@"No se han encontrado PDF's" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alerta show];
		}
		else
		{
			[self.tableView reloadData];

			[botonReload removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents]; 
			[botonReload addTarget:self action:@selector(download) forControlEvents:UIControlEventTouchUpInside];
			botonReload.backgroundColor = [UIColor clearColor];
			[botonReload setBackgroundImage:[UIImage imageNamed:@"descargar"] forState:UIControlStateNormal];
			[botonReload setBackgroundImage:[UIImage imageNamed:@"loadingRed"] forState:UIControlStateDisabled];
			self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:botonReload];

		}
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	//[self.navigationController popToRootViewControllerAnimated:YES];
	if (alertView.tag == 13)
	{
		if (buttonIndex == 0)
		{
			descargador.delegate=nil;
			descargador=nil;
			[self dejarDeAnimarLoading];
		}
	}
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return arrayPDF.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ID"];

	if (((NSArray *)[arrayPDF objectAtIndex:indexPath.row]).count >1)
	{
		cell = [tableView dequeueReusableCellWithIdentifier:@"pdf"];
	}
	else
	{
		cell = [tableView dequeueReusableCellWithIdentifier:@"textoSeccion"];
	}

	if (cell == nil)
	{
		if (((NSArray *)[arrayPDF objectAtIndex:indexPath.row]).count >1)
		{
			cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"pdf"];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

			UIImageView* imagen= [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
			[cell addSubview:imagen];
			imagen.tag=1;
			imagen.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

			UILabel *texto = [[UILabel alloc] init];
			texto.backgroundColor=[UIColor clearColor];
			texto.font = [UIFont fontWithName:@"QuicksandBook-Regular" size:20];
			texto.textColor = COLOR_LETRA;
			texto.numberOfLines = 0;
			texto.lineBreakMode = NSLineBreakByWordWrapping;
			[cell addSubview:texto];
			texto.tag=2;
			texto.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		}
		else
		{
			cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"textoSeccion"];

			UIView *fondoTitulo = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
			fondoTitulo.backgroundColor=GRIS;
			[cell addSubview:fondoTitulo];
			fondoTitulo.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

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
	}

	if (((NSArray *)[arrayPDF objectAtIndex:indexPath.row]).count >1)
	{
		NSString* file=[[[offlineFile stringByAppendingString:@"/ArchivosPDF/"]stringByAppendingString:[[arrayPDF objectAtIndex:indexPath.row] objectAtIndex:0]]stringByAppendingString:[[arrayPDF objectAtIndex:indexPath.row] objectAtIndex:2]];

		((UIImageView *)[cell viewWithTag:1]).frame=CGRectMake(10, (cell.frame.size.height/2)-15, 30, 30);

		if([AlmacenamientoLocal existe:file])
		{
			((UIImageView *)[cell viewWithTag:1]).image = [UIImage imageNamed:@"saveOk"];
		}
		else
		{
			((UIImageView *)[cell viewWithTag:1]).image = [UIImage imageNamed:@"saveFail"];
		}

		((UILabel *)[cell viewWithTag:2]).frame=CGRectMake(30 +10 + 10, 15, cell.frame.size.width-30- 20-10-10-10, cell.frame.size.height-30);
		((UILabel *)[cell viewWithTag:2]).text= [[arrayPDF objectAtIndex:indexPath.row]objectAtIndex:0];
	}
	else
	{
		((UILabel *)[cell viewWithTag:1]).frame=CGRectMake(15, 15, cell.frame.size.width-30, cell.frame.size.height-30);
		((UILabel *)[cell viewWithTag:1]).text= [[arrayPDF objectAtIndex:indexPath.row]objectAtIndex:0];
		cell.userInteractionEnabled = NO;
	}

	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *str = @"";
	CGSize size = [str sizeWithFont:[UIFont fontWithName:@"QuicksandBook-Regular" size:20] constrainedToSize:CGSizeMake(280, 999) lineBreakMode:NSLineBreakByWordWrapping];

	if (((NSArray *)[arrayPDF objectAtIndex:indexPath.row]).count >1)
	{
		str = [[arrayPDF objectAtIndex:indexPath.row]objectAtIndex:0];

		if(!UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
		{
			size = [str sizeWithFont:[UIFont fontWithName:@"QuicksandBook-Regular" size:20] constrainedToSize:CGSizeMake([[UIScreen mainScreen] applicationFrame].size.width-30- 20-10-10-10, 999) lineBreakMode:NSLineBreakByWordWrapping];
		}
		else
		{
			size = [str sizeWithFont:[UIFont fontWithName:@"QuicksandBook-Regular" size:20] constrainedToSize:CGSizeMake([[UIScreen mainScreen] applicationFrame].size.height-30- 20-10-10-10, 999) lineBreakMode:NSLineBreakByWordWrapping];
		}
	}
	else
	{
		str = [[arrayPDF objectAtIndex:indexPath.row]objectAtIndex:0];

		if(!UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
		{
			size = [str sizeWithFont:[UIFont fontWithName:@"QuicksandBook-Regular" size:20] constrainedToSize:CGSizeMake([[UIScreen mainScreen] applicationFrame].size.width-30, 999) lineBreakMode:NSLineBreakByWordWrapping];
		}
		else
		{
			size = [str sizeWithFont:[UIFont fontWithName:@"QuicksandBook-Regular" size:20] constrainedToSize:CGSizeMake([[UIScreen mainScreen] applicationFrame].size.height-30, 999) lineBreakMode:NSLineBreakByWordWrapping];
		}
	}

	return size.height + 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	MoodleWebViewViewController *vc = [[MoodleWebViewViewController alloc] init];
	vc.URL = [[arrayPDF objectAtIndex:indexPath.row] objectAtIndex:1];
	vc.offlineFile=[[[offlineFile stringByAppendingString:@"/ArchivosPDF/"]stringByAppendingString:[[arrayPDF objectAtIndex:indexPath.row] objectAtIndex:0]]stringByAppendingString:[[arrayPDF objectAtIndex:indexPath.row] objectAtIndex:2]];
	vc.navViewTitle= [[arrayPDF objectAtIndex:indexPath.row] objectAtIndex:0];


	CATransition* transition = [CATransition animation];
	transition.duration = 0.40;
	transition.type = kCATransitionMoveIn;
	transition.subtype = kCATransitionFromBottom;
	[self.navigationController.view.layer addAnimation:transition forKey:nil];
	[self.navigationController pushViewController:vc animated:NO];
}

- (void)voyDescargandoPorElNumero:(int) numero conError:(NSString*) error
{
	if(error==nil)
	{
		alertaDescargarTodo.message=[[NSString stringWithFormat:@"%d/", numero+1] stringByAppendingString:[NSString stringWithFormat:@"%d", [arrayPDF count]]];
	}
	else
	{
		UIAlertView *alerta = [[UIAlertView alloc]initWithTitle:@"error" message:error delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alerta show];
	}
	[self.tableView reloadData];
}

- (void)acaboDeDescargarTodo
{
	[alertaDescargarTodo dismissWithClickedButtonIndex:0 animated:YES];
	[self dejarDeAnimarLoading];
	[self.tableView reloadData];
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
		UIAlertView *alerta = [[UIAlertView alloc]initWithTitle:@"ERROR DE MOODLE en vista de PDFs" message:error delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alerta show];

		[self dejarDeAnimarLoading];
	}
	[modelo removeDelegate:self];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

@end




