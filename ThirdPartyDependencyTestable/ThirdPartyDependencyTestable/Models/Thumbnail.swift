//
//  Thumbnail.swift
//  ThirdPartyDependencyTestable
//
//  Created by Jin Lee on 20/7/20.
//  Copyright © 2020 Jin Lee. All rights reserved.
//

import Foundation

struct Thumbnail {
    let url: URL
    let width: Float
    let height: Float
}

extension Thumbnail: Decodable {
    enum CodingKeys: String, CodingKey {
        case oembed
        
        enum OembedCodingKeys: String, CodingKey {
            case url = "thumbnail_url"
            case width = "thumbnail_width"
            case height = "thumbnail_height"
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let oembedContainer = try container.nestedContainer(keyedBy: CodingKeys.OembedCodingKeys.self, forKey: .oembed)
        
        url = try oembedContainer.decode(URL.self, forKey: .url)
        width = try oembedContainer.decode(Float.self, forKey: .width)
        height = try oembedContainer.decode(Float.self, forKey: .height)
        
    }
}
