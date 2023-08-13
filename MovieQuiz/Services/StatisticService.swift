//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Dinara on 14.07.2023.
//

import Foundation

protocol StatisticService {
    func store(correct count: Int, total amount: Int)
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
}


final class StatisticServiceImplementation: StatisticService {
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    private let userDefaults = UserDefaults.standard

    var totalAccuracy: Double {
        let correct = userDefaults.integer(forKey: Keys.correct.rawValue)
        let total = userDefaults.integer(forKey: Keys.total.rawValue)
        return total > 0 ? Double(correct) / Double(total) * 100.0 : 0.0
    }

    var gamesCount: Int {
        return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
    }

    var bestGame: GameRecord {
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
        let currentRecord = GameRecord(correct: count, total: amount, date: Date())
        if currentRecord > bestGame {
            bestGame = currentRecord
        }
        let newCorrect = userDefaults.integer(forKey: Keys.correct.rawValue) + count
        let newTotal = userDefaults.integer(forKey: Keys.total.rawValue) + amount
        let newGamesCount = userDefaults.integer(forKey: Keys.gamesCount.rawValue) + 1

        userDefaults.set(newCorrect, forKey: Keys.correct.rawValue)
        userDefaults.set(newTotal, forKey: Keys.total.rawValue)
        userDefaults.set(newGamesCount, forKey: Keys.gamesCount.rawValue)
    }
}

