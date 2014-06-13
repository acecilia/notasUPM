//
//  MoodleNSObject.h
//  notasUPM
//
//  Created by andres on 13/06/14.
//  Copyright (c) 2014 Alvaro Roman. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MoodleNSObjectDelegate <NSObject>
@optional
- (void)modelUPMacaboDeCargarDatosMoodleConError:(NSString *)error;

@end

@interface MoodleNSObject : NSObject <UIWebViewDelegate>
{
	NSString *user, *pass;
	NSMutableArray *asignaturas;
	UIWebView* webViewMoodle;
    
	//int errorNum;
    
	//NSString *errorDescription;
}


@property (retain, nonatomic) UIWebView* webViewMoodle;
@property (nonatomic, assign) BOOL moodleEstaCargando;

- (void)cargarDatosMoodle;
- (void)inicializarMoodleConNuevaCuenta;

- (void)addDelegate:(id)delegate;
- (void)removeDelegate:(id)delegate;

- (NSString *)getUsuario;
- (NSString *)getContraseña;

- (NSMutableArray *)getAsignaturas;

- (NSString *)getDescripcionError;

@end
