//
//  StoryTellingRealm.swift
//  StoryTelling
//
//  Created by Bader Alrshaid on 7/27/15.
//  Copyright (c) 2015 Bader Alrshaid. All rights reserved.
//

import RealmSwift

class StoryTelling : Object
{
    dynamic var date : NSDate!
    let scenes = List<Scene>()
}

class Scene : Object
{
    dynamic var order = 0
    dynamic var story    : String?
    dynamic var videoUrl : String?
    dynamic var backgroundImageName : String!
    let elements = List<Element>()
}

class Element : Object
{
    dynamic var positionX : Float = 0
    dynamic var positionY : Float = 0
    dynamic var imageName = ""
}