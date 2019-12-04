//
//  AlermSoundSetting.swift
//  palerm-02
//
//  Created by shuuhei-hanashiro on 2019/11/20.
//  Copyright © 2019 shuuhei-hanashiro. All rights reserved.
//

import UIKit
import AVFoundation

class AlermSoundSettingViewController: UIViewController {
    
    var audioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("--- alerm sound setting view controller")
        self.view.backgroundColor = PalermColor.Dark500.UIColor
        playSound(name: "alarm")
    }
}

extension AlermSoundSettingViewController: AVAudioPlayerDelegate {
    func playSound(name: String) {
        guard let path = Bundle.main.path(forResource: name, ofType: "mp3") else {
            print("Not found mp3.")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            
            audioPlayer.delegate = self
            
            audioPlayer.play()
        } catch {
        }
    }
}
