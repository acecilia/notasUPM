#import <UIKit/UIKit.h>

@protocol DescargadorDelegate <NSObject>
@optional
- (void)acaboDeDescargarTodo;
- (void)voyDescargandoPorElNumero:(int) numero conError:(NSString*) error;

@end

@interface Descargador : NSObject <NSURLConnectionDataDelegate>

@property (weak, nonatomic) id<DescargadorDelegate> delegate;
//descargarTodo
- (void)descargarTodo:(NSMutableArray *)array :(NSString*) file;

- (void) dejarDeDescargar;

@end



