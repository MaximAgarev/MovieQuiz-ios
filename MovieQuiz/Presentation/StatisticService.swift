import Foundation

protocol StatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    func store(correct count: Int, total amount: Int)
}

final class StatisticServiceImplementation: StatisticService {
    private let userDefaults = UserDefaults.standard
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    private (set) var total: Int {
        get {
            return userDefaults.integer(forKey: Keys.total.rawValue)
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    
    private (set) var correct: Int {
        get {
            return userDefaults.integer(forKey: Keys.correct.rawValue)
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            let total = userDefaults.integer(forKey: Keys.total.rawValue)
            let correct = userDefaults.integer(forKey: Keys.correct.rawValue)
            return Double(correct) / Double(total)
        }
    }
    
    private(set) var gamesCount: Int {
        get {
            return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
            }
        
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    private(set) var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
            let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        self.correct += count
        self.total += amount
        self.gamesCount += 1
        
        let currentGame = GameRecord(correct: count, total: amount, date: Date())
        if currentGame.isBest(bestGame: self.bestGame) {
            self.bestGame = currentGame
        }
        }
    
    }
