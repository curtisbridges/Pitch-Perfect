//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Curtis Bridges on 11/21/15.
//  Copyright © 2015 Curtis Bridges. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!

    var audioRecorder:AVAudioRecorder!
    var recordedAudio: RecordedAudio!

	var isRecordingAudio = false
	var isPausedAudio = false

	var pauseImage: UIImage!
	var recordImage: UIImage!
	var resumeImage: UIImage!

	// MARK: VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

		// Do any additional setup after loading the view, typically from a nib.
		pauseImage = UIImage(named: "Pause")
		recordImage = UIImage(named: "Microphone")
		resumeImage = UIImage(named: "Resume")
    }

    override func viewWillAppear(animated: Bool) {
        recordButton.enabled = true
        stopButton.hidden = true

		isRecordingAudio = false
		isPausedAudio = false

		recordButton.setImage(recordImage, forState: .Normal)
		recordingLabel.text = "Tap to Record"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	// MARK: ACTIONS
    @IBAction func recordAudio(sender: UIButton) {
		// whether starting or pausing, show the stop button
        stopButton.hidden = false

		if(!isRecordingAudio) {
			startRecording()
		} else {
			if(isPausedAudio) {
				resumeRecording()
			} else {
				pauseRecording()
			}
		}
    }

	@IBAction func stopRecording(sender: UIButton) {
		recordButton.enabled = true
		stopButton.hidden = true

		audioRecorder.stop()
		let audioSession = AVAudioSession.sharedInstance()
		try! audioSession.setActive(false)
	}

	// MARK: Custom Methods
	func startRecording() {
		isRecordingAudio = true
		recordButton.setImage(pauseImage, forState: .Normal)
		recordingLabel.text = "Recording in progress"

		let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String

		let recordingName = "my_audio.wav"
		let pathArray = [dirPath, recordingName]
		let filePath = NSURL.fileURLWithPathComponents(pathArray)
		print(filePath)

		let session = AVAudioSession.sharedInstance()
		// make sure the session will play back with the speaker rather than the (default) "ear" speaker
		try! session.setCategory(AVAudioSessionCategoryPlayAndRecord,
			withOptions:AVAudioSessionCategoryOptions.DefaultToSpeaker)

		try! audioRecorder = AVAudioRecorder(URL: filePath!, settings: [:])
		audioRecorder.delegate = self
		audioRecorder.meteringEnabled = true
		audioRecorder.prepareToRecord()
		audioRecorder.record()
	}

	func pauseRecording() {
		isPausedAudio = true
		recordButton.setImage(resumeImage, forState: .Normal)
		recordingLabel.text = "Recording paused"

		audioRecorder.pause()
	}

	func resumeRecording() {
		isPausedAudio = false
		recordButton.setImage(pauseImage, forState: .Normal)
		recordingLabel.text = "Recording in progress"

		audioRecorder.record()
	}

	// MARK: AVAudioRecorderDelegate
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if(flag) {
            recordedAudio = RecordedAudio(name: recorder.url.lastPathComponent!, path: recorder.url)
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        } else {
            print("failed to record audio")
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stopRecording") {
            let playSoundsVC: PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController
            let data = sender as! RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
}

