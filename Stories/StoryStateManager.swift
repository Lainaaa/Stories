import Foundation
import Observation

protocol StoryStateProtocol {
    func markAsSeen(userId: Int, storyIndex: Int)
    func isStorySeen(userId: Int, storyIndex: Int) -> Bool
    func toggleLike(userId: Int, storyIndex: Int)
    func isStoryLiked(userId: Int, storyIndex: Int) -> Bool
    func hasUnseenStories(userId: Int, storyCount: Int) -> Bool
}

@Observable
final class StoryStateManager: StoryStateProtocol {
    private let userDefaults = UserDefaults.standard
    
    private let seenStoriesKey = "com.stories.seenStories"
    private let likedStoriesKey = "com.stories.likedStories"
    
    private var seenStories: Set<String> = []
    private var likedStories: Set<String> = []
    
    init() {
        loadState()
    }
    
    private func loadState() {
        if let seenData = userDefaults.data(forKey: seenStoriesKey),
           let seenSet = try? JSONDecoder().decode(Set<String>.self, from: seenData) {
            seenStories = seenSet
        }
        
        if let likedData = userDefaults.data(forKey: likedStoriesKey),
           let likedSet = try? JSONDecoder().decode(Set<String>.self, from: likedData) {
            likedStories = likedSet
        }
    }
    
    private func saveState() {
        if let seenData = try? JSONEncoder().encode(seenStories) {
            userDefaults.set(seenData, forKey: seenStoriesKey)
        }
        
        if let likedData = try? JSONEncoder().encode(likedStories) {
            userDefaults.set(likedData, forKey: likedStoriesKey)
        }
    }
    
    func markAsSeen(userId: Int, storyIndex: Int) {
        let key = "\(userId)-\(storyIndex)"
        seenStories.insert(key)
        saveState()
    }
    
    func isStorySeen(userId: Int, storyIndex: Int) -> Bool {
        let key = "\(userId)-\(storyIndex)"
        return seenStories.contains(key)
    }
    
    func toggleLike(userId: Int, storyIndex: Int) {
        let key = "\(userId)-\(storyIndex)"
        if likedStories.contains(key) {
            likedStories.remove(key)
        } else {
            likedStories.insert(key)
        }
        saveState()
    }
    
    func isStoryLiked(userId: Int, storyIndex: Int) -> Bool {
        let key = "\(userId)-\(storyIndex)"
        return likedStories.contains(key)
    }
    
    func hasUnseenStories(userId: Int, storyCount: Int) -> Bool {
        for index in 0..<storyCount {
            if !isStorySeen(userId: userId, storyIndex: index) {
                return true
            }
        }
        return false
    }
}
