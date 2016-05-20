//
//  RSImageTableCell.swift
//  RSImageCrawler
//
//  Created by shenzw on 4/19/16.
//  Copyright © 2016 shenzw. All rights reserved.
//

import UIKit

class RSImageTableCell: UITableViewCell {

    @IBOutlet weak var centerImageView: UIImageView!
    @IBOutlet weak var downButton: UIButton!
    var originUrl:String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
