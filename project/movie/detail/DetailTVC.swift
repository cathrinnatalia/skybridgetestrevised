//
//  DetailTVC.swift
//  project
//
//  Created by mac on 25/04/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import SwiftyJSON
import YouTubePlayer

class DetailTVC: UITableViewController {
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var voteLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var releaseLabel: UILabel!
    @IBOutlet weak var oriLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    
    @IBOutlet weak var genreCollection: UICollectionView!
    @IBOutlet weak var castCollection: UICollectionView!
    @IBOutlet weak var trailerCollection: UICollectionView!
    
    var moviedetail = Movie()
    var cast = [Cast]()
    var trailers = [String]()
    
    var url = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = moviedetail.title
        
        genreCollection.delegate = self
        genreCollection.dataSource = self
        
        castCollection.delegate = self
        castCollection.dataSource = self
        
        trailerCollection.delegate = self
        trailerCollection.dataSource = self
        
        display()
        getCast()
        getDetail()
        getYoutube()
        
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            if trailers.count == 0 && moviedetail.backdrop_path == "" {
                return 0
            }
            else {
                return 220
            }
        }
        else if indexPath.row == 2 {
            if moviedetail.genre_ids.count == 0 {
                return 0
            }
        }
        else if indexPath.row == 3 {
            if moviedetail.overview == "" {
                return 0
            }
        }
        else if indexPath.row == 4 {
            if cast.count == 0 {
                return 0
            }
        }
        return UITableView.automaticDimension
    }
    
    func display(){
        let poster = URL(string: Global.imagepath + moviedetail.poster_path)
        posterImage.sd_setImage(with: poster, placeholderImage: UIImage(named: "default.png"))
        posterImage.clipsToBounds = true
        
        scoreLabel.text = "Score: \(moviedetail.vote_average)/10"
        durationLabel.text = ""
        releaseLabel.text = moviedetail.release_date
        oriLabel.text = moviedetail.original_language
        
        if moviedetail.vote_count > 1 {
            voteLabel.text = "\(moviedetail.vote_count) votes"
        }
        else {
            voteLabel.text = "\(moviedetail.vote_count) vote"
        }
        
        synopsisLabel.text = moviedetail.overview
    }
    
    func getGenreTitle(id: Int) -> String {
        let index = Global.genreid.firstIndex(of: id)
   
        if index != nil {
            return Global.genretitle[index!]
        }
        else {
            return "Others"
        }
    }
    
    func getCast(){
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(moviedetail.id)/casts?api_key=10944034094887ff57310692a5c0d8b5") else {
            return
        }
        
        Alamofire.request(url, method: .get).responseJSON { response in
            if response.result.isSuccess {
//                print(response.result.value!)
                _ = self.getDataCast(json: JSON(response.result.value!))
                self.view.stopactindicator()
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.castCollection?.reloadData()
                }
            }
            else {
                self.presentAlert(withTitle: "Oops! Something went wrong. Please try again later.", message: "")
                self.view.stopactindicator()
                print("movie error: ", response.result.error!)
            }
        }
    }
    
    func getDataCast(json: JSON) -> [Cast] {
        let getdata = json["cast"]
        
        if getdata.count > 0 {
            for index in 0 ... getdata.count - 1 {
                let data = Cast()
                
                data.cast_id = getdata[index]["cast_id"].intValue
                data.character = getdata[index]["character"].stringValue
                data.credit_id = getdata[index]["credit_id"].stringValue
                data.gender = getdata[index]["gender"].intValue
                data.id = getdata[index]["id"].intValue
                data.name = getdata[index]["name"].stringValue
                data.order = getdata[index]["order"].intValue
                data.profile_path = getdata[index]["profile_path"].stringValue
                
                cast.append(data)
            }
        }
        else {
            print("no data cast")
        }
        
        return cast
    }
    
    func getDetail(){
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(moviedetail.id)?api_key=10944034094887ff57310692a5c0d8b5") else {
            return
        }
        
        Alamofire.request(url, method: .get).responseJSON { response in
            if response.result.isSuccess {
//                print(response.result.value!)
                let runtime = self.getDuration(json: JSON(response.result.value!))
                
                self.durationLabel.text = "\(runtime) minutes"
            }
            else {
                self.presentAlert(withTitle: "Oops! Something went wrong. Please try again later.", message: "")
                self.view.stopactindicator()
                print("movie error: ", response.result.error!)
            }
        }
    }
    
    func getDuration(json: JSON) -> Int {
        return json["runtime"].intValue
    }
    
    func getYoutube(){
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(moviedetail.id)/videos?api_key=10944034094887ff57310692a5c0d8b5") else {
            return
        }
        
        Alamofire.request(url, method: .get).responseJSON { response in
            if response.result.isSuccess {
//                print(response.result.value!)
                _ = self.getLink(json: JSON(response.result.value!))
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.trailerCollection.reloadData()
                }
            }
            else {
                self.presentAlert(withTitle: "Oops! Something went wrong. Please try again later.", message: "")
                self.view.stopactindicator()
                print("movie error: ", response.result.error!)
            }
        }
    }
    
    func getLink(json: JSON) {
        let getData = json["results"]
        
        if getData.count > 0 {
            for index in 0 ... getData.count - 1 {
                trailers.append(getData[index]["key"].stringValue)
            }
        }
        else {
            url = Global.imagepath + moviedetail.backdrop_path
            print("no data trailers", moviedetail.backdrop_path)
        }
    }
}

extension DetailTVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == genreCollection {
            return moviedetail.genre_ids.count
        }
        if collectionView == trailerCollection {
            if trailers.count > 0 {
                return trailers.count
            }
            else {
                return 1
            }
        }
        else {
            if cast.count > 5 {
                return 5
            }
            else {
                return cast.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == genreCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! GenreCell
            
            cell.genreLabel.text = getGenreTitle(id: moviedetail.genre_ids[indexPath.row])
            cell.layer.cornerRadius = 10
            
            return cell
        }
        if collectionView == trailerCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! TrailerCell
            
            if trailers.count > 0 {
                cell.youtubeImage.isHidden = true
                cell.playerView.isHidden = false
                
                cell.playerView.loadVideoID(trailers[indexPath.row])
                
                if trailers.count == 1 {
                    trailerCollection.isScrollEnabled = false
                }
                else {
                    trailerCollection.isScrollEnabled = true
                }
            }
            else {
                cell.playerView.isHidden = true
                cell.youtubeImage.isHidden = false
                
                let yutup = URL(string: url)
                cell.youtubeImage.sd_setImage(with: yutup)
                cell.youtubeImage.clipsToBounds = true

                trailerCollection.isScrollEnabled = false
            }
            
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CastCell
            
            cell.nameLabel.text = cast[indexPath.row].name
            cell.characterLabel.text = cast[indexPath.row].character
            
            let pic = URL(string: Global.imagepath + cast[indexPath.row].profile_path)
            cell.avatar.sd_setImage(with: pic, placeholderImage: UIImage(named: "default.png"))
            cell.avatar.clipsToBounds = true
            cell.avatar.layer.cornerRadius = 10
            
            cell.layer.cornerRadius = 10
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == genreCollection {
            return CGSize(width: 128, height: 45)
        }
        if collectionView == trailerCollection {
            return CGSize(width: self.view.frame.size.width - 20, height: 195)
        }
        else {
            return CGSize(width: 150, height: 245)
        }
    }
    
}
