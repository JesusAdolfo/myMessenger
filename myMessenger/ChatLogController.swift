//
//  ChatLogController.swift
//  myMessenger
//
//  Created by Jesus Adolfo on 09/04/16.
//  Copyright © 2016 Jesus Adolfo. All rights reserved.
//

import UIKit

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    fileprivate let cellId = "cellId"
    
    var friend: Friend? {
        didSet {
            //sets the title of the ChatLogController to the current's friend name
            navigationItem.title = friend?.name
            //gets the messages from this friend and sets them to the messages variable below
            messages = friend?.messages?.allObjects as? [Message]
            
            //we apply again the same sort we had before
            messages = messages?.sorted(by: {$0.date!.compare($1.date! as Date) == .orderedAscending})
        }
    }
    
    var messages: [Message]?
    
    //view that will contain the area where we type and the send button
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white //must be white to block the items on the back
        return view
    }()
    //inputTextField for the area where we are going to type
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your message..."
        return textField
    }()
    //button for the "Send" functionality in our chat
    lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setTitle("Send", for: UIControlState())
        let titleColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
        button.setTitleColor(titleColor, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        //addTarget connects this button to the handleSend() function below
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        
        return button
    }()
    
    func handleSend(){
        print(inputTextField.text)
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext
        
        let message = FriendsController.createMessageWithText(inputTextField.text!, friend: friend!, minutesAgo: 0, context: context, isSender: true)
        
        
        //because context.save throws an error we have to use: "do, try, catch"
        do{
            try context.save()
            
            messages?.append(message)
            
            let item = messages!.count - 1
            let insertionIndexPath = IndexPath(row: item, section: 0)
            
            //inserts senders message into the collection
            collectionView?.insertItems(at: [insertionIndexPath])
            //scrolls collection to the bottom
            collectionView?.scrollToItem(at: insertionIndexPath, at: .bottom, animated: true)
            //clears the input text
            inputTextField.text = nil
            
        }catch let err {
            print(err)
        }
        
    }
    
    var bottomConstraint: NSLayoutConstraint?
    
    func simulate()  {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.managedObjectContext
        
        let message = FriendsController.createMessageWithText("Here is a text a message that was sent some minutes ago", friend: friend!, minutesAgo: 2, context: context)
        
        
        //because context.save throws an error we have to use: "do, try, catch"
        do{
            try context.save()
            
            messages?.append(message)
            
            messages = messages?.sorted(by: {$0.date!.compare($1.date! as Date) == .orderedAscending})
            
            if let item = messages?.index(of: message){
                
                let receivingIndexPath = IndexPath(item: item, section: 0)
                collectionView?.insertItems(at: [receivingIndexPath])
            }
            
            
        }catch let err {
            print(err)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //creates the "simulate" button on the UIBar. simulate is the function above that this button will call
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Simulate", style: .plain, target: self, action: #selector(simulate))
        
        //hides the tabBarController everytime we open this view
        tabBarController?.tabBar.isHidden = true
        
        collectionView?.backgroundColor = UIColor.white
        
        collectionView?.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        
        //adding the bottom bar (input text and send button) to the containerView hierarchy
        view.addSubview(messageInputContainerView)
        view.addConstraintsWithFormat("H:|[v0]|", views: messageInputContainerView) //expands horizontally
        view.addConstraintsWithFormat("V:[v0(48)]", views: messageInputContainerView) // we give a height of 48px
        
        
        //creating the bottomConstraint for our bottomBar (messageInputContainerView)
        bottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!) //adds the bottomConstraint and pins the messageInputContainerView to the bottom of the view
        
        setupInputComponents()
        
        
        //handles the keyboard events
        //when it is shown
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //when it hides
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    
    // this function is called to handle the keyboard events
    func handleKeyboardNotification(_ notification: Notification) {
        
        if let userInfo = notification.userInfo {
            
            //gets the frame for the location of our keyboard
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            print(keyboardFrame)
            
            
            //i it is showing the this will be true
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            
            
            //changing the constant of the bottomConstraint to move the screen upwards 
            //if the keyboard is showing then it will move it up, otherwise it will be zero (and stay on the bottom)
            bottomConstraint?.constant = isKeyboardShowing ? -keyboardFrame!.height : 0
            
            
            //this code animates the messageInputContainerView (our bottom bar) t
            //this way, we avoid our bottom bar from just appearing on its final position
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                
                self.view.layoutIfNeeded()
                
                }, completion: { (completed) in
                    //runs after the completion of the keyboard animation
                    if isKeyboardShowing {
                        
                        //getting the last item of our collectionView in the chat log
                        let indexPath = IndexPath(item: self.messages!.count - 1, section: 0)
                        
                        //scrolls down to that item ˆ
                        self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                    }
                    
            })
        }
    }
    
    
    //dismisses the keyboard when we touch something outside the keyboard
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        inputTextField.endEditing(true)
    }
    
    fileprivate func setupInputComponents(){
        
        // creating the top border for our bottom bar
        let topBorderView = UIView()
        topBorderView.backgroundColor = UIColor(white: 0.5, alpha: 0.5) //gray line
        
        //addinf the inputTextField, sendButton and topBorderView to our bottomBar (messageInputContainerView)
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        messageInputContainerView.addSubview(topBorderView)
        
        //moves the inputTextField 8px to the left and makes the sendButton take 60 horizontal pixels
        messageInputContainerView.addConstraintsWithFormat("H:|-8-[v0][v1(60)]|", views: inputTextField, sendButton)
        messageInputContainerView.addConstraintsWithFormat("V:|[v0]|", views: inputTextField) //takes whole space vertically
        messageInputContainerView.addConstraintsWithFormat("V:|[v0]|", views: sendButton)  //takes whole space vertically
        
        //expands horizontally from left to right
        messageInputContainerView.addConstraintsWithFormat("H:|[v0]|", views: topBorderView)
        //pinning the border to the top and giving it a height of .5 pixels
        messageInputContainerView.addConstraintsWithFormat("V:|[v0(0.5)]", views: topBorderView)
    }
    
    
    //returns the numbers of cells (messages in this case) that this collecion has
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = messages?.count{
            return count
        }
        return 0
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogMessageCell
        
        //gets the correct message from the array and presents it to this cell
        cell.messageTextView.text = messages?[indexPath.item].text
        
        //unwraps the message and the profileImage for this message 
        if let message = messages?[indexPath.item], let messageText = message.text, let profileImageName = message.friend?.profileImageName {
            
            cell.profileImageView.image = UIImage(named: profileImageName)
            
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
            
            if message.isSender == nil || !message.isSender!.boolValue {
                
                //48 moves the text bubble to the right (X = horizontally
                cell.messageTextView.frame = CGRect(x: 48 + 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                
                cell.textBubbleView.frame = CGRect(x: 48 - 10 , y: -4 , width: estimatedFrame.width + 16 + 8 + 16, height: estimatedFrame.height + 20 + 6 )
                
                cell.profileImageView.isHidden = false
                
            //    cell.textBubbleView.backgroundColor = UIColor(white: 0.95, alpha: 1)
                cell.bubbleImageView.image = ChatLogMessageCell.grayBubbleImage
                //changes the outgoing message bubble background color to blue (We use tint because it is an image)
                cell.bubbleImageView.tintColor = UIColor(white: 0.95, alpha: 1)
                cell.messageTextView.textColor = UIColor.black
        

            }else{
                
                //outgoing or sending message
                
                cell.messageTextView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 16 - 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                
                cell.textBubbleView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 8 - 16 - 10 , y: -4 , width: estimatedFrame.width + 16 + 8 + 10, height: estimatedFrame.height + 20 + 6)
                
                cell.profileImageView.isHidden = true
                
             //   cell.textBubbleView.backgroundColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
                cell.bubbleImageView.image = ChatLogMessageCell.blueBubbleImage
                //changes the outgoing message bubble background color to blue (We use tint because it is an image)
                cell.bubbleImageView.tintColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
                // changes the outgoing message bubble text to white
                cell.messageTextView.textColor = UIColor.white
                
                
            }
        

        }
        
        return cell
    }
    
    //modifies each cell in this collectionView (in this case it will be each chat bubble)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let messageText = messages?[indexPath.item].text {
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)], context: nil)
            
            return CGSize(width: view.frame.width, height: estimatedFrame.height + 20)
        }
        
        return CGSize(width: view.frame.width, height: 100)
    }
    
    
    //gives padding to the collection view (in this case just to the top to avoid the first message from 
    //hugging the top
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 0, 0, 0)
    }
}

