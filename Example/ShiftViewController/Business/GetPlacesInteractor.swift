//
// Created by David Martinez on 28/08/2018.
// Copyright (c) 2018 CocoaPods. All rights reserved.
//

import Foundation

protocol GetPlaces {
    func get() -> [Location]
}

class GetPlacesInteractor: GetPlaces {
    func get() -> [Location] {
        var locations: [Location] = []
        for i in 0..<10 {
            locations.append(getRandom(i: i))
        }
        return locations
    }

    private func getRandom(i: Int) -> Location {
        return Location(
                name: "Name",
                country: "Country",
                imageUrl: URL(string: "https://picsum.photos/400/600/?image=\(510+i)")!)
    }
}