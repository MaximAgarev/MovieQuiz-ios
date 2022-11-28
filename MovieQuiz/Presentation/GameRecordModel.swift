import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBest(bestGame: GameRecord) -> Bool {
        return bestGame < self
    }
}

extension GameRecord: Comparable {
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        return lhs.correct < rhs.correct
    }
}
