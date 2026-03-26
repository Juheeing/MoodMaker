//
//  MoodClassifierService.swift
//  MoodMaker
//
//  Created by 김주희 on 3/26/26.
//

import CoreML
import Vision
import UIKit

class MoodClassifierService {
    
    struct MoodResult {
        let mood: String
        let confidence: Float
        let profile: MusicProfile  // 매핑된 음악 파라미터
    }
    
    func classify(image: UIImage, completion: @escaping (MoodResult?) -> Void) {
        
        print("🔍 분류 시작")  // 추가
        
        guard let model = try? VNCoreMLModel(
            for: MoodClassifier(configuration: MLModelConfiguration()).model
        ) else {
            print("❌ 모델 로드 실패")  // 여기서 막히면 mlmodel 문제
            completion(nil)
            return
        }
        
        print("✅ 모델 로드 성공")
        
        let request = VNCoreMLRequest(model: model) { request, error in
            
            if let error = error {
                print("❌ Vision 오류: \(error)")
                completion(nil)
                return
            }
            
            guard let results = request.results as? [VNClassificationObservation],
                  let top = results.first else {
                print("❌ 결과 없음")
                completion(nil)
                return
            }
            
            guard let profile = moodProfileMap[top.identifier] else {
                print("❌ 프로필 매핑 실패: \(top.identifier)")
                completion(nil)
                return
            }
            
            print("🎯 감지: \(top.identifier) (\(Int(top.confidence * 100))%)")
            completion(MoodResult(mood: top.identifier, confidence: top.confidence, profile: profile))
        }
        
        request.imageCropAndScaleOption = .centerCrop
        
        guard let ciImage = CIImage(image: image) else {
            print("❌ CIImage 변환 실패")
            completion(nil)
            return
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("❌ handler 오류: \(error)")
            }
        }
    }
}
