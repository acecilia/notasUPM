#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ModelUPMDelegate <NSObject>
@optional
- (void)modelUPMacaboDeCargarDatosTablonDeNotasConError:(NSString *)error;
- (void)modelUPMacaboDeCargarDatosExpedienteConError:(NSString *)error;
- (void)modelUPMacaboDeCargarDatosPersonalesconError:(NSString *)error;

@end

@interface ModelUPM : NSObject <UIWebViewDelegate>
{
	NSString *user, *pass;

	UIImage *foto;
	NSString *nombre;
	NSString *apellidos;
	NSMutableArray *convocatorias;
	NSMutableArray *expediente;
	NSMutableArray *TableDataNotas, *CabeceraSeccion;
	UIWebView* webViewPolitecnicaVirtual;
}

@property (retain, nonatomic) UIWebView* webViewPolitecnicaVirtual;

- (void)inicializarConUsuario:(NSString *)usuario contraseña:(NSString *)contraseña;

- (void)cargarDatosPolitecnicaVirtual;

- (void)addDelegate:(id)delegate;
- (void)removeDelegate:(id)delegate;

- (NSString *)getUsuario;
- (NSString *)getContraseña;

- (UIImage *)getFoto;
- (NSString *)getNombre;
- (NSString *)getApellidos;
- (NSMutableArray *)getExpediente;
- (NSMutableArray *)getExpediente:(int) numeroExpediente;
- (NSMutableArray *)getConvocatorias;
- (NSMutableArray *)getSections;

- (NSString *)getDescripcionError;

@end




