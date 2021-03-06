//
//  LooksViewButton.swift
//  Snapvideo
//
//  Created by Anastasia Petrova on 02/02/2020.
//  Copyright © 2020 Anastasia Petrova. All rights reserved.
//

import UIKit

final class LooksViewButton: UIButton {
    init(imageName: String) {
        super.init(frame: .zero)
        self.imageView?.contentMode = .scaleAspectFit
        self.setImage(UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.tintColor = .darkGray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
