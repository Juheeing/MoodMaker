//
//  MusicGeneratorService.swift
//  MoodMaker
//
//  Created by 김주희 on 3/26/26.
//

import AVFoundation

class MusicGeneratorService {
    
    private var player: AVPlayer?
    private(set) var isPlaying = false
    
    // MARK: - 재생 (분위기 받아서 검색 → 재생)
    func play(profile: MusicProfile, completion: @escaping (Bool) -> Void) {
        stop()
        
        guard let keywords = moodSearchKeywords[profile.mood],
              let keyword = keywords.randomElement() else {
            print("❌ 검색 키워드 없음: \(profile.mood)")
            completion(false)
            return
        }
        
        searchAndPlay(keyword: keyword, volume: profile.volume, completion: completion)
    }
    
    // MARK: - iTunes 검색
    private func searchAndPlay(keyword: String, volume: Float, completion: @escaping (Bool) -> Void) {
        
        guard let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://itunes.apple.com/search?term=\(encodedKeyword)&media=music&limit=15") else {
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ 네트워크 오류: \(error)")
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            do {
                let result = try JSONDecoder().decode(iTunesSearchResult.self, from: data)
                
                // previewUrl이 있는 트랙만 필터링
                let validTracks = result.results.filter { $0.previewUrl != nil }
                
                guard let track = validTracks.randomElement(),
                      let previewURLString = track.previewUrl,
                      let previewURL = URL(string: previewURLString) else {
                    print("❌ 재생 가능한 트랙 없음: \(keyword)")
                    DispatchQueue.main.async { completion(false) }
                    return
                }
                
                print("🎵 선택된 곡: \(track.trackName) - \(track.artistName)")
                
                DispatchQueue.main.async {
                    self.playStream(url: previewURL, volume: volume)
                    completion(true)
                }
                
            } catch {
                print("❌ JSON 파싱 오류: \(error)")
                DispatchQueue.main.async { completion(false) }
            }
            
        }.resume()
    }
    
    // MARK: - 스트리밍 재생
    private func playStream(url: URL, volume: Float) {
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        player?.volume = volume
        player?.play()
        isPlaying = true
        
        // 재생 끝나면 자동으로 상태 변경
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            self?.isPlaying = false
        }
    }
    
    // MARK: - 정지
    func stop() {
        player?.pause()
        player = nil
        isPlaying = false
    }
    
    // MARK: - 볼륨 조절
    func setVolume(_ volume: Float) {
        player?.volume = volume
    }
}

// MARK: - iTunes API 응답 모델
struct iTunesSearchResult: Codable {
    let results: [iTunesTrack]
}

struct iTunesTrack: Codable {
    let trackName: String
    let artistName: String
    let previewUrl: String?
}
