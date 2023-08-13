//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Dinara on 11.07.2023.
//

import Foundation

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var completion: () -> Void
}
