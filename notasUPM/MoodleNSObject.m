//
//  MoodleNSObject.m
//  notasUPM
//
//  Created by andres on 13/06/14.
//  Copyright (c) 2014 Alvaro Roman. All rights reserved.
//

#import "MoodleNSObject.h"
#import "AlmacenamientoLocal.h"
#import "MoodleViewController.h"
#import "ViewController.h"
#import "AppDelegate.h"

#define USER @"a.cecilia@alumnos.upm.es"
#define PASS @"admin123cuni"

#define URL_MOODLE_LOGIN @"https://moodle.upm.es/titulaciones/oficiales/login/login.php"
#define URL_MOODLE @"https://moodle.upm.es/titulaciones/oficiales/"
#define URL_LOGOUT_MOODLE @"http://moodle.upm.es/titulaciones/oficiales/login/logout.php"

@interface MoodleNSObject ()
{
	NSMutableArray* delegates;
    
    NSError* errorGlobal;
    
    NSString *userAgentActual;
    NSMutableArray *userAgentsBlackList;
    
    NSMutableArray* conexionMoodle;
    NSMutableArray* webdataMoodle;
    
    AppDelegate * AppDelegateObject;
}

@end

@implementation MoodleNSObject

@synthesize webViewMoodle, moodleEstaCargando;

- (id)init
{
	if (self = [super init])
	{
		delegates = [[NSMutableArray alloc] init];
        
        if ((userAgentsBlackList = [AlmacenamientoLocal leer:@"BlackList.plist"]) == nil)
            userAgentsBlackList = [[NSMutableArray alloc] init];
        else
        {
            for (NSString *str in userAgentsBlackList)
            {
                NSLog(@"BLACK LIST -> %@",str);
            }
        }
        
        [self asignarUserAgentActual];
    }
	return self;
}


- (void) despertarDelegatesParaEvento:(SEL)evento
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

- (void)asignarUserAgentActual
{
    NSString *userAgent;
    do
    {
        userAgent = [self generarUserAgentAleatorio];
    }
    while ([self userAgentIsInBlackList:userAgent]);
    
    userAgentActual = userAgent;
    
    // PARA PROBAR QUE FUNCIONA EL CAMBIO DE USER AGENT
    /*int ran = arc4random() % 10;
     if (ran % 2 == 0)
     {
     userAgentActual = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9) AppleWebKit/537.71 (KHTML, like Gecko) Version/7.0 Safari/537.71";
     }
     
     NSLog(@"USER AGENT FINAL -> %@", userAgentActual);*/
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:userAgentActual, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
}

- (BOOL)userAgentIsInBlackList:(NSString *)userAgent
{
    BOOL encontrado = NO;
    NSString *str;
    
    for (int i = 0; (i < userAgentsBlackList.count) && (!encontrado); i++)
    {
        str = [userAgentsBlackList objectAtIndex:i];
        if ([str isEqualToString:userAgent])
            encontrado = YES;
    }
    
    return encontrado;
}

