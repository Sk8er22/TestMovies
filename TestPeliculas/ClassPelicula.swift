//
//  ClassPelicula.swift
//  TestPeliculas
//
//  Created by PEDRO ARMANDO MANFREDI on 27/5/17.
//  Copyright © 2017 Pedro Manfredi. All rights reserved.
//

import Foundation

class ClassPeliculas {
    
    let poster_path : String
    let overview : String
    let release_date : String
    let title : String
    
    init(dictionary : [String : AnyObject]) {
        poster_path = dictionary["poster_path"] as? String ?? ""
        overview = dictionary["overview"] as? String ?? ""
        release_date = dictionary["release_date"] as? String ?? ""
        title = dictionary["title"] as? String ?? ""
    }
}
