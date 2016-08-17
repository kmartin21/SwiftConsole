//
//  MessageCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 8/2/16.
//
//

import UIKit
import PubNub

protocol MessageItem: ResultItem, SubscriberData {
    init(itemType: ItemType, pubNubResult result: PNMessageResult)
    var payload: Any? {get}
}

class Message: Result, MessageItem {
    let payload: Any?
    let actualChannel: String?
    let subscribedChannel: String?
    let timetoken: NSNumber
    
    required convenience init(itemType: ItemType, pubNubResult result: PNResult) {
        self.init(itemType: itemType, pubNubResult: result as! PNMessageResult)
    }
    
    required init(itemType: ItemType, pubNubResult result: PNMessageResult) {
        self.actualChannel = result.data.actualChannel
        self.subscribedChannel = result.data.subscribedChannel
        self.timetoken = result.data.timetoken
        self.payload = result.data.message
        super.init(itemType: itemType, pubNubResult: result as! PNResult)
    }
    
    override class func createResultItem(itemType: ItemType, pubNubResult result: PNResult) -> ResultItem {
        return Message(itemType: itemType, pubNubResult: result)
    }
    
    override var reuseIdentifier: String {
        return MessageCollectionViewCell.reuseIdentifier
    }
}

class MessageCollectionViewCell: ResultCollectionViewCell {

    let payloadLabel: UILabel
    let timetokenLabel: UILabel
    let actualChannelLabel: UILabel
    let subscribedChannelLabel: UILabel

    override init(frame: CGRect) {
        self.payloadLabel = UILabel(frame: .zero)
        self.timetokenLabel = UILabel(frame: .zero)
        self.actualChannelLabel = UILabel(frame: .zero)
        self.subscribedChannelLabel = UILabel(frame: .zero)
        super.init(frame: frame)
        contentView.addSubview(payloadLabel)
        payloadLabel.forceAutoLayout()
        contentView.addSubview(timetokenLabel)
        timetokenLabel.forceAutoLayout()
//        contentView.addSubview(actualChannelLabel)
//        actualChannelLabel.forceAutoLayout()
//        contentView .addSubview(subscribedChannelLabel)
//        subscribedChannelLabel.forceAutoLayout()
        setUpInitialConstraints()
        // FIXME: // let's get rid of borderWidth
        contentView.layer.borderWidth = 3
        contentView.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setUpInitialConstraints() {
        let views = [
            "operation": operationLabel,
            "creationDate": creationDateLabel,
            "statusCode": statusCodeLabel,
            "uuid": uuidLabel,
            "clientRequest": clientRequestLabel,
            "payload": payloadLabel,
            "timetoken": timetokenLabel,
            ]
        
        let metrics = [
            "payloadHeight": NSNumber(integerLiteral: 100),
            "labelHeight": NSNumber(integerLiteral: 30),
            "horizontalPadding": NSNumber(integerLiteral: 5),
            "verticalPadding": NSNumber(integerLiteral: 5),
            ]
        
        let messageConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-verticalPadding-[payload(100)]-verticalPadding-[timetoken(labelHeight)]-[operation(==timetoken)]-verticalPadding-[creationDate(==operation)]-verticalPadding-[statusCode(==operation)]-verticalPadding-[uuid(==operation)]-verticalPadding-[clientRequest(==operation)]", options: .alignAllCenterX, metrics: metrics, views: views)
        NSLayoutConstraint.activate(messageConstraints)
    }
    
    override func updateCell(item: Item) {
        super.updateCell(item: item)
        guard let messageItem = item as? MessageItem else {
            fatalError("wrong class")
        }
        payloadLabel.text = "Message: \(messageItem.payload ?? "Cannot display message")"
        timetokenLabel.text = "Timetoken: \(messageItem.timetoken)"
        if let actualChannel = messageItem.actualChannel {
            actualChannelLabel.text = "Actual channel: \(actualChannel)"
            actualChannelLabel.isHidden = false
        } else {
            actualChannelLabel.isHidden = true
        }
        if let subscribedChannel = messageItem.subscribedChannel {
            subscribedChannelLabel.text = "Subscribed channel: \(subscribedChannel)"
            subscribedChannelLabel.isHidden = false
        } else {
            subscribedChannelLabel.isHidden = true
        }
        contentView.setNeedsLayout()
    }
    
    class override func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: collectionViewSize.width, height: 300.0)
    }
}
