#import "MoodleWebViewViewController.h"
#import "QuartzCore/CAAnimation.h"
#import "AppDelegate.h"
#import "AlmacenamientoLocal.h"
#import "Animador.h"

#define URL_MOODLE_LOGIN @"https://moodle.upm.es/titulaciones/oficiales/login/index.php"

@interface MoodleWebViewViewController ()
{
	UIButton* botonReload;

	NSData* PDFdata;
	NSMutableData* webdata;

	MoodleNSObject *moodleNSObject;
}

@end

@implementation MoodleWebViewViewController

@synthesize URL, offlineFile, navViewTitle;

- (void)viewDidLoad
{
	[super viewDidLoad];

	AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
	moodleNSObject = appDelegate.moodleNSObject;
	//moodleNSObject.delegate = self;

	self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	self.view.backgroundColor=[UIColor whiteColor];
	[self setNavView];

	PDFdata =[AlmacenamientoLocal leerPDF:offlineFile];

	if (PDFdata!=nil)
	{
		UIWebView *PDF = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
		PDF.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
		PDF.backgroundColor=[UIColor whiteColor];

		[PDF loadData:PDFdata MIMEType:@"application/pdf" textEncodingName:@"utf-8" baseURL:nil];
		PDF.scalesPageToFit = YES;

		[self.view insertSubview:PDF atIndex:0];
	}

	if(moodleNSObject.moodleEstaCargando == 0)
	{
		NSURLRequest *myRequest = [NSURLRequest requestWithURL: [NSURL URLWithString:URL]];
		[NSURLConnection connectionWithRequest: myRequest delegate:self];	
	}
	else
	{
		[moodleNSObject addDelegate:self];
	}

	[self animarLoading]; 
}

- (void)viewWillAppear:(BOOL)animated
{
	[self.navigationController setNavigationBarHidden:YES animated:animated];
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self.navigationController setNavigationBarHidden:NO animated:animated];
	[super viewWillDisappear:animated];
}

