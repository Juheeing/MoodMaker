//
//  WaveformView.swift
//  MoodMaker
//
//  Created by 김주희 on 3/28/26.
//

import SwiftUI

struct WaveformView: View {
    
    let isPlaying: Bool
    let accentColor: Color
    
    // 막대 개수
    private let barCount = 30
    
    // 각 막대의 애니메이션 높이
    @State private var heights: [CGFloat] = Array(repeating: 4, count: 30)
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<barCount, id: \.self) { i in
                RoundedRectangle(cornerRadius: 3)
                    .fill(accentColor.opacity(0.8))
                    .frame(width: 4, height: heights[i])
                    .animation(
                        .easeInOut(duration: Double.random(in: 0.3...0.7))
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.05),
                        value: heights[i]
                    )
            }
        }
        .frame(height: 60)
        .onChange(of: isPlaying, { oldValue, newValue in
            updateHeights(playing: newValue)
        })
        .onAppear {
            updateHeights(playing: isPlaying)
        }
    }
    
    private func updateHeights(playing: Bool) {
        for i in 0..<barCount {
            heights[i] = playing ? CGFloat.random(in: 8...55) : 4
        }
    }
}
