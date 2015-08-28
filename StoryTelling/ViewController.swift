//
//  ViewController.swift
//  StoryTelling
//
//  Created by Bader Alrshaid on 7/16/15.
//  Copyright (c) 2015 Bader Alrshaid. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    var orderOfSceneInStory : Int! // this is the first scene in the story
    var dateOfStory         : NSDate! // needed for Story.realm
    var videoUrl            : NSURL? // needed for Scene.realm - videoURL

    @IBOutlet weak var storyLabel: UILabel!
    @IBOutlet weak var typeStoryContainerView: UIView!
    @IBOutlet weak var videoRecordingContainerView: UIView!
    @IBOutlet weak var elementsScrollView: ElementsScrollView!
    @IBOutlet weak var storyBlurBackground: UIVisualEffectView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var typeStoryViewController : TypeStoryViewController!
    var videoRecordingViewController : VideoRecordingViewController!
    
    var viewIsLoaded = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationController!.navigationBar.hidden = true
        
        self.elementsScrollView.addElements()
        
        self.backgroundImageView.image?.accessibilityIdentifier = "parkLandscapeBG"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TypeStory"
        {
            typeStoryViewController = segue.destinationViewController as! TypeStoryViewController
            
            typeStoryViewController.story = self.storyLabel.text
        }
        
        else if segue.identifier == "VideoRecording"
        {
            videoRecordingViewController = segue.destinationViewController as! VideoRecordingViewController
            
            videoRecordingViewController.nameOfFile = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
            
        }
        
        else if segue.identifier == "NextScene"
        {
            self.saveSceneToRealm()
            
            let vc = segue.destinationViewController as! ViewController
            vc.orderOfSceneInStory = self.orderOfSceneInStory + 1
            vc.dateOfStory         = self.dateOfStory
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "NextScene"
        {
            if self.storyLabel.text?.isEmpty == true && self.videoUrl == nil
            {
                let alertView = UIAlertView(title: "اكتب القصة او صورها", message: "يجب عليك كتابة القصة او تسجيلها اولا", delegate: nil, cancelButtonTitle: "حسناً")
                alertView.show()
                
                return false
            }
        }
        
        return true
    }
    
    
    func enableUserInteractionsForAllElements(enable : Bool)
    {
        // disabling/enabling user intercations with elements ( so he can't drag them )
        for element in self.elementsScrollView.elementsOnscreen
        {
            element.userInteractionEnabled = enable
        }
        
        self.elementsScrollView.userInteractionEnabled = enable
    }

    
    @IBAction func typeButtonTapped(sender: UIButton) {
        self.showTypeStoryContainerView()
    }
    
    
    @IBAction func videoButtonTapped(sender: UIButton) {
        self.showVideoRecordingContainerView()
    }
    
    @IBAction func homeButtonTapped(sender: AnyObject) {
        if self.storyLabel!.text != "" || self.videoUrl != nil || self.elementsScrollView.elementsOnscreen.count > 0
        {
            self.saveSceneToRealm()
        }
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func backButtonTapped(sender: UIButton) {
        if self.storyLabel!.text != "" || self.videoUrl != nil || self.elementsScrollView.elementsOnscreen.count > 0
        {
            self.saveSceneToRealm()
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLayoutSubviews() {
        if viewIsLoaded == false
        {
            viewIsLoaded = true
            
            self.storyBlurBackground.layer.cornerRadius = self.storyBlurBackground.frame.height/2
            self.storyBlurBackground.clipsToBounds = true
            
            
            self.checkIfSceneIsSaved()
        }
    }
}


// TypeStoryContainerView extensions
extension ViewController
{
    func showTypeStoryContainerView()
    {
        self.enableUserInteractionsForAllElements(false)
        
        // un-hiding ( animating ) the typeStoryViewController & making it on top of everything
        self.typeStoryContainerView.hidden = false
        self.view.bringSubviewToFront(self.typeStoryContainerView)
        
        // to display the keyboard
        typeStoryViewController.textView.becomeFirstResponder()
    }
    
    // making the opposite of the previous func
    func hideTypeStoryContainerView()
    {
        self.enableUserInteractionsForAllElements(true)
        
        self.typeStoryContainerView.hidden = true
        
        typeStoryViewController.textView.resignFirstResponder() // to hide the keyboard
        
        if self.storyLabel.text != ""
        {
            self.storyBlurBackground.hidden = false
        }
        else
        {
            self.storyBlurBackground.hidden = true
        }
    }
}

// VideoRecordingContainerView extensions
extension ViewController
{
    func showVideoRecordingContainerView()
    {
        self.enableUserInteractionsForAllElements(false)
        
        self.videoRecordingViewController.camera.start()
        
        if let url = self.videoUrl
        {
            self.videoRecordingViewController.showVideoPreview(url)
        }
    
        self.view.bringSubviewToFront(self.videoRecordingContainerView)
        self.videoRecordingContainerView.hidden = false
    }
    
    func hideVideoRecordingContainerView()
    {
        self.enableUserInteractionsForAllElements(true)
        
        
        self.videoRecordingContainerView.hidden = true
        self.videoRecordingViewController.camera.stop()
    }
    
    func videoHasBeenRecorded(url : NSURL)
    {
        self.videoUrl = url
    }
}

// Realm stuff
extension ViewController
{
    func saveSceneToRealm()
    {
        let realm = try! Realm()
        
        /*** Story Telling ***/
        var storyTelling = StoryTelling()
        
        let predicate = NSPredicate(format: "date = %@", self.dateOfStory) // dateOfStory checking predicate
        
        
        if realm.objects(StoryTelling).filter(predicate).count == 0 // it's a new story - not editing an old story
        {
            storyTelling.date = self.dateOfStory
        }
        else // editing an old story or adding new scenes to a story
        {
            storyTelling = realm.objects(StoryTelling).filter(predicate).first!
        }
        
        
        /*** Scene ***/
        for scene in storyTelling.scenes
        {
            if scene.order == self.orderOfSceneInStory
            {
                realm.write {
                    realm.delete(scene)
                }
                
                break
            }
        }
        
        let scene = Scene()
        
        scene.order = self.orderOfSceneInStory
        scene.backgroundImageName = self.backgroundImageView.image?.accessibilityIdentifier
        
        if let story = self.storyLabel.text
        {
            scene.story = story
        }
        else
        {
            scene.story = nil
        }
        
        if let url = self.videoUrl
        {
            scene.videoUrl = "\(url)"
        }
        else
        {
            scene.videoUrl = ""
        }
        

        /*** Element ***/
        for elementOnScreen in self.elementsScrollView.elementsOnscreen
        {
            let element = Element()
            element.positionX = Float(elementOnScreen.frame.origin.x)
            element.positionY = Float(elementOnScreen.frame.origin.y)
            element.imageName = elementOnScreen.image!.accessibilityIdentifier!
            
            scene.elements.append(element) // adding every Element to Scene
        }

        
        // writing to realm
        realm.write {
            storyTelling.scenes.append(scene)
            
            if realm.objects(StoryTelling).filter(predicate).count == 0 // it's a new story - not editing an old story
            {
                realm.add(storyTelling)
            }
        }
    }
    
    func checkIfSceneIsSaved()
    {
        let realm = try! Realm()
        
        let predicate = NSPredicate(format: "date = %@", self.dateOfStory) // dateOfStory checking predicate
        
        
        if realm.objects(StoryTelling).filter(predicate).count == 1 // saved story
        {
            let storyTelling = realm.objects(StoryTelling).filter(predicate).first!
            
            
            for scene in storyTelling.scenes
            {
                if scene.order == self.orderOfSceneInStory
                {
                    self.showSavedScene(scene)
                    break
                }
            }
        }
    }
    
    func showSavedScene(scene : Scene)
    {
        // add everything to screen
        self.backgroundImageView.image = UIImage(named: scene.backgroundImageName)
        
        if scene.story! != ""
        {
            self.storyLabel.text = scene.story!
            self.storyBlurBackground.hidden = false
        }
        
        if scene.videoUrl != ""
        {
            self.videoUrl = NSURL(string: scene.videoUrl!)
        }
        
        
        let elements = scene.elements
        
        for elementFromRealm in elements
        {
            let element = ElementImageView(image: UIImage(named: elementFromRealm.imageName))
            element.frame = CGRectMake(CGFloat(elementFromRealm.positionX), CGFloat(elementFromRealm.positionY), element.image!.size.width, element.image!.size.height)
            element.image?.accessibilityIdentifier = elementFromRealm.imageName
            
            self.view.insertSubview(element, aboveSubview: self.backgroundImageView)
            
            // add it to the array
            self.elementsScrollView.elementsOnscreen.append(element)
        }
    }
}