//
//  DukePerson.swift
//  ECE564_HOMEWORK
//
//  Created by Nan Ni on 1/25/20.
//  Copyright © 2020 ECE564. All rights reserved.
//

import Foundation
import UIKit

enum Gender: String,  Codable {
    case Male
    case Female
}

class Person: Codable {
    var firstName = "First"
    var lastName = "Last"
    var whereFrom = "Anywhere"  // this is just a free String - can be city, state, both, etc.
    var gender : Gender = .Male
}

enum DukeRole : String, Codable {
    case Student = "Student"
    case Professor = "Professor"
    case TA = "Teaching Assistant"
}

protocol ECE564 {
    var hobbies : [String] { get }
    var role : DukeRole { get }
    var degree : String { get }
    var languages : [String] {get}
    var picture: String? {get}  // we will use in future HW
    var team: String? {get} // we will use in future HW
    var netid: String? {get} // we will use in future HW
    var email: String? {get} // we will use in future HW
    var department: String? {get} // we will use in future HW
    var id: String? {get} // we will use in future HW
}

extension ECE564 {
    var picture: String? {return nil}
    var team: String? {return nil}
    var netid: String? {return nil}
    var email: String? {return nil}
    var department: String? {return nil}
    var id: String? {return nil}
}

//CustomStringConvertible,
class DukePerson: NSObject, ECE564, Codable {
    
    
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("DukePersonJSONFile_nn75")
    
    var firstName = "First"
    var lastName = "Last"
    var whereFrom = "Anywhere"
    var gender : Gender = .Male
    
    var hobbies: [String] = []
    var role: DukeRole = .Student
    var degree: String = ""
    var languages: [String] = []
    var team: String?
    var picture = ""
    
    override init() {
        super.init()
    }
    
    init(f firstName: String,
         l lastName: String,
         w whereFrom: String,
         g gender: Gender,
         h hobbies : [String],
         r role : DukeRole,
         d degree : String,
         l languages : [String],
         t team: String,
         p picture: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.whereFrom = whereFrom
        self.gender = gender
        self.hobbies = hobbies
        self.role = role
        self.degree = degree
        self.languages = languages
        self.picture = picture
        self.team = team
        
        super.init()

    }
    
    override var description: String {
        let firstSentence = firstName + " " + lastName + " is from " + whereFrom + " and is a " + role.rawValue.lowercased() + ". "
        let secondSentence = (gender == Gender.Male ? "He" : "She") + " is proficient in " + languages.joined(separator: ", ") + ". "
        let thirdSentence = "When not in class, " + firstName + " enjoys " + hobbies.joined(separator: ", ") + ". \n"
        
        var outputString = firstSentence
        if languages[0] != "" {
            outputString += secondSentence
        }
        if hobbies[0] != "" {
            outputString += thirdSentence
        }
        return outputString
    }
    
    
    static func saveDukePersonInfo(_ dukePersonList: [DukePerson]) -> Bool {
        var outputData = Data()
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(dukePersonList) {
            //if let json = String(data: encoded, encoding: .utf8) {
            if let _ = String(data: encoded, encoding: .utf8) {
                //print(json)
                outputData = encoded
            }
            else { return false }
            
            do {
                try outputData.write(to: ArchiveURL)
            } catch let error as NSError {
                print (error)
                return false
            }
            return true
        }
        else { return false }
    }
    
    static func loadDukePersonInfo() -> [DukePerson]? {
        let decoder = JSONDecoder()
        var dukePersons = [DukePerson]()
        let tempData: Data
        
        do {
            tempData = try Data(contentsOf: ArchiveURL)
        } catch let error as NSError {
            print(error)
            return nil
        }
        if let decoded = try? decoder.decode([DukePerson].self, from: tempData) {
            print(decoded[0].firstName)
            dukePersons = decoded
        }
        return dukePersons
    }
}


