//
//  VideoEditorViewController.swift
//  Snapvideo
//
//  Created by Anastasia Petrova on 02/02/2020.
//  Copyright © 2020 Anastasia Petrova. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

final class VideoEditorViewController: UIViewController {
    let asset: AVAsset
    let url: URL
    let videoViewController: VideoViewController
    let looksContainerView = UIView()
    let exportView = UIView()
    var topExportConstraint = NSLayoutConstraint()
    let looksViewController: LooksViewController
    var topLooksConstraint = NSLayoutConstraint()
    let tabBar = TabBar(items: "LOOKS", "TOOLS", "EXPORT")
    let toolsViewController: ToolsViewController
    var topToolsConstraint = NSLayoutConstraint()
    var cancelButton = LooksViewButton(imageName: "cancel")
    var doneButton = LooksViewButton(imageName: "done")
    var saveCopyButton = SaveCopyVideoButton()
    var spacerHeight = CGFloat()
    let saveStackView = UIStackView()
    let saveCopyStackView = UIStackView()
    let itemSize = CGSize(width: 60, height: 76)
    var previouslySelectedIndex: Int?
    
    var isLooksButtonSelected: Bool = false {
        didSet {
            if isLooksButtonSelected {
                openLooks()
            } else {
                closeLooks()
            }
        }
    }
    
    var isExportButtonSelected: Bool = false {
        didSet {
            if isExportButtonSelected {
                openExportMenu()
            } else {
                closeExportMenu()
            }
        }
    }
    
    var isToolsButtonSelected: Bool = false {
        didSet {
            if isToolsButtonSelected {
                openTools()
            } else {
                closeTools()
            }
        }
    }
    
    var isExportViewShown: Bool = true {
        didSet {
            if isExportButtonSelected &&  isExportButtonSelected != isExportViewShown {
                isExportButtonSelected = isExportViewShown
                tabBar.selectedItem = nil
                previouslySelectedIndex = nil
            }
        }
    }
    
    var isToolsViewShown: Bool = true {
        didSet {
            if isToolsButtonSelected &&  isToolsButtonSelected != isToolsViewShown {
                isToolsButtonSelected = isToolsViewShown
                tabBar.selectedItem = nil
                previouslySelectedIndex = nil
            }
        }
    }
    
    var previewImage: UIImage? {
        didSet {
            looksViewController.dataSource.image = previewImage
        }
    }
    
    var trackDuration: Float {
        guard let trackDuration = videoViewController.player.currentItem?.asset.duration else {
            return 0
        }
        return Float(CMTimeGetSeconds(trackDuration))
    }
    
