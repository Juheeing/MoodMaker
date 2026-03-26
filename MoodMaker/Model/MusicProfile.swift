//
//  MusicProfile.swift
//  MoodMaker
//
//  Created by 김주희 on 3/26/26.
//

import Foundation

// 음계 종류
enum Scale {
    case major  // 장조 (밝은 느낌)
    case minor  // 단조 (어두운 느낌)
}

// 악기 종류
enum Instrument: String {
    case piano   = "piano"
    case strings = "strings"
    case synth   = "synth"
    case guitar  = "guitar"
}

// 음악 파라미터 모델
struct MusicProfile {
    let mood: String
    let tempo: Double      // BPM
    let scale: Scale       // 장조/단조
    let instrument: Instrument
    let reverb: Float      // 공간감 0.0 ~ 1.0
    let volume: Float      // 볼륨 0.0 ~ 1.0
    
    // 분위기 설명 (UI 표시용)
    var description: String {
        switch mood {
        case "calm":      return "잔잔하고 평화로운"
        case "sad":       return "감성적이고 서정적인"
        case "energetic": return "활기차고 역동적인"
        case "romantic":  return "따뜻하고 낭만적인"
        default:          return ""
        }
    }
    
    // 분위기 이모지 (UI 표시용)
    var emoji: String {
        switch mood {
        case "calm":      return "🌊"
        case "sad":       return "🌧️"
        case "energetic": return "⚡️"
        case "romantic":  return "🌅"
        default:          return "🎵"
        }
    }
}

// 분위기 → 음악 파라미터 매핑 테이블
let moodProfileMap: [String: MusicProfile] = [
    "calm": MusicProfile(
        mood:       "calm",
        tempo:      60,
        scale:      .major,
        instrument: .piano,
        reverb:     0.8,
        volume:     0.7
    ),
    "sad": MusicProfile(
        mood:       "sad",
        tempo:      55,
        scale:      .minor,
        instrument: .strings,
        reverb:     0.6,
        volume:     0.6
    ),
    "energetic": MusicProfile(
        mood:       "energetic",
        tempo:      128,
        scale:      .major,
        instrument: .synth,
        reverb:     0.2,
        volume:     0.9
    ),
    "romantic": MusicProfile(
        mood:       "romantic",
        tempo:      75,
        scale:      .major,
        instrument: .guitar,
        reverb:     0.5,
        volume:     0.75
    )
]
