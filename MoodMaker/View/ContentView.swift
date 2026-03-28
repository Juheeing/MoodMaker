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
    @State private var rotationDegrees: Double = 0
    @State private var rotationTimer: Timer? = nil
    
    var body: some View {
        ZStack {
            // 배경 그라디언트
            backgroundGradient
            
            VStack(spacing: 28) {
                // 타이틀
                titleView
                
                // 앨범 커버 (사진)
                albumCoverView
                
                // 분위기 결과
                moodResultView
                
                // 파형 애니메이션
                waveformSection
                
                // 컨트롤 버튼
                controlButtons
            }
            .padding(.horizontal, 24)
        }
        .ignoresSafeArea()
        .sheet(isPresented: $showPicker) {
            ImagePicker(image: $selectedImage, onSelect: { image in
                viewModel.analyze(image: image)
            })
        }
    }
    
    // MARK: - 배경 그라디언트
    private var backgroundGradient: some View {
        LinearGradient(
            colors: viewModel.moodResult != nil
                ? viewModel.moodResult!.profile.gradientColors
                : [Color(hex: "1a202c"), Color(hex: "0d1117")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .animation(.easeInOut(duration: 1.0), value: viewModel.moodResult?.mood)
    }
    
    // MARK: - 타이틀
    private var titleView: some View {
        VStack(spacing: 4) {
            Text("🎵 MoodMaker")
                .font(.title2).bold()
                .foregroundColor(.white)
            Text("사진으로 만드는 나만의 음악")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.top, 60)
    }
    
    // MARK: - 앨범 커버
    private var albumCoverView: some View {
        ZStack {
            // 그림자 효과
            Circle()
                .fill(.black.opacity(0.3))
                .frame(width: 260, height: 260)
                .blur(radius: 20)
            
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 250, height: 250)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.2), lineWidth: 2)
                    )
                    .rotationEffect(.degrees(rotationDegrees))
            } else {
                Circle()
                    .fill(.white.opacity(0.1))
                    .frame(width: 250, height: 250)
                    .overlay(
                        VStack(spacing: 12) {
                            Image(systemName: "photo.circle")
                                .font(.system(size: 50))
                                .foregroundColor(.white.opacity(0.5))
                            Text("사진을 선택하세요")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.5))
                        }
                    )
            }
        }
        .onChange(of: viewModel.isPlaying) { _, playing in
            if playing {
                rotationTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
                    rotationDegrees += 0.5
                }
            } else {
                rotationTimer?.invalidate()
                rotationTimer = nil
            }
        }
    }
    
    // MARK: - 분위기 결과
    private var moodResultView: some View {
        Group {
            if viewModel.isAnalyzing {
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(.white)
                    Text("분위기 분석 중...")
                        .foregroundColor(.white.opacity(0.8))
                }
            } else if let result = viewModel.moodResult {
                VStack(spacing: 8) {
                    Text(result.profile.emoji)
                        .font(.system(size: 44))
                    Text(result.profile.description)
                        .font(.title3).bold()
                        .foregroundColor(.white)
                    
                    // 확신도 바
                    VStack(spacing: 4) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.white.opacity(0.2))
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.white.opacity(0.8))
                                    .frame(width: geo.size.width * CGFloat(result.confidence))
                            }
                        }
                        .frame(height: 6)
                        .padding(.horizontal, 40)
                        
                        Text("\(Int(result.confidence * 100))% 확신")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            } else {
                Text("사진을 선택하면\n분위기를 분석해드려요")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.5))
                    .font(.subheadline)
            }
        }
        .frame(height: 110)
    }
    
    // MARK: - 파형 애니메이션
    private var waveformSection: some View {
        Group {
            if viewModel.moodResult != nil {
                WaveformView(
                    isPlaying: viewModel.isPlaying,
                    accentColor: viewModel.moodResult?.profile.accentColor ?? .white
                )
            }
        }
        .frame(height: 60)
    }
    
    // MARK: - 컨트롤 버튼
    private var controlButtons: some View {
        HStack(spacing: 24) {
            // 사진 선택 버튼
            Button {
                showPicker = true
            } label: {
                Image(systemName: "photo.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.white.opacity(0.8))
            }
            .disabled(viewModel.isAnalyzing)
            
            // 재생/정지 버튼
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
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.15))
                            .frame(width: 72, height: 72)
                        Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                }
                
                // 공유 버튼
                Button {
                    shareResult()
                } label: {
                    Image(systemName: "square.and.arrow.up.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding(.bottom, 40)
    }
    
    // MARK: - 공유 기능
    private func shareResult() {
        guard let result = viewModel.moodResult,
              let image = selectedImage else { return }
        
        let text = "\(result.profile.emoji) 내 사진의 분위기는 '\(result.profile.description)'!\nMoodMaker로 만든 나만의 음악 🎵"
        let activityVC = UIActivityViewController(
            activityItems: [text, image],
            applicationActivities: nil
        )
        
        // iPad 대응
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            activityVC.popoverPresentationController?.sourceView = window
            rootVC.present(activityVC, animated: true)
        }
    }
}
