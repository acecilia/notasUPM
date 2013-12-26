#import "ModelUPM.h"
#import "AlmacenamientoLocal.h"

#define URL_POLITECNICA_VIRTUAL @"https://www.upm.es/politecnica_virtual/?c=1693DLFOA"
#define URL_MOODLE_LOGIN @"https://moodle.upm.es/titulaciones/oficiales/login/login.php"
#define URL_MOODLE @"http://moodle.upm.es/titulaciones/oficiales/"

@interface ModelUPM ()
{
	int indicePV;
	NSMutableArray* delegates;
}

@end

@implementation ModelUPM

@synthesize webViewMoodle;
@synthesize webViewPolitecnicaVirtual;
@synthesize moodleEstaCargando;

- (id)init
{
	if (self = [super init])
	{
		delegates = [[NSMutableArray alloc] init];
	}
	return self;
}


-(void) despertarDelegatesParaEvento:(SEL)evento
{
	NSArray *arrayToEnumerate = [delegates copy];

	for(id delegate in arrayToEnumerate)
	{
		if ([delegate respondsToSelector: evento]) 
		{
			IMP metodo = [delegate methodForSelector:evento];
            void (*func)(__strong id,SEL,NSString*) = (void (*)(__strong id, SEL,NSString*))metodo;
			func(delegate, evento, errorDescription);
		}
	}
}

- (void)addDelegate:(id)delegate
{
	NSArray *arrayToEnumerate = [delegates copy];

	for(id delegateLoop in arrayToEnumerate)
	{
		if ([[delegateLoop class] isEqual:[delegate class]]) 
		{
			[self removeDelegate: delegateLoop];
		}
	}

	[delegates addObject:delegate];

	/*NSArray *arrayToEnumerate2 = [delegates copy];
	  NSLog(@"\n\n\n\nAñadiendo delegate:\n");
	  NSLog(@"Numero de delegates: %d\n",[delegates count]);
	  for(id delegateLoop in arrayToEnumerate2)
	  {
	  NSLog(@"Delegate: %@\n",NSStringFromClass([delegateLoop class]));
	  }
	  NSLog(@"\n\n\n\nFIN");*/


}

- (void)removeDelegate:(id)delegate
{
	[delegates removeObjectIdenticalTo:delegate];

	/*NSArray *arrayToEnumerate = [delegates copy];
	  NSLog(@"\n\n\n\nEliminado delegate: %@\n",NSStringFromClass([delegate class]));
	  NSLog(@"Numero de delegates: %d\n",[delegates count]);
	  for(id delegateLoop in arrayToEnumerate)
	  {
	  NSLog(@"Delegate: %@\n",NSStringFromClass([delegateLoop class]));
	  }
	  NSLog(@"\n\n\n\nFIN");*/
}


//pone las webviews en modo escritorio
+ (void)initialize {
	// Set user agent (the only problem is that we can't modify the User-Agent later in the program)
	NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:@"Mozilla/5.0", @"UserAgent", nil];
	[[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];

}

- (void)inicializarConUsuario:(NSString *)usuario contraseña:(NSString *)contraseña
{
	user = usuario;
	pass = contraseña;

	indicePV = 0;

	TableDataNotas = [[NSMutableArray alloc]init];
}


// Politecnica Virtual

- (void)cargarDatosPolitecnicaVirtual
{
	indicePV=0;
	webViewPolitecnicaVirtual = [[UIWebView alloc]init];

	webViewPolitecnicaVirtual.frame = CGRectMake(0, 240, 160, 240);
	webViewPolitecnicaVirtual.scalesPageToFit=YES;

	webViewPolitecnicaVirtual.delegate = self;
	[webViewPolitecnicaVirtual loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URL_POLITECNICA_VIRTUAL]]];

	TableDataNotas=[AlmacenamientoLocal leer:@"TableDataNotas.plist"];
	CabeceraSeccion=[AlmacenamientoLocal leer:@"CabeceraSeccion.plist"];
	expediente=[AlmacenamientoLocal leer:@"expediente.plist"];
	nombre=[AlmacenamientoLocal leerString:@"Nombre.plist"];
	apellidos=[AlmacenamientoLocal leerString:@"Apellidos.plist"];
	foto=[AlmacenamientoLocal leerImagen:@"fotoDePerfil.png"];

}

