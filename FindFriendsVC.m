#import "FindFriendsVC.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <FacebookSDK/FacebookSDK.h>
#import "SCLAlertView.h"
#import <RESideMenu/RESideMenu.h>
#import <Parse/Parse.h>

@interface FindFriendsVC ()

@end

@implementation FindFriendsVC

@synthesize searchBar;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)fbTapped:(id)sender {
    [self connectToFB];
    
}

- (IBAction)menuTapped:(id)sender {
    [self.sideMenuViewController presentLeftMenuViewController];

}

- (IBAction)blaButton:(id)sender {
    [self queryParseUsers];
}

-(void)queryParseUsers{
    NSString* searchText = searchBar.text;
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"username" equalTo:searchText];
    
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu users.", (unsigned long)objects.count);
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];


}
- (void)connectToFB {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location",@"user_friends"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
    

        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
      
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            
            [alert showError:self title:@"Log In Error" subTitle:errorMessage closeButtonTitle:@"Done" duration:0.0f]; // Notice
            
        }
        else {
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
            } else {
                NSLog(@"User with facebook logged in!");
            }
            
            NSLog(@"should now present users details view controller");
            
            FBRequest *request = [FBRequest requestForMe];
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    NSDictionary *userData = (NSDictionary *)result;
                    NSLog(@"facebook dictionary %@",userData);
                    NSString *name = userData[@"name"];
                    NSLog(@"first name ?? %@",name);
                    
                }
            }];
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            
            [alert hideView];
            
            FBRequest* friendsRequest = [FBRequest requestForMyFriends];
            
            [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                          
                                                          NSDictionary* result,
                                                          NSError *error) {
                if(!error){
                    NSMutableArray *facebookUIDs = [NSMutableArray array];
                    NSArray* friends = [result objectForKey:@"data"];
                    NSLog(@"Found: %i friends", friends.count);
                    
                    if (friends.count < 1) {
                        SCLAlertView *alert = [[SCLAlertView alloc] init];

                  
                        [alert showCustom:self image:[UIImage imageNamed:@"fb.png"] color:[UIColor blueColor] title:@"Facebook" subTitle:@"No one on your friends list is currently using snoozle." closeButtonTitle:@"OK" duration:2.0f];

                        
                    }
                    // STUFFS
                    for (NSDictionary<FBGraphUser>* friend in friends) {
                        [facebookUIDs addObject:friend.id];
                    }
                    
                    
                }
            }];
            
        }
    }];
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.shouldDismissOnTapOutside = YES;
    [alert showCustom:self image:[UIImage imageNamed:@"fb.png"] color:[UIColor blueColor] title:@"Facebook" subTitle:@"Connecting" closeButtonTitle:@"OK" duration:2.0f];
}





@end
