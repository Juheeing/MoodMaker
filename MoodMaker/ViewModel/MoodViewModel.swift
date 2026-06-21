//
//  MoodViewModel.swift
//  MoodMaker
//
//  Created by 김주희 on 3/26/26.
//

import SwiftUI
import Combine

class MoodViewModel: ObservableObject {
    
    @Published var moodResult: MoodClassifierService.MoodResult? = nil
    @Published var isAnalyzing: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isPlaying: Bool = false
    @Published var isLoadingMusic: Bool = false
    
    private let classifier = MoodClassifierService()
    private let musicGenerator = MusicGeneratorService()
    
    func analyze(image: UIImage) {
        isAnalyzing = true
        errorMessage = nil
        moodResult = nil
        stopMusic()
        
        classifier.classify(image: image) { [weak self] result in
            DispatchQueue.main.async {
                self?.isAnalyzing = false
                if let result = result {
                    self?.moodResult = result
                    self?.playNewMusic(profile: result.profile)  // 이름 변경: 새 곡 검색
                } else {
                    self?.errorMessage = "분석에 실패했어요. 다시 시도해주세요."
                }
            }
        }
    }
    
    // 새 곡을 검색해서 재생 (분위기 바뀔 때만)
    func playNewMusic(profile: MusicProfile) {
        isLoadingMusic = true
        
        musicGenerator.play(profile: profile) { [weak self] success in
            DispatchQueue.main.async {
                self?.isLoadingMusic = false
                if success {
                    self?.isPlaying = true
                } else {
                    self?.errorMessage = "음악을 찾지 못했어요. 다시 시도해주세요."
                }
            }
        }
    }
    
    // 재생/일시정지 토글 (같은 곡 유지)
    func togglePlayPause() {
        if isPlaying {
            musicGenerator.pause()
            isPlaying = false
        } else {
            musicGenerator.resume()
            isPlaying = true
        }
    }
    
    func stopMusic() {
        musicGenerator.stop()
        isPlaying = false
    }
}
