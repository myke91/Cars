//
//  ViewController.swift
//  Cars
//
//  Created by Michael Dugah on 22/11/2021.
//

import UIKit
import RxSwift
import Reachability

class CarsViewController: UICollectionViewController {
    
    // MARK: - Properties
    private let reuseIdentifier = "CarCell"
    private let sectionInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    private var cars: [CarModel] = []
    private let carRepository = CarsRepository()
    private let itemsPerRow: CGFloat = 1
    private let progressView = ProgressView(text: "Loading...")
    private let disposeBag = DisposeBag()
    
    let reachability = try? Reachability()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            navigationController?.navigationBar.standardAppearance = appearance;
            navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        }
        
        
        view.addSubview(progressView)
        progressView.show()
        loadCars()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability?.startNotifier()
        }catch{
            NSLog("could not start reachability notifier")
        }
    }
    
    /**
      Reload records after 60 mins if there's a network status change.
      Ideal duration should be determined based on frequency of update of records on the server
     */
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
    
        switch reachability.connection {
        case .wifi:
            NSLog("Reachable via WiFi")
            if(carRepository.timeElapsedSinceLastFetch() > 60) {
                doOnlineFetch()
            }
        case .cellular:
            NSLog("Reachable via Cellular")
            if(carRepository.timeElapsedSinceLastFetch() > 60){
                doOnlineFetch()
            }
        case .unavailable:
            NSLog("Network not reachable")
        case .none:
            NSLog("Network start not determined")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
        
    }
    /**
     Check if cached records are available and display them.
     Alternatively, perform an online fetch if cache is not available
     */
    private func loadCars(){
        if isAvailableCache(){
            doOfflineFetch()
        }else{
            doOnlineFetch()
        }
    }
    
    private func doOnlineFetch() {
        carRepository.fetchCars { carResults in
            DispatchQueue.main.async {
                switch carResults {
                case .failure(let error) :
                    NSLog("Error in fetching cars: \(error)")
                    let alert = UIAlertController(title: "Cars",
                                                  message: """
                                                            There was error retrieving records.
                                                            If this issue persist kindly contact support at support@myapp.com
                                                           """,
                                                  preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                case .success(let results):
                    NSLog("Found \(results.count)")
                    self.progressView.hide()
                    self.cars = results
                    self.collectionView?.reloadData()
                    self.carRepository.persistCarRecords(records: results)
                }
            }
        }
    }
    
    private func doOfflineFetch(){
        let results = carRepository.retrieveCars()
        progressView.hide()
        self.cars = results
        self.collectionView?.reloadData()
    }
    
    private func isAvailableCache() -> Bool {
        return carRepository.offlineRecordCount() > 0
    }
}

// MARK: - Private
private extension CarsViewController {
    func car(for indexPath: IndexPath) -> CarModel {
        return cars[indexPath.row]
    }
}

// MARK: - UICollectionViewDataSource
extension CarsViewController{
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cars.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CarCollectionViewCell
        
        let carSpec = car(for: indexPath)
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = carSpec.photo.getImage() ?? nil
        backgroundImage.contentMode = .scaleAspectFill
        
        cell.backgroundView = backgroundImage
        cell.titleView.text = carSpec.title
        cell.dateTimeView.text = carSpec.getDate()
        cell.descriptionView.text = carSpec.desc
        return cell
    }
}

//MARK: Collection View Flow Layout Delegate
extension CarsViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.collectionView.bounds.width, height: 500)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
}
