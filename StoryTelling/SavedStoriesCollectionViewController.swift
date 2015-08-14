//
//  SavedStoriesCollectionViewController.swift
//  StoryTelling
//
//  Created by Bader Alrshaid on 7/31/15.
//  Copyright (c) 2015 Bader Alrshaid. All rights reserved.
//

import UIKit
import RealmSwift


class SavedStoriesCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var addToReadStoriesButton: UIBarButtonItem!
    
    
    var numberOfStories : Int!
    var stories : Results<StoryTelling>!
    
    var selectedStoryTelling : StoryTelling!
    
    let reuseIdentifier = "Cell"
    var isEditingCollectionView = false
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = true
        self.collectionView?.allowsMultipleSelection = true

       
        let realm = Realm()
        self.stories = realm.objects(StoryTelling).sorted("date", ascending: false)
        self.numberOfStories = self.stories.count
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController!.navigationBar.hidden = false
        self.navigationController?.toolbarHidden        = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController!.navigationBar.hidden = true
        self.navigationController?.toolbarHidden        = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "ShowSavedScene"
        {
            let vc = segue.destinationViewController as! ViewController
            vc.orderOfSceneInStory = 1 // because it's the first one
            vc.dateOfStory         = self.selectedStoryTelling.date
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool
    {
        if identifier == "ShowSavedScene" && self.isEditingCollectionView == true
        {
            return false
        }
        
        return true
    }
}


// MARK: Storyboard buttons actions
extension SavedStoriesCollectionViewController
{
    @IBAction func editButtonTapped(sender: UIBarButtonItem) {
        if !self.isEditingCollectionView {
            self.isEditingCollectionView = true
            
            sender.title = "تم"
            
            self.deleteButton.enabled           = true
            self.addToReadStoriesButton.enabled = true
            
            self.collectionView!.reloadData()
            
        }
        else if self.isEditingCollectionView {
            self.isEditingCollectionView = false
            
            sender.title = "تعديل"
            
            self.deleteButton.enabled           = false
            self.addToReadStoriesButton.enabled = false
            
            self.collectionView!.reloadData()
        }
    }
    
    
    @IBAction func deleteAllStoriesButtonTapped(sender: UIBarButtonItem)
    {
        let alertController = UIAlertController(title: "تأكيد", message: "هل انت متأكد من مسح جميع القصص المحفوظة؟", preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "الغاء", style: .Cancel, handler: nil)
        
        let deleteAction = UIAlertAction(title: "مسح جميع القصص", style: UIAlertActionStyle.Destructive)
            { (action) -> Void in
                let realm = Realm()
                
                realm.write {
                    realm.delete(realm.objects(StoryTelling))
                }
                
                self.stories = realm.objects(StoryTelling).sorted("date", ascending: false)
                self.numberOfStories = self.stories.count
                
                self.collectionView?.reloadData()
        }
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func deleteButtonTapped(sender: UIBarButtonItem)
    {
        let alertController = UIAlertController(title: "تأكيد", message: "هل انت متأكد من مسح جميع القصص المحفوظة؟", preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "الغاء", style: .Cancel, handler: nil)
        
        let deleteAction = UIAlertAction(title: "مسح جميع القصص", style: UIAlertActionStyle.Destructive)
            { (action) -> Void in
                
                var stories = [StoryTelling]()
                
                for indexPath in self.collectionView!.indexPathsForSelectedItems()
                {
                    let cell = self.collectionView!.cellForItemAtIndexPath(indexPath as! NSIndexPath) as!SavedStoryCollectionViewCell
                    
                    stories.append(cell.storyTelling)
                }
                
                let realm = Realm()
                
                realm.write {
                    realm.delete(stories)
                }
                
                
                self.stories = realm.objects(StoryTelling).sorted("date", ascending: false)
                self.numberOfStories = self.stories.count
                
                self.collectionView?.reloadData()
        }
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}


// MARK: UICollectionViewDataSource & UICollectionViewDelegate
extension SavedStoriesCollectionViewController
{
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfStories
    }
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! SavedStoryCollectionViewCell
        
        cell.dateLabel.text = "\(self.stories[indexPath.item].date)"
        cell.storyTelling   = self.stories[indexPath.item]
        
        
        let backgroundView = UIView(frame: cell.frame)
        backgroundView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    

    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! SavedStoryCollectionViewCell
        
        if self.isEditingCollectionView == false
        {
            self.selectedStoryTelling = cell.storyTelling // getting the story to pass it in prepareForSegue:
        }
        
        return true
    }
    
    
    override func collectionView(collectionView: UICollectionView, shouldDeselectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
}
