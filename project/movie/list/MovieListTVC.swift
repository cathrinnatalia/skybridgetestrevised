//
//  MovieListTVC.swift
//  project
//
//  Created by mac on 25/04/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class MovieListTVC: UITableViewController {
    
    var movie = [Movie]()
    
    var totalpage = 0
    var nextpage = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = Global.title
        
        view.startactindicator()
        getMovie(page: 1)
        
        if Global.genreid.count == 0 {
            getGenre()
        }
        
        refreshControl?.addTarget(self, action: #selector(refreshaction(sender:)), for: .valueChanged)
        
        tableView.tableFooterView = UIView()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movie.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MovieListCell

        let pic = URL(string: Global.imagepath + movie[indexPath.row].poster_path)
        cell.poster.sd_setImage(with: pic, placeholderImage: UIImage(named: "default.png"))
        cell.poster.clipsToBounds = true
        
        cell.titleLabel.text = movie[indexPath.row].title
        cell.dateLabel.text = movie[indexPath.row].release_date
        cell.scoreLabel.text = "Score: \(movie[indexPath.row].vote_average)/10"
        
        if movie[indexPath.row].vote_count > 1 {
            cell.voteLabel.text = "\(movie[indexPath.row].vote_count) votes"
        }
        else {
            cell.voteLabel.text = "\(movie[indexPath.row].vote_count) vote"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastelement = movie.count
        
        if indexPath.row == lastelement - 1 {
            if nextpage <= totalpage {
                Global.spinner.startAnimating()
                Global.spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
                
                self.tableView.tableFooterView = Global.spinner
                self.tableView.tableFooterView?.isHidden = false
                
                getMovie(page: nextpage)
                nextpage = nextpage + 1
            }
            else {
                Global.spinner.stopAnimating()
                presentAlert(withTitle: "No more data!", message: "")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let destination = storyBoard.instantiateViewController(withIdentifier: "detail") as! DetailTVC
        
        destination.moviedetail = movie[indexPath.row]
        
        navigationController?.pushViewController(destination, animated: true)
    }
    
    @objc func refreshaction(sender:AnyObject) {
        movie.removeAll()
        getMovie(page: 1)
       
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    func getMovie(page: Int){
        guard let url = URL(string: Global.apiurl + "\(page)") else {
            return
        }
        
        Alamofire.request(url, method: .post).responseJSON { response in
            if response.result.isSuccess {
//                print(response.result.value!)
                _ = self.getDataMovie(json: JSON(response.result.value!))
                self.view.stopactindicator()
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            else {
                self.presentAlert(withTitle: "Oops! Something went wrong. Please try again later.", message: "")
                self.view.stopactindicator()
                print("movie error: ", response.result.error!)
            }
        }
    }
    
    func getDataMovie(json: JSON) -> [Movie] {
        let getdata = json["results"]
        totalpage = json["total_pages"].intValue
        
        if getdata.count > 0 {
            for index in 0 ... getdata.count - 1 {
                let data = Movie()
                
                data.vote_count = getdata[index]["vote_count"].intValue
                data.id = getdata[index]["id"].intValue
                data.video = getdata[index]["video"].boolValue
                data.vote_average = getdata[index]["vote_average"].doubleValue
                data.title = getdata[index]["title"].stringValue
                data.popularity = getdata[index]["popularity"].doubleValue
                data.poster_path = getdata[index]["poster_path"].stringValue
                data.original_language = getdata[index]["original_language"].stringValue
                data.original_title = getdata[index]["original_title"].stringValue
                
                let genres = getdata[index]["genre_ids"]
                if genres.count > 0 {
                    for i in 0 ... genres.count - 1 {
                        data.genre_ids.append(genres[i].intValue)
                    }
                }
                
                data.backdrop_path = getdata[index]["backdrop_path"].stringValue
                data.adult = getdata[index]["adult"].boolValue
                data.overview = getdata[index]["overview"].stringValue
                data.release_date = getdata[index]["release_date"].stringValue
                
                movie.append(data)
            }
        }
        else {
            print("no data movie")
        }
        
        return movie
    }
    
    func getGenre(){
        guard let url = URL(string: "https://api.themoviedb.org/3/genre/movie/list?api_key=10944034094887ff57310692a5c0d8b5&language=en-US") else {
            return
        }
        
        Alamofire.request(url, method: .get).responseJSON { response in
            if response.result.isSuccess {
//                print(response.result.value!)
                _ = self.getDataGenre(json: JSON(response.result.value!))
                self.view.stopactindicator()
            }
            else {
                self.presentAlert(withTitle: "Oops! Something went wrong. Please try again later.", message: "")
                self.view.stopactindicator()
                print("genre error:", response.result.error!)
            }
        }
    }
    
    func getDataGenre(json: JSON) {
        let getdata = json["genres"]
        
        if getdata.count > 0 {
            for index in 0 ... getdata.count - 1 {
                Global.genreid.append(getdata[index]["id"].intValue)
                Global.genretitle.append(getdata[index]["name"].stringValue)
            }
        }
        else {
            print("no data genre")
        }
    }
}

