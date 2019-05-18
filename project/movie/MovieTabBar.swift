//
//  MovieTabBar.swift
//  project
//
//  Created by mac on 26/04/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class MovieTabBar: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let tab = tabBar.items!.index(of: item)
        
        if tab == 0 {
            Global.apiurl = "https://api.themoviedb.org/3/movie/now_playing?api_key=10944034094887ff57310692a5c0d8b5&page="
            Global.title = "Now Playing"
        }
        else if tab == 1 {
            Global.apiurl = "https://api.themoviedb.org/3/movie/upcoming?api_key=10944034094887ff57310692a5c0d8b5&page="
            Global.title = "Upcoming"
        }
        else {
            Global.apiurl = "https://api.themoviedb.org/3/discover/movie?sort_by=popularity.desc&api_key=10944034094887ff57310692a5c0d8b5&page="
            Global.title = "Popular"
        }
    }
}