- (void)setNavView
{
	UILabel *titulo = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
	titulo.text = navViewTitle;
	titulo.textAlignment = NSTextAlignmentCenter;
	titulo.textColor = [UIColor whiteColor];
	titulo.backgroundColor = [UIColor clearColor];
	titulo.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:20];
	self.navigationItem.titleView = titulo;

	UIImage *imagenBack = [UIImage imageNamed:@"backTop"];
	UIButton *botonBack = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
	botonBack.center = CGPointMake(self.view.frame.size.width - botonBack.frame.size.width/2 -5, self.view.frame.size.height-botonBack.frame.size.height/2 - 5);
	botonBack.autoresizingMask=(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
	[botonBack addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchDown];
	[botonBack setBackgroundColor:[UIColor clearColor]];
	[botonBack setBackgroundImage:imagenBack forState:UIControlStateNormal];
	[botonBack setTitle:@"" forState:UIControlStateNormal];
	[self.view addSubview:botonBack];

	botonReload =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
	botonReload.center = CGPointMake(self.view.frame.size.width - botonReload.frame.size.width/2 -5, botonReload.frame.size.height/2 + 5);
	botonReload.autoresizingMask=(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
	[botonReload addTarget:self action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
	botonReload.backgroundColor = [UIColor clearColor];
	[botonReload setBackgroundImage:[UIImage imageNamed:@"loadingWV"] forState:UIControlStateNormal];
	[botonReload setBackgroundImage:[UIImage imageNamed:@"loadingWVAnimated"] forState:UIControlStateDisabled];
	[self.view addSubview:botonReload];

}


- (void)reload
{
}


- (void)back
{
	CATransition* transition = [CATransition animation];
	transition.duration = 0.40;
	transition.type = kCATransitionReveal;
	transition.subtype = kCATransitionFromTop;
	[self.navigationController.view.layer addAnimation:transition forKey:nil];

	[self.navigationController popViewControllerAnimated:NO];
	[moodleNSObject removeDelegate:self];
}


- (void)animarLoading
{
    [botonReload setEnabled:NO];
    [Animador animarBoton:botonReload];
}

- (void)dejarDeAnimarLoading
{
    [Animador dejarDeAnimarBoton:botonReload conDelegate:self];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    if(theAnimation == [botonReload.layer animationForKey:@"scaleFinal"])
    {
        [botonReload.layer removeAllAnimations];
        CABasicAnimation *scale2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scale2.fromValue = @0.1;
        scale2.toValue = @1.0;
        //scale2.autoreverses=YES;
        //scale2.beginTime = CACurrentMediaTime()+scale.duration;
        scale2.duration = 0.5;
        scale2.cumulative = YES;
        scale2.removedOnCompletion = NO;
        scale2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [botonReload.layer addAnimation:scale2 forKey:@"scaleFinal2"];
        
        CABasicAnimation *rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.duration = 0.5;
        //rotationAnimation.beginTime = CACurrentMediaTime()+scale.duration;
        rotationAnimation.delegate = self;
        rotationAnimation.fromValue = [NSNumber numberWithFloat: -M_PI];
        rotationAnimation.toValue = [NSNumber numberWithFloat: 0];
        rotationAnimation.removedOnCompletion = NO;
        rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [botonReload.layer addAnimation:rotationAnimation forKey:@"rotationAnimation2"];
    }
    else if(theAnimation == [botonReload.layer animationForKey:@"rotationAnimation2"])
    {
        [botonReload.layer removeAllAnimations];
        [botonReload setEnabled:YES];
        [UIView animateWithDuration:0.5 animations:^(void)
         {
             botonReload.alpha=0;
         }];
    }
}


- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse{
	if([request.URL.absoluteString isEqualToString:URL_MOODLE_LOGIN])
	{
		[moodleNSObject addDelegate:self];
		if(moodleNSObject.moodleEstaCargando == NO)
		{
			[moodleNSObject cargarDatosMoodle];
		}
		[connection cancel];
		return nil;
	}
	else
	{
		return request;
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	webdata = [[NSMutableData alloc] init];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	[webdata appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
	if (![webdata isEqualToData:PDFdata])
	{
		UIWebView *PDF = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
		PDF.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
		PDF.backgroundColor=[UIColor whiteColor];

		[PDF loadData:webdata MIMEType:@"application/pdf" textEncodingName:@"utf-8" baseURL:nil];
		PDF.scalesPageToFit = YES;

		for (int j = 0; j < [self.view.subviews count]-2; j++)
		{
			[self.view.subviews[j] removeFromSuperview];
		}
		[self.view insertSubview:PDF atIndex:0];

		[AlmacenamientoLocal escribirPDF: webdata:offlineFile];
	}
	[self dejarDeAnimarLoading];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if (error.code != NSURLErrorNotConnectedToInternet)
	{
		NSString *descripcionError = [error localizedDescription];
		UIAlertView * alerta = [[UIAlertView alloc]initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"Se ha producido un error en la conexión: %@", descripcionError] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		alerta.tag = 4;
		[alerta show];
	}

	[self dejarDeAnimarLoading];
}


/*- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
  {
  if (alertView.tag == 1)
  {
  if (buttonIndex == 0)
  {
  [self.navigationController popToRootViewControllerAnimated:YES];
  }
  }
  else if (alertView.tag == 2)
  {
  if (buttonIndex == 0)
  {
//[self.navigationController popViewControllerAnimated:YES];
[self.navigationController popToRootViewControllerAnimated:YES];
}
}
else if (alertView.tag == 3)
{
if (buttonIndex == 0)
{
[self.navigationController popToRootViewControllerAnimated:YES];
}
}
else if (alertView.tag == 4)
{
if (buttonIndex == 0)
{
[self.navigationController popToRootViewControllerAnimated:YES];
}
}
}*/


// ModelUPM Delegate
- (void)modelUPMacaboDeCargarDatosMoodleConError:(NSString *)error
{
	if (error == nil)
	{
		NSURLRequest *myRequest = [NSURLRequest requestWithURL: [NSURL URLWithString:URL]];
		[NSURLConnection connectionWithRequest: myRequest delegate:self];
	}
	else
	{
		UIAlertView *alerta = [[UIAlertView alloc]initWithTitle:@"ERROR DE MOODLE en visor PDF" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alerta show];

		[self dejarDeAnimarLoading];
	}
	[moodleNSObject removeDelegate:self];
}


- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end






