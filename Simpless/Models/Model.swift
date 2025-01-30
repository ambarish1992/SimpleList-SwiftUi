//
//  Model.swift
//  Simpless
//
//  Created by Ambarish Shivakumar on 04/12/24.
//

import Foundation

struct Product: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let image: String
}

