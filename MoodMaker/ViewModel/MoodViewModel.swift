//
//  MoodViewModel.swift
//  MoodMaker
//
//  Created by 김주희 on 3/26/26.
//

import SwiftUI
import Combine

class MoodViewModel: ObservableObject {
    
    // View가 관찰하는 상태값들
    @Published var moodResult: MoodClassifierService.MoodResult? = nil
    @Published var isAnalyzing: Bool = false
    @Published var errorMessage: String? = nil
    
    private let classifier = MoodClassifierService()
    
    // 분위기 분석 실행
    func analyze(image: UIImage) {
        isAnalyzing = true
        errorMessage = nil
        moodResult = nil
        
        classifier.classify(image: image) { [weak self] result in
            DispatchQueue.main.async {
                self?.isAnalyzing = false
                if let result = result {
                    self?.moodResult = result
                } else {
                    self?.errorMessage = "분석에 실패했어요. 다시 시도해주세요."
                }
            }
        }
    }
}
