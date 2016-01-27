//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Luis Liz on 1/18/16.
//  Copyright © 2016 Luis Liz. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    var movies: [NSDictionary]?
    var endPoint: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        getMovies()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshMovies:", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        
        if let posterUrl = movie["poster_path"] as? String {
            let imageUrl = NSURL(string: baseUrl + posterUrl)
            cell.posterView.setImageWithURL(imageUrl!)
        }
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        return cell
    }
    
    func getMovies() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endPoint!)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true) //added
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            
                            self.movies = (responseDictionary["results"]as! [NSDictionary])
                            self.tableView.reloadData()
                    }
                }
        });
        task.resume()
    }
    
    func refreshMovies(refreshControl: UIRefreshControl) {
        getMovies()
        refreshControl.endRefreshing()
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailViewController

        detailViewController.movie = movie
        
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
