//
//  SmashTweetersTableViewController.swift
//  Smashtag
//
//  Created by Michel Deiman on 26/03/2017.
//  Copyright © 2017 Michel Deiman. All rights reserved.
//

import UIKit
import CoreData
import Twitter

class SmashTweetersTableViewController: FetchedResultsTableViewController
{
	var mention: String? { didSet { updateUI() } }
	
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer { didSet {updateUI() }}
	
    fileprivate var fetchedResultsController: NSFetchedResultsController<TwitterUser>?
	
	private func updateUI()
    {
        if let context = container?.viewContext, mention != nil {
            let request: NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
			let selector = #selector(NSString.caseInsensitiveCompare(_:))
			request.sortDescriptors = [NSSortDescriptor(key: "handle", ascending: true, selector: selector)]
            /// ??
            request.predicate = NSPredicate(format: "any tweets.text contains[c] %@", mention!)
            fetchedResultsController = NSFetchedResultsController<TwitterUser>(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
			try? fetchedResultsController?.performFetch()
			tableView.reloadData()
        }
	}
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Twitter User Cell", for: indexPath)
        if let twitterUser = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.text = twitterUser.handle
			let tweetCount = tweetCountWithMentionBy(twitterUser)
			cell.detailTextLabel?.text = "\(tweetCount) tweet\((tweetCount == 1) ? "": "s")"
        }
        return cell
    }
	
	private func tweetCountWithMentionBy(_ twitterUser: TwitterUser) -> Int {
		let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
		request.predicate = NSPredicate(format: "text contains[c] %@ and tweeter = %@", mention!, twitterUser)
		return (try? twitterUser.managedObjectContext!.count(for: request)) ?? 0
	}
}

extension SmashTweetersTableViewController
{
 // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {   if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].name
        } else {
            return nil
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]?
    {
        return fetchedResultsController?.sectionIndexTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int
    {
        return fetchedResultsController?.section(forSectionIndexTitle: title, at: index) ?? 0
    }
    
}
