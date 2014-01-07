#import "Descargador.h"
#import "AlmacenamientoLocal.h"

@interface Descargador ()
{
	int i;
    bool dejarDeDescargar;
	NSMutableArray* arrayPDF;
	NSString* URL;
	NSString* offlineFile;
	NSMutableData* webdata;
	NSString * rutaPDF;
    NSURLConnection *conexion;
}
@end

@implementation Descargador

//descargarTodo
- (void)descargarTodo:(NSMutableArray *)array :(NSString*) file
{
	arrayPDF=array;
	offlineFile=file;
	i=0;
    dejarDeDescargar = false;

	[self comprobarSiEsNecesarioDescargar];
}

- (void)dejarDeDescargar
{
    dejarDeDescargar = true;
    [conexion cancel];
    conexion = nil;
}



- (void)comprobarSiEsNecesarioDescargar
{
	while([arrayPDF count]>i && dejarDeDescargar == false)
	{
		rutaPDF=[[[offlineFile stringByAppendingString:@"/ArchivosPDF/"]stringByAppendingString:[[arrayPDF objectAtIndex:i] objectAtIndex:0]]stringByAppendingString:[[arrayPDF objectAtIndex:i] objectAtIndex:2]];

		if([AlmacenamientoLocal existe:rutaPDF])
		{
			i++;
		}
		else
		{
			URL = [[arrayPDF objectAtIndex:i] objectAtIndex:1];

			NSURLRequest *myRequest = [NSURLRequest requestWithURL: [NSURL URLWithString:URL]];
            conexion=[NSURLConnection connectionWithRequest: myRequest delegate:self];

			if(conexion==nil)
			{
				if ([self.delegate respondsToSelector: @selector(voyDescargandoPorElNumero:conError:)])
				{
					[self.delegate voyDescargandoPorElNumero:i conError:[@"No se a podido crear la petición con URL: " stringByAppendingString:URL]];
				}
			}
			return;
		}
	}

	if ([self.delegate respondsToSelector: @selector(acaboDeDescargarTodo)]) 
	{
		[self.delegate acaboDeDescargarTodo];
	}	
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	webdata = [[NSMutableData alloc] init];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	[webdata appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[AlmacenamientoLocal escribirPDF:webdata:rutaPDF];

	if([AlmacenamientoLocal existe:rutaPDF])
	{
		if ([self.delegate respondsToSelector: @selector(voyDescargandoPorElNumero:conError:)]) 
		{
			[self.delegate voyDescargandoPorElNumero:i conError:nil];
		}
	}
	else
	{
		if ([self.delegate respondsToSelector: @selector(voyDescargandoPorElNumero:conError:)]) 
		{
			[self.delegate voyDescargandoPorElNumero:i conError:[@"no se ha encontrado el PDF en almacenamiento local: " stringByAppendingString:rutaPDF]];
		}
	}
	i++;
	[self comprobarSiEsNecesarioDescargar];
}

@end





