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