    init(url: URL, filters: [AnyFilter], tools: [AnyTool]) {
        self.url = url
        asset = AVAsset(url: url)
        videoViewController = VideoViewController(asset: asset)
        looksViewController = LooksViewController(itemSize: itemSize, filters: filters) {
            [
            weak videoViewController,
            weak doneButton,
            weak tabBar
            ] newIndex, previousIndex in
            videoViewController?.playerView.filter = filters[newIndex]
            videoViewController?.bgVideoView.filter = filters[newIndex] + AnyFilter(BlurFilter(blurRadius: 100))
            doneButton?.isEnabled = newIndex != 0
            tabBar?.isHidden = newIndex != 0
            guard newIndex != previousIndex && newIndex != 0 else { return }
            videoViewController?.player.play()
        }
        toolsViewController = ToolsViewController(tools: tools)
        super.init(nibName: nil, bundle: nil)
        addChild(looksViewController)
        looksViewController.didMove(toParent: self)
        
        toolsViewController.didSelectToolCallback = { [weak self] toolIndex in
            let vc = AdjustmentsViewController(url: url, tool: tools[toolIndex])
            vc.modalTransitionStyle = .crossDissolve
            self?.present(vc, animated: true, completion: nil)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        AssetImageGenerator.getThumbnailImageFromVideoAsset(
            asset: asset,
            maximumSize: itemSize.applying(.init(scaleX: UIScreen.main.scale, y: UIScreen.main.scale)),
            completion: { [weak self] image in
                self?.previewImage = image
            }
        )
        
        view.addSubview(videoViewController.view)
        view.addSubview(looksContainerView)
        view.addSubview(toolsViewController.view)
        view.addSubview(exportView)
        view.addSubview(tabBar)
        
        setUpVideoViewController()
        setUpLooksView()
        setUpCancelButton()
        setUpDoneButton()
        setUpToolsView()
        setUpExportView()
        setUpSaveStackView()
        setUpSaveCopyStackView()
        setUpSaveCopyButton()
        setUpTabBar()
    }
    
    private func setUpTabBar() {
        tabBar.delegate = self
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        tabBar.setContentHuggingPriority(.required, for: .vertical)
        tabBar.setContentCompressionResistancePriority(.required, for: .vertical)
        NSLayoutConstraint.activate([
            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func setUpVideoViewController() {
        videoViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate ([
            videoViewController.view.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            videoViewController.view.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            videoViewController.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tabBar.topAnchor.constraint(greaterThanOrEqualTo: videoViewController.view.bottomAnchor)
        ])
    }
   
    func setUpLooksView() {
        looksContainerView.translatesAutoresizingMaskIntoConstraints = false
        looksContainerView.backgroundColor = .white
        topLooksConstraint = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: looksContainerView.topAnchor, constant: -view.safeAreaInsets.bottom)
        let looksViewHeight: CGFloat = 100.0
        let bottomConstraint = looksContainerView.topAnchor.constraint(equalTo: videoViewController.view.bottomAnchor)
        bottomConstraint.priority = .defaultLow
        NSLayoutConstraint.activate ([
            looksContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            looksContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            looksContainerView.heightAnchor.constraint(equalTo: tabBar.heightAnchor, constant: looksViewHeight),
            bottomConstraint,
            topLooksConstraint
        ])
        let buttonsStackView = UIStackView()
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(doneButton)
        buttonsStackView.axis = .horizontal
        buttonsStackView.distribution = .fillEqually
        
        let collectionStackView = UIStackView()
        collectionStackView.translatesAutoresizingMaskIntoConstraints = false
        collectionStackView.axis = .vertical
        
        looksContainerView.addSubview(collectionStackView)
        collectionStackView.addArrangedSubview(looksViewController.view)
        collectionStackView.addArrangedSubview(buttonsStackView)
        let spacer = UIView()
        spacer.backgroundColor = .white
        collectionStackView.addArrangedSubview(spacer)
        
        NSLayoutConstraint.activate ([
            collectionStackView.trailingAnchor.constraint(equalTo: looksContainerView.trailingAnchor),
            collectionStackView.leadingAnchor.constraint(equalTo: looksContainerView.leadingAnchor),
            collectionStackView.topAnchor.constraint(equalTo: looksContainerView.topAnchor),
            collectionStackView.bottomAnchor.constraint(equalTo: looksContainerView.bottomAnchor),
            looksViewController.view.heightAnchor.constraint(equalToConstant: looksViewHeight)
        ])
    }
    
    func setUpToolsView() {
        toolsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        topToolsConstraint = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: toolsViewController.view.topAnchor)
        
        NSLayoutConstraint.activate ([
            toolsViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolsViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolsViewController.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            topToolsConstraint
        ])
    }
    
    func setUpExportView() {
        exportView.translatesAutoresizingMaskIntoConstraints = false
        exportView.backgroundColor = .white
        topExportConstraint = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: exportView.topAnchor, constant: -view.safeAreaInsets.bottom)
        
        NSLayoutConstraint.activate ([
            exportView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            exportView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            exportView.heightAnchor.constraint(equalToConstant: 100),
            topExportConstraint
        ])
        
        let exportStackView = UIStackView()
        exportStackView.translatesAutoresizingMaskIntoConstraints = false
        exportStackView.axis = .vertical
        exportStackView.distribution = .fillEqually
        exportView.addSubview(exportStackView)
        
        NSLayoutConstraint.activate ([
            exportStackView.trailingAnchor.constraint(equalTo: exportView.trailingAnchor),
            exportStackView.leadingAnchor.constraint(equalTo: exportView.leadingAnchor),
            exportStackView.topAnchor.constraint(equalTo: exportView.topAnchor),
            exportStackView.bottomAnchor.constraint(equalTo: exportView.bottomAnchor)
        ])
        saveStackView.translatesAutoresizingMaskIntoConstraints = false
        saveStackView.axis = .horizontal
        saveCopyStackView.translatesAutoresizingMaskIntoConstraints = false
        saveCopyStackView.axis = .horizontal
        exportStackView.addArrangedSubview(saveStackView)
        exportStackView.addArrangedSubview(saveCopyStackView)
    }
    
    func setUpCancelButton() {
        NSLayoutConstraint.activate ([
            cancelButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        cancelButton.addTarget(self, action: #selector(self.discardLooks), for: .touchUpInside)
    }
    
    func setUpDoneButton() {
        doneButton.isEnabled = false
        NSLayoutConstraint.activate ([
            doneButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        doneButton.addTarget(self, action: #selector(self.saveFilter), for: .touchUpInside)
    }
    
    func setUpSaveStackView() {
        saveStackView.spacing = 16
        saveStackView.alignment = .center
        let imageView = ExportImageView(imageName: "saveVideoImage")
        let leftSpacer = UIView()
        let rightSpacer = UIView()
        let labelsStackView = UIStackView()
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.axis = .vertical
        
        saveStackView.addArrangedSubview(leftSpacer)
        saveStackView.addArrangedSubview(imageView)
        saveStackView.addArrangedSubview(labelsStackView)
        saveStackView.addArrangedSubview(rightSpacer)
        saveStackView.setCustomSpacing(0, after: leftSpacer)
        saveStackView.setCustomSpacing(0, after: labelsStackView)
        
        NSLayoutConstraint.activate ([
            leftSpacer.widthAnchor.constraint(equalToConstant: 16),
            rightSpacer.widthAnchor.constraint(equalTo: leftSpacer.widthAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 20)
        ])
        
        let header = HeaderExportLabel()
        header.text = "Save"
        
        let body = BodyExportLabel()
        body.text = "Saves with changes that you can undo. IOS will ask for permission to modify this photo."
        
        labelsStackView.addArrangedSubview(header)
        labelsStackView.addArrangedSubview(body)
        labelsStackView.layoutMargins = .init(top: 8, left: 0, bottom: 8, right: 0)
        labelsStackView.isLayoutMarginsRelativeArrangement = true
    }
    
    func setUpSaveCopyStackView() {
        saveCopyStackView.spacing = 16
        saveCopyStackView.alignment = .center
        let imageView = ExportImageView(imageName: "saveVideoCopyImage")
        let leftSpacer = UIView()
        let rightSpacer = UIView()
        let labelsStackView = UIStackView()
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.axis = .vertical
        
        saveCopyStackView.addArrangedSubview(leftSpacer)
        saveCopyStackView.addArrangedSubview(imageView)
        saveCopyStackView.addArrangedSubview(labelsStackView)
        saveCopyStackView.addArrangedSubview(rightSpacer)
        
        saveCopyStackView.setCustomSpacing(0, after: leftSpacer)
        saveCopyStackView.setCustomSpacing(0, after: labelsStackView)
        
        NSLayoutConstraint.activate ([
            leftSpacer.widthAnchor.constraint(equalToConstant: 16),
            rightSpacer.widthAnchor.constraint(equalTo: leftSpacer.widthAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 20)
        ])
        
        let header = HeaderExportLabel()
        header.text = "Save a copy"
        
        let body = BodyExportLabel()
        body.text = "Creates a copy with changes that you can undo."
        
        labelsStackView.addArrangedSubview(header)
        labelsStackView.addArrangedSubview(body)
        labelsStackView.layoutMargins = .init(top: 8, left: 0, bottom: 8, right: 0)
        labelsStackView.isLayoutMarginsRelativeArrangement = true
    }
    
    func setUpSaveCopyButton() {
        saveCopyButton.translatesAutoresizingMaskIntoConstraints = false
        saveCopyButton.addTarget(self, action: #selector(self.saveVideoCopy), for: .touchUpInside)
        saveCopyStackView.addSubview(saveCopyButton)
        NSLayoutConstraint.activate ([
            saveCopyButton.trailingAnchor.constraint(equalTo: saveCopyStackView.trailingAnchor),
            saveCopyButton.leadingAnchor.constraint(equalTo: saveCopyStackView.leadingAnchor),
            saveCopyButton.topAnchor.constraint(equalTo: saveCopyStackView.topAnchor),
            saveCopyButton.bottomAnchor.constraint(equalTo: saveCopyStackView.bottomAnchor)
        ])
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: CMTime.zero, completionHandler: nil)
        }
    }
   
    public func openLooks() {
        self.view.layoutIfNeeded()
        topLooksConstraint.constant = looksViewController.view.frame.height + tabBar.frame.height
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    public func closeLooks() {
        self.view.layoutIfNeeded()
        topLooksConstraint.constant = -view.safeAreaInsets.bottom
        resetToDefaultFilter()
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    public func openExportMenu() {
        self.view.layoutIfNeeded()
        isExportViewShown = true
        topExportConstraint.constant = exportView.frame.height + tabBar.frame.height
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    public func closeExportMenu() {
        self.view.layoutIfNeeded()
        topExportConstraint.constant = -self.view.safeAreaInsets.bottom
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    public func openTools() {
        self.view.layoutIfNeeded()
        isToolsViewShown = true
        topToolsConstraint.constant = toolsViewController.view.frame.height + tabBar.frame.height
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    public func closeTools() {
        self.view.layoutIfNeeded()
        topToolsConstraint.constant = -self.view.safeAreaInsets.bottom
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func resetToDefaultFilter() {
        looksViewController.deselectFilter()
    }
    
    @objc func discardLooks() {
        resetToDefaultFilter()
    }
    
    @objc func saveFilter() {
        self.view.layoutIfNeeded()
        topLooksConstraint.constant = 146
        resetToDefaultFilter()
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func saveVideoCopy() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            switch status {
            case .authorized:
                self?.saveVideoToPhotos()
            default:
                print("Photos permissions not granted.")
                return
            }
        }
    }
    
    func saveVideoToPhotos() {
        DispatchQueue.main.async {
            self.isExportViewShown = false
        }
        guard let playerItem = videoViewController.player.currentItem else { return }
        VideoEditer.saveEditedVideo(
            choosenFilter: looksViewController.selectedFilter,
            asset: playerItem.asset
        )
    }
    
}

extension VideoEditorViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let selectedIndex = tabBar.items?.firstIndex(of: item) else { return }
        
        isLooksButtonSelected = selectedIndex == 0 && previouslySelectedIndex != selectedIndex
        
        isExportButtonSelected = selectedIndex == 2 && previouslySelectedIndex != selectedIndex
        
        isToolsButtonSelected = selectedIndex == 1 && previouslySelectedIndex != selectedIndex
        
        if previouslySelectedIndex == selectedIndex {
            previouslySelectedIndex = nil
        } else {
            previouslySelectedIndex = selectedIndex
        }
    }
}
