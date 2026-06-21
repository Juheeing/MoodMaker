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
    @Published var isLoadingMusic: Bool = false  // 추가: 음악 검색 중 로딩
    
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
                    self?.playMusic(profile: result.profile)
                } else {
                    self?.errorMessage = "분석에 실패했어요. 다시 시도해주세요."
                }
            }
        }
    }
    
    // 수정: 음악 검색 + 재생
    func playMusic(profile: MusicProfile) {
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
    
    func stopMusic() {
        musicGenerator.stop()
        isPlaying = false
    }
}
