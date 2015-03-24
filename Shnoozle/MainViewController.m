

#import "MainViewController.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <FacebookSDK/FacebookSDK.h>

@interface MainViewController (){
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    NSURL *tempSoundStorage;
    NSTimer *timer;

}

@end

@implementation MainViewController

@synthesize playBtn;
@synthesize playView;
@synthesize recordPauseBtn;
@synthesize recordView;
@synthesize timerLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    // Disable Stop/Play button when application launches
//    [stopBtn setEnabled:NO];
//    [playBtn setEnabled:NO];
//    
    // Set the audio file
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)uploadToParseClicked:(id)sender {
    PFObject *testObject = [PFObject objectWithClassName:@"AudioFiles"];
    
    //get the audio in NSData format
    NSData *audioData = [NSData dataWithContentsOfURL:tempSoundStorage];
    NSLog(@"audioData = %@", audioData);
    
    //create audiofile as a property
    PFFile *audioFile = [PFFile fileWithName:@"audio.caf" data:audioData];
    testObject[@"audioFile"] = audioFile;
    
    //save
    [testObject saveInBackground];
}

- (IBAction)playBtnClicked:(id)sender {
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:tempSoundStorage error:nil];
        [player setDelegate:self];
        [player play];
    if ([recordPauseBtn.titleLabel  isEqual: @"Pause"]) {
        [recordPauseBtn setTitle:@"Record" forState:UIControlStateNormal];

    }
    
}

-(void)aTime
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    id obj = [standardUserDefaults objectForKey:@"TimerValue"];
    int i = 0;
    
    if(obj != nil)
    {
        i = [obj intValue];
    }
    
    timerLabel.text = [NSString stringWithFormat:@"%d",i];
    i++;
    
    [standardUserDefaults setObject:[NSNumber numberWithInt:i] forKey:@"TimerValue"];
    [standardUserDefaults synchronize];
}

- (IBAction)recordTouchDown:(id)sender {

    [recorder recordForDuration:30];
     NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(aTime) userInfo:nil repeats:YES];

    NSLog(@"started started");

}


- (IBAction)recordTouchUp:(id)sender {
    [recorder stop];
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *soundFilePath = [docsDir
                               stringByAppendingPathComponent:@"tmpSound.caf"];
    
    tempSoundStorage = [NSURL fileURLWithPath:soundFilePath];
    
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
    
    recorder = [[AVAudioRecorder alloc] initWithURL:tempSoundStorage settings:recSettings error:nil];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    
    NSLog(@"%@",tempSoundStorage);

    
    NSLog(@"stopped stopped");
    playView.hidden=false;

}
- (IBAction)closeClicked:(id)sender {
    playView.hidden=true;
    
}



- (IBAction)logOutClicked:(id)sender {
    [PFUser logOut];
    [self performSegueWithIdentifier:@"logOutClicked" sender:self];


}
- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [recordPauseBtn setTitle:@"Record" forState:UIControlStateNormal];
    
}
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
                                                    message: @"Finish playing the recording!"
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}



@end