- (NSString *)generarUserAgentAleatorio
{
    NSString *moz = [NSString stringWithFormat:@"Mozilla/%.1f", [self randomFloatWithMinimum:1 maximum:6]];
    
    // MAC
    NSString *macSafariChrome = [NSString stringWithFormat:@"(Macintosh; Intel Mac OS X 10_%d) AppleWebKit/%.1f (KHTML, like Gecko) Chrome/%d.0.%d.%d Safari/%.2f", [self randomIntWithMinimum:0 maximum:9], [self randomFloatWithMinimum:500 maximum:537], [self randomIntWithMinimum:30 maximum:33], [self randomIntWithMinimum:1600 maximum:1750], [self randomIntWithMinimum:0 maximum:120], [self randomFloatWithMinimum:500 maximum:537]];
    
    NSString *macFirefox = [NSString stringWithFormat:@"(Macintosh; Intel Mac OS X 10_%d; rv:%.1f) Gecko/20100101 Firefox/%.1f", [self randomIntWithMinimum:0 maximum:9], [self randomFloatWithMinimum:20 maximum:27], [self randomFloatWithMinimum:20 maximum:27]];
    
    NSArray *machineMac = [[NSArray alloc]initWithObjects:macSafariChrome, macFirefox, nil];
    
    // WINDOWS
    NSString *windowsIE = [NSString stringWithFormat:@"(compatible; MSIE %.1f; Windows NT %.1f; Trident/%.1f)", [self randomFloatWithMinimum:9 maximum:1], [self randomFloatWithMinimum:1 maximum:6], [self randomFloatWithMinimum:1 maximum:5]];
    NSString *windowsChromeSafari = [NSString stringWithFormat:@"(Windows NT %.1f) AppleWebKit/%.1f (KHTML, like Gecko) Chrome/%d.0.%d.%d Safari/%.2f", [self randomFloatWithMinimum:1 maximum:6], [self randomFloatWithMinimum:500 maximum:537], [self randomIntWithMinimum:30 maximum:33], [self randomIntWithMinimum:1600 maximum:1750], [self randomIntWithMinimum:0 maximum:120], [self randomFloatWithMinimum:500 maximum:537]];
    
    NSArray *machineWindows = [[NSArray alloc]initWithObjects:windowsIE, windowsChromeSafari, nil];
    
    // LINUX
    NSString *linuxFirefox = [NSString stringWithFormat:@"(X11; Ubuntu; Linux x86_64; rv:%.1f) Gecko/20100101 Firefox/%.1f", [self randomFloatWithMinimum:20 maximum:27], [self randomFloatWithMinimum:20 maximum:27]];
    
    NSArray *machineLinux = [[NSArray alloc]initWithObjects:linuxFirefox, nil];
    
    
    NSArray *machines = [[NSArray alloc]initWithObjects:[machineMac objectAtIndex:[self randomIntWithMinimum:0 maximum:(int)(machineMac.count-1)]], [machineWindows objectAtIndex:[self randomIntWithMinimum:0 maximum:(int)(machineWindows.count-1)]], [machineLinux objectAtIndex:[self randomIntWithMinimum:0 maximum:(int)(machineLinux.count-1)]], nil];
    
    NSString *userAgent = [NSString stringWithFormat:@"%@ %@", moz, [machines objectAtIndex:[self randomIntWithMinimum:0 maximum:(int)(machines.count - 1)]]];
    
    NSLog(@"USER AGENT GENERADO -> %@", userAgent);
    
    return userAgent;
}

