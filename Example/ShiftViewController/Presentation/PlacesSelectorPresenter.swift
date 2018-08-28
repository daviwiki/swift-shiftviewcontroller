//
// Created by David Martinez on 28/08/2018.
// Copyright (c) 2018 CocoaPods. All rights reserved.
//

import Foundation

protocol PlacesSelectorPresenter {
    func bind(view: PlacesSelectorView)
    func loadPlaces()
}

class PlacesSelectorPresenterDefault: PlacesSelectorPresenter {

    private weak var view: PlacesSelectorView?
    private var getPlaces: GetPlaces = GetPlacesInteractor()

    func bind(view: PlacesSelectorView) {
        self.view = view
    }

    func loadPlaces() {
        let places = getPlaces.get()
        view?.showPlaces(places: places)
    }

}