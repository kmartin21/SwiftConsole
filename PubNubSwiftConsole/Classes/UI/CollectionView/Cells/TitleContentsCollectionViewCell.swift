//
//  TitleContentsCollectionViewCell.swift
//  Pods
//
//  Created by Jordan Zucker on 10/6/16.
//
//

import UIKit

protocol TitleContents: Title {
    var contents: String? { get }
    func updatedTitleContentsItem(with contents: String?) -> TitleContents
}

extension TitleContents {
    func updatedTitleContentsItem(with contents: String?) -> TitleContents {
        guard let actualContents = contents else {
            return TitleContentsItem(title: title, contents: nil, isTappable: isTappable, overrideDefaultBackgroundColor: overrideDefaultBackgroundColor)
        }
        return TitleContentsItem(title: title, contents: actualContents, isTappable: isTappable, overrideDefaultBackgroundColor: overrideDefaultBackgroundColor)
    }
}

struct TitleContentsItem: TitleContents {
    var title: String
    var contents: String?
    var isTappable: Bool = false
    var overrideDefaultBackgroundColor: UIColor?
}

class TitleContentsCollectionViewCell: TitleCollectionViewCell {
    
    private let contentsLabel: UILabel
    
    override init(frame: CGRect) {
        self.contentsLabel = UILabel(frame: .zero)
        super.init(frame: frame)
        contentsLabel.textAlignment = .center
        stackView.addArrangedSubview(contentsLabel)
        contentView.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(contents: String?) {
        contentsLabel.text = contents
        contentView.setNeedsLayout()
    }
    
    func update(titleContents: TitleContents?) {
        super.update(title: titleContents)
        titleLabel.textColor = .gray
        if isTappable {
            contentsLabel.textColor = .black
        } else {
            contentsLabel.textColor = .gray
        }
        update(contents: titleContents?.contents)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentsLabel.text = nil
        contentsLabel.textColor = .black
        titleLabel.textColor = .black
    }
    
    /*
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        let bounds = UIScreen.main.bounds
        return attributes
    }
 */
    
    class override var size: CGSize {
        return CGSize(width: 75.0, height: 75.0)
    }
    
    class override func size(collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: 75.0, height: 75.0)
    }
    
}
