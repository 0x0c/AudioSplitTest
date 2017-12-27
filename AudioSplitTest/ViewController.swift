//
//  ViewController.swift
//  AudioSplitTest
//
//  Created by Akira Matsuda on 2017/12/27.
//  Copyright © 2017 Akira Matsuda. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
//		AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:openPanel.URL options:nil];
//		NSLog(@"Tracks: %@", asset.tracks);
		var urlString = Bundle.main.path(forResource: "IMG_1785", ofType: "MOV")
		var url = URL(fileURLWithPath: urlString!)
		let asset1 = AVURLAsset.init(url: url)
		print(asset1.tracks)
		
		urlString = Bundle.main.path(forResource: "IMG_1786", ofType: "MOV")
		url = URL(fileURLWithPath: urlString!)
		let asset2 = AVURLAsset.init(url: url)
		
		let composition = AVMutableComposition()
		let audioTrack = asset1.tracks(withMediaType: .audio)[0]
		let videoTrack = asset2.tracks(withMediaType: .video)[0]
		
		do {
			let range = CMTimeRangeMake(kCMTimeZero, asset1.duration)
			let videoTrackComposition = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
			try videoTrackComposition?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration), of: videoTrack, at: kCMTimeZero)
			
			let instruction = AVMutableVideoCompositionInstruction()
			instruction.timeRange = range
			let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrackComposition!)
			
			let audioTrackComposition = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
			try audioTrackComposition?.insertTimeRange(range, of: audioTrack, at: kCMTimeZero)
			
			instruction.layerInstructions = [layerInstruction]
			let videoComposition = AVMutableVideoComposition()
			videoComposition.instructions = [instruction]
			videoComposition.renderSize = videoTrack.naturalSize
			videoComposition.frameDuration = CMTimeMake(1, 30)
			
			let outputPath = NSHomeDirectory() + "/Documents" + "/out.mp4"
			let session = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
			session?.outputURL = URL(fileURLWithPath: outputPath)
			session?.outputFileType = AVFileType.m4v
			session?.videoComposition = videoComposition
			session?.exportAsynchronously(completionHandler: {
				print("done")
				print(outputPath)
			})
			
			let composition2 = AVMutableComposition()
			composition2.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
			let audioTrackComposition2 = composition2.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
			try audioTrackComposition2?.insertTimeRange(range, of: audioTrack, at: kCMTimeZero)
			
			let outputPath2 = NSHomeDirectory() + "/Documents" + "/out.m4a"
			let session2 = AVAssetExportSession(asset: composition2, presetName: AVAssetExportPresetAppleM4A)
			session2?.outputURL = URL(fileURLWithPath: outputPath2)
			session2?.metadata = audioTrack.asset!.metadata
			session2?.outputFileType = AVFileType.m4a
			session2?.exportAsynchronously(completionHandler: {
				print("audio done")
				print(outputPath2)
			})
		}
		catch {
			print("exception")
		}

		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

