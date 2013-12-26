#import "Descargador.h"
#import "AlmacenamientoLocal.h"

@interface Descargador ()
{
	int i;
	NSMutableArray* arrayPDF;
	NSString* URL;
	NSString* offlineFile;
	NSMutableData* webdata;
	NSString * rutaPDF;
}
@end

@implementation Descargador

//descargarTodo
- (void)descargarTodo:(NSMutableArray *)array :(NSString*) file
{
	arrayPDF=array;
	offlineFile=file;
	i=0;

	[self comprobarSiEsNecesarioDescargar];
}

- (void)comprobarSiEsNecesarioDescargar
{
	while([arrayPDF count]>i)
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

			if([NSURLConnection connectionWithRequest: myRequest delegate:self]==nil)
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





