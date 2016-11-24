//
//  ViewController.swift
//  myMessenger
//
//  Created by Jesus Adolfo on 08/04/16.
//  Copyright © 2016 Jesus Adolfo. All rights reserved.
//

import UIKit

//UICollectionViewDelegateFlowLayout is called to change the width of a cell

class FriendsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    fileprivate let cellId = "cellId"
    
    var messages: [Message]?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = false 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //adds title to to this controller
        navigationItem.title = "Recent"
        
        collectionView?.backgroundColor = UIColor.white
        
        //allows vertical horizontal (drag up and down)
        collectionView?.alwaysBounceVertical = true
        
        //register the variable cellId as our cell for this collection view (a row inside our friends list)
        collectionView?.register(MessageCell.self , forCellWithReuseIdentifier: cellId)
        
        setupData()
    }
    
    
    // returns the number of rows in a collectionView
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = messages?.count {
            return count
        }
        return 0
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MessageCell
        
        if let message = messages?[indexPath.item]{
            cell.message = message
        }
        
        return cell
    }
    
    
    //method from UICollectionViewDelegateFlowLayout that changes the width and height of each cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
    
    
    //method to move to the following view once a row has been clicked 
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let layout = UICollectionViewFlowLayout()
        let controller = ChatLogController(collectionViewLayout: layout)
        controller.friend = messages?[indexPath.row].friend
        navigationController?.pushViewController(controller, animated: true)
    }

}



// Inherits from our BaseCell Class that we created down below
class MessageCell: BaseCell{
    
    override var isHighlighted: Bool{
        didSet {
            backgroundColor = isHighlighted ? UIColor(red: 0, green: 134/255, blue: 249/255, alpha: 1) : UIColor.white
            nameLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            timeLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            messageLabel.textColor = isHighlighted ? UIColor.white : UIColor.black

        }
    }
    
    var message: Message? {
        didSet {
            nameLabel.text = message?.friend?.name
            
            if let profileImageName = message?.friend?.profileImageName {
                profileImageView.image = UIImage(named: profileImageName)
                hasReadImageView.image = UIImage(named: profileImageName)
            }
            
            messageLabel.text = message?.text
            
            if let date = message?.date {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mm a"
                
                let elapsedTimeInSeconds = Date().timeIntervalSince(date as Date)
                
                let secondInDays: TimeInterval = 60 * 60 * 24
                
                if elapsedTimeInSeconds > 7 * secondInDays {
                    dateFormatter.dateFormat = "MM/dd/yy"
                } else if elapsedTimeInSeconds > secondInDays {
                    dateFormatter.dateFormat = "EEE"
                }
                
                timeLabel.text = dateFormatter.string(from: date as Date)
            }
        }
    }
    
    
    //Creating the imageView for the profile picture on the table
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 34 // 50% of the image size will make round the edges to a circle
        imageView.layer.masksToBounds = true // to make sure it is round
        return imageView
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "My friends name"
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "The message from my friend and this is like making it longer to test..."
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "4:02 pm"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .right //aligns the timeLabel to the right
        return label
    }()
    
    let hasReadImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10 // to make the image round
        imageView.layer.masksToBounds = true // to make sure it is round
        return imageView
    }()
    
    override func setupViews() {
        
        //add addSubview adds element to the under the current MessageCell
        addSubview(profileImageView)
        addSubview(dividerLineView)
        
        setupContainerView()
        
        //References the image name of our assets catalog
        profileImageView.image = UIImage(named: "maduro") //big profile image
        hasReadImageView.image = UIImage(named: "chaplin") //small image to indicate the message has been seen 
        
        //from the top we add a margin of 12 and the image width is 68
        addConstraintsWithFormat("H:|-12-[v0(68)]", views: profileImageView)
        //making the image height equals to 68
        addConstraintsWithFormat("V:[v0(68)]", views: profileImageView)
        
        //centering the profileImageView to the center of its parent
        addConstraint(NSLayoutConstraint(item: profileImageView, attribute: .centerY, relatedBy: .equal , toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        
        //82 pixels from the top to where the element starts
        addConstraintsWithFormat("H:|-82-[v0]|", views: dividerLineView)
        //we give the divider the height equals to 1px and leave the trailing pipe | to indicate it should stay on the bottom
        addConstraintsWithFormat("V:[v0(1)]|", views: dividerLineView)
    }
    
    
    // contains the right part of the cell (with the name, text preview and time
    fileprivate func setupContainerView(){
        let containerView = UIView()
        addSubview(containerView) //adds this view to the hierarchy
        
        //moves this view 90 pixels away from the left
        addConstraintsWithFormat("H:|-90-[v0]|", views: containerView)
        //makes the containerView 50px tall
        addConstraintsWithFormat("V:[v0(50)]", views: containerView)
        
        //centering the containerView to the center of its parent
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal , toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(hasReadImageView)
        
        
        //v0 (nameLabel) attached to the left margin
        //v1 timeLabel has 80 horizontal pixels and 12 pixels of margin the right (so it is not hugging the screen)
        containerView.addConstraintsWithFormat("H:|[v0][v1(80)]-12-|", views: nameLabel, timeLabel)
        
        //v0 represents the nameLabel and v1 represents the messageLabel width
        //v1 has 24 vertical pixels
        containerView.addConstraintsWithFormat("V:|[v0][v1(24)]|", views: nameLabel, messageLabel)
        
        
        //v0 (messageLabel) has 8 pixels to the right and v1 (hasReadImageView) has 20 horizontal pixels and 12 pixels of margin to te right
        containerView.addConstraintsWithFormat("H:|[v0]-8-[v1(20)]-12-|", views: messageLabel, hasReadImageView)
        
        
        
        containerView.addConstraintsWithFormat("V:|[v0(24)]", views: timeLabel)
        
        containerView.addConstraintsWithFormat("V:[v0(20)]|", views: hasReadImageView)
        
    }

}

//extension to addConstraints easier, which looks much cleaner
extension UIView {
    
    func addConstraintsWithFormat(_ format: String, views: UIView...) {
        
        var viewsDictionary = [String: UIView]()
        
        // we iterate through our views array
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
        
    }
}


//BaseCell Class that represents the base each of our Cells

class BaseCell: UICollectionViewCell{
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
    }
}
