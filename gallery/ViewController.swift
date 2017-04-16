//
//  ViewController.swift
//  gallery
//
//  Created by Admin on 13.04.17.
//  Copyright © 2017 justsayozz. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UIScrollViewDelegate {
    static let portraitColumnsCount = 3
    static let landscapeColumnsCount = 5
    static let columnSpacing = 1
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var photos: [Photo]?
    var filteredPhotos = [Photo]()
    var columnsCount: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        orientationDidChange()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.orientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func orientationDidChange() {
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            columnsCount = ViewController.landscapeColumnsCount
        }
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            columnsCount = ViewController.portraitColumnsCount
        }
        collectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        searchBar.resignFirstResponder()
        if segue.identifier == "showPhoto" {
            if let destVC = segue.destination as? PhotoViewController {
                if let thumbImageCell = sender as? ThumbImageCell {
                    destVC.setPhoto(photo: thumbImageCell.getPhoto())
                }
            }
        }
    }
    
    func refresh() {
        ApiManager.sharedInstance.getPhotos(completion: { (photos) in
            DispatchQueue.main.async {
                self.photos = photos
                self.filterPhotos(filterText: "")
                self.collectionView.reloadData()
            }
        }, error: {
            let alertController = UIAlertController(title: "Error", message: "Error loading photos from server. Please try again.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    func filterPhotos(filterText: String) {
        filteredPhotos.removeAll()
        
        guard !filterText.isEmpty else {
            if let photos = photos {
                filteredPhotos.append(contentsOf: photos)
            }
            collectionView.reloadData()
            return
        }
        
        if let photos = photos {
            for photo in photos {
                let searchString = filterText.lowercased()
                if let photoTitle = photo.title?.lowercased() {
                    if photoTitle.contains(searchString) {
                        filteredPhotos.append(photo)
                    }
                }
            }
        }
        collectionView.reloadData()
    }
    
    //UISearchBar delegates
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterPhotos(filterText: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filterPhotos(filterText: "")
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    //UIScrollView delegates
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
    }

    //UICollectionView delegates
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "thumbImageCell", for: indexPath)
        if let cell = cell as? ThumbImageCell {
            cell.setPhoto(photo: filteredPhotos[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let photo = filteredPhotos[indexPath.row]
            if photo.thumbnailImage != nil {
                continue
            }
            photo.getThumbImage(completion: { (updateNeeded) in
                if updateNeeded {
                    DispatchQueue.main.async {
                        collectionView.reloadItems(at: [indexPath])
                    }
                }
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width / CGFloat(columnsCount) - CGFloat(ViewController.columnSpacing)
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(ViewController.columnSpacing)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(ViewController.columnSpacing)
    }
    
    //
}

