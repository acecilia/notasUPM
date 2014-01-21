#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ModelUPMDelegate <NSObject>
@optional
- (void)modelUPMacaboDeCargarDatosTablonDeNotasConError:(NSString *)error;
- (void)modelUPMacaboDeCargarDatosExpedienteConError:(NSString *)error;
- (void)modelUPMacaboDeCargarDatosMoodleConError:(NSString *)error;
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
	NSMutableArray *asignaturas;
	NSMutableArray *TableDataNotas, *CabeceraSeccion;
	UIWebView* webViewPolitecnicaVirtual;
	UIWebView* webViewMoodle;

	//int errorNum;
    
	//NSString *errorDescription;
}

//@property (weak, nonatomic) id<ModelUPMDelegate> delegate;
@property (retain, nonatomic) UIWebView* webViewMoodle;
@property (retain, nonatomic) UIWebView* webViewPolitecnicaVirtual;

@property (nonatomic, assign) BOOL moodleEstaCargando;

- (void)inicializarConUsuario:(NSString *)usuario contraseña:(NSString *)contraseña;

- (void)cargarDatosPolitecnicaVirtual;
- (void)cargarDatosMoodle;
- (void)inicializarMoodleConNuevaCuenta;

- (void)addDelegate:(id)delegate;
- (void)removeDelegate:(id)delegate;

- (NSString *)getUsuario;
- (NSString *)getContraseña;

- (UIImage *)getFoto;
- (NSString *)getNombre;
- (NSString *)getApellidos;
- (NSMutableArray *)getAsignaturas;
- (NSMutableArray *)getExpediente;
- (NSMutableArray *)getExpediente:(int) numeroExpediente;
- (NSMutableArray *)getConvocatorias;
- (NSMutableArray *)getSections;

- (NSString *)getDescripcionError;

@end




