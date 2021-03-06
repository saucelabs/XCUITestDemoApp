//
//  ListViewController.swift
//  ToDoSample
//
//  Created by David on 17.04.18.
//  Copyright © 2018 Saucelabs. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
    
    var items: [ListItem] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitleView(image: #imageLiteral(resourceName: "sauce_logo_large"))
        
        navigationController?.navigationBar.tintColor = UIColor.sauceRed
        items = loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "detail" else {
            return
        }
        
        if let vc = segue.destination as? DetailViewController {
            vc.item = sender as? ListItem
        }
    }
    
    @IBAction func addPressed(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("Create Item", comment: ""), message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("Title", comment: "")
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Add", comment: ""), style: .default, handler: { [unowned self] (action) in
            guard let titleTextField = alert.textFields?[0] else {
                return
            }
            
            guard let title = titleTextField.text, title.count > 0 else {
                return
            }
            self.addItem(title: title)
        }))
        
        alert.view.tintColor = UIColor.sauceRed
        
        present(alert, animated: true, completion: nil)
    }
    
    private func addItem(title: String) {
        let row = self.items.count
        let item = ListItem(title: title)
        self.items.append(item)
        store(items: self.items)
        
        self.tableView.insertRows(at: [IndexPath(row: row, section: 0)], with: .bottom)
    }
    
    @IBAction func editPressed(_ sender: UIBarButtonItem) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        let editString = NSLocalizedString("Edit", comment: "")
        let doneString = NSLocalizedString("Done", comment: "")
        
        sender.title = sender.title == editString ? doneString : editString
    }
}

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemRow", for: indexPath) as! ListItemTableViewCell
        
        let item = items[indexPath.row]
        cell.titleLabel.attributedText = nil
        cell.showsReorderControl = true
        cell.doneImageView.image = nil
        
        if item.done {
            let attributes: [NSAttributedStringKey: Any] = [
                .font: cell.titleLabel.font,
                .strikethroughStyle: 1
            ]
            let title = NSAttributedString(string: item.title, attributes: attributes)
            cell.titleLabel.attributedText = title
            setAccessibilityTrait(selected: true, forView: cell.titleLabel)
            cell.doneImageView.image = #imageLiteral(resourceName: "saucebot_lederhosen")
            
        } else {
            cell.titleLabel.text = item.title
            setAccessibilityTrait(selected: false, forView: cell.titleLabel)
        }
        
        return cell
    }
    
    private func setAccessibilityTrait(selected: Bool, forView view: UIView) {
        var traits: UIAccessibilityTraits
        if selected {
            traits = view.accessibilityTraits | UIAccessibilityTraitSelected
        } else {
            traits = view.accessibilityTraits & (~UIAccessibilityTraitSelected)
        }
        
        view.accessibilityTraits = traits
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = items.remove(at: sourceIndexPath.row)
        items.insert(item, at: destinationIndexPath.row)
        store(items: items)
    }
    
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: NSLocalizedString("Delete", comment: "")) { (action, indexPath) in
            self.items.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            store(items: self.items)
        }
        
        let moveToTop = UITableViewRowAction(style: .normal, title: NSLocalizedString("Move to top", comment: "")) { (action, indexPath) in
            let item = self.items.remove(at: indexPath.row)
            self.items.insert(item, at: 0)
            
            let rows = (0...indexPath.row).map({ (row) -> IndexPath in
                return IndexPath(row: row, section: 0)
            })
            
            self.tableView.reloadRows(at: rows, with: .automatic)
        }
        
        return [deleteAction, moveToTop]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detail", sender: items[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}
