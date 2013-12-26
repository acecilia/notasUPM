#import "VisorWeb.h"
#import "QuartzCore/CAAnimation.h"
#import "AppDelegate.h"

#define URL_MOODLE_LOGIN @"https://moodle.upm.es/titulaciones/oficiales/login/login.php"

@interface VisorWeb ()
{
	UIButton* botonReload;
	ModelUPM *modelo;
	UIWebView *myWebView;
}

@end

@implementation VisorWeb

@synthesize URL, navViewTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
	modelo = appDelegate.modelo;

	self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	self.view.backgroundColor=[UIColor whiteColor];
	[self setNavView];

	NSURLRequest *myRequest = [NSURLRequest requestWithURL: [NSURL URLWithString:URL]];
	myWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	myWebView.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
	myWebView.backgroundColor=[UIColor whiteColor];
	myWebView.delegate = self;
	myWebView.scalesPageToFit = YES;
	myWebView.alpha = 0;
	[self.view insertSubview:myWebView atIndex:0];

	if(modelo.moodleEstaCargando == 0)
	{
		[myWebView loadRequest:myRequest];
	}
	else
	{
		[modelo addDelegate:self];
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

	UIImage *atras = [UIImage imageNamed:@"atras"];
	UIButton *botonAtras = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
	botonAtras.center = CGPointMake(botonAtras.frame.size.width/2 + 5, self.view.frame.size.height-botonAtras.frame.size.height/2 - 5);
	botonAtras.autoresizingMask=(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
	[botonAtras addTarget:self action:@selector(atras) forControlEvents:UIControlEventTouchDown];
	[botonAtras setBackgroundColor:[UIColor clearColor]];
	[botonAtras setBackgroundImage:atras forState:UIControlStateNormal];
	[botonAtras setTitle:@"" forState:UIControlStateNormal];
	[self.view addSubview:botonAtras];

	UIImage *adelante = [UIImage imageNamed:@"adelante"];
	UIButton *botonAdelante = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
	botonAdelante.center = CGPointMake(botonAtras.frame.size.width + 10 + botonAdelante.frame.size.width/2 + 5, self.view.frame.size.height-botonAdelante.frame.size.height/2 - 5);
	botonAdelante.autoresizingMask=(UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
	[botonAdelante addTarget:self action:@selector(adelante) forControlEvents:UIControlEventTouchDown];
	[botonAdelante setBackgroundColor:[UIColor clearColor]];
	[botonAdelante setBackgroundImage:adelante forState:UIControlStateNormal];
	[botonAdelante setTitle:@"" forState:UIControlStateNormal];
	[self.view addSubview:botonAdelante];

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

- (void)atras
{
	if ([myWebView canGoBack]) 
	{
		[myWebView goBack];
	}
}

- (void)adelante
{
	if ([myWebView canGoForward]) 
	{
		[myWebView goForward];
	}
}


- (void)back
{
	CATransition* transition = [CATransition animation];
	transition.duration = 0.40;
	transition.type = kCATransitionReveal;
	transition.subtype = kCATransitionFromTop;
	[self.navigationController.view.layer addAnimation:transition forKey:nil];

	[self.navigationController popViewControllerAnimated:NO];

	[modelo removeDelegate:self];
}


- (void)animarLoading
{
	[botonReload setEnabled:NO];

	[UIView animateWithDuration:0.5 animations:^(void)
	{
		botonReload.alpha=1;
	}];

	CABasicAnimation *rotationAnimation;
	rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	rotationAnimation.repeatCount = 1000;
	rotationAnimation.duration = 1;
	rotationAnimation.cumulative = YES;
	rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 * 1 * 1 ];
	rotationAnimation.removedOnCompletion = NO;
	[botonReload.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)dejarDeAnimarLoading
{
	[botonReload setEnabled:YES];
	[botonReload.layer removeAllAnimations];
	[UIView animateWithDuration:0.5 animations:^(void)
	{
		botonReload.alpha=0;
	}];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	if([webView.request.URL.absoluteString isEqualToString:URL_MOODLE_LOGIN])
	{ 
		[modelo addDelegate:self];
		if(modelo.moodleEstaCargando == 0)
		{
			[modelo cargarDatosMoodle];
		}
		[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URL]]];
	}
	else
	{
		if([webView.request.URL.absoluteString isEqualToString:URL])
		{ 
			myWebView.alpha = 1;
		}
		[self dejarDeAnimarLoading];
	}
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[self animarLoading];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	UIAlertView *alerta;

	if ([webView isLoading])
		[webView stopLoading];

	if (error.code != NSURLErrorNotConnectedToInternet)
	{
		NSString *descripcionError = [error localizedDescription];
		alerta = [[UIAlertView alloc]initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"Se ha producido un error en la conexión: %@", descripcionError] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alerta show];
	}

	[self dejarDeAnimarLoading];
}


