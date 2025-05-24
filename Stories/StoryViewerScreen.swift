import SwiftUI

struct StoryViewerScreen: View {
    let user: User
    let storyStateManager: StoryStateProtocol
    let onDismiss: () -> Void
    let onNextUser: (User) -> Void
    let onPreviousUser: (User) -> Void
    
    @State private var currentStoryIndex = 0
    @State private var storyProgress: CGFloat = 0
    @State private var timer: Timer? = nil
    @State private var isPaused = false
    
    private let story: Story
    
    private let storyDuration: TimeInterval = 15.0
    
    init(user: User, storyStateManager: StoryStateProtocol, onDismiss: @escaping () -> Void, onNextUser: @escaping (User) -> Void, onPreviousUser: @escaping (User) -> Void) {
        self.user = user
        self.storyStateManager = storyStateManager
        self.onDismiss = onDismiss
        self.onNextUser = onNextUser
        self.onPreviousUser = onPreviousUser
        
        self.story = Story.storiesFor(userId: user.id)        
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ZStack(alignment: .top) {
                    Color.black
                        .ignoresSafeArea()
                    
                    HStack(spacing: 4) {
                        ForEach(0..<story.imageUrls.count, id: \.self) { index in
                            ProgressBar(
                                progress: index == currentStoryIndex ? storyProgress : (index < currentStoryIndex ? 1 : 0)
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    VStack {
                        HStack {
                            AsyncImage(url: URL(string: user.profilePictureURL)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Circle().fill(Color.gray.opacity(0.3))
                            }
                            .frame(width: 36, height: 36)
                            .clipShape(Circle())
                            
                            Text(user.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button {
                                onDismiss()
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color.black.opacity(0.6))
                                        .frame(width: 38, height: 38)
                                    
                                    Image(systemName: "xmark")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .zIndex(100)
                        }
                        .padding(.horizontal)
                        .padding(.top, 40)
                        
                        Spacer()
                        
                        ZStack {
                            if currentStoryIndex < story.imageUrls.count {
                                StoryImageContainer(
                                    imageUrl: story.imageUrls[currentStoryIndex],
                                    isLiked: storyStateManager.isStoryLiked(userId: user.id, storyIndex: currentStoryIndex)
                                )
                                .id(user.id) 
                                .overlay(
                                    HStack(spacing: 0) {
                                        Rectangle()
                                            .opacity(0.001)
                                            .frame(width: geometry.size.width / 3)
                                            .onTapGesture {
                                                goToPreviousStory()
                                            }
                                            .onLongPressGesture(minimumDuration: .infinity, pressing: { isPressing in
                                                isPaused = isPressing
                                            }, perform: {})
                                        
                                        Rectangle()
                                            .opacity(0.001)
                                            .frame(width: geometry.size.width / 3)
                                            .onTapGesture(count: 2) {
                                                if !storyStateManager.isStoryLiked(userId: user.id, storyIndex: currentStoryIndex) {
                                                    storyStateManager.toggleLike(userId: user.id, storyIndex: currentStoryIndex)
                                                }
                                            }
                                            .onLongPressGesture(minimumDuration: .infinity, pressing: { isPressing in
                                                isPaused = isPressing
                                            }, perform: {})
                                        
                                        Rectangle()
                                            .opacity(0.001)
                                            .frame(width: geometry.size.width / 3)
                                            .onTapGesture {
                                                goToNextStory()
                                            }
                                            .onLongPressGesture(minimumDuration: .infinity, pressing: { isPressing in
                                                isPaused = isPressing
                                            }, perform: {})
                                    }
                                )
                            }
                        }
                        
                        Spacer()
                        
                        HStack {
                            ZStack(alignment: .leading) {
                                Text("Send message")
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .frame(height: 40)
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            
                            Button {
                                storyStateManager.toggleLike(userId: user.id, storyIndex: currentStoryIndex)
                            } label: {
                                Image(systemName: storyStateManager.isStoryLiked(userId: user.id, storyIndex: currentStoryIndex) ? "heart.fill" : "heart")
                                    .font(.system(size: 24))
                                    .foregroundColor(storyStateManager.isStoryLiked(userId: user.id, storyIndex: currentStoryIndex) ? .red : .white)
                                    .frame(width: 44, height: 44)
                            }
                            
                            Button {
                            } label: {
                                Image(systemName: "paperplane")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                }
            }
            .statusBar(hidden: true)
            .onAppear {
                storyStateManager.markAsSeen(userId: user.id, storyIndex: currentStoryIndex)
                start()
            }
            .onDisappear { stop() }
            .onChange(of: user.id) { _ in
                reset()
                start()
            }
        }
    }
    
    private func start() {
        storyStateManager.markAsSeen(userId: user.id, storyIndex: currentStoryIndex)
        startTimer()
    }
    
    private func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    private func reset() {
        stop()
        currentStoryIndex = 0
        storyProgress = 0
        isPaused = false
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard !isPaused else { return }
            
            if storyProgress < 1.0 {
                storyProgress += 0.1 / storyDuration
            } else {
                storyProgress = 0
                goToNextStory()
            }
        }
    }
    
    private func goToNextStory() {
        if currentStoryIndex < story.imageUrls.count - 1 {
            currentStoryIndex += 1
            storyProgress = 0
            storyStateManager.markAsSeen(userId: user.id, storyIndex: currentStoryIndex)
        } else {
            onNextUser(user)
        }
    }
    
    private func goToPreviousStory() {
        if currentStoryIndex > 0 {
            currentStoryIndex -= 1
            storyProgress = 0
        } else {
            onPreviousUser(user)
        }
    }
}

struct ProgressBar: View {
    let progress: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color.white.opacity(0.3))
                    .frame(width: geometry.size.width, height: 2)
                
                Rectangle()
                    .foregroundColor(.white)
                    .frame(width: geometry.size.width * progress, height: 2)
            }
        }
        .frame(height: 2)
    }
}

struct StoryImageContainer: View {
    let imageUrl: String
    let isLiked: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(0.2))
                    .cornerRadius(12)
                
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
                .cornerRadius(8)
                .padding(4)
            }
            .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
        }
    }
}
