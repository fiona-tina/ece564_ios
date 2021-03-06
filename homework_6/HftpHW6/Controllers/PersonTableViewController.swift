//
//  PersonTableViewController.swift
//  HftpHW6
//
//  Created by Nan Ni on 1/31/20.
//  Copyright © 2020 ECE564. All rights reserved.
//

import UIKit

class PersonTableViewController: UITableViewController {

    @IBOutlet var personTableView: UITableView!
    
    //Pass to InformationViewController as a reference
    var selectedPerson: DukePerson?
    var newPerson: DukePerson = DukePerson()
    
    //For search
    var filteredDukePersons: [DukePerson] = []
    let searchController = UISearchController(searchResultsController: nil)
    
    //For section display
    var dukePersonsSection: [DukePersonSection] = [
        DukePersonSection(name: "Professor", dukePersons: []),
        DukePersonSection(name: "TA", dukePersons: []),
        DukePersonSection(name: "Student", dukePersons: []),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(DukePerson.ArchiveURL)
        
        loadInitialData()
        loadDukePersonSections()
        
        // Set table view cell
        personTableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        personTableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.animateCellIdentifier)
        personTableView.dataSource = self
        
        // Set search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search ECE564"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.scopeButtonTitles = ["All", "MS", "BS", "MENG", "PHD", "NA", "Other"]
        searchController.searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    @IBAction func refreshData(_ sender: UIRefreshControl) {
        print("Refreshing...")
        let httprequest = urlGET(false, sender, self)
        httprequest.resume()
    }
    
    /**
        If DukePersonJSONfile exists, load data from it;
        If not, build new file and save data to it.
     */
    func loadInitialData() {
        if let dukePersons = DukePerson.loadDukePersonInfo() {
            dukePersonsArray = dukePersons
        } else {
            //Save the initial dukePersonsArray to disk.
            let _ = DukePerson.saveDukePersonInfo(dukePersonsArray)
        }
    }
    
    /**
        1) Save data to local file
        2) Add persons in flat array to section struct for front-end display
     */
    func loadDukePersonSections() {
        //Save data to local file
        if !DukePerson.saveDukePersonInfo(dukePersonsArray) {
            Alert.saveFailedAlert(on: self, message: "Save data to local file failed")
        }
        
        //Add person in flat array to section
        for i in (0 ... dukePersonsSection.count - 1).reversed() {
            if dukePersonsSection[i].name == "Professor" || dukePersonsSection[i].name == "TA" || dukePersonsSection[i].name == "Student" {
                dukePersonsSection[i].dukePersons.removeAll()
            } else {
                dukePersonsSection.remove(at: i)
            }
        }
        for person in dukePersonsArray {
            appendPersonToSection(person)
        }
    }
    
