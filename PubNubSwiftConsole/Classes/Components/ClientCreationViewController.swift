//
//  ClientCreationViewController.swift
//  Pods
//
//  Created by Jordan Zucker on 7/18/16.
//
//

import Foundation
import PubNub

enum PubNubConfigurationCreationError: ErrorType, CustomStringConvertible {
    case NilValue(propertyName: String)
    case EmptyStringValue(propertyName: String)
    case OriginInvalid
    var description: String {
        switch self {
        case let .NilValue(name):
            return "Value for " + name + " property is nil"
        case let .EmptyStringValue(name):
            return "Value for " + name + " property is empty"
        case .OriginInvalid:
            return "Origin is invalid, it should be pubsub.pubnub.com or something specially provided"
        }
    }
}

extension UIAlertController {
    static func alertControllerForPubNubConfigurationCreationError(error: PubNubConfigurationCreationError, handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let title = "Cannot create client with configuration"
        let message = error.description
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: handler))
        return alertController
    }
}

extension PNConfiguration {
    enum Property: String {
        case SubscribeKey = "Subscribe Key"
        case PublishKey = "Publish Key"
        case Origin
    }
    typealias KeyValue = (name: Property, value: String?)
    // TODO: clean this up
    convenience init(properties: KeyValue...) throws {
        var pubKey: KeyValue = (.PublishKey, nil)
        var subKey: KeyValue = (.SubscribeKey, nil)
        var otherProperties = [KeyValue]()
        for var pair in properties {
            guard let value = pair.value else {
                throw PubNubConfigurationCreationError.NilValue(propertyName: pair.name.rawValue)
            }
            guard value.characters.count > 0 else {
                throw PubNubConfigurationCreationError.EmptyStringValue(propertyName: pair.name.rawValue)
            }
            switch pair.name {
            case .SubscribeKey:
                subKey.value = value
            case .PublishKey:
                pubKey.value = value
            case .Origin:
                guard value.hasSuffix(".com") else {
                    throw PubNubConfigurationCreationError.OriginInvalid
                }
                pair.value = value
                otherProperties.append(pair)
            }
        }
        guard let finalPubKey = pubKey.value else {
            throw PubNubConfigurationCreationError.NilValue(propertyName: Property.PublishKey.rawValue)
        }
        guard let finalSubKey = subKey.value else {
            throw PubNubConfigurationCreationError.NilValue(propertyName: Property.SubscribeKey.rawValue)
        }
        self.init(publishKey: finalPubKey, subscribeKey: finalSubKey)
        for otherPropertyPair in otherProperties {
            switch otherPropertyPair.name {
            case .Origin:
                self.origin = otherPropertyPair.value!
            default:
                continue
            }
        }
    }
}

public class ClientCreationViewController: CollectionViewController, CollectionViewControllerDelegate {
    // MARK: - DataSource
    
    struct ClientCreationLabelItem: LabelItem {
        init(itemType: ClientCreationItemType) {
            self.init(itemType: itemType, contentsString: itemType.defaultValue)
        }
        
        init(itemType: ClientCreationItemType, contentsString: String) {
            self.itemType = itemType
            self.contents = contentsString
        }
        
        let itemType: ItemType
        var contents: String
        var reuseIdentifier: String {
            return LabelCollectionViewCell.reuseIdentifier
        }
        
    }
    
    struct ClientCreationButtonItem: ButtonItem {
        let itemType: ItemType
        init(itemType: ClientCreationItemType, selected: Bool, targetSelector: TargetSelector) {
            self.itemType = itemType
            self.selected = selected
            self.targetSelector = targetSelector
        }
        init(itemType: ClientCreationItemType, targetSelector: TargetSelector) {
            self.init(itemType: itemType, selected: false, targetSelector: targetSelector)
        }
        var selected: Bool = false
        var targetSelector: TargetSelector
        
        var reuseIdentifier: String {
            return ButtonCollectionViewCell.reuseIdentifier
        }
        
        
    }
    
    enum ClientCreationSectionType: Int, ItemSectionType {
        case ConfigurationLabels = 0
        case ClientCreationButton = 1
    }
    
    enum ClientCreationItemType: ItemType {
        case PublishKey
        case SubscribeKey
        case Origin
        case ClientCreationButton
        
