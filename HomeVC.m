#import "HomeVC.h"
#import "TimePickerVC.h"
#import "SCLAlertView.h"
#import <RESideMenu/RESideMenu.h>
#import <ParseUI/ParseUI.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <FacebookSDK/FacebookSDK.h>
#import "PlayMemoVC.h"
#import "LeftMenuVC.h"

@interface HomeVC (){
    AVAudioRecorder *recorder;
    NSTimer *timer;
    SCLAlertView *alert;
    BOOL *date;
}

@property (strong, nonatomic) TimeOfDay *timeOfDay;


@end

@implementation HomeVC


@synthesize datePicker;
@synthesize titleLabel;
@synthesize alarmToggle;
@synthesize recordButton;
@synthesize recordView;
@synthesize tempMemoURL;
@synthesize hamburgerMenuButton;
@synthesize savedAlarmTime;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self recorderSettings];
    self.recordView.layer.cornerRadius = 80;
    [alarmToggle addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    [self isAlarmSwitchToggled];
  
    NSUInteger *savedAlarmHour = (NSUInteger*)[[NSUserDefaults standardUserDefaults] integerForKey:@"AlarmHour"];
    NSUInteger *savedAlarmMinute = (NSUInteger*)[[NSUserDefaults standardUserDefaults] integerForKey:@"AlarmMinute"];
   
    NSLog(@"saved AlarmHour %lu",savedAlarmHour);
    NSLog(@"Saved Alarm Minute %lu",savedAlarmMinute);

     savedAlarmTime = [TimeOfDay createFromHours:savedAlarmHour minutes:savedAlarmMinute];
    
    _selectedTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (unsigned long)savedAlarmTime.hours, (unsigned long)savedAlarmTime.minutes];
    
    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);

    hamburgerMenuButton.lineColor=[UIColor redColor];
    [hamburgerMenuButton updateAppearance];
}

-(void)isAlarmSwitchToggled {
    if (_selectedTimeLabel.text.length > 0) {
        [alarmToggle setOn:YES animated:YES];
        alarmToggle.enabled = true;
        [self alarm];
        
    }
    else {
        titleLabel.text=@"No Alarm Set";
        [alarmToggle setOn:NO animated:YES];
        alarmToggle.enabled = FALSE;
        
    }
}

- (IBAction)didCloseButtonTouch:(JTHamburgerButton *)sender
{
    if(sender.currentMode == JTHamburgerButtonModeHamburger){
        [sender setCurrentMode:JTHamburgerButtonModeCross withAnimation:.3];
        [self.sideMenuViewController presentLeftMenuViewController];


    }
    else{
        [sender setCurrentMode:JTHamburgerButtonModeHamburger withAnimation:.3];

    }
}


- (BOOL)date:(NSDate *)date hour:(NSInteger)h minute:(NSInteger)m {
    
    NSCalendar *calendar = [[NSCalendar alloc] init];
    
    NSDateComponents *componets = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit )fromDate:[NSDate date]];
    if ([componets hour ] == h && [componets minute] == m) {
        
        return YES;
    }
    return NO;
}




- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
    TimePickerVC *source = [segue sourceViewController];
    if (source.timeOfDay != nil) {
        _timeOfDay = source.timeOfDay;
        
        [[NSUserDefaults standardUserDefaults] setInteger:source.timeOfDay.hours forKey:@"AlarmHour"];
        [[NSUserDefaults standardUserDefaults] setInteger:source.timeOfDay.minutes forKey:@"AlarmMinute"];
       NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
        [[NSUserDefaults standardUserDefaults] synchronize];
        

        [self alarm];
        

    }
}