- (void)loginPolitecnicaVirtual
{
	[webViewPolitecnicaVirtual stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('user').value='%@';", user]];
	[webViewPolitecnicaVirtual stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('pass').value='%@';", pass]];
	[webViewPolitecnicaVirtual stringByEvaluatingJavaScriptFromString:@"document.getElementById('form_login_enviar').click();"];
}

- (NSString*)cargarFoto
{
	NSString *dirImagen = [webViewPolitecnicaVirtual stringByEvaluatingJavaScriptFromString:@"document.getElementById('usuario_datos').getElementsByTagName('dd')[0].getElementsByTagName('img')[0].src;"];

	//NSURLResponse *response;
	NSURL *url = [[NSURL alloc] initWithString:dirImagen];
	//NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
	//[NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:nil];
	foto = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];

	[AlmacenamientoLocal escribirImagen: foto:@"fotoDePerfil.png"];

	return dirImagen;
}



- (void)cargarNombreYApellidos
{
	nombre = [webViewPolitecnicaVirtual stringByEvaluatingJavaScriptFromString:@"document.getElementById('usuario_datos').getElementsByTagName('dd')[1].innerText;"];
	apellidos = [webViewPolitecnicaVirtual stringByEvaluatingJavaScriptFromString:@"document.getElementById('usuario_datos').getElementsByTagName('dd')[2].innerText;"];

	[AlmacenamientoLocal escribirString: nombre:@"Nombre.plist"];
	[AlmacenamientoLocal escribirString: apellidos:@"Apellidos.plist"];
}



- (void)verNotasExpediente:(UIWebView *)miWebView
{
	NSMutableArray* fila=[[NSMutableArray alloc]init];
	NSMutableArray* curso=[[NSMutableArray alloc]init];
	int maxTabla=[[miWebView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('tbody').length;"]intValue];
	double sumaDeNotas=0;
	double sumaDeCreditos=0;


	for (int numTabla = 0; numTabla < maxTabla ; numTabla++)
	{
		NSString *titulo = @"";
		titulo = [miWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"document.getElementsByTagName('thead')[%d].getElementsByTagName('tr')[0].innerText;",numTabla]];

		if (titulo.length != 0)
		{
			[curso addObject:titulo];
		}

		int numFilas = [[miWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByTagName('tbody')[%d].getElementsByTagName('tr').length;", numTabla]]intValue];

		for (int i = 0; i < numFilas ; i++)
		{
			int numColumnas = [[miWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"document.getElementsByTagName('tbody')[%d].getElementsByTagName('tr')[%d].getElementsByTagName('td').length;",numTabla,i]]intValue];


			for (int j = 0; j < numColumnas; j++)
			{
				if (numColumnas != 0)
				{
					NSString *celda=@"";

					if(j==1 || j==3)  //salta la duración || salta el tipo de asignatura
					{
						j++;
					}

					celda = [miWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"document.getElementsByTagName('tbody')[%d].getElementsByTagName('tr')[%d].getElementsByTagName('td')[%d].innerText;",numTabla, i, j]];

					celda=[celda stringByReplacingOccurrencesOfString:@"," withString:@"."];

					if(j==0)
					{
						celda=[celda substringToIndex:[celda length]-12];
					}

					if (celda.length != 0)
					{
						[fila addObject:celda];
					}
					else
					{
						[fila addObject:@"No disponible"];
					}
				}
			}

			if (fila.count != 0)
			{
				[curso addObject:fila];
				fila = [[NSMutableArray alloc]init];
			}
		}

		for (int z = 1; z < [curso count]; z++)
		{
			sumaDeNotas=sumaDeNotas+[self obtieneNota:[[curso objectAtIndex:z]objectAtIndex:4]]*[[[curso objectAtIndex:z]objectAtIndex:1] doubleValue];
			sumaDeCreditos=sumaDeCreditos+[[[curso objectAtIndex:z]objectAtIndex:1] doubleValue];
		}
		[curso insertObject:[NSString stringWithFormat:@"%.3f",sumaDeNotas/sumaDeCreditos] atIndex:1];
		sumaDeNotas=0;
		sumaDeCreditos=0;

		[expediente addObject:curso];
		curso = [[NSMutableArray alloc]init];
	}

}


- (void)obtenerNotasTablon:(UIWebView *)miWebView datosTabla:(NSMutableArray *)TableData numTabla:(int)numTabla
{
	NSMutableArray* fila=[[NSMutableArray alloc]init];

	int numFilas = [[miWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByTagName('tbody')[%d].getElementsByTagName('tr').length;", numTabla]]intValue];



	for (int i = 0; i < numFilas ; i++)
	{
		int numColumnas = [[miWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"document.getElementsByTagName('tbody')[%d].getElementsByTagName('tr')[%d].getElementsByTagName('td').length;",numTabla,i]]intValue];

		for (int j = 0; j < numColumnas; j++)
		{
			if (numColumnas != 0)
			{
				NSString *celda=@"";

				celda = [miWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"document.getElementsByTagName('tbody')[%d].getElementsByTagName('tr')[%d].getElementsByTagName('td')[%d].innerText;",numTabla, i, j]];

				if (celda.length != 0)
				{
					[fila addObject:celda];
				}
			}
		}

		if (fila.count != 0)
		{
			if([fila count]<3)
			{
				[fila insertObject:@"No disponible" atIndex:1];
			}
			[TableData addObject:fila];
			fila = [[NSMutableArray alloc]init];
		}
	}

}


- (double)obtieneNota:(NSString *)cadena
{
	NSString *nota=@"";
	NSScanner *scanner = [NSScanner scannerWithString:cadena];
	NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
	scanner = [NSScanner scannerWithString:cadena];

	// Throw away characters before the first number.
	[scanner scanUpToCharactersFromSet:numbers intoString:NULL];

	// Collect numbers.
	if(![scanner scanCharactersFromSet:numbers intoString:&nota])
	{
		nota=@"0";
	}
	return [nota doubleValue];
}


- (NSString *)emoticono:(NSString *)cadena nota:(double)nota
{
	if(nota==-1)
	{
	}
	else{
		if (nota<4)
		{
			cadena=[cadena stringByAppendingString:@" 😢"];
		}
		else
		{
			if (nota>=4 && nota<5)
			{
				cadena=[cadena stringByAppendingString:@" 😨"];
			}
			else
			{
				if(nota>=5 && nota<7)
				{
					cadena=[cadena stringByAppendingString:@" 😅"];
				}
				else
				{
					if (nota>=7 && nota<9)
					{
						cadena=[cadena stringByAppendingString:@" 😋"];
					}
					else
					{
						cadena=[cadena stringByAppendingString:@" 😵😎😃👍👏🎉"];
					}
				}
			}
		}
	}

	return cadena;
}


// MOODLE

- (void)cargarDatosMoodle
{
	moodleEstaCargando = YES;

	webViewMoodle = [[UIWebView alloc]init];

	[webViewMoodle loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URL_MOODLE]]];

	webViewMoodle.frame = CGRectMake(160, 240, 160, 240);
	webViewMoodle.scalesPageToFit=YES;
	webViewMoodle.delegate = self;

	asignaturas=[AlmacenamientoLocal leer:@"asignaturas.plist"];
}

