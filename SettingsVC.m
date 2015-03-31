//
//  SettingsVC.m
//  Shnoozle
//
//  Created by Leo on 28/03/2015.
//  Copyright (c) 2015 Leo. All rights reserved.
//

#import "SettingsVC.h"
#import <RESideMenu/RESideMenu.h>
#import <AVFoundation/AVFoundation.h>
@interface SettingsVC (){
    bool playing;
}
@property (nonatomic) MPMediaItem *mediaItem;
@property (weak, nonatomic) IBOutlet UILabel *songTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *songArtistLabel;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (nonatomic) AVAudioPlayer *player;
@property (weak, nonatomic) IBOutlet UIButton *playPauseBtn;

@end

@implementation SettingsVC



- (void)viewDidLoad {
    [super viewDidLoad];
    [self labelStates];

    float volume = [[NSUserDefaults standardUserDefaults]
                           floatForKey:@"AlarmVolume"];
    _slider.value=volume*100;
     playing = NO;
}
- (IBAction)sliderValueChanged:(id)sender {
    float volume= _slider.value / 100.0;
    
    [[NSUserDefaults standardUserDefaults] setFloat:volume forKey:@"AlarmVolume"];

}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker
  didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    MPMediaItem *mpMediaItem;
    
    self.mediaItem = nil;
    if (mediaItemCollection.items.count <= 0) {
    }
    
    mpMediaItem = mediaItemCollection.items[0];
    if ([[mpMediaItem valueForProperty:MPMediaItemPropertyIsCloudItem] boolValue]) {
        self.songTitleLabel.text = @"(sorry, not on the device)";
    }
    
    self.mediaItem = mpMediaItem;
    NSString *songTitle=[mpMediaItem valueForProperty:MPMediaItemPropertyTitle];
    NSString *songArtist=[mpMediaItem valueForProperty:MPMediaItemPropertyArtist];

    [self labelStates];
    

    NSString *songPath =[NSString stringWithFormat:@"%@", [mpMediaItem valueForProperty:MPMediaItemPropertyAssetURL]];
    

    
    [[NSUserDefaults standardUserDefaults] setObject:songPath forKey:@"AlarmSound"];
    [[NSUserDefaults standardUserDefaults] setObject:songTitle forKey:@"AlarmSoundTitle"];
    [[NSUserDefaults standardUserDefaults] setObject:songArtist forKey:@"AlarmSoundArtist"];



    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)chooseSong
{
    MPMediaPickerController *picker =
    [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    picker.delegate = self;
    picker.allowsPickingMultipleItems = NO;
    picker.showsCloudItems = NO;
    picker.prompt = @"music picker";
    
    [self presentViewController:picker animated:YES completion: nil];
}
- (void)labelStates {
    [_playPauseBtn setBackgroundImage:[UIImage imageNamed:@"playBtn@2x.png"] forState:UIControlStateNormal];

    NSString *songTitle = [[NSUserDefaults standardUserDefaults]
                           stringForKey:@"AlarmSoundTitle"];
    NSString *songArtist = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"AlarmSoundArtist"];
    
    if (songTitle.length < 1) {
        self.songTitleLabel.text = @"Default Tone";
        
    }
    else {
        self.songTitleLabel.text = songTitle;
        
    }
    if (songArtist.length < 1) {
        self.songArtistLabel.text =@"No Artist Info";
        
    }
    else {
        self.songArtistLabel.text = songArtist;
        
    }

}

-(void)PlayPause{
    if (playing==NO) {
        [_playPauseBtn setBackgroundImage:[UIImage imageNamed:@"pause@2x.png"] forState:UIControlStateNormal];
        [self runPlayer];
        playing=YES;
    }
    else if(playing==YES){
        [_playPauseBtn setBackgroundImage:[UIImage imageNamed:@"playBtn@2x.png"] forState:UIControlStateNormal];
        [self.player pause];

        playing=NO;
    }
    
    
}

- (void)runPlayer
{
    NSString *songString = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"AlarmSound"];
    NSURL *url=[NSURL URLWithString:songString];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    float volume = [[NSUserDefaults standardUserDefaults]
                    floatForKey:@"AlarmVolume"];
    self.player.volume=volume;
    [self.player play];
}
- (IBAction)playPauseTapped:(id)sender {
    [self PlayPause];
    
}

- (IBAction)menuTapped:(id)sender {
    [self.sideMenuViewController presentLeftMenuViewController];
    
    

}

- (IBAction)pickerTapped:(id)sender {
    [self chooseSong];
}




@end
