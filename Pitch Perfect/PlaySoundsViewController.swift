//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Curtis Bridges on 11/21/15.
//  Copyright © 2015 Curtis Bridges. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
	@IBOutlet weak var stopButton: UIButton!

    var audioPlayer : AVAudioPlayer!
    var audioEngine : AVAudioEngine!
    var audioFile: AVAudioFile!
    var receivedAudio : RecordedAudio!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        audioPlayer = try! AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl)
        audioPlayer.enableRate = true
        audioPlayer.prepareToPlay()

        audioEngine = AVAudioEngine()
        audioFile = try! AVAudioFile(forReading: receivedAudio.filePathUrl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        // Dispose of any resources that can be recreated.
    }

	// MARK: ACTIONS
    @IBAction func playSoundSlow(sender: UIButton) {
        playAudio(0.5)
    }

    @IBAction func playSoundFast(sender: UIButton) {
        playAudio(1.5)
    }

	@IBAction func playChipmunkAudio(sender: UIButton) {
		playAudioWithVariablePitch(1000)
	}

	@IBAction func playDarthVaderAudio(sender: UIButton) {
		playAudioWithVariablePitch(-1000)
	}

	@IBAction func playEchoAudio(sender: UIButton) {
		resetAudio()

		let audioPlayerNode = AVAudioPlayerNode()
		audioEngine.attachNode(audioPlayerNode)

		let delay = AVAudioUnitDelay()
		delay.delayTime = 0.5
		audioEngine.attachNode(delay)

		audioEngine.connect(audioPlayerNode, to: delay, format: nil)
		audioEngine.connect(delay, to: audioEngine.outputNode, format: nil)
		try! audioEngine.start()

		audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: { () -> Void in
			// hide the stop button when the audio completes playing (no reason to stop anymore...)
			self.stopButton.hidden = true
		})
		audioPlayerNode.play()
	}

	@IBAction func playReverbAudio(sender: UIButton) {
		resetAudio()

		let audioPlayerNode = AVAudioPlayerNode()
		audioEngine.attachNode(audioPlayerNode)

		let reverbEffect = AVAudioUnitReverb()
		reverbEffect.loadFactoryPreset(AVAudioUnitReverbPreset.Cathedral)
		reverbEffect.wetDryMix = 50
		audioEngine.attachNode(reverbEffect)

		audioEngine.connect(audioPlayerNode, to: reverbEffect, format: nil)
		audioEngine.connect(reverbEffect, to: audioEngine.outputNode, format: nil)
		try! audioEngine.start()

		audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: { () -> Void in
			// hide the stop button when the audio completes playing (no reason to stop anymore...)
			self.stopButton.hidden = true
		})
		audioPlayerNode.play()
	}

    @IBAction func stopPlaying(sender: UIButton) {
		stopButton.hidden = true

        audioPlayer.stop()
    }

	// MARK: custom functions
	func resetAudio() {
		stopButton.hidden = false

		audioEngine.stop()
		audioEngine.reset()

		audioPlayer.stop()
		audioPlayer.currentTime = 0.0
	}

    func playAudio(let speed :Float) {
		resetAudio()

		audioPlayer.rate = speed
        audioPlayer.play()
    }

    func playAudioWithVariablePitch(pitch: Float) {
		resetAudio()

        let audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)

        let changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        audioEngine.attachNode(changePitchEffect)

        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        try! audioEngine.start()

		audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: { () -> Void in
			// hide the stop button when the audio completes playing (no reason to stop anymore...)
			self.stopButton.hidden = true
		})
        audioPlayerNode.play()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
