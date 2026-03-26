//
//  ContentView.swift
//  MoodMaker
//
//  Created by 김주희 on 3/26/26.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = MoodViewModel()
    @State private var selectedImage: UIImage? = nil
    @State private var showPicker: Bool = false
    
    var body: some View {
        VStack(spacing: 24) {
            
            // 이미지 미리보기
            imagePreview
            
            // 분석 결과
            resultView
            
            // 사진 선택 버튼
            selectButton
            
            musicControlButton
        }
        .padding()
        .sheet(isPresented: $showPicker) {
            ImagePicker(image: $selectedImage, onSelect: { image in
                viewModel.analyze(image: image)
            })
        }
    }
    
    // MARK: - 이미지 미리보기
    private var imagePreview: some View {
        Group {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 300, height: 300)
                    .overlay(
                        Text("사진을 선택하세요")
                            .foregroundColor(.gray)
                    )
            }
        }
    }
    
    // MARK: - 분석 결과
    private var resultView: some View {
        Group {
            if viewModel.isAnalyzing {
                ProgressView("분석 중...")
            } else if let result = viewModel.moodResult {
                VStack(spacing: 8) {
                    Text(result.profile.emoji)
                        .font(.system(size: 60))
                    Text(result.profile.description)
                        .font(.title2).bold()
                    Text("\(Int(result.confidence * 100))% 확신")
                        .foregroundColor(.secondary)
                }
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
        }
    }
    
    // MARK: - 사진 선택 버튼
    private var selectButton: some View {
        Button("사진 선택") {
            showPicker = true
        }
        .buttonStyle(.borderedProminent)
        .disabled(viewModel.isAnalyzing)
    }
    
    // MARK: - 재생/정지 버튼
    private var musicControlButton: some View {
        Group {
            if viewModel.moodResult != nil {
                Button {
                    if viewModel.isPlaying {
                        viewModel.stopMusic()
                    } else {
                        if let profile = viewModel.moodResult?.profile {
                            viewModel.playMusic(profile: profile)
                        }
                    }
                } label: {
                    Label(
                        viewModel.isPlaying ? "정지" : "재생",
                        systemImage: viewModel.isPlaying ? "stop.fill" : "play.fill"
                    )
                }
                .buttonStyle(.bordered)
            }
        }
    }
}
