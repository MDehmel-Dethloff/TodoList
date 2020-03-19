//
//  TodoTableViewCell.swift
//  TodoList
//
//  Created by Marko Dehmel-Dethloff on 13.03.20.
//  Copyright © 2020 Marko Dehmel-Dethloff. All rights reserved.
//

import Foundation
import UIKit

protocol cellButtonDelegate {
    func checkTodoAction(at index: IndexPath, _ sender: UIButton)
}

class TodoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabelForCell: UILabel!
    @IBOutlet weak var imageForCell: UIImageView!
    @IBOutlet weak var checkmarkLabel: UIButton!
    
    var indexPath: IndexPath!
    var delegate: cellButtonDelegate!
    
        override func awakeFromNib() {
            super.awakeFromNib()
        }

        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)

        }
    
    @IBAction func checkButtonAction(_ sender: UIButton) {
        self.delegate?.checkTodoAction(at: indexPath, sender)
    }
    

}
