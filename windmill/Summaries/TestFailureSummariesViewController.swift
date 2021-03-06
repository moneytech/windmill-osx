//
//  TestErrorSummariesViewController.swift
//  windmill
//
//  Created by Markos Charatzas (markos@qnoid.com) on 16/3/18.
//  Copyright © 2014-2020 qnoid.com. All rights reserved.
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation is required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source distribution.
//

import Cocoa

class TestFailureSummariesView: NSView {
    override var intrinsicContentSize: NSSize {
        return NSSize(width: 329, height: 240)
    }
}

protocol TestFailureSummariesViewControllerDelegate: class {
    func didSelect(_ errorSummariesViewController: TestFailureSummariesViewController, testFailureSummary: ResultBundle.TestFailureSummary)
}

class TestFailureSummariesViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSMenuDelegate, SummariesViewController {
    
    enum TestFailureSummaryIdentifier: String {
        
        static var allValues: [TestFailureSummaryIdentifier] = [.Branch, .Commit, .TestCase, .IssueType, .Message]
        
        case Branch
        case Commit
        case TestCase
        case IssueType
        case Message
    }
    
    
    @IBOutlet weak var tableView: NSTableView! {
        didSet{
            tableView.allowsMultipleSelection = false
        }
    }
    
    @IBOutlet weak var tableViewHeaderMenu: NSMenu! {
        didSet{
            TestFailureSummaryIdentifier.allValues.forEach { (testFailureSummaryIdentifier) in
                
                guard testFailureSummaryIdentifier != .Message else {
                    return
                }
                
                let menuItem = NSMenuItem(title: testFailureSummaryIdentifier.rawValue, action:  #selector(self.didSelect(menuItem:)), keyEquivalent: "")
                menuItem.identifier = NSUserInterfaceItemIdentifier(rawValue: testFailureSummaryIdentifier.rawValue)
                menuItem.state = .on
                tableViewHeaderMenu.addItem(menuItem)
            }
        }
    }
    
    @IBOutlet weak var pathControl: NSPathControl! {
        didSet{
            pathControl.isEditable = false
        }
    }
    
    weak var delegate: TestFailureSummariesViewControllerDelegate?
    
    var commit: Repository.Commit?
    var testFailureSummaries: [ResultBundle.TestFailureSummary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        tableView.reloadData()
    }
    
    // MARK: NSTableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return testFailureSummaries.count
    }
    
    // MARK: NSTableViewDelegate
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let identifier = tableColumn?.identifier else {
            return nil
        }
        
        let tableCellView = tableView.makeView(withIdentifier: identifier, owner: self) as! NSTableCellView
        
        let testFailureSummaryIdentifier = TestFailureSummaryIdentifier(rawValue: identifier.rawValue)
        
        if case TestFailureSummaryIdentifier.Branch? = testFailureSummaryIdentifier {
            tableCellView.textField?.stringValue = commit?.branch ?? ""
        } else if case TestFailureSummaryIdentifier.Commit? = testFailureSummaryIdentifier {
            tableCellView.textField?.stringValue = commit?.shortSha ?? ""
        } else if case TestFailureSummaryIdentifier.TestCase? = testFailureSummaryIdentifier {
            tableCellView.textField?.stringValue = testFailureSummaries[row].testCase
        } else  if case TestFailureSummaryIdentifier.IssueType? = testFailureSummaryIdentifier {
            tableCellView.textField?.stringValue = testFailureSummaries[row].issueType
        } else if case TestFailureSummaryIdentifier.Message? = testFailureSummaryIdentifier {
            tableCellView.textField?.stringValue = testFailureSummaries[row].message
        }
        
        tableCellView.toolTip = testFailureSummaries[row].message
        
        return tableCellView
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let sender = notification.object as? NSTableView else {
            return
        }
        self.tableViewDidSelectRow(sender)
    }
    
    @IBAction func tableViewDidSelectRow(_ sender: NSTableView) {
        
        guard tableView.selectedRow >= 0 && tableView.selectedRow < testFailureSummaries.count else {
            return
        }
        
        let testFailureSummary = testFailureSummaries[tableView.selectedRow]
        
        self.delegate?.didSelect(self, testFailureSummary: testFailureSummary)
    }
    
    @objc func didSelect(menuItem: NSMenuItem) {
        menuItem.state = (menuItem.state == .on) ? .off : .on
        
        guard let identifier = menuItem.identifier else {
            return
        }
        
        let column = tableView.tableColumn(withIdentifier: identifier)
        column?.isHidden = menuItem.state == .off ? true : false
    }
}

