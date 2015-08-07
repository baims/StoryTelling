//
//  HomeViewController.swift
//  StoryTelling
//
//  Created by Bader Alrshaid on 7/27/15.
//  Copyright (c) 2015 Bader Alrshaid. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "StoryTelling"
        {
            let vc = segue.destinationViewController as! ViewController
            vc.orderOfSceneInStory = 1 // because it's the first one
            vc.dateOfStory         = NSDate()
        }
    }
}
