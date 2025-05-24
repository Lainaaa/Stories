import SwiftUI

struct ContentView: View {
    @State private var storyStateManager: StoryStateProtocol = StoryStateManager()
    @State private var users: [User] = []
    @State private var currentPage = 0
    @State private var isLoading = false
    @State private var hasMorePages = true
    @State private var selectedUser: User? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Stories")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 15) {
                        ForEach(users) { user in
                            StoryAvatarView(user: user, storyStateManager: storyStateManager)
                                .onTapGesture {
                                    selectedUser = user
                                }
                        }
                        
                        if hasMorePages {
                            ProgressView()
                                .onAppear {
                                    loadMoreUsers()
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 100)
                
                Spacer()
                
                Button(action: {
                    clearUserDefaults()
                }) {
                    Text("Clear All Stories Data")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.bottom, 20)
            }
            .onAppear {
                if users.isEmpty {
                    loadMoreUsers()
                }
            }
            .refreshable {
                currentPage = 0
                users = []
                hasMorePages = true
                loadMoreUsers()
            }
            .fullScreenCover(item: $selectedUser) { user in
                StoryViewerScreen(
                    user: user,
                    storyStateManager: storyStateManager,
                    onDismiss: { 
                        selectedUser = nil 
                    },
                    onNextUser: { current in
                        selectedUser = getNextUser(after: current)
                    },
                    onPreviousUser: { current in
                        selectedUser = getPreviousUser(before: current)
                    }
                )
                .id(user.id) 
            }
        }
    }
    
    private func loadMoreUsers() {
        guard !isLoading && hasMorePages else { return }
        
        isLoading = true
        
        let newUsers = loadUsersFromJSON(page: currentPage)
        
        if newUsers.isEmpty {
            currentPage = 0
            users.append(contentsOf: loadUsersFromJSON(page: currentPage))
        } else {
            users.append(contentsOf: newUsers)
            currentPage += 1
        }
        
        isLoading = false
    }
    
    private func loadUsersFromJSON(page: Int) -> [User] {
        do {
            let response = try JSONDecoder().decode(UsersResponse.self, from: jsonData)
            if page < response.pages.count {
                return response.pages[page].users
            }
            return []
        } catch {
            print("Error parsing JSON: \(error)")
            return []
        }
    }
    
    private func getNextUser(after currentUser: User) -> User? {
        guard let currentIndex = users.firstIndex(where: { $0.id == currentUser.id }) else {
            return nil
        }
        let nextIndex = users.index(after: currentIndex)
        return nextIndex < users.count ? users[nextIndex] : nil
    }
    
    private func getPreviousUser(before currentUser: User) -> User? {
        guard let currentIndex = users.firstIndex(where: { $0.id == currentUser.id }) else {
            return nil
        }
        if currentIndex > 0 {
            return users[currentIndex - 1]
        } else {
            return nil
        }
    }
    
    // Only for testing purposes
    private func clearUserDefaults() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier ?? "")
        UserDefaults.standard.synchronize()
        
        storyStateManager = StoryStateManager()
        
        let currentUsers = users
        users = []
        self.users = currentUsers
    }
}