class ChatLogMessageCell: BaseCell {
    
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.text = "texto lorem ipsum"
        textView.backgroundColor = UIColor.clear
        return textView
    }()
    
    let textBubbleView: UIView = {
        let view = UIView()
     //   view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    static let grayBubbleImage = UIImage(named: "bubble_gray")!.resizableImage(withCapInsets: UIEdgeInsetsMake(22, 26, 22, 26)).withRenderingMode(.alwaysTemplate)
    static let blueBubbleImage = UIImage(named: "bubble_blue")!.resizableImage(withCapInsets: UIEdgeInsetsMake(22, 26, 22, 26)).withRenderingMode(.alwaysTemplate)
    
    let bubbleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ChatLogMessageCell.grayBubbleImage
        imageView.tintColor = UIColor(white: 0.90, alpha: 1)
        return imageView
    }()
    
    override func setupViews() {
        super.setupViews()
        
        //addSubview adds the parameter view to the hierarchy
        addSubview(textBubbleView)
        addSubview(messageTextView)
        addSubview(profileImageView)
        addConstraintsWithFormat("H:|-8-[v0(30)]|", views: profileImageView)
        addConstraintsWithFormat("V:[v0(30)]|", views: profileImageView)
        profileImageView.backgroundColor = UIColor.red
        
        textBubbleView.addSubview(bubbleImageView)
        textBubbleView.addConstraintsWithFormat("H:|[v0]|", views: bubbleImageView)
        textBubbleView.addConstraintsWithFormat("V:|[v0]|", views: bubbleImageView)

        
    }
}