let RicTelford: DukePerson = DukePerson(f: "Ric",
                                        l: "Telford",
                                        w: "US",
                                        g: .Male,
                                        h: ["Swimming", "Biking", "Hiking"],
                                        r: .Professor,
                                        d: "BS",
                                        l: ["Swift", "C", "C++"],
                                        t: "",
                                        p: UIImage(named: "Ric Telford")?.resizeImage(resize: K.photoSize).scaleImage(scaleSize: K.scaleSize).base64ToString() ?? "")
let JingruGao: DukePerson = DukePerson(f: "Jingru",
                                       l: "Gao",
                                       w: "CN",
                                       g: .Female,
                                       h: ["Traveling", "Reading", "Movies"],
                                       r: .TA,
                                       d: "MS",
                                       l: ["Swift", "C++", "Python"],
                                       t: "",
                                       p: UIImage(named: "Jingru Gao")?.resizeImage(resize: K.photoSize).scaleImage(scaleSize: K.scaleSize).base64ToString() ?? "")
let HaohongZhao: DukePerson = DukePerson(f: "Haohong",
                                         l: "Zhao",
                                         w: "CN",
                                         g: .Male,
                                         h: ["Reading", "Jogging"],
                                         r: .TA,
                                         d: "MS",
                                         l: ["Swift","Python"],
                                         t: "",
                                         p: UIImage(named: "Haohong Zhao")?.resizeImage(resize: K.photoSize).scaleImage(scaleSize: K.scaleSize).base64ToString() ?? "")
let NanNi: DukePerson = DukePerson(f: "Nan",
                                   l: "Ni",
                                   w: "CN",
                                   g: .Female,
                                   h: ["Traveling", "Playing online games", "Cardio workout"],
                                   r: .Student,
                                   d: "MS",
                                   l: ["C", "C++", "Swift"],
                                   t: "HFTP",
                                   p: UIImage(named: "Nan Ni")?.resizeImage(resize: K.photoSize).scaleImage(scaleSize: K.scaleSize).base64ToString() ?? "")
let NiboYing: DukePerson = DukePerson(f: "Nibo",
                                      l: "Ying",
                                      w: "CN",
                                      g: .Male,
                                      h: ["Basketball"],
                                      r: .Student,
                                      d: "MS",
                                      l: ["C++", "Swift"],
                                      t: "HFTP",
                                      p: UIImage(named: "Nibo Ying")?.resizeImage(resize: K.photoSize).scaleImage(scaleSize: K.scaleSize).base64ToString() ?? "")
let ZihuiZheng: DukePerson = DukePerson(f: "Zihui",
                                        l: "Zheng",
                                        w: "CN",
                                        g: .Male,
                                        h: ["Video games", "Workout", "Basketball"],
                                        r: .Student,
                                        d: "MS",
                                        l: ["C++", "Scala", "Swift"],
                                        t: "HFTP",
                                        p: UIImage(named: "Zihui Zheng")?.resizeImage(resize: K.photoSize).scaleImage(scaleSize: K.scaleSize).base64ToString() ?? "")
let KaiWang: DukePerson = DukePerson(f: "Kai",
                                     l: "Wang",
                                     w: "CN",
                                     g: .Male,
                                     h: ["Traveling", "Playing online games", "Cardio workout"],
                                     r: .Student,
                                     d: "MS",
                                     l: ["C++", "Swift"],
                                     t: "HFTP",
                                     p: UIImage(named: "Kai Wang")?.resizeImage(resize: K.photoSize).scaleImage(scaleSize: K.scaleSize).base64ToString() ?? "")
var dukePersonsArray = [RicTelford, JingruGao, HaohongZhao, NanNi, NiboYing, ZihuiZheng, KaiWang]


//
// To display in sections
//
struct DukePersonSection {
    var name: String
    var dukePersons: [DukePerson]
    var collapsed: Bool
    
    public init(name: String, dukePersons: [DukePerson], collapsed: Bool = false) {
        self.name = name
        self.dukePersons = dukePersons
        self.collapsed = collapsed
    }
}


