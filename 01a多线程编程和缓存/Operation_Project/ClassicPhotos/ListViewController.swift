//
//  ListViewController.swift
//  ClassicPhotos
//
//  Created by Richard Turton on 03/07/2014.
//  Copyright (c) 2014 raywenderlich. All rights reserved.
//

import UIKit
import CoreImage
let dataSourceURL = URL(string:"http://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist")

class ListViewController: UITableViewController {
  
    lazy var photos = [PhotoRecord]()
    lazy var pendOperation  = PendingOperation()
  
      override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Classic Photos"
        fetchPhotoDetails()
      }
    
    
    func fetchPhotoDetails() {

        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let path = Bundle.main.path(forResource: "abc", ofType: "plist");
        let datasourceDictionary = NSDictionary.init(contentsOfFile: path!);

        for(key,value) in datasourceDictionary! {
            let name = key as? String
            let url = URL.init(string: value as? String ?? "")
            if name != nil && url != nil  {
                let photoRecord = PhotoRecord(name:name!, url:url!)
                self.photos.append(photoRecord)
            }
        }
        print(self.photos)

        
    }
    
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // #pragma mark - Table view data source
  
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
    return photos.count
  }
  
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath as IndexPath)
        //1, 加载loadingView
        if cell.accessoryView == nil {
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            cell.accessoryView = indicator
        }
        let indicator = cell.accessoryView as! UIActivityIndicatorView
       
        let photeoDetails  = photos[indexPath.row];
        cell.textLabel?.text = photeoDetails.name;
        cell.imageView?.image = photeoDetails.image;
  
        switch photeoDetails.state {
        case .Filtered:
            indicator.stopAnimating()
        case .Failed:
            indicator.stopAnimating()
            cell.textLabel?.text = "failed to load"
        case .New, .Downloaded:
            indicator.startAnimating()
            startExcute(indexPath: indexPath, record: photeoDetails)
            
        }
        return cell
    }
    
    func startExcute(indexPath:IndexPath,record:PhotoRecord  )  {
        switch record.state {
        case .New:
            self.startDownload(indexPath: indexPath, record: record)
            break
        case .Downloaded:
            self.startFilter(indexPath: indexPath, record: record)
            break
        default: break
        }
    }
    
    
    func startDownload(indexPath:IndexPath,record:PhotoRecord  ){
        if  let _ = self.pendOperation.dowdloadProgeres[indexPath]  {
            return;
        }
        let downloader = DownLoader.init(photoRecord: record)
        self.pendOperation.downloadQueue.addOperation(downloader)
        self.pendOperation.dowdloadProgeres[indexPath] = downloader;

        downloader.completionBlock = {
            if downloader.isCancelled {
                return;
            }
            DispatchQueue.main.async {
                self.pendOperation.dowdloadProgeres.removeValue(forKey: indexPath)
                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
            }
        }
    }
    
    func startFilter(indexPath:IndexPath,record:PhotoRecord  ){
        
        if  let _ = self.pendOperation.filterProgeres[indexPath]  {
            return;
        }
        let imageFilter =  ImageFiltration.init(photoRecord: record)
        self.pendOperation.filterQueue.addOperation(imageFilter)
        self.pendOperation.filterProgeres[indexPath] = imageFilter;
        
        imageFilter.completionBlock = {
            if imageFilter.isCancelled {
                return;
            }
            DispatchQueue.main.async {
                self.pendOperation.filterProgeres.removeValue(forKey: indexPath)
                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
            }
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //
        suspendAllOperations()
    }
    
 
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadImagesForOnscreenCells()
        resumeAllOperations()
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == true {
            loadImagesForOnscreenCells()
            resumeAllOperations()
        }
    }
    
    func suspendAllOperations()  {
        self.pendOperation.downloadQueue.isSuspended = true
        self.pendOperation.filterQueue.isSuspended = true
    }
    
    func resumeAllOperations() {
        self.pendOperation.downloadQueue.isSuspended = false
        self.pendOperation.filterQueue.isSuspended = false
    }
    
    
    func loadImagesForOnscreenCells () {
        //1
        if let pathsArray = tableView.indexPathsForVisibleRows{
            //2
            let allPendingOperations = Set(self.pendOperation.dowdloadProgeres.keys)
            _ =  allPendingOperations.union(self.pendOperation.filterProgeres.keys)
            
            //3
            var toBeCancelled = allPendingOperations
            let visiblePaths = Set(pathsArray)
        
            toBeCancelled.subtract(visiblePaths)
            
            //4
            var toBeStarted = visiblePaths
            toBeStarted.subtract(allPendingOperations)
            
            // 5
            for indexPath in toBeCancelled {
                if let pendingDownload = pendOperation.dowdloadProgeres[indexPath] {
                    pendingDownload.cancel()
                }
                pendOperation.dowdloadProgeres.removeValue(forKey: indexPath)
               
                if let pendingFiltration = pendOperation.filterProgeres[indexPath] {
                    pendingFiltration.cancel()
                }
                pendOperation.filterProgeres.removeValue(forKey: indexPath)
            }
            
            // 6
            for indexPath in toBeStarted {
                let indexPath = indexPath as IndexPath
                let recordToProcess = self.photos[indexPath.row]
                startExcute(indexPath: indexPath, record: recordToProcess)
            }
        }
    }

    
    
}