    func appendPersonToSection(_ person: DukePerson) {
        if person.role == .Professor {
            dukePersonsSection[0].dukePersons.append(person)
        } else if person.role == .TA {
            dukePersonsSection[1].dukePersons.append(person)
        } else if person.role == .Student {
            let teamName = person.team
            if teamName == "" {        //If the team name is empty,add to "Student" section
                dukePersonsSection[2].dukePersons.append(person)
            } else {
                var teamExist = false
                for i in 0 ..< dukePersonsSection.count {
                    if dukePersonsSection[i].name == teamName {
                        dukePersonsSection[i].dukePersons.append(person)
                        teamExist = true
                    }
                }
                if teamExist == false {
                    dukePersonsSection.append(DukePersonSection(name: teamName!, dukePersons: [person]))
                }
            }
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case K.editSegue:
                if let destination = segue.destination as? PageViewController {
                    destination.personFullName = selectedPerson!.fullName
                    let nextViewController = destination.subViewControllers[0] as! NavigationViewController
                    let informationVC = nextViewController.viewControllers[0] as! InformationViewController
                    informationVC.person = selectedPerson!
                    informationVC.mode = .Displaying
                    if selectedPerson?.role == .Professor || selectedPerson?.role == .TA {
                        informationVC.teamHide = true
                    }
                }
            case K.addSegue:
                if let destination = segue.destination as? UINavigationController {
                    let informationVC  = destination.viewControllers[0] as! InformationViewController
                    informationVC.mode = .Adding
                    //Important! Create a new person
                    newPerson = DukePerson()
                    informationVC.person = newPerson
                    informationVC.teamHide = true
                }
            default:
                print("Prepare animation segue")
            }
        }
    }
    
    @IBAction func returnFromInformationView(segue: UIStoryboardSegue) {
        let source: InformationViewController = segue.source as! InformationViewController
        if source.mode == .Adding {
            if source.cancelButtonPressed || source.backButtonPressed {
                //Do nothing
            } else {
                //Append new person
                dukePersonsArray.append(newPerson)
                
                // if this entry is the authorized user, post it
                if newPerson.netid! == CurrentUserData!.netid!{
                    RESTPost(newPerson,vc: self)
                }
                loadDukePersonSections()
            }
        } else if source.mode == .Displaying {
            // if this entry is the authorized user, post it
            if selectedPerson!.netid! == CurrentUserData!.netid!{
                RESTPost(selectedPerson!,vc: self)
            }
            loadDukePersonSections()
        }
        self.tableView.reloadData()
    }
    
    
    // MARK: - Search
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!isSearchBarEmpty || searchBarScopeIsFiltering)
    }
    
    func filterContentForSearchText(_ searchText: String, category: String = "All") {
        filteredDukePersons.removeAll()
        // Display in Professor-TA-Student order
        for i in 0 ..< dukePersonsSection.count {
            for j in 0 ..< dukePersonsSection[i].dukePersons.count {
                filteredDukePersons.append(dukePersonsSection[i].dukePersons[j])
            }
        }
        // Filter both by search bar and search category
        filteredDukePersons = filteredDukePersons.filter({ (p: DukePerson) -> Bool in
            let doesCategoryMatch = category == "All" || p.degree == category
            if isSearchBarEmpty {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch
                    && (p.description.lowercased().contains(searchText.lowercased()) || p.gender.rawValue.lowercased().isEqual(searchText.lowercased()) ||
                        p.netid?.isEqual(searchText.lowercased()) ?? false
                )
            }
        })
        tableView.reloadData()
    }
}




// MARK: - Table view data source

