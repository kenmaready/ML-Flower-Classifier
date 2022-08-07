//
//  WikiData.swift
//  ML-Flower-Classifier
//
//  Created by Ken Maready on 8/5/22.
//

import Foundation

struct WikiData: Decodable {
    var query: Query
}

struct Query: Decodable {
    let pageids: [String]
    let pages: [String: Page]
}

struct Page: Decodable {
    let pageid: Int
    let title: String
    let extract: String
    let thumbnail: Thumbnail
}

struct Thumbnail: Decodable {
    let source: String
}