        func size(collectionViewSize: CGSize) -> CGSize {
            switch self {
            case .PublishKey, .SubscribeKey, .Origin:
                return CGSize(width: 200.0, height: 150.0)
            case .ClientCreationButton:
                return CGSize(width: 250.0, height: 100.0)
            }
        }
        
        var selectedTitle: String? {
            return nil
        }
        
        var title: String {
            switch self {
            case .PublishKey:
                return "Publish Key"
            case .SubscribeKey:
                return "Subscribe Key"
            case .Origin:
                return "Origin"
            case .ClientCreationButton:
                return "Create Client"
            }
        }
        
        var sectionType: ItemSectionType {
            switch self {
            case .PublishKey, .SubscribeKey, .Origin:
                return ClientCreationSectionType.ConfigurationLabels
            case .ClientCreationButton:
                return ClientCreationSectionType.ClientCreationButton
            }
        }
        
        var defaultValue: String {
            switch self {
            case .PublishKey, .SubscribeKey:
                return "demo-36"
            case .Origin:
                return "pubsub.pubnub.com"
            default:
                return ""
            }
        }
        
        var item: Int {
            switch self {
            case .PublishKey:
                return 0
            case .SubscribeKey:
                return 1
            case .Origin:
                return 2
            case .ClientCreationButton:
                return 0
            }
        }
    }
    
    // MARK: - View Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        let creationButtonItem = ClientCreationButtonItem(itemType: .ClientCreationButton, targetSelector: (self, #selector(self.clientCreationButtonPressed(_:))))
        let creationSection = BasicDataSource.BasicSection(items: [creationButtonItem])
        let configSection = BasicDataSource.BasicSection(items: [ClientCreationLabelItem(itemType: .PublishKey), ClientCreationLabelItem(itemType: .SubscribeKey), ClientCreationLabelItem(itemType: .Origin)])
        let clientCreationDataSource = BasicDataSource(sections: [configSection, creationSection])
        self.dataSource = clientCreationDataSource
        guard let collectionView = self.collectionView else { fatalError("We expected to have a collection view by now. Please contact support@pubnub.com") }
        collectionView.registerClass(LabelCollectionViewCell.self, forCellWithReuseIdentifier: LabelCollectionViewCell.reuseIdentifier)
        collectionView.registerClass(ButtonCollectionViewCell.self, forCellWithReuseIdentifier: ButtonCollectionViewCell.reuseIdentifier)
        collectionView.reloadData() // probably a good idea to reload data after all we just did
    }
    
    // MARK: - Actions
    
    func clientCreationButtonPressed(sender: UIButton!) {
        guard let client = createPubNubClient() else {
            return
        }
        let consoleViewController = ConsoleViewController(client: client)
        self.navigationController?.pushViewController(consoleViewController, animated: true)
    }
    
    func createPubNubClient() -> PubNub? {

        func stringForItem(itemType: ClientCreationItemType) -> String {
            guard let item = dataSource?[itemType.indexPath] as? ClientCreationLabelItem where item.title == itemType.title else {
                fatalError("oops, dataSourceIndex is probably out of whack")
            }
            return item.contents
        }

        let pubKey = stringForItem(.PublishKey)
        let pubKeyProperty = PNConfiguration.KeyValue(.PublishKey, pubKey)
        let subKey = stringForItem(.SubscribeKey)
        let subKeyProperty = PNConfiguration.KeyValue(.SubscribeKey, subKey)
        let origin = stringForItem(.Origin)
        let originProperty = PNConfiguration.KeyValue(.Origin, origin)
        do {
            let config = try PNConfiguration(properties: pubKeyProperty, subKeyProperty, originProperty)
            return PubNub.clientWithConfiguration(config)
        } catch let pubNubError as PubNubConfigurationCreationError {
            let alertController = UIAlertController.alertControllerForPubNubConfigurationCreationError(pubNubError, handler: nil)
            presentViewController(alertController, animated: true, completion: nil)
            return nil
        } catch {
            fatalError("\(error)")
        }
    }
    
    // MARK: - UINavigationItem
    
    public override var navBarTitle: String {
        return "PubNub Client Creation"
    }
}