extension PersonTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering {
            return 1
        } else {
            return dukePersonsSection.count
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredDukePersons.count
        } else {
            if dukePersonsSection[section].collapsed {
                return 0
            } else {
                return dukePersonsSection[section].dukePersons.count
            }
        }
    }
    
    //For cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tempPerson: DukePerson
        if isFiltering {
            tempPerson = filteredDukePersons[indexPath.row]
        } else {
            tempPerson = dukePersonsSection[indexPath.section].dukePersons[indexPath.row]
        }
        
        let cell = tempPerson.team == "HFTP" ? tableView.dequeueReusableCell(withIdentifier: K.animateCellIdentifier, for: indexPath) as! PersonTableViewCell : tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier) as! PersonTableViewCell

        if tempPerson.team == "HFTP" {
            cell.hasAnimation = true
        }
        
        cell.personInCell = tempPerson
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFiltering {
            selectedPerson = filteredDukePersons[indexPath.row]
        } else {
            selectedPerson = dukePersonsSection[indexPath.section].dukePersons[indexPath.row]
        }
        performSegue(withIdentifier: K.editSegue, sender: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isFiltering {
            return 130
        } else if dukePersonsSection[indexPath.section].collapsed || dukePersonsSection[indexPath.section].dukePersons.count == 0 {
            return CGFloat.leastNormalMagnitude
        }
        return 130
    }
    
    
    //For header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isFiltering {
            return nil
        }
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: K.headerIdentifier) as? CollapsibleTableViewHeader ?? CollapsibleTableViewHeader(reuseIdentifier: K.headerIdentifier)
        
        header.titleLabel.text = dukePersonsSection[section].name
        header.arrowLabel.text = ">"
        header.setCollapsed(dukePersonsSection[section].collapsed)
        
        header.section = section
        header.delegate = self
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isFiltering {
            return CGFloat.leastNormalMagnitude
        }
        return 35.0
    }
    
    //For swipe left
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let modifyAction = UIContextualAction(style: .normal, title:  "Edit", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            if self.isFiltering {
                self.selectedPerson = self.filteredDukePersons[indexPath.row]
            } else {
                self.selectedPerson = self.dukePersonsSection[indexPath.section].dukePersons[indexPath.row]
            }
            
            self.performSegue(withIdentifier: K.editSegue, sender: indexPath)
            success(true)
        })
        modifyAction.backgroundColor = UIColor(named: K.BrandColors.gray)
        modifyAction.image = UIImage(named: "Edit")
        
        let deleteAction = UIContextualAction(style: .normal, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let personToDelete: DukePerson
            if self.isFiltering {
                personToDelete = self.filteredDukePersons[indexPath.row]
                self.filteredDukePersons.remove(at: indexPath.row)
            } else {
                personToDelete = self.dukePersonsSection[indexPath.section].dukePersons[indexPath.row]
                self.dukePersonsSection[indexPath.section].dukePersons.remove(at: indexPath.row)
            }
            
            dukePersonsArray.removeAll{ $0.netid == personToDelete.netid }
            self.loadDukePersonSections()
            
            tableView.reloadData()
            success(true)
        })
        deleteAction.backgroundColor = UIColor.red
        deleteAction.image = UIImage(named: "Delete")
        
        return UISwipeActionsConfiguration(actions: [deleteAction, modifyAction])
    }
    
    // For swipe right
    override func tableView(_ tableView: UITableView,
               leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if self.isFiltering {
            self.selectedPerson = self.filteredDukePersons[indexPath.row]
        } else {
            self.selectedPerson = self.dukePersonsSection[indexPath.section].dukePersons[indexPath.row]
        }
        if self.selectedPerson?.team != "HFTP" {return UISwipeActionsConfiguration(actions: [])}
        
        // animation action
        let animateAction = UIContextualAction(style: .normal, title:  "Animation", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.performSegue(withIdentifier: self.decideSegue(name:self.selectedPerson!.fullName), sender: indexPath)
            success(true)
        })
        animateAction.backgroundColor = UIColor(named: K.BrandColors.cellBlue)
        // to be implemented
        // animateAction.image = UIImage(named: "animation")
        
        return UISwipeActionsConfiguration(actions: [animateAction])
    }
    
    // Help function of swipe right delegate function
    func decideSegue(name : String) -> String{
        switch name {
        case "Nan Ni":
            return K.nanAniSegue
        case "Nibo Ying":
            return K.niboAniSegue
        case "Kai Wang":
            return K.kaiAniSegue
        case "Zihui Zheng":
            return K.zihuiAniSegue
        default:
            return K.nanAniSegue
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
        let cell:PersonTableViewCell = cell as! PersonTableViewCell
        if cell.hasAnimation {
            cell.animateAvatar()
        }
    }
    
}


// MARK: - Search controller

extension PersonTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let category = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchBar.text!, category: category)
    }
}

extension PersonTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!)
    }
}




// MARK: - Section Header Delegate

extension PersonTableViewController: CollapsibleTableViewHeaderDelegate {
    
    func toggleSection(_ header: CollapsibleTableViewHeader, section: Int) {
        let collapsed = !dukePersonsSection[section].collapsed
        
        // Toggle collapse
        dukePersonsSection[section].collapsed = collapsed
        header.setCollapsed(collapsed)
        
        tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
    }
    
}

