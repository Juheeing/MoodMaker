//
//  MusicGeneratorService.swift
//  MoodMaker
//
//  Created by 김주희 on 3/26/26.
//

import AVFoundation

class MusicGeneratorService {
    
    private var audioPlayer: AVAudioPlayer?
    private(set) var isPlaying = false
    
    // 분위기별 파일 개수
    private let fileCount = 5
    
    init() {
        setupAudioSession()
    }
    
    // MARK: - 오디오 세션 설정
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ 오디오 세션 오류: \(error)")
        }
    }
    
    // MARK: - 재생
    func play(profile: MusicProfile) {
        stop()
        
        // 1~5 중 랜덤 선택
        let randomIndex = Int.random(in: 1...fileCount)
        let fileName = "\(profile.mood)_\(randomIndex)"
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") ??
                        Bundle.main.url(forResource: fileName, withExtension: "wav") else {
            print("❌ 파일 없음: \(fileName)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = profile.volume
            audioPlayer?.numberOfLoops = -1  // 무한 루프
            audioPlayer?.play()
            isPlaying = true
            print("🎵 재생: \(fileName) (랜덤 선택)")
        } catch {
            print("❌ 재생 오류: \(error)")
        }
    }
    
    // MARK: - 정지
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }
    
    // MARK: - 볼륨 조절
    func setVolume(_ volume: Float) {
        audioPlayer?.volume = volume
    }
}
