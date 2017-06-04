//
//  SmashTweetTableViewController.swift
//  Smashtag
//
//  Created by Michel Deiman on 26/03/2017.
//  Copyright © 2017 Michel Deiman. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class SmashTweetTableViewController: TweetTableViewController
{
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    override func insertTweets(_ newTweets: [Twitter.Tweet])
    {
        super.insertTweets(newTweets)
        updateDatabase(with: newTweets)
    }
    
    private func updateDatabase(with tweets: [Twitter.Tweet])
    {   print("starting database load...")
        container?.performBackgroundTask {  [weak self] context in
            for twitterInfo in tweets {
                _ = try? Tweet.findOrCreateTweet(matching: twitterInfo, in: context)
            }
            try? context.save()
            print("done loading database...")
			self?.printDatabaseStatistics()
        }
    }
    
    private func printDatabaseStatistics()
    {   if let context = container?.viewContext {	// context == main context on main thread
			context.perform {						// better be sure this is executed on main thread
				if Thread.isMainThread {
					print("on main thread")
				} else {
					print("off main thread")
				}
                if let tweetCount: Int = (try? context.fetch(Tweet.tweetFetchRequest()))?.count {
					print("\(tweetCount) tweets")
				}
				// a better way .... context.count
				if let tweeterCount = try? context.count(for: TwitterUser.fetchRequest()) {
					print("\(tweeterCount) twitter users")
				}
			}
        }
        
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "Tweeters Mentioning Search Term" {
			if let tweetersTVC = segue.destination as? SmashTweetersTableViewController {
				tweetersTVC.mention = searchText
				tweetersTVC.container = container
				
			}
		}

	}

 
}
