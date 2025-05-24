//
//  StoryAvatarView.swift
//  Stories
//
//  Created by Dmitrij Meidus on 24.05.25.
//

import SwiftUI

struct StoryAvatarView: View {
    let user: User
    let storyStateManager: StoryStateProtocol
    
    private var storyCount: Int {
        (user.id % 3) + 3
    }
    
    private var hasUnseenStories: Bool {
        storyStateManager.hasUnseenStories(userId: user.id, storyCount: storyCount)
    }
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .strokeBorder(
                        hasUnseenStories ? LinearGradient(
                            colors: [.purple, .red, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) : LinearGradient(
                            colors: [.gray],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 70, height: 70)
                
                AsyncImage(url: URL(string: user.profilePictureURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 62, height: 62)
                .clipShape(Circle())
            }
            
            Text(user.name)
                .font(.caption)
                .lineLimit(1)
        }
    }
}
