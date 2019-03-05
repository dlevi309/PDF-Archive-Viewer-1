//
//  DetailViewController.swift
//  PDFArchiveViewer
//
//  Created by Julian Kahnert on 29.12.18.
//  Copyright © 2018 Julian Kahnert. All rights reserved.
//

import ArchiveLib
import os.log
import PDFKit
import UIKit

class DetailViewController: UIViewController, Logging {

    // MARK: - properties
    private var isNavigationBarHidden = false

    var detailDocument: Document? {
        didSet {
            configureView()
        }
    }

    // MARK: - outlets
    @IBOutlet weak var documentView: PDFView!

    @IBAction private func shareButtonClicked(_ sender: UIBarButtonItem) {
        guard let document = detailDocument,
            let pdfDocumentData = NSData(contentsOf: document.path) else {

            // pop up an alert dialogue letting us know it has failed
            let alertTitle = NSLocalizedString("Error", comment: "The title of an error message popup")
            let errorMessage = NSLocalizedString("Unable to share document without the pdf file", comment: "Error mesage to be displayed when failing to share a document")
            let actionTitle = NSLocalizedString("OK", comment: "Button confirmation label")

            let alert = UIAlertController(title: alertTitle,
                                          message: errorMessage,
                                          preferredStyle: .alert)
            let action = UIAlertAction(title: actionTitle,
                                       style: .default,
                                       handler: nil)
            alert.addAction(action)

            self.present(alert, animated: true, completion: nil)

            return
        }
        // creating the sharing activity view controller
        let activity = UIActivityViewController(activityItems: [pdfDocumentData],
                                                applicationActivities: nil)
        // presenting it
        self.present(activity, animated: true, completion: nil)
    }

    @IBAction private func tapGestureRecognizer(_ sender: UITapGestureRecognizer) {

        // change the state of the navigation bar
        isNavigationBarHidden.toggle()

        // animate the navigation bar
        navigationController?.setNavigationBarHidden(isNavigationBarHidden, animated: true)

        // TODO: fix the color change
        if let controller = UIApplication.shared.keyWindow?.rootViewController as? NavigationController {
            controller.whiteStatusBarText(isNavigationBarHidden)
        }

    }

    // MARK: - delegates
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear()")

        // cascade viewWillAppear(:)
        super.viewWillAppear(animated)

        // setup document view
        documentView.displayMode = .singlePage
        documentView.autoScales = true
        documentView.interpolationQuality = .low
        documentView.backgroundColor = UIColor(named: "TextColorLight") ?? .darkGray

        // hide tab bar controller
        // TODO: might be changed to https://stackoverflow.com/questions/31367387/detect-if-app-is-running-in-slide-over-or-split-view-mode-in-ios-9
        if detailDocument != nil,
            UIDevice.current.userInterfaceIdiom != .pad {
            self.tabBarController?.tabBar.isHidden = true
            self.tabBarController?.view.setNeedsLayout()
            self.tabBarController?.view.layoutIfNeeded()
        }
    }

    override func viewDidLoad() {
        print("viewDidLoad()")
        super.viewDidLoad()
        configureView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear()")

        // cascade viewDidDisappear(:)
        super.viewWillDisappear(animated)

        // show tab bar controller
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.view.setNeedsLayout()
        self.tabBarController?.view.layoutIfNeeded()

        // change status bar text color
        // TODO: fix the color change
        if let controller = UIApplication.shared.keyWindow?.rootViewController as? NavigationController {
            controller.whiteStatusBarText(false)
        }
    }

    // MARK: - helper functions
    private func configureView() {
        if let detailDocument = detailDocument,
            let documentView = documentView {

            // set the title
            title = detailDocument.specificationCapitalized

            // setup the pdf view
            documentView.document = PDFDocument(url: detailDocument.path)
            documentView.goToFirstPage(self)
        }
    }
}
