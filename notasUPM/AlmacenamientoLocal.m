#import "AlmacenamientoLocal.h"


@interface AlmacenamientoLocal ()
{
}
@end

@implementation AlmacenamientoLocal

+ (void) añadirVersionYEscribir:(NSString *)path :(id)file
{
	NSMutableArray* array =[[NSMutableArray alloc] init];

	NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
	NSString *version    = infoDictionary[(NSString*)kCFBundleVersionKey];

	[array addObject: version];
	[array addObject: file];

	[array writeToFile:path atomically:YES];
}

+ (id)obtenerArchivoSinVersion:(NSString *)path
{
	NSMutableArray* array =[[NSMutableArray alloc] init];

	NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
	NSString *version    = infoDictionary[(NSString*)kCFBundleVersionKey];

	array=[NSArray arrayWithContentsOfFile:path];

	if ([[array objectAtIndex:0] isEqualToString:version])
	{
		return [array objectAtIndex:1];
	}
	else
	{
		return nil;
	}
}

//NSArray
+ (NSMutableArray*)leer:(NSString *)offlineFile
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *filePath = [documentsDirectory stringByAppendingPathComponent:offlineFile];

	return [self obtenerArchivoSinVersion:filePath];
	//return [NSArray arrayWithContentsOfFile:filePath];
}


+ (void)escribir: (NSMutableArray *)array :(NSString *)offlineFile
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSArray *directorio = [offlineFile componentsSeparatedByString:@"/"];
	NSString * filePath = documentsDirectory;

	for (int j = 0; j < [directorio count]-1; j++)
	{
		filePath = [filePath stringByAppendingPathComponent:[directorio objectAtIndex:j]];
		if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
			[[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:nil]; 
		}
	}

	filePath = [documentsDirectory stringByAppendingPathComponent:offlineFile];

	[self añadirVersionYEscribir:filePath:array];
	//[array writeToFile:filePath atomically:YES];
}


//NSString
+ (NSString*)leerString:(NSString *)offlineFile
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *filePath = [documentsDirectory stringByAppendingPathComponent:offlineFile];



	return [self obtenerArchivoSinVersion:filePath];
	//return [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:NULL];

}

+ (void)escribirString: (NSString *)string :(NSString *)offlineFile
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSArray *directorio = [offlineFile componentsSeparatedByString:@"/"];
	NSString * filePath = documentsDirectory;

	for (int j = 0; j < [directorio count]-1; j++)
	{
		filePath = [filePath stringByAppendingPathComponent:[directorio objectAtIndex:j]];
		if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
			[[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:nil]; 
		}
	}

	filePath = [documentsDirectory stringByAppendingPathComponent:offlineFile];

	[self añadirVersionYEscribir:filePath:string];

	//[string writeToFile:filePath atomically:YES encoding:NSASCIIStringEncoding error:NULL];

}


//UIImage
+ (UIImage*)leerImagen:(NSString *)offlineFile
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *filePath = [documentsDirectory stringByAppendingPathComponent:offlineFile];

	return [UIImage imageWithContentsOfFile:filePath];

}

+ (void)escribirImagen: (UIImage *)imagen :(NSString *)offlineFile
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSArray *directorio = [offlineFile componentsSeparatedByString:@"/"];
	NSString * filePath = documentsDirectory;

	for (int j = 0; j < [directorio count]-1; j++)
	{
		filePath = [filePath stringByAppendingPathComponent:[directorio objectAtIndex:j]];
		if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
			[[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:nil]; 
		}
	}

	filePath = [documentsDirectory stringByAppendingPathComponent:offlineFile];

	NSData * binaryImageData = UIImagePNGRepresentation(imagen);

	[binaryImageData writeToFile:filePath atomically:YES];

}


//PDF
+ (NSData*)leerPDF:(NSString *)offlineFile
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *filePath = [documentsDirectory stringByAppendingPathComponent:offlineFile];
	//NSURLRequest *request;
	NSData* data;

	if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{
		//request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath isDirectory:NO]];
		data = [[NSFileManager defaultManager] contentsAtPath:filePath];
	}
	else
	{
		//request=nil;
		data=nil;
	}

	return data;

}

+ (void)escribirPDF: (NSData *)PDFdata :(NSString *)offlineFile
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSArray *directorio = [offlineFile componentsSeparatedByString:@"/"];
	NSString * filePath = documentsDirectory;

	for (int j = 0; j < [directorio count]-1; j++)
	{
		filePath = [filePath stringByAppendingPathComponent:[directorio objectAtIndex:j]];
		if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
			[[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:nil]; 
		}
	}

	filePath = [documentsDirectory stringByAppendingPathComponent:offlineFile];

	//[PDFdata writeToFile:filePath options:NSDataWritingAtomic error:&error]
	[PDFdata writeToFile:filePath atomically:YES];

	//if([error localizedDescription]!=nil)


}

//existe
+ (bool)existe:(NSString *)offlineFile
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString * filePath = [documentsDirectory stringByAppendingPathComponent:offlineFile];

	return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

+ (BOOL)eliminar:(NSString *)offlineFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString * filePath = [documentsDirectory stringByAppendingPathComponent:offlineFile];
    NSError* error = [[NSError alloc] init];
    
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    if (error == nil)
        return YES;
    else
        return NO;
}

+ (BOOL)eliminarTodo
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    NSError* error = [[NSError alloc] init];
    
    [[NSFileManager defaultManager] removeItemAtPath:documentsDirectory error:&error];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:NO attributes:nil error:&error];
    if (error == nil)
        return YES;
    else
        return NO;
}

@end






