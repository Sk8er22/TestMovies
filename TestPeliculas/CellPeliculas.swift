//
//  CellPeliculas.swift
//  TestPeliculas
//
//  Created by PEDRO ARMANDO MANFREDI on 27/5/17.
//  Copyright © 2017 Pedro Manfredi. All rights reserved.
//

import UIKit

class CellPeliculas: UITableViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)        
        // Configure the view for the selected state
    }
    
}
