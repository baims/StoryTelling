//
//  SavedStoriesCollectionViewController.swift
//  StoryTelling
//
//  Created by Bader Alrshaid on 7/31/15.
//  Copyright (c) 2015 Bader Alrshaid. All rights reserved.
//

import UIKit
import RealmSwift

let reuseIdentifier = "Cell"

class SavedStoriesCollectionViewController: UICollectionViewController {
    
    var numberOfStories : Int!
    var stories : Results<StoryTelling>!
    
    var selectedStoryTelling : StoryTelling!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false

       
        let realm = Realm()
        self.stories = realm.objects(StoryTelling).sorted("date", ascending: false)
        self.numberOfStories = self.stories.count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowSavedScene"
        {
            let vc = segue.destinationViewController as! ViewController
            vc.orderOfSceneInStory = 1 // because it's the first one
            vc.dateOfStory         = self.selectedStoryTelling.date
        }
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfStories
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! SavedStoryCollectionViewCell
        
        cell.dateLabel.text = "\(self.stories[indexPath.item].date)"
        cell.storyTelling   = self.stories[indexPath.item]
    

        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! SavedStoryCollectionViewCell
        self.selectedStoryTelling = cell.storyTelling
        
        return true
    }

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
