#import <UIKit/UIKit.h>

@interface AlmacenamientoLocal : NSObject

//manejo de version
+ (void) añadirVersionYEscribir:(NSString *)path :(id)file;
+ (id)obtenerArchivoSinVersion:(NSString *)path;

//NSArray
+ (NSMutableArray*)leer:(NSString *)offlineFile;
+ (void)escribir: (NSMutableArray *)array :(NSString *)offlineFile;

//NSString
+ (NSString*)leerString:(NSString *)offlineFile;
+ (void)escribirString: (NSString *)string :(NSString *)offlineFile;

//UIImage
+ (UIImage*)leerImagen:(NSString *)offlineFile;
+ (void)escribirImagen: (UIImage *)imagen :(NSString *)offlineFile;

//PDF
+ (NSData*)leerPDF:(NSString *)offlineFile;
+ (void)escribirPDF: (NSData *)PDFdata :(NSString *)offlineFile;

//existe
+ (bool)existe:(NSString *)offlineFile;

@end