- (void)loginMoodle
{
	[webViewMoodle stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"document.getElementById('identificador').value='%@';", user]];
	[webViewMoodle stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"document.getElementById('clave').value='%@';", pass]];
	[webViewMoodle stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('input')[2].click();"];
}

- (void)cargarAsignaturasMoodle
{
	asignaturas = [[NSMutableArray alloc]init];
	NSString *strLength = [webViewMoodle stringByEvaluatingJavaScriptFromString:@"document.getElementsByClassName('unlist')[0].getElementsByTagName('li').length;"];
	int numAsignaturas = [strLength intValue];

	NSString *asignatura, *linkAsignatura;
	for (int i = 0; i < numAsignaturas; i++)
	{
		asignatura = [webViewMoodle stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByClassName('unlist')[0].getElementsByTagName('li')[%d].getElementsByTagName('a')[0].innerText;", i]];
		linkAsignatura = [webViewMoodle stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByClassName('unlist')[0].getElementsByTagName('li')[%d].getElementsByTagName('a')[0].href;", i]];

		[asignaturas addObject:[NSArray arrayWithObjects:asignatura, linkAsignatura, nil]];
	}

	[AlmacenamientoLocal escribir: asignaturas:@"asignaturas.plist"];

	moodleEstaCargando = NO;

	[self despertarDelegatesParaEvento:@selector(modelUPMacaboDeCargarDatosMoodleConError:)];
	/*if ([self.delegate respondsToSelector: @selector(modelUPMacaboDeCargarDatosMoodleConError:)]) 
	  {
	  [self.delegate modelUPMacaboDeCargarDatosMoodleConError:errorDescription];
	  }*/

	errorDescription = nil;
}




// Get's

- (NSString *)getUsuario
{
	return user;
}

- (NSString *)getContraseña
{
	return pass;
}

- (UIImage *)getFoto
{
	return foto;
}

- (NSString *)getNombre
{
	return nombre;
}

- (NSString *)getApellidos
{
	return apellidos;
}

- (NSMutableArray *)getAsignaturas
{
	return asignaturas;
}

- (NSMutableArray *)getExpediente
{
	return expediente;
}

- (NSMutableArray *)getConvocatorias
{
	return TableDataNotas;
}

- (NSMutableArray *)getSections
{
	return CabeceraSeccion;
}


- (NSString *)getDescripcionError
{
	return errorDescription;
}


// UIWebview delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	NSLog(@"%@",webView.request.URL.absoluteString);

	if (webView == webViewPolitecnicaVirtual)
	{
		if([webView.request.URL.absoluteString isEqualToString:@"https://www.upm.es/politecnica_virtual/login.upm"])
		{
			errorDescription = @"El nombre de usuario y/o la contraseña son incorrectos";

			[self despertarDelegatesParaEvento:@selector(modelUPMacaboDeCargarDatosTablonDeNotasConError:)];

			/*if ([self.delegate respondsToSelector: @selector(modelUPMacaboDeCargarDatosTablonDeNotasConError:)]) 
			  {
			  [self.delegate modelUPMacaboDeCargarDatosTablonDeNotasConError:errorDescription];
			  }*/
			errorDescription = nil;

			[webView stopLoading];
		}
		else
		{
			if ([webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('form_login_enviar').value;"].length != 0)
			{
				[self loginPolitecnicaVirtual];
			}
			else
			{
				switch (indicePV)
				{
					case 0:
						[self cargarNombreYApellidos];
						[self cargarFoto];

						[self despertarDelegatesParaEvento:@selector(modelUPMacaboDeCargarDatosPersonalesconError:)];

						/*if ([self.delegate respondsToSelector: @selector(modelUPMacaboDeCargarDatosPersonalesconError:)]) 
						  {
						  [self.delegate modelUPMacaboDeCargarDatosPersonalesconError:errorDescription];
						  }*/



						int secciones=[[webView stringByEvaluatingJavaScriptFromString:@"document.body.getElementsByTagName(\"table\").length;"] intValue];

						if(secciones==0)//POLITECNICA VIRTUAL CAIDA
						{
							//Primera vez que se comprueba si la politécnica virtual está colgada
							errorDescription = @"Se ha producido un error, seguramente debido a una actualización de Politécnica Virtual. Acceda a través del navegador o inténtelo de nuevo más tarde. Disculpe las molestias.";

							[self despertarDelegatesParaEvento:@selector(modelUPMacaboDeCargarDatosTablonDeNotasConError:)];
							/*if ([self.delegate respondsToSelector: @selector(modelUPMacaboDeCargarDatosTablonDeNotasConError:)]) 
							  {
							  [self.delegate modelUPMacaboDeCargarDatosTablonDeNotasConError:errorDescription];
							  }*/
							[self despertarDelegatesParaEvento:@selector(modelUPMacaboDeCargarDatosExpedienteConError:)];
							/*if ([self.delegate respondsToSelector: @selector(modelUPMacaboDeCargarDatosExpedienteConError:)]) 
							  {
							  [self.delegate modelUPMacaboDeCargarDatosExpedienteConError:errorDescription];
							  }*/
							errorDescription=nil;
							[webView stopLoading];
							indicePV=7;
						}
						else
						{

							TableDataNotas=[[NSMutableArray alloc]init];
							CabeceraSeccion=[[NSMutableArray alloc]init];
							int i=0;

							while([TableDataNotas count]<secciones)
							{
								[TableDataNotas addObject:[[NSMutableArray alloc]init]];
							}

							while(i<secciones)
							{
								[self obtenerNotasTablon:webView datosTabla:[TableDataNotas objectAtIndex: i] numTabla:i];
								i++;
							}
							i=0;
							while(i<secciones)
							{
								[CabeceraSeccion addObject: [webView stringByEvaluatingJavaScriptFromString:[[@"document.body.getElementsByTagName(\"table\")[" stringByAppendingString:[NSString stringWithFormat:@"%d", i]] stringByAppendingString:@"].getElementsByTagName(\"caption\")[0].textContent;"]] ];

								i++;
							}
							//[CabeceraSeccion addObject:@"EXPEDIENTE"];

							[AlmacenamientoLocal escribir: CabeceraSeccion:@"CabeceraSeccion.plist"];
							[AlmacenamientoLocal escribir: TableDataNotas:@"TableDataNotas.plist"];

							[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('carpeta_activa').value='C';document.getElementById('accion').value='3_7_355'; document.getElementById('f').submit();"];
							//salta directamente al apartado de expediente sin tener que cargar paso por paso
							indicePV++;

							[self despertarDelegatesParaEvento:@selector(modelUPMacaboDeCargarDatosTablonDeNotasConError:)];
							/*if ([self.delegate respondsToSelector: @selector(modelUPMacaboDeCargarDatosTablonDeNotasConError:)]) 
							  {
							  [self.delegate modelUPMacaboDeCargarDatosTablonDeNotasConError:errorDescription];
							  }*/
						}
						errorDescription = nil;
						break;

					case 1:
						if([[webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName(\"label\")[1].getElementsByTagName(\"strong\")[1].textContent;"]isEqualToString:@"Completo por curso"])
						{
							[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('ultima').click();"];
							[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('form_ver').click();"];
						}
						else
						{
							//Segunda vez que se comprueba si la politécnica virtual está colgada
							errorDescription = @"Se ha producido un error, seguramente debido a una actualización de Politécnica Virtual. Acceda a través del navegador o inténtelo de nuevo más tarde. Disculpe las molestias.";

							[self despertarDelegatesParaEvento:@selector(modelUPMacaboDeCargarDatosTablonDeNotasConError:)];
							/*if ([self.delegate respondsToSelector: @selector(modelUPMacaboDeCargarDatosTablonDeNotasConError:)]) 
							  {
							  [self.delegate modelUPMacaboDeCargarDatosTablonDeNotasConError:errorDescription];
							  }*/

							[self despertarDelegatesParaEvento:@selector(modelUPMacaboDeCargarDatosExpedienteConError:)];
							/*if ([self.delegate respondsToSelector: @selector(modelUPMacaboDeCargarDatosExpedienteConError:)]) 
							  {
							  [self.delegate modelUPMacaboDeCargarDatosExpedienteConError:errorDescription];
							  }*/
							errorDescription = nil;

							[webView stopLoading];
						}

						indicePV++;
						break;
					case 2:
						expediente=[[NSMutableArray alloc]init];
						[self verNotasExpediente:webView];

						[AlmacenamientoLocal escribir: expediente:@"expediente.plist"];

						indicePV = 0;

						[self despertarDelegatesParaEvento:@selector(modelUPMacaboDeCargarDatosExpedienteConError:)];
						/*if ([self.delegate respondsToSelector: @selector(modelUPMacaboDeCargarDatosExpedienteConError:)]) 
						  {
						  [self.delegate modelUPMacaboDeCargarDatosExpedienteConError:errorDescription];
						  }*/

						break;
					default:
						break;
				}
			}
		}
	}
	else if (webView == webViewMoodle)
	{
		if([webView.request.URL.absoluteString isEqualToString:URL_MOODLE_LOGIN])
		{ 
			[self loginMoodle];
		}

		if([webView.request.URL.absoluteString isEqualToString:URL_MOODLE])
		{ 
			[self cargarAsignaturasMoodle];
		}
	}
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	if ([webView isLoading])
	{
		[webView stopLoading];
		//webView=nil;
	}

	if (error.code == NSURLErrorNotConnectedToInternet)
	{
		errorDescription = @"No está conectado a Internet";
	}
	else
	{
		errorDescription = error.localizedDescription;
	}

	if (webView == webViewPolitecnicaVirtual)
	{

		[self despertarDelegatesParaEvento:@selector(modelUPMacaboDeCargarDatosTablonDeNotasConError:)];
		/*if ([self.delegate respondsToSelector: @selector(modelUPMacaboDeCargarDatosTablonDeNotasConError:)]) 
		  {
		  [self.delegate modelUPMacaboDeCargarDatosTablonDeNotasConError:errorDescription];
		  }*/

		[self despertarDelegatesParaEvento:@selector(modelUPMacaboDeCargarDatosExpedienteConError:)];
		/*if ([self.delegate respondsToSelector: @selector(modelUPMacaboDeCargarDatosExpedienteConError:)]) 
		  {
		  [self.delegate modelUPMacaboDeCargarDatosExpedienteConError:errorDescription];
		  }*/
	}
	else if (webView == webViewMoodle)
	{
		moodleEstaCargando = NO;

		[self despertarDelegatesParaEvento:@selector(modelUPMacaboDeCargarDatosMoodleConError:)];
		/*if ([self.delegate respondsToSelector: @selector(modelUPMacaboDeCargarDatosMoodleConError:)]) 
		  {
		  [self.delegate modelUPMacaboDeCargarDatosMoodleConError:errorDescription];
		  }*/
	}
	errorDescription=nil;
}



@end









