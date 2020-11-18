//
//  FileManagerExtension.swift
//  HotProspects
//
//  Created by Chloe Fermanis on 3/10/20.
//  Copyright © 2020 Chloe Fermanis. All rights reserved.
//

import UIKit

extension FileManager {
    
    func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
