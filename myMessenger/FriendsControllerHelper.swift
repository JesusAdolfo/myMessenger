//
//  FriendsControllerHelper.swift
//  myMessenger
//
//  Created by Jesus Adolfo on 08/04/16.
//  Copyright © 2016 Jesus Adolfo. All rights reserved.
//

import UIKit

//class Friend: NSObject {
//    
//    var name: String?
//    var profileImageName: String?
//}
//
//class Message: NSObject {
//    
//    var text: String?
//    var date: NSDate?
//    
//    var friend: Friend?
//}
import CoreData

extension FriendsController {
    
    func clearData() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.managedObjectContext {
            
            do{
                let entityNames = ["Friend", "Message"]
                
                for entityName in entityNames{
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                    
                    let objects = try(context.fetch(fetchRequest) as? [NSManagedObject])
                    
                    for object in objects! {
                        context.delete(object)
                    }
                }
                
                
                
                try(context.save())
            }catch let err{
                print(err)
            
            }
        }
    }
    
    func setupData(){
        
        clearData()
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.managedObjectContext{
            let nikola = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            
            nikola.name = "Nikola Tesla"
            nikola.profileImageName = "tesla"
            
            FriendsController.createMessageWithText("Edison is a bum", friend: nikola, minutesAgo: 0, context: context)

            createAlbertMessagesWithContext(context)
            
            let chaplin = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            chaplin.name = "Charles Chaplin"
            chaplin.profileImageName = "chaplin"
            
            FriendsController.createMessageWithText("( ͡° ͜ʖ ͡°)", friend: chaplin, minutesAgo: 60 * 24 , context: context)
            
            let edison = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            edison.name = "Thomas Edison"
            edison.profileImageName = "edison"
            
            FriendsController.createMessageWithText("I will beat Tesla!!", friend: edison, minutesAgo: 8 * 60 * 24 , context: context)

            
            do{
                try(context.save())
            }catch let err {
                print(err)
            }
        }
        loadData()
    }
    
    
    fileprivate func createAlbertMessagesWithContext(_ context: NSManagedObjectContext){
        let albert = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
        albert.name = "Albert Einstein"
        albert.profileImageName = "einstein"
        
        FriendsController.createMessageWithText("Hello, some people think that I am the smartest person to ever live but that is not true", friend: albert, minutesAgo: 4, context: context)
        FriendsController.createMessageWithText("I was no even the smartest man in my era. When asked what does it feel to be the smartest man alive, I said 'I don't know you must ask that to Tesla'", friend: albert, minutesAgo: 3,context: context)
        FriendsController.createMessageWithText("e=mc^2", friend: albert, minutesAgo: 2, context: context)
        
        //response message
        FriendsController.createMessageWithText("uh?", friend: albert, minutesAgo: 2, context: context, isSender: true)
        
        FriendsController.createMessageWithText("I knew you were there, why you didn't text me back before?", friend: albert, minutesAgo: 2, context: context)
        
        //response message
        FriendsController.createMessageWithText("Ummm, do I know you buddy?", friend: albert, minutesAgo: 2, context: context, isSender: true)
        
        //response message
        FriendsController.createMessageWithText("Ohhh, I remember now. But aren't you dead? Or did your intelligence allowed you to find a way to live much longer than us mortals?", friend: albert, minutesAgo: 2, context: context, isSender: true)
        
        
        FriendsController.createMessageWithText("Nonsense! that is a foolish thought. There is no way to escape our destiny. If you knew a little bit about science you would know that   ", friend: albert, minutesAgo: 2, context: context)
    }
    
    static func createMessageWithText(_ text: String, friend: Friend, minutesAgo: Double, context: NSManagedObjectContext, isSender: Bool = false) -> Message{
        
        let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        message.friend = friend
        message.text = text
        message.date = Date().addingTimeInterval(-minutesAgo * 60)
        message.isSender = NSNumber(value: isSender as Bool)
        return message
    }
    
    func loadData() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.managedObjectContext {
            
            if let friends = fetchFriends(){
                
                messages = [Message]()
                
                for friend in friends {
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
                    fetchRequest.predicate = NSPredicate(format: "friend.name = %@", friend.name!)
                    fetchRequest.fetchLimit = 1
                    do{
                        
                        let fetchedMessages = try(context.fetch(fetchRequest)) as? [Message]
                        messages?.append(contentsOf: fetchedMessages!)
                        
                    } catch let err {
                        print(err)
                    }
                }
                messages = messages?.sorted(by: {$0.date!.compare($1.date! as Date) == .orderedDescending})
            }
            
        }
    }
    
    fileprivate func fetchFriends() -> [Friend]?{
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.managedObjectContext {
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
            
            do{
                return try context.fetch(request) as? [Friend]
            }catch let err{
                print(err)
            }
        }
        return nil
    }

}

