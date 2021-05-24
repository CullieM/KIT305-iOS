//
//  MovieUITableViewCell.swift
//  assignment3
//
//  Created by Cullie McElduff on 16/5/21.
//

import UIKit

class MovieUITableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subTitleLabel: UILabel!
    @IBOutlet var overallLabel: UILabel!
    @IBOutlet var overallWeekLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var markLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
