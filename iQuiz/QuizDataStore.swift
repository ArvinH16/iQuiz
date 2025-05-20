import Foundation

class QuizDataStore {
    static let shared = QuizDataStore()
    
    private let userDefaults = UserDefaults.standard
    private let quizzesKey = "savedQuizzes"
    private let lastRefreshKey = "lastRefreshTimestamp"
    
    private init() {}
    
    func saveQuizzes(_ quizzes: [QuizData]) {
        do {
            let data = try JSONEncoder().encode(quizzes)
            userDefaults.set(data, forKey: quizzesKey)
            userDefaults.set(Date().timeIntervalSince1970, forKey: lastRefreshKey)
        } catch {
            print("Failed to save quizzes: \(error)")
        }
    }
    
    func loadQuizzes() -> [QuizData]? {
        guard let data = userDefaults.data(forKey: quizzesKey) else {
            return nil
        }
        
        do {
            let quizzes = try JSONDecoder().decode([QuizData].self, from: data)
            return quizzes
        } catch {
            print("Failed to load quizzes: \(error)")
            return nil
        }
    }
    
    func lastRefreshTime() -> Date? {
        let timestamp = userDefaults.double(forKey: lastRefreshKey)
        if timestamp > 0 {
            return Date(timeIntervalSince1970: timestamp)
        }
        return nil
    }
    
    func convertToAppQuizzes(_ apiQuizzes: [QuizData]) -> [Quiz] {
        return apiQuizzes.map { apiQuiz in
            let questions = apiQuiz.questions.map { questionData in
                // Find the correct answer index
                let correctIndex = questionData.answers.firstIndex(of: questionData.answer) ?? 0
                
                return Question(
                    text: questionData.text,
                    options: questionData.answers,
                    correctAnswerIndex: correctIndex
                )
            }
            
            // Get a suitable system image based on the quiz title
            let icon = getIconForQuiz(title: apiQuiz.title)
            
            return Quiz(
                title: apiQuiz.title,
                description: apiQuiz.desc,
                icon: icon,
                questions: questions
            )
        }
    }
    
    private func getIconForQuiz(title: String) -> String {
        let lowerTitle = title.lowercased()
        
        if lowerTitle.contains("math") {
            return "number.circle"
        } else if lowerTitle.contains("marvel") || lowerTitle.contains("super") || lowerTitle.contains("hero") {
            return "bolt.circle"
        } else if lowerTitle.contains("science") {
            return "atom"
        } else if lowerTitle.contains("history") {
            return "book.circle"
        } else if lowerTitle.contains("music") {
            return "music.note"
        } else if lowerTitle.contains("movie") || lowerTitle.contains("film") {
            return "film"
        } else if lowerTitle.contains("sport") {
            return "sportscourt"
        } else {
            return "questionmark.circle"
        }
    }
    
    func shouldRefresh(interval: Int) -> Bool {
        guard interval > 0, let lastRefresh = lastRefreshTime() else {
            return false
        }
        
        let intervalSeconds = TimeInterval(interval * 60)
        let now = Date()
        return now.timeIntervalSince(lastRefresh) > intervalSeconds
    }
} 