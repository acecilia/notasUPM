#import "ModelUPM.h"
#import "AlmacenamientoLocal.h"
#import "MoodleViewController.h"
#import "ExpedienteViewController.h"
#import "ViewController.h"
#import "AppDelegate.h"

#define URL_POLITECNICA_VIRTUAL @"https://www.upm.es/politecnica_virtual/?c=1693DLFOA"
#define URL_MOODLE_LOGIN @"https://moodle.upm.es/titulaciones/oficiales/login/login.php"
#define URL_MOODLE @"http://moodle.upm.es/titulaciones/oficiales/"
#define URL_LOGOUT_MOODLE @"http://moodle.upm.es/titulaciones/oficiales/login/logout.php"

@interface ModelUPM ()
{
	int indicePV;
	NSMutableArray* delegates;
    int numExpedientes;
    int contadorExpedientes;
    
    NSError* errorGlobal;
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
	NSMutableArray *arrayToEnumerate = [delegates copy];
    
	for(id delegate in arrayToEnumerate)
	{
		if ([delegate respondsToSelector: evento]) 
		{
            IMP metodo = [delegate methodForSelector:evento];
            void (*func)(__strong id,SEL,NSString*) = (void (*)(__strong id, SEL,NSString*))metodo;
            func(delegate, evento, errorGlobal.localizedDescription);
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
}

- (void)removeDelegate:(id)delegate
{
	[delegates removeObjectIdenticalTo:delegate];
}

-(void) cambiarUserAgent
{
    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:[ModelUPM generarUserAgentAleatorio], @"UserAgent", nil];
	[[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    
    //Para que tenga efecto el cambio de userAgent en las uiWebViews hay que crearlas otra vez: tras este metodo habria que llamar
    // a cargarDatosMoodle y cargarDatosPV
    
    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"UserAgent"]);
}

//pone las webviews en modo escritorio
+ (void)initialize
{
	// Set user agent (the only problem is that we can't modify the User-Agent later in the program)
	NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:[self generarUserAgentAleatorio], @"UserAgent", nil];
	[[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
}

+ (NSString *)generarUserAgentAleatorio
{
    NSString *moz = [NSString stringWithFormat:@"Mozilla/%.1f", [self randomFloatWithMinimum:0 maximum:6]];
    
    // MAC
    NSString *macSafariChrome = [NSString stringWithFormat:@"(Macintosh; Intel Mac OS X 10.%d) AppleWebKit/%.1f (KHTML, like Gecko) Chrome/%d.0.%d.%d Safari/%.2f", [self randomIntWithMinimum:0 maximum:9], [self randomFloatWithMinimum:500 maximum:537], [self randomIntWithMinimum:30 maximum:33], [self randomIntWithMinimum:1600 maximum:1750], [self randomIntWithMinimum:0 maximum:120], [self randomFloatWithMinimum:500 maximum:537]];
    
    NSString *macFirefox = [NSString stringWithFormat:@"(Macintosh; Intel Mac OS X 10.%d; rv:%.1f) Gecko/20100101 Firefox/%.1f", [self randomIntWithMinimum:0 maximum:9], [self randomFloatWithMinimum:20 maximum:27], [self randomFloatWithMinimum:20 maximum:27]];
    
    NSArray *machineMac = [[NSArray alloc]initWithObjects:macSafariChrome, macFirefox, nil];
    
    // WINDOWS
    NSString *windowsIE = [NSString stringWithFormat:@"(compatible; MSIE %.1f; Windows NT %.1f; Trident/%.1f)", [self randomFloatWithMinimum:9 maximum:1], [self randomFloatWithMinimum:1 maximum:6], [self randomFloatWithMinimum:1 maximum:5]];
    NSString *windowsChromeSafari = [NSString stringWithFormat:@"(Windows NT %.1f) AppleWebKit/%.1f (KHTML, like Gecko) Chrome/%d.0.%d.%d Safari/%.2f", [self randomFloatWithMinimum:1 maximum:6], [self randomFloatWithMinimum:500 maximum:537], [self randomIntWithMinimum:30 maximum:33], [self randomIntWithMinimum:1600 maximum:1750], [self randomIntWithMinimum:0 maximum:120], [self randomFloatWithMinimum:500 maximum:537]];
    
    NSArray *machineWindows = [[NSArray alloc]initWithObjects:windowsIE, windowsChromeSafari, nil];
    
    // LINUX
    NSString *linuxFirefox = [NSString stringWithFormat:@"(X11; Ubuntu; Linux x86_64; rv:%.1f) Gecko/20100101 Firefox/%.1f", [self randomFloatWithMinimum:20 maximum:27], [self randomFloatWithMinimum:20 maximum:27]];
    
    NSArray *machineLinux = [[NSArray alloc]initWithObjects:linuxFirefox, nil];
    
    
    NSArray *machines = [[NSArray alloc]initWithObjects:[machineMac objectAtIndex:[self randomIntWithMinimum:0 maximum:machineMac.count-1]], [machineWindows objectAtIndex:[self randomIntWithMinimum:0 maximum:machineWindows.count-1]], [machineLinux objectAtIndex:[self randomIntWithMinimum:0 maximum:machineLinux.count-1]], nil];

    NSString *userAgent = [NSString stringWithFormat:@"%@ %@", moz, [machines objectAtIndex:[self randomIntWithMinimum:0 maximum:machines.count-1]]];
    
    NSLog(@"%@", userAgent);
    
    return userAgent;
}

+ (float)randomFloatWithMinimum:(int)min maximum:(int)max
{
    return (((float)(arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * (max-min)) + min;
}

+ (int)randomIntWithMinimum:(int)min maximum:(int)max
{
    return (arc4random() % (max-min+1)) + min;
}


- (void)inicializarConUsuario:(NSString *)usuario contraseña:(NSString *)contraseña
{
	user = usuario;
	pass = contraseña;
}


// Politecnica Virtual

- (void)cargarDatosPolitecnicaVirtual
{
	indicePV=0;
    contadorExpedientes = 0;
    numExpedientes = 1;
    
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
	/*[webViewPolitecnicaVirtual stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('user').value='%@';", user]];
	[webViewPolitecnicaVirtual stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('pass').value='%@';", pass]];
	[webViewPolitecnicaVirtual stringByEvaluatingJavaScriptFromString:@"document.getElementById('form_login_enviar').click();"];*/
    
    int numTag = [[webViewPolitecnicaVirtual stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('input').length;"] intValue];
    for (int i=0; i<numTag; i++)
    {
        if ([[webViewPolitecnicaVirtual stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByTagName('input')[%d].type;", i]] isEqualToString:@"text"])
        {
            [webViewPolitecnicaVirtual stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByTagName('input')[%d].value='%@';", i,user]];
            //	[webViewPolitecnicaVirtual stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"document.getElementById('identificador').value='%@';", user]];
        }
        else if ([[webViewPolitecnicaVirtual stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByTagName('input')[%d].type;", i]] isEqualToString:@"password"])
        {
            [webViewPolitecnicaVirtual stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByTagName('input')[%d].value='%@';", i,pass]];
            //	[webViewPolitecnicaVirtual stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"document.getElementById('clave').value='%@';", pass]];
        }
        else if ([[webViewPolitecnicaVirtual stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByTagName('input')[%d].type;", i]] isEqualToString:@"submit"])
        {
            [webViewPolitecnicaVirtual stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByTagName('input')[%d].click();", i]];
            //[webViewPolitecnicaVirtual stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('input')[2].click();"];
        }
    }
}

- (NSString*)cargarFoto
{
	NSString *dirImagen = [webViewPolitecnicaVirtual stringByEvaluatingJavaScriptFromString:@"document.getElementById('usuario_datos').getElementsByTagName('dd')[0].getElementsByTagName('img')[0].src;"];

	NSURL *url = [[NSURL alloc] initWithString:dirImagen];
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



- (void)verNotasExpediente:(UIWebView *)miWebView :(NSMutableArray*)expedient
{
	NSMutableArray* fila=[[NSMutableArray alloc]init];
	NSMutableArray* curso=[[NSMutableArray alloc]init];
	int maxTabla=[[miWebView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('tbody').length;"]intValue];
	double sumaDeNotas=0;
	double sumaDeCreditos=0;


	for (int numTabla = 0; numTabla < maxTabla ; numTabla++)
	{
		NSString *titulo = @"";
		//titulo = [miWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"document.getElementsByTagName('thead')[%d].getElementsByTagName('tr')[0].innerText;",numTabla]];
        //titulo = [miWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"document.getElementsByTagName('table')[%d].getElementsByTagName('caption')[0].innerText;",numTabla]];
        titulo = [miWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"document.getElementsByTagName('table')[%d].caption.innerText;",numTabla]];
        
        

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

                    celda = [celda stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    
                    //elimina varios saltos de carro seguidos dejando un único salto de carro
                    while ([@"\n\n" rangeOfString:celda].location != NSNotFound)
                    {
                        celda=[celda stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
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

        //El jaleo de código que hay ahora es por si sale dos veces la misma asignatura pero con distintas notas coger la nota más alta
        
        NSMutableArray* arrayAuxiliar = [[NSMutableArray alloc] initWithArray:curso copyItems:YES];
        [arrayAuxiliar removeObjectAtIndex:0];
        
        while ([arrayAuxiliar count]>0)
		{
            NSString* nombreAsignatura = [[arrayAuxiliar objectAtIndex:0]objectAtIndex:0];
            double notaMasAlta = [self obtieneNota:[[arrayAuxiliar objectAtIndex:0]objectAtIndex:4]];
            double creditos = [[[arrayAuxiliar objectAtIndex:0]objectAtIndex:1] doubleValue];
            NSMutableIndexSet *notasYaObtenidas = [NSMutableIndexSet indexSet];
            [notasYaObtenidas addIndex:0];

            for (int z = 1; z < [arrayAuxiliar count]; z++)
            {
                if([[[arrayAuxiliar objectAtIndex:z]objectAtIndex:0]isEqualToString:nombreAsignatura])
                {
                    double notaActual = [self obtieneNota:[[arrayAuxiliar objectAtIndex:z]objectAtIndex:4]];
                    [notasYaObtenidas addIndex:z];
                    
                    if(notaActual>notaMasAlta)
                    {
                        notaMasAlta = notaActual;
                    }
                }
            }
            
            //Añade a la media solo los creditos que tienen nota: no añade a la media las prácticas en empresas, por ejemplo
            if(notaMasAlta>0)
            {
                sumaDeNotas=sumaDeNotas+notaMasAlta*creditos;
                sumaDeCreditos=sumaDeCreditos+creditos;
            }
            
            [arrayAuxiliar removeObjectsAtIndexes:notasYaObtenidas];
		}
        
        //si la suma de creditos es cero evita que se divida por cero y salga el valor nan
        if(sumaDeCreditos==0)
        {
            sumaDeNotas=0;
            sumaDeCreditos=1;
        }
        
		[curso insertObject:[NSString stringWithFormat:@"%.3f",sumaDeNotas/sumaDeCreditos] atIndex:1];
		sumaDeNotas=0;
		sumaDeCreditos=0;

		[expedient addObject:curso];
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

                celda = [celda stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                //elimina varios saltos de carro seguidos dejando un único salto de carro
                while ([celda rangeOfString:@"\n\n"].location != NSNotFound)
                {
                    celda=[celda stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
                }
                
				if (celda.length != 0)
				{
					[fila addObject:celda];
				}
			}
		}

		if (fila.count != 0)
		{
			while([fila count]<3)
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

	webViewMoodle.frame = CGRectMake(160, 240, 500, 700);
	webViewMoodle.scalesPageToFit=YES;
	webViewMoodle.delegate = self;

	asignaturas=[AlmacenamientoLocal leer:@"asignaturas.plist"];
}

- (void)loginMoodle
{
	/*[webViewMoodle stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"document.getElementById('identificador').value='%@';", user]];
	[webViewMoodle stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"document.getElementById('clave').value='%@';", pass]];*/
    
    int numTag = [[webViewMoodle stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('input').length;"] intValue];
    for (int i=0; i<numTag; i++)
    {
        if ([[webViewMoodle stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByTagName('input')[%d].type;", i]] isEqualToString:@"text"])
        {
            [webViewMoodle stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByTagName('input')[%d].value='%@';", i,user]];
        }
        else if ([[webViewMoodle stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByTagName('input')[%d].type;", i]] isEqualToString:@"password"])
        {
            [webViewMoodle stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByTagName('input')[%d].value='%@';", i,pass]];
        }
        else if ([[webViewMoodle stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByTagName('input')[%d].type;", i]] isEqualToString:@"submit"])
        {
            [webViewMoodle stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByTagName('input')[%d].click();", i]];
            //[webViewMoodle stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('input')[2].click();"];
        }
    }
}

- (void)inicializarMoodleConNuevaCuenta
{
    moodleEstaCargando = YES;
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    [self addDelegate:appDelegate.MoodleNC.topViewController];
    
    asignaturas = [[NSMutableArray alloc]init];
    
	webViewMoodle = [[UIWebView alloc]init];
    
	[webViewMoodle loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URL_MOODLE_LOGIN]]];
    
	webViewMoodle.frame = CGRectMake(160, 240, 160, 240);
	webViewMoodle.scalesPageToFit=YES;
	webViewMoodle.delegate = self;
}

- (void)cargarAsignaturasMoodle
{
    if (asignaturas == nil || [asignaturas count]==0)
    {
       asignaturas = [[NSMutableArray alloc]init];
    }
	
	NSString *strLength = [webViewMoodle stringByEvaluatingJavaScriptFromString:@"document.getElementsByClassName('unlist')[0].getElementsByTagName('li').length;"];
	int numAsignaturas = [strLength intValue];

	NSString *asignatura, *linkAsignatura;
	for (int i = 0; i < numAsignaturas; i++)
	{
		asignatura = [webViewMoodle stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByClassName('unlist')[0].getElementsByTagName('li')[%d].getElementsByTagName('a')[0].innerText;", i]];
		linkAsignatura = [webViewMoodle stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByClassName('unlist')[0].getElementsByTagName('li')[%d].getElementsByTagName('a')[0].href;", i]];

        
        NSArray* array = [NSArray arrayWithObjects:asignatura, linkAsignatura, nil];
        NSMutableArray* asignaturasEliminadas = [AlmacenamientoLocal leer:@"asignaturasEliminadas.plist"];
        
        if (asignaturasEliminadas == nil)
        {
            asignaturasEliminadas = [[NSMutableArray alloc] init];
        }
        
        if(![asignaturas containsObject:array] && ![asignaturasEliminadas containsObject:array])
        {
            [asignaturas addObject:array];
        }
	}

	[AlmacenamientoLocal escribir: asignaturas:@"asignaturas.plist"];

	moodleEstaCargando = NO;

	[self despertarDelegatesParaEvento:@selector(modelUPMacaboDeCargarDatosMoodleConError:)];

	//errorDescription = nil;
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


- (NSMutableArray *)getExpediente: (int) numeroExpediente
{
    if ([expediente count] > numeroExpediente)
    {
        if([[expediente objectAtIndex:numeroExpediente]count]>1)
        {
            return [[expediente objectAtIndex:numeroExpediente]objectAtIndex:1];
        }
        else
        {
            return nil;
        }
       
    }
    else
    {
        return nil;
    }
	
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
	return [errorGlobal localizedDescription];
}


// UIWebview delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	NSLog(@"%@",webView.request.URL.absoluteString);

    if ([webView.request.URL.absoluteString rangeOfString:@"error"].location != NSNotFound)
    {
        NSMutableDictionary *details = [NSMutableDictionary dictionary];
        [details setValue:@"Los servidores no se encuentran disponibles en estos momentos. Por favor, inténtelo de nuevo en unos minutos." forKey:NSLocalizedDescriptionKey];
        errorGlobal = [NSError errorWithDomain:@"Global" code:404 userInfo: details];
        
        [self avisarDelegatesDePV];
        
        errorGlobal = nil;
        [webView stopLoading];
    }
    
	if (webView == webViewPolitecnicaVirtual)
	{
        //ERROR DE AUTENTIFICACION
        if([webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('login_error').innerText;"].length != 0)
        {
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('login_error').innerText;"] forKey:NSLocalizedDescriptionKey];
            errorGlobal = [NSError errorWithDomain:@"Global" code:200 userInfo:details];
            
			[self avisarDelegatesDePV];
            
            errorGlobal = nil;
			[webView stopLoading];
        }
        //LOGEO
        else if ([webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('form_login_enviar').value;"].length != 0)
		{
            [self loginPolitecnicaVirtual];
            
		}
        //ESTA EN LA PAGINA DEL TABLON DE NOTAS
        else if([[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('accion').value;"] isEqualToString:@"16_13_1693"])
        {
            [self cargarNombreYApellidos];
            [self cargarFoto];
            
            [self despertarDelegatesParaEvento:@selector(modelUPMacaboDeCargarDatosPersonalesconError:)];
            
            int secciones=[[webView stringByEvaluatingJavaScriptFromString:@"document.body.getElementsByTagName(\"table\").length;"] intValue];
            
            TableDataNotas=[[NSMutableArray alloc]init];
            CabeceraSeccion=[[NSMutableArray alloc]init];
            
            if(secciones!=0)
            {
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
            }
            [AlmacenamientoLocal escribir: CabeceraSeccion:@"CabeceraSeccion.plist"];
            [AlmacenamientoLocal escribir: TableDataNotas:@"TableDataNotas.plist"];
            
            [self despertarDelegatesParaEvento:@selector(modelUPMacaboDeCargarDatosTablonDeNotasConError:)];
            
            errorGlobal = nil;
            
            //salta directamente al apartado de expediente sin tener que cargar paso por paso
            [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('carpeta_activa').value='C';document.getElementById('accion').value='3_7_355'; document.getElementById('f').submit();"];
            indicePV++;
            
        }
        //NO ESTA EN LA PAGINA DE TABLON DE NOTAS Y NECESITA DESCARGAR LAS NOTAS
        else if (indicePV==0)
        {
            [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('carpeta_activa').value='F';document.getElementById('accion').value='16_13_1693'; document.getElementById('f').submit();"];
        }
        //ESTA EN LA PAGINA DE ELECCION DEL EXPEDIENTE
        else if([[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('accion').value;"] isEqualToString:@"3_7_355"])
        {
            //Si está en la página de los expedientes
            if([[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('form_ver').type;"]isEqualToString:@"submit"])
            {
                if([[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('ultima').checked;"]isEqualToString:@"false"])
                {
                    if (contadorExpedientes == 0)
                    {
                        expediente=[[NSMutableArray alloc]init];
                    }
                    
                    NSMutableArray* expedienteAuxiliar = [[NSMutableArray alloc]init];
                    NSString* cadena = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('expediente').textContent;"];
                    [expedienteAuxiliar addObject:cadena];
                    [expediente insertObject:expedienteAuxiliar atIndex:contadorExpedientes];
                    
                    [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('ultima').click();"];
                    [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('form_ver').click();"];
                }
                else
                {
                    //Si no está en la página del expediente y si ha descargado las notas del tablon, vuelve a la pagina del expediente
                    
                    NSMutableArray* expedienteAuxiliar = [[NSMutableArray alloc]init];
                    [self verNotasExpediente:webView:expedienteAuxiliar];
                    [[expediente objectAtIndex:contadorExpedientes] addObject:expedienteAuxiliar];
                    
                    contadorExpedientes++;
                    
                    //si faltan expedientes por cargar vuelve atras y selecciona el siguiente
                    if (contadorExpedientes < numExpedientes)
                    {
                        [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('accion').value='3_7_355';document.getElementById('accion_anterior').value='0'; document.getElementById('f').submit();"];
                    }
                    else
                    {
                        [AlmacenamientoLocal escribir: expediente:@"expediente.plist"];
                        [self despertarDelegatesParaEvento:@selector(modelUPMacaboDeCargarDatosExpedienteConError:)];
                    }
                }
            }
            else
            {
                //para gente que se ha cambiado de titulación
                numExpedientes = [[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('lista_expedientes').getElementsByTagName(\"li\").length;"] intValue];
                
                [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('lista_expedientes').getElementsByTagName(\"li\")[%d].getElementsByTagName(\"a\")[0].click();", contadorExpedientes]];
                
                //[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('lista_expedientes').getElementsByTagName(\"li\")[document.getElementById('lista_expedientes').getElementsByTagName(\"li\").length-1].getElementsByTagName(\"a\")[0].click();"];
            }            
        }
        //SI NO ESTA EN LA PAGINA DEL EXPEDIENTE
        else if (indicePV==1)
        {
            //salta directamente al apartado de expediente sin tener que cargar paso por paso
            [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('carpeta_activa').value='C';document.getElementById('accion').value='3_7_355'; document.getElementById('f').submit();"];
        }
	}
	else if (webView == webViewMoodle)
	{
		if([[webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('input').length;"] intValue]>=3)
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
	}

	if (error.code == NSURLErrorNotConnectedToInternet)
	{
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"No está conectado a Internet" forKey:NSLocalizedDescriptionKey];
        errorGlobal = [NSError errorWithDomain:error.domain code:error.code userInfo:details];
	}
	else
	{
		errorGlobal = [error copy];
	}

	if (webView == webViewPolitecnicaVirtual)
	{
        [self avisarDelegatesDePV];
	}
	else if (webView == webViewMoodle)
	{
		moodleEstaCargando = NO;
		[self despertarDelegatesParaEvento:@selector(modelUPMacaboDeCargarDatosMoodleConError:)];
	}
	errorGlobal=nil;
}

-(void) avisarDelegatesDePV
{
    NSMutableArray* delegateArray = [delegates copy];
    
    [self despertarDelegatesParaEvento:@selector(modelUPMacaboDeCargarDatosTablonDeNotasConError:)];
    
    //las alertas de error de webViewPolitecnicaVirtual solo se sacan por viewController si viewController y expedienteViewController están aladidas al delegate para que no salgan repetidas en la vista del expediente ya que siempre van a producirse los mismos errores al ser el mismo webView
    for (id delegate in delegateArray)
    {
        if ([delegate isKindOfClass:[ViewController class]])
        {
            errorGlobal = nil;
        }
    }
    
    [self despertarDelegatesParaEvento:@selector(modelUPMacaboDeCargarDatosExpedienteConError:)];
}



@end









