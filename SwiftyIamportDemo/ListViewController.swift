//
//  ListViewController.swift
//  SwiftIamport
//
//  Created by JosephNK on 2017. 4. 21..
//  Copyright © 2017년 JosephNK. All rights reserved.
//

import UIKit

enum ListRowType: Int {
    case remote             = 0
    case nice
    case html5_inicis
}

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    private let listCellIdentifier = "ListTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Demo"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func numberOfSections(in tableView: UITableView) -> Int  {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        
        guard let rowType = ListRowType(rawValue: indexPath.row)  else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: listCellIdentifier, for: indexPath)

        switch rowType {
        case .remote:
            cell.textLabel?.text = (section == 0) ? "Iamport UIWebView Demo" : "Iamport WKWebView Demo"
            break
        case .nice:
            cell.textLabel?.text = (section == 0) ? "NicePay UIWebView Demo" : "NicePay WKWebView Demo"
            break
        case .html5_inicis:
            cell.textLabel?.text = (section == 0) ? "Html5 Inicis UIWebView Demo" : "Html5 Inicis WKWebView Demo"
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        DispatchQueue.main.async {
            let section = indexPath.section
            
            guard let rowType = ListRowType(rawValue: indexPath.row)  else {
                return
            }
            
            var controller: UIViewController!
            
            switch rowType {
            case .remote:
                controller = (section == 0) ? RemoteViewController() : WKRemoteViewController()
                break
            case .nice:
                controller = (section == 0) ? NiceViewController() : WKNiceViewController()
                break
            case .html5_inicis:
                controller = (section == 0) ? Html5InicisViewController() : WKHtml5InicisViewController()
                break
            }
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (section == 0) ? "UIWebView" : "WKWebView"
    }
}

@IBDesignable class ListTableViewCell: UITableViewCell {
    @IBInspectable var newColor: UIColor = UIColor.green
    
    lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.black
        label.text = ""
        return label
    }()
    
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupViews()
    }
    
    open func setupViews() {
        self.contentView.addSubview(titleLabel)
        titleLabel.frame = self.bounds
    }
}
