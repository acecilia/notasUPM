#import "ECSlidingViewController.h"
#import "ContactoViewController.h"

#define COLOR_PRINCIPAL [UIColor colorWithRed:85/255.0 green:172/255.0 blue:239/255.0 alpha:1.0] //AZUL NUEVO

@interface ContactoViewController ()
{
}
@end

@implementation ContactoViewController

@synthesize celdas;

- (id)initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];
	if (self) {}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	[self setNavTitleView];

	self.tableView.alwaysBounceVertical = NO;
	self.tableView.separatorColor = [UIColor clearColor];

	self.celdas = [NSArray arrayWithObjects:@"Puedes ponerte en contacto con los desarrolladores mandándonos un mail a:",@"\n", @"Utiliza esta direción para darnos a conocer sugerencias y problemas de la aplicación.\n\n¡Disfrútala!\n\nCreada por Andrés Cecilia y Álvaro Román.\n\nSoportada por la Escuela Técnica Superior de Ingeniería de Sistemas de Telecomunicación ETSIST.", nil];
}


- (void)setNavTitleView
{
	UILabel *titulo = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];

	titulo.text = @"Contacto";
	titulo.textAlignment = NSTextAlignmentCenter;
	titulo.textColor = [UIColor whiteColor];
	titulo.backgroundColor = [UIColor clearColor];
	titulo.font = [UIFont fontWithName:@"QuicksandBold-Regular" size:20];
	self.navigationItem.titleView = titulo;



	UIButton* botonMenu = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
	[botonMenu addTarget:self action:@selector(revealMenu) forControlEvents:UIControlEventTouchUpInside];
	botonMenu.backgroundColor = [UIColor clearColor];
	[botonMenu setBackgroundImage:[UIImage imageNamed:@"menuButton"] forState:UIControlStateNormal];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:botonMenu];

	UIButton *right = [[UIButton alloc]initWithFrame:CGRectMake(10, 12, 34,24)];
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithCustomView:right];

	self.navigationItem.rightBarButtonItem = rightButton;

}

- (void)revealMenu
{
	[self.slidingViewController anchorTopViewTo:ECRight];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.celdas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"Cell %li",(long)indexPath.section]];

	if(cell==nil)
	{
		cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[NSString stringWithFormat:@"Cell %li",(long)indexPath.section]];
	}
	cell.textLabel.numberOfLines = 0;
	cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
	cell.textLabel.textColor = [UIColor blackColor];
	cell.textLabel.font=[UIFont fontWithName:@"QuicksandBook-Regular" size:16];
	cell.textLabel.textAlignment = NSTextAlignmentCenter;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.backgroundColor = [UIColor clearColor];

	cell.textLabel.text = [NSString stringWithFormat:@"%@", [self.celdas objectAtIndex:indexPath.row]];

	cell.userInteractionEnabled = NO;

	return cell;
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.row==1)
	{
		UILabel *titulo = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 35)];

		titulo.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;

		[titulo setTextColor:[UIColor whiteColor]];
		[titulo setBackgroundColor:COLOR_PRINCIPAL];
		[titulo setTextAlignment:NSTextAlignmentCenter];
		[titulo setFont:[UIFont fontWithName:@"QuicksandBold-Regular" size:20]];
		[titulo setText:@"apple.dev@euitt.upm.es"];
		titulo.adjustsFontSizeToFitWidth = YES;


		[cell addSubview:titulo];

		cell.userInteractionEnabled = YES;


	}
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.row)
	{
		case 1:
			[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"mailto:apple.dev@euitt.upm.es"]];
			break;
		default:
			break;
	}

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *str = @"";
	CGSize size = [str sizeWithFont:[UIFont fontWithName:@"QuicksandBook-Regular" size:16] constrainedToSize:CGSizeMake(300, 999) lineBreakMode:NSLineBreakByWordWrapping];

	str = [NSString stringWithFormat:@"%@", [self.celdas objectAtIndex:indexPath.row]];


	if(!UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
	{

		size = [str sizeWithFont:[UIFont fontWithName:@"QuicksandBook-Regular" size:16] constrainedToSize:CGSizeMake(300, 999) lineBreakMode:NSLineBreakByWordWrapping];
	}
	else
	{
		size = [str sizeWithFont:[UIFont fontWithName:@"QuicksandBook-Regular" size:16] constrainedToSize:CGSizeMake(450, 999) lineBreakMode:NSLineBreakByWordWrapping];
	}

	if (indexPath.row==1)
	{
		size.height=20;
	}

	return size.height + 20;
}





- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

@end






