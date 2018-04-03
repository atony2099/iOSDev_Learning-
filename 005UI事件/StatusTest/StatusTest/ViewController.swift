//
//  ViewController.swift
//  StatusTest
//
//  Created by admin on 04/12/2017.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override var prefersStatusBarHidden: Bool {
        return false;
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
//    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return self.childViewControllers.last
    }

    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true;
        // Do any additional setup after loading the view, typically from a nib.
        
        let vc = ViewController2();
        addChildViewController(vc)
        vc.view.frame = view.bounds;
        view.addSubview(vc.view);
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    

}

