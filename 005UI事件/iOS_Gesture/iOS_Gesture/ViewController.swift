//
//  ViewController.swift
//  iOS_Gesture
//
//  Created by admin on 17/01/2018.
//  Copyright © 2018 atony. All rights reserved.
//

import UIKit


class ViewB:UIView {
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        print("a=begin ")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
         super.touchesMoved(touches, with: event)
        print("a=touchmove ")
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        print("a=cancle")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        print("a=end")
    }
}

class ViewA:UIView {
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        print("b==============begin ")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        print("b========= touch move ")
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        print("b============cancle")
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        print("b============end")

    }
    
}


// 手势识别
// 1.
// 2.

class ViewController: UIViewController {
    @IBOutlet weak var viewA: ViewA!
    
    @IBOutlet weak var viewB: ViewB!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let ges  = UITapGestureRecognizer.init(target: self, action: #selector(gets))
//        ges.cancelsTouchesInView = false
        
        viewA.addGestureRecognizer(ges);

    }
    
    @objc func gets()  {
        print("gest")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