/*- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
  {
  UIAlertView *alerta;
  if (error.code == NSURLErrorNotConnectedToInternet)
  {
//alerta = [[UIAlertView alloc]initWithTitle:@"ERROR" message:@"No está conectado a Internet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//alerta.tag = 3;
//[alerta show];
}
else //if (error.code != NSURLErrorCancelled)
{
NSString *descripcionError = [error localizedDescription];
alerta = [[UIAlertView alloc]initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"Se ha producido un error en la conexión: %@", descripcionError] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
alerta.tag = 4;
[alerta show];
}

[self dejarDeAnimarLoading];
}*/


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


/*- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  CGFloat ratioAspect = myWebView.bounds.size.width/myWebView.bounds.size.height;
  switch (toInterfaceOrientation) {
  case UIInterfaceOrientationPortraitUpsideDown:
  case UIInterfaceOrientationPortrait:
// Going to Portrait mode
for (UIScrollView *scroll in [myWebView subviews]) { //we get the scrollview 
// Make sure it really is a scroll view and reset the zoom scale.
if ([scroll respondsToSelector:@selector(setZoomScale:)]){
scroll.minimumZoomScale = scroll.minimumZoomScale/ratioAspect;
scroll.maximumZoomScale = scroll.maximumZoomScale/ratioAspect;
[scroll setZoomScale:(scroll.zoomScale/ratioAspect) animated:YES];
}
}
break;
default:
// Going to Landscape mode
for (UIScrollView *scroll in [myWebView subviews]) { //we get the scrollview 
// Make sure it really is a scroll view and reset the zoom scale.
if ([scroll respondsToSelector:@selector(setZoomScale:)]){
scroll.minimumZoomScale = scroll.minimumZoomScale *ratioAspect;
scroll.maximumZoomScale = scroll.maximumZoomScale *ratioAspect;
[scroll setZoomScale:(scroll.zoomScale*ratioAspect) animated:YES];
}
}
break;
}
}*/

/*- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
  {
  CGFloat ratioAspect = myWebView.bounds.size.height/myWebView.bounds.size.width;
  switch (fromInterfaceOrientation) {
  case UIInterfaceOrientationPortraitUpsideDown:
  break;
  case UIInterfaceOrientationPortrait:
// Gone to Landscape mode
for (UIScrollView *scroll in [myWebView subviews]) { //we get the scrollview 
// Make sure it really is a scroll view and reset the zoom scale.
if ([scroll respondsToSelector:@selector(setZoomScale:)]){
scroll.minimumZoomScale = scroll.minimumZoomScale /ratioAspect;
scroll.maximumZoomScale = scroll.maximumZoomScale /ratioAspect;
[scroll setZoomScale:(scroll.zoomScale/ratioAspect) animated:YES];
}
}
break;
default:
if([[UIDevice currentDevice] orientation]==UIInterfaceOrientationPortrait)
{
// Gone to Portrait mode
for (UIScrollView *scroll in [myWebView subviews]) { //we get the scrollview 
// Make sure it really is a scroll view and reset the zoom scale.
if ([scroll respondsToSelector:@selector(setZoomScale:)]){
scroll.minimumZoomScale = scroll.minimumZoomScale/ratioAspect;
scroll.maximumZoomScale = scroll.maximumZoomScale/ratioAspect;
[scroll setZoomScale:(scroll.zoomScale/ratioAspect) animated:YES];
}
}
}
break;
}
}*/



/*- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {

  [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

  CGFloat scale = myWebView.contentScaleFactor;
  NSString *javaStuff = [NSString stringWithFormat:@"document.body.style.zoom = %f;", scale];
  [myWebView stringByEvaluatingJavaScriptFromString:javaStuff];

  }*/


// ModelUPM Delegate
- (void)modelUPMacaboDeCargarDatosMoodleConError:(NSString *)error
{
	if (error == nil)
	{
		[myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URL]]];
	}
	else
	{
		UIAlertView *alerta = [[UIAlertView alloc]initWithTitle:@"ERROR DE MOODLE en el Visor Web" message:error delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alerta show];

		[self dejarDeAnimarLoading];
	}
	[modelo removeDelegate:self];
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	for (UIView *subView in [myWebView subviews]) 
	{
		if ([subView isKindOfClass:[UIScrollView class]]) {
			UIScrollView *scrollView = (UIScrollView *)subView;
			[scrollView setZoomScale:1.01f animated:YES];
		}
	}
}



- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate
{
	return YES;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

@end






