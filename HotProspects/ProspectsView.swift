//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Chloe Fermanis on 28/9/20.
//  Copyright © 2020 Chloe Fermanis. All rights reserved.
//

import CodeScanner
import SwiftUI
import UserNotifications

enum FilterType {
    case none, contacted, uncontacted
}

enum SortType {
    case none, name, recent
}

struct ProspectsView: View {

    @EnvironmentObject var prospects: Prospects
    @State private var isShowingScanner = false
    @State private var isShowingSortActionSheet = false
    @State private var sort: SortType = .none

    let filter: FilterType
    
    var title: String {
        switch filter {
        case .none:
            return "Everyone"
        case .contacted:
            return "Contacted people"
        case .uncontacted:
            return "Uncontacted people"
        }
    }
    
    var filteredProspects: [Prospect] {
        
        switch filter {
        case .none:
            return prospects.people
        case .contacted:
            return prospects.people.filter { $0.isContacted }
        case .uncontacted:
            return prospects.people.filter { !$0.isContacted }
        }
    }
    
    var sortedProspects: [Prospect] {
        
        switch sort {
        case .none:
            return filteredProspects
        case .name:
            return filteredProspects.sorted { $0.name < $1.name }
        case .recent:
            return filteredProspects.sorted { $0.dateAdded > $1.dateAdded}
        }
    }

    var body: some View {
        
        NavigationView {
        
            List {
                ForEach(sortedProspects) { prospect in
                    HStack {
                       
                        Group {
                            if filter == .none {
                                Image(systemName: (prospect.isContacted ? "checkmark.circle" : "questionmark.diamond"))
                                    .foregroundColor(prospect.isContacted ? .blue : .yellow)
                            }
                        }
                    
                        VStack(alignment: .leading) {
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.emailAddress)
                                .foregroundColor(.secondary)
                        }
                    }
                    .contextMenu {
                        Button(prospect.isContacted ? "Mark Uncontacted" : "Mark Contacted") {
                            self.prospects.toggle(prospect)
                        }
                        if !prospect.isContacted {
                            Button("Remind Me") {
                                self.addNotification(for: prospect)
                            }
                        }
                    }
                }
            }
            
            .navigationBarTitle("\(title)", displayMode: .inline)
            .navigationBarItems(leading: Button(action:  {
                self.isShowingSortActionSheet = true
            }) {
                Text("Sort")
            }, trailing: Button(action: {
                
                self.isShowingScanner = true
                
            }) {
                Image(systemName: "qrcode.viewfinder")
                Text("Scan")
            })
            
            .actionSheet(isPresented: $isShowingSortActionSheet) {
                ActionSheet(title: Text("Sort by"), buttons: [
                    .default(Text("Name")) { self.sort = .name },
                    .default(Text("Most Recent")) { self.sort = .recent },
                    .cancel()
                ])
            }
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.qr], simulatedData: "Nic Nat\nicnat@wce.com", completion: self.handleScan)
            }
        }
    }
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        self.isShowingScanner = false
        // more code to come
        
        switch result {
        case .success(let code):
            let details = code.components(separatedBy: "\n")
            guard details.count == 2 else { return }
            
            let person = Prospect()
            person.name = details[0]
            person.emailAddress = details[1]
            
            self.prospects.add(person)
            
            //self.prospects.people.append(person)
            //self.prospects.save()
            
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
            
        }
    }
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()

        let addRequest = {
            
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default

            var dateComponents = DateComponents()
            dateComponents.hour = 9
            //let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)


            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            center.add(request)
        }

        // more code to come
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else {
                        print("D'oh")
                    }
                }
            }
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
    }
}