-(void)alarm {
    _selectedTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (unsigned long)savedAlarmTime.hours, (unsigned long)savedAlarmTime.minutes];
    titleLabel.text=@"";
    [alarmToggle setOn:YES animated:YES];
    alarmToggle.enabled = true;
    
    
    NSDate *now = [NSDate date];
    
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:now];
    
    
    [comps setMinute:savedAlarmTime.minutes];
    [comps setHour:savedAlarmTime.hours];
    NSDate *newDatefromComp = [[NSCalendar currentCalendar] dateFromComponents:comps];
    
    if ([now compare:newDatefromComp] == NSOrderedDescending ) {
        NSDate *tomorrowAlarm = [now dateByAddingTimeInterval:60*60*24*1];
        NSDateComponents *tomorrowAlarmComps = [[NSCalendar currentCalendar] components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:tomorrowAlarm];
        NSInteger day = [tomorrowAlarmComps day];
        [comps setDay:day];
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showSuccess:self title:@"Alarm" subTitle:[NSString stringWithFormat:@"Alarm Set for tomorrow %1$@",_selectedTimeLabel.text] closeButtonTitle:@"Done" duration:0.0f]; // Notice

    }
    else {
        SCLAlertView *alert = [[SCLAlertView alloc] init];

        [alert showSuccess:self title:@"Alarm" subTitle:[NSString stringWithFormat:@"Alarm Set for %1$@",_selectedTimeLabel.text] closeButtonTitle:@"Done" duration:0.0f]; // Notice

        
    }
    
    NSDate *fireTime = [[NSCalendar currentCalendar] dateFromComponents:comps];
    
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = fireTime;
    localNotification.alertBody = @"Wake Now Up!!";
    localNotification.alertAction = @"Show me the item";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.soundName=@"alarm1.wav";
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    


    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)changeSwitch:(id)sender{
    if([sender isOn]){
        
        _selectedTimeLabel.textColor=[UIColor colorWithRed:132/255 green:255/255 blue:93/255 alpha:1];
    } else{

        _selectedTimeLabel.textColor=[UIColor colorWithRed:255/255 green:132/255 blue:93/255 alpha:1];
    }
}

- (IBAction)switchTapped:(id)sender {
    [self changeSwitch:sender];
}

- (IBAction)recordButtonUpOutside:(id)sender {
    [self performSegueWithIdentifier:@"playMemo" sender:self];
    NSLog(@"shouldTransitionToMemo");

//    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"playMemoVC"]]
//                                                 animated:YES];
    
}

- (IBAction)recordTouchUp:(id)sender {
    [recorder stop];
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *soundFilePath = [docsDir
                               stringByAppendingPathComponent:@"tmpSound.caf"];
    
    self.tempMemoURL = [NSURL fileURLWithPath:soundFilePath];
    
    NSDictionary *recSettings = [NSDictionary
                                 dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithInt:AVAudioQualityMin],
                                 AVEncoderAudioQualityKey,
                                 [NSNumber numberWithInt:16],
                                 AVEncoderBitRateKey,
                                 [NSNumber numberWithInt: 2],
                                 AVNumberOfChannelsKey,
                                 [NSNumber numberWithFloat:44100.0],
                                 AVSampleRateKey,
                                 nil];
    
    recorder = [[AVAudioRecorder alloc] initWithURL:tempMemoURL settings:recSettings error:nil];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    
    
    NSLog(@"stopped stopped");
    
    [recordView.layer removeAllAnimations];
    [recordView setBackgroundColor: [UIColor redColor]];
    [self recordButtonUpOutside:self];
}


- (void)recorderSettings {
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord
             withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                   error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
}
- (void)animateColors {
    
    
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut |
     UIViewAnimationOptionRepeat |
     UIViewAnimationOptionAutoreverse |
     UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         [recordView setBackgroundColor: [UIColor whiteColor]];
                         
                     }
                     completion:nil];
    
}




- (IBAction)recordTouchDown:(id)sender {
    [self animateColors];

    [recorder recordForDuration:30];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(updateTime)
                                           userInfo:nil
                                            repeats:YES];
    NSLog(@"started started");
    
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier  isEqual:@"playMemo"]){
        PlayMemoVC *vc = segue.destinationViewController;
        vc.memoURL = tempMemoURL;
    }
}


-(void)updateTime
{
    //Get the time left until the specified date
    NSInteger seconds = 30;
    
    
    //Update the label with the remaining time
}


@end
