//
//  Photo.swift
//  MVVMUnitTest
//
//  Created by Jin Lee on 21/7/20.
//  Copyright © 2020 Jin Lee. All rights reserved.
//

import Foundation

struct Photos: Decodable {
    let photos: [Photo]
}

struct Photo: Decodable {
    let id: Int
    let name: String
    let description: String?
    let created_at: Date
    let image_url: String
    let for_sale: Bool
    let camera: String?
}
