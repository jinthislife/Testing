//
//  Feed.swift
//  ThirdPartyDependencyTestable
//
//  Created by Jin Lee on 20/7/20.
//  Copyright © 2020 Jin Lee. All rights reserved.
//

import Foundation

struct Feed {
    let title: String
    let author: String
    let thumbnail: Thumbnail?
}

extension Feed: Decodable {
    enum CodingKeys: String, CodingKey {
        case title
        case author
        case thumbnail = "media"
    }
}

struct RedditResponse {
    let feeds: [Feed]
}

extension RedditResponse: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    private struct Data: Decodable {
        let children: [Child]
    }
    
    private struct Child: Decodable {
        let data: Feed
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let children = try container.decode(Data.self, forKey: .data).children
        
        feeds = children.map { $0.data }
    }
}