- (float)randomFloatWithMinimum:(int)min maximum:(int)max
{
    return (((float)(arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * (max-min)) + min;
}

- (int)randomIntWithMinimum:(int)min maximum:(int)max
{
    return (arc4random() % (max-min+1)) + min;
}


// MOODLE

- (void)cargarDatosMoodle
{
	moodleEstaCargando = YES;
    
    webViewMoodle = [[UIWebView alloc]init];
    webViewMoodle.frame = CGRectMake(160, 240, 500, 700);
    webViewMoodle.scalesPageToFit=YES;
    webViewMoodle.delegate = self;
    [webViewMoodle loadRequest:[NSURLRequest requestWithURL: [NSURL URLWithString:URL_MOODLE]]];
    
	asignaturas=[AlmacenamientoLocal leer:@"asignaturas.plist"];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if(webView == webViewMoodle)
    {
        BOOL retorno = false;
        
        if (webView.tag == 1)
        {
            retorno = YES;
        }
        else
        {
            [conexionMoodle addObject:[NSURLConnection connectionWithRequest:request delegate:self]];
            retorno = NO;
        }
        webView.tag = 0;
        return retorno;
    }
    else
    {
        return YES;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    for (int i = [webdataMoodle count]; i <= [conexionMoodle indexOfObject:connection]; i++) {
        
        [webdataMoodle insertObject:[[NSMutableData alloc] init] atIndex:i];
    }
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	[[webdataMoodle objectAtIndex:[conexionMoodle indexOfObject:connection]] appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSRange r;
    NSString* cadena = [[NSString alloc] initWithData:[webdataMoodle objectAtIndex:[conexionMoodle indexOfObject:connection]] encoding:NSUTF8StringEncoding];
    
    while ((r = [cadena rangeOfString:@"img" options:NSRegularExpressionSearch]).length!=0)
    {
        r.length = cadena.length - r.location;
        NSRange r1 = [cadena rangeOfString:@">" options:NSRegularExpressionSearch range:r];
        
        r.length = r.location;
        r.location = 0;
        NSRange r2 = [cadena rangeOfString:@"<" options:NSBackwardsSearch range:r];
        
        r.location = r2.location;
        r.length = r1.location - r2.location;
        
        cadena = [cadena stringByReplacingCharactersInRange:r withString:@""];
    }
    
    while ((r = [cadena rangeOfString:@"png" options:NSRegularExpressionSearch]).length!=0)
    {
        r.length = cadena.length - r.location;
        NSRange r1 = [cadena rangeOfString:@">" options:NSRegularExpressionSearch range:r];
        
        r.length = r.location;
        r.location = 0;
        NSRange r2 = [cadena rangeOfString:@"<" options:NSBackwardsSearch range:r];
        
        r.location = r2.location;
        r.length = r1.location - r2.location;
        
        cadena = [cadena stringByReplacingCharactersInRange:r withString:@""];
    }
    
    while ((r = [cadena rangeOfString:@"gif" options:NSRegularExpressionSearch]).length!=0)
    {
        r.length = cadena.length - r.location;
        NSRange r1 = [cadena rangeOfString:@">" options:NSRegularExpressionSearch range:r];
        
        r.length = r.location;
        r.location = 0;
        NSRange r2 = [cadena rangeOfString:@"<" options:NSBackwardsSearch range:r];
        
        r.location = r2.location;
        r.length = r1.location - r2.location;
        
        cadena = [cadena stringByReplacingCharactersInRange:r withString:@""];
    }
    
    while ((r = [cadena rangeOfString:@"link" options:NSRegularExpressionSearch]).length!=0)
    {
        r.length = cadena.length - r.location;
        NSRange r1 = [cadena rangeOfString:@">" options:NSRegularExpressionSearch range:r];
        
        r.length = r.location;
        r.location = 0;
        NSRange r2 = [cadena rangeOfString:@"<" options:NSBackwardsSearch range:r];
        
        r.location = r2.location;
        r.length = r1.location - r2.location;
        
        cadena = [cadena stringByReplacingCharactersInRange:r withString:@""];
    }
    
    //cadena = [cadena stringByReplacingOccurrencesOfString:@"img" withString:@""];
    
    [webViewMoodle loadData:[cadena dataUsingEncoding:NSUTF8StringEncoding] MIMEType: @"text/html" textEncodingName: @"UTF-8" baseURL:connection.currentRequest.URL];
    webViewMoodle.tag = 1;
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
            [webViewMoodle stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByTagName('input')[%d].value='%@';", i,USER]];
        }
        else if ([[webViewMoodle stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByTagName('input')[%d].type;", i]] isEqualToString:@"password"])
        {
            [webViewMoodle stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementsByTagName('input')[%d].value='%@';", i,PASS]];
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

//GETS

- (NSString *)getUsuario
{
	return USER;
}

- (NSString *)getContraseña
{
	return PASS;
}

- (NSMutableArray *)getAsignaturas
{
	return asignaturas;
}

- (NSString *)getDescripcionError
{
	return [errorGlobal localizedDescription];
}



- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	/*NSLog(@"%@",webView.request.URL.absoluteString);

    // COMPROBAR QUE ESTA EL USER AGENT BLOQUEADO
    if ([[webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('tbody')[0].getElementsByTagName('img')[0].alt"] isEqualToString:@"Alerta"])
    {
        if (![userAgentsBlackList containsObject:userAgentActual])
        {
            [userAgentsBlackList addObject:userAgentActual];
            [AlmacenamientoLocal escribir:userAgentsBlackList :@"BlackList.plist"];
        }
        
        [self asignarUserAgentActual];
        [self cargarDatosMoodle];
    }
    else if([[webViewMoodle stringByEvaluatingJavaScriptFromString:@"document.getElementsByClassName('unlist')[0].getElementsByTagName('li').length;"]intValue] > 0)
    {
        [self cargarAsignaturasMoodle];
    }
    else if([[webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('input').length;"] intValue]>=3)
    {
        [self loginMoodle];
    }*/
    
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

    moodleEstaCargando = NO;
    [self despertarDelegatesParaEvento:@selector(modelUPMacaboDeCargarDatosMoodleConError:)];

}




@end
