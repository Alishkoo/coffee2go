//
//  MapViewController.swift
//  MapSearch
//

import Combine
import UIKit
import YandexMapsMobile
import CoreLocation

class MapViewController: UIViewController {
    // MARK: - Public methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = YMKMapView(frame: view.frame)
        view.addSubview(mapView)
        
        map = mapView.mapWindow.map
        
        setupCustomMapStyle()
        
        map.addCameraListener(with: mapCameraListener)
        
        searchViewModel.setupSubscriptions()
        
        setupSearchController()
        
        moveToStartPoint()
        
        setupLocationManager()
    }
    
    // MARK: - Private methods
    
    private func setupLocationManager() {
        locationManager.requestLocationAccess()
        locationManager.startUpdatingLocation()
        
        // Подписываемся на обновления местоположения
        locationManager.$userLocation
            .compactMap { $0 } // Пропускаем nil значения
            .sink { [weak self] location in
                self?.updateUserLocation(location: location)
            }
            .store(in: &bag)
    }
    
    private func updateUserLocation(location: CLLocation) {
        let userPoint = YMKPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        // Если маркер уже существует, обновляем его позицию
        if let userPlacemark = userPlacemark, userPlacemark.isValid {
            userPlacemark.geometry = userPoint
        } else {
            // Создаем новый маркер для пользователя
            let placemark = map.mapObjects.addPlacemark(with: userPoint)
            placemark.setIconWith(UIImage(systemName: "circle.circle.fill")!
                .withTintColor(view.tintColor)) // Устанавливаем иконку
            placemark.isDraggable = false
            userPlacemark = placemark
        }
        
        // Перемещаем камеру на пользователя (если нужно)
        if shouldFollowUserLocation {
            let cameraPosition = YMKCameraPosition(target: userPoint, zoom: 14.0, azimuth: 0, tilt: 0)
            map.move(with: cameraPosition, animation: YMKAnimation(type: .smooth, duration: 1.5))
            
            // После первого перемещения отключаем автоматическое следование
            shouldFollowUserLocation = false
        }
    }
    
    
    private func moveToStartPoint() {
        map.move(with: Const.startPosition, animation: YMKAnimation(type: .smooth, duration: 0.5))
        searchViewModel.setVisibleRegion(with: map.visibleRegion)
    }
    
    private func setupSearchController() {
        // searchResultsUpdater: Обновляет результаты поиска.
        self.searchBarController.searchResultsUpdater = self
        // obscuresBackgroundDuringPresentation: Затемняет фон при вводе текста.
        self.searchBarController.obscuresBackgroundDuringPresentation = true
        // hidesNavigationBarDuringPresentation: Отключает скрытие навигационной панели.
        self.searchBarController.hidesNavigationBarDuringPresentation = false
        // placeholder: Устанавливает текст-заполнитель для строки поиска.
        self.searchBarController.searchBar.placeholder = "Search places"
        
        self.navigationItem.searchController = searchBarController
        self.definesPresentationContext = true
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        searchBarController.delegate = self
        searchBarController.searchBar.delegate = self
        searchBarController.searchBar.showsBookmarkButton = false
        
        resultsTableController.tableView.delegate = self
        
        setupStateUpdates()
    }
    
    private func focusCamera(points: [YMKPoint], boundingBox: YMKBoundingBox) {
        if points.isEmpty {
            return
        }
        
        let position = points.count == 1
        ? YMKCameraPosition(
            target: points.first!,
            zoom: map.cameraPosition.zoom,
            azimuth: map.cameraPosition.azimuth,
            tilt: map.cameraPosition.tilt
        )
        : map.cameraPosition(with: YMKGeometry(boundingBox: boundingBox))
        
        map.move(with: position, animation: YMKAnimation(type: .smooth, duration: 0.5))
    }
    
    private func displaySearchResults(
        items: [SearchResponseItem],
        zoomToItems: Bool,
        itemsBoundingBox: YMKBoundingBox
    ) {
        map.mapObjects.clear()
        
        items.forEach { item in
            let image = UIImage(systemName: "circle.circle.fill")!
                .withTintColor(view.tintColor)
            
            let placemark = map.mapObjects.addPlacemark()
            placemark.geometry = item.point
            placemark.setViewWithView(YRTViewProvider(uiView: UIImageView(image: image)))
            
            placemark.userData = item.geoObject
            placemark.addTapListener(with: mapObjectTapListener)
        }
    }
    
    private func setupCustomMapStyle() {
        let customMapStyle = """
            [
                {
                    "tags": { "all": ["landscape"] },
                    "stylers": {
                        "color": "#F7F7F7"
                    }
                },
                {
                    "tags": { "all": ["water"] },
                    "elements": ["geometry"],
                    "stylers": {
                        "color": "#B7DFEC"
                    }
                },
                {
                    "tags": { "any": ["road_1", "road_2", "road_3"] },
                    "elements": ["geometry"],
                    "stylers": {
                        "color": "#FFFFFF"
                    }
                },
                {
                    "tags": { "any": ["road_1", "road_2", "road_3"] },
                    "elements": ["geometry.outline"],
                    "stylers": {
                        "color": "#EAEAEA"
                    }
                },
                {
                    "tags": { "any": ["road_4", "road_5", "road_6", "road_7"] },
                    "elements": ["geometry"],
                    "stylers": {
                        "color": "#FFFFFF"
                    }
                },
                {
                    "tags": { "any": ["road_4", "road_5", "road_6", "road_7"] },
                    "elements": ["geometry.outline"],
                    "stylers": {
                        "color": "#EAEAEA"
                    }
                },
                {
                    "tags": { "any": ["building"] },
                    "elements": ["geometry"],
                    "stylers": {
                        "color": "#E9E5DC"
                    }
                },
                {
                    "tags": { "any": ["park", "vegetation"] },
                    "elements": ["geometry"],
                    "stylers": {
                        "color": "#D3EACD"
                    }
                },
                {
                    "tags": { "any": ["transit"] },
                    "elements": ["geometry"],
                    "stylers": {
                        "color": "#D5D5D5"
                    }
                },
                {
                    "tags": { "all": ["poi"] },
                    "elements": ["label.text.fill"],
                    "stylers": {
                        "color": "#6C6C6C"
                    }
                },
                {
                    "tags": { "all": ["road"] },
                    "elements": ["label.text.fill"],
                    "stylers": {
                        "color": "#6C6C6C"
                    }
                },
                    {
                    "tags": { "any": ["cultural", "museum"] },
                    "stylers": {
                        "visibility": "off"
                    }
                },
                
            ]
            """
        
        do {
            map.setMapStyleWithStyle(customMapStyle)
            print("Кастомный стиль карты применен успешно")
        } catch {
            print("Ошибка применения стиля карты: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private properties
    
    private var mapView: YMKMapView!
    private lazy var map: YMKMap = mapView.mapWindow.map
    private let buttonsView = UIStackView()
    // Камера
    private lazy var mapCameraListener = MapCameraListener(searchViewModel: searchViewModel)
    
    private lazy var resultsTableController = ResultsTableController()
    // Поиск
    private lazy var searchBarController = UISearchController(searchResultsController: resultsTableController)
    private let searchViewModel = SearchViewModel()
    // Локация персонажа
    private let locationManager = LocationManager()
    private var userPlacemark: YMKPlacemarkMapObject? // Маркер для пользователя
    // Флаг для контроля следования камеры за пользователем
    private var shouldFollowUserLocation = true
    
    // bag: Это коллекция для хранения подписок Combine, чтобы управлять их жизненным циклом.
    private var bag = Set<AnyCancellable>()
    // searchSuggests: Это массив предложений для автозаполнения поиска.
    @Published private var searchSuggests: [SuggestItem] = []
    // mapObjectTapListener: Это объект, который обрабатывает нажатия на объекты карты.
    private lazy var mapObjectTapListener = MapObjectTapListener(controller: self)
    
    // MARK: - Private nesting
    
    private enum Const {
        static let startPoint = YMKPoint(latitude: 43.2567, longitude: 76.9286)
        static let startPosition = YMKCameraPosition(target: startPoint, zoom: 13.0, azimuth: .zero, tilt: .zero)
    }
    
    // MARK: - Layout
    
    private enum Layout {
        static let buttonSize: CGFloat = 50.0
    }
}

extension MapViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchViewModel.reset()
        searchViewModel.setQueryText(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchViewModel.startSearch()
        searchBarController.searchBar.text = searchViewModel.mapUIState.query
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if case .idle = searchViewModel.mapUIState.searchState {
            updatePlaceholder()
        }
    }
    
    func setupStateUpdates() {
        searchViewModel.$mapUIState.sink { [weak self] state in
            let query = state?.query ?? String()
            self?.searchBarController.searchBar.text = query
            self?.updatePlaceholder(with: query)
            
            if case let .success(items, zoomToItems, itemsBoundingBox) = state?.searchState {
                self?.displaySearchResults(items: items, zoomToItems: zoomToItems, itemsBoundingBox: itemsBoundingBox)
                if zoomToItems {
                    self?.focusCamera(points: items.map { $0.point }, boundingBox: itemsBoundingBox)
                }
            }
            if let suggestState = state?.suggestState {
                self?.updateSuggests(with: suggestState)
            }
        }
        .store(in: &bag)
    }
    
    private func updateSuggests(with suggestState: SuggestState) {
        switch suggestState {
        case .success(let items):
            resultsTableController.items = items
            resultsTableController.tableView.reloadData()
            
        default:
            return
        }
    }
    
    private func updatePlaceholder(with text: String = String()) {
        searchBarController.searchBar.placeholder = text.isEmpty ? "Search places" : text
    }
}

extension MapViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < resultsTableController.items.count else { return }
        
        searchBarController.isActive = false
        
        let item = resultsTableController.items[indexPath.row]
        item.onClick()
    }
}

fileprivate class ResultsTableController: UITableViewController {
    
    private let cellIdentifier = "cellIdentifier"
    
    var items = [SuggestItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.numberOfLines = 0
        
        let item = items[indexPath.row]
        
        cell.textLabel?.attributedText = item.cellText
        
        return cell
    }
}

fileprivate extension SuggestItem {
    
    var cellText: NSAttributedString {
        let result = NSMutableAttributedString(string: title.text)
        result.append(NSAttributedString(string: " "))
        
        let subtitle = NSMutableAttributedString(string: subtitle?.text ?? "")
        subtitle.setAttributes(
            [.foregroundColor: UIColor.secondaryLabel],
            range: NSRange(location: 0, length: subtitle.string.count)
        )
        result.append(subtitle)
        
        return result
    }
}
