//
//  NewsListViewController.swift
//  umiiiku
//
//  Created by 村上英夫 on 2020/11/14.
//  Copyright © 2020 村上英夫. All rights reserved.
//

import UIKit

class NewsListViewController: UIViewController {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var newsListCollectionView: UICollectionView!
    
    private var prevContentOffset: CGPoint = .init(x: 0, y: 0)
    private let headerMoveheight: CGFloat = 7
    
    private let cellId = "cellId"
    private var newsContents = [Content]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.layer.cornerRadius = 20
        
        newsListCollectionView.delegate = self
        newsListCollectionView.dataSource = self
        
        newsListCollectionView.register(UINib(nibName: "NewsListCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        
        fetchMicroCmsInfo()
        
        newsListCollectionView.refreshControl = UIRefreshControl()
        newsListCollectionView.refreshControl?.addTarget(self,
                                                         action: #selector(didPullToRefresh),
                                                         for: .valueChanged)
        
    }

    @objc func didPullToRefresh() {
        fetchMicroCmsInfo()
    }
        
        private func fetchMicroCmsInfo() {
            
            if newsListCollectionView.refreshControl?.isRefreshing == true {
                print("refreshing data")
            } else {
                print("fetching data")
            }
            
            let url = URL(string: "https://umiiiku.microcms.io/api/v1/news")!
            var request = URLRequest(url: url)
            request.addValue("d655a7b9-b9ab-4883-a6e5-5d2d939b396b", forHTTPHeaderField: "X-API-KEY")
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if error == nil, let data = data, let _ = response as? HTTPURLResponse {
                    print(String(data: data, encoding: String.Encoding.utf8) ?? "")
                         
                    do {
                        let decoder = JSONDecoder()
                        let news = try decoder.decode(News.self, from: data)
                        self.newsContents = news.contents
                        
                        DispatchQueue.main.sync {
                            self.newsListCollectionView.refreshControl?.endRefreshing()
                            self.newsListCollectionView.reloadData()
                        }
                          
                    } catch {
                        print("CMSの変換に失敗しました", error)
                    }
                    
                }
            }.resume()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.prevContentOffset = scrollView.contentOffset
        }
        
        guard let presentIndexPath = newsListCollectionView.indexPathForItem(at: scrollView.contentOffset) else { return }
        if scrollView.contentOffset.y < 0 { return }
        if presentIndexPath.row >= newsContents.count - 2 { return }
        
        let alphaRatio = 1 / headerHeightConstraint.constant
        
        if prevContentOffset.y < scrollView.contentOffset.y {
            if headerTopConstraint.constant <= -headerHeightConstraint.constant { return }
            headerTopConstraint.constant -= headerMoveheight
            headerView.alpha -= alphaRatio * headerMoveheight
        } else if prevContentOffset.y > scrollView.contentOffset.y {
            if headerTopConstraint.constant >= 0 { return }
            headerTopConstraint.constant += headerMoveheight
            headerView.alpha += alphaRatio * headerMoveheight
        }
        print("prevContentOffset: ", self.prevContentOffset, "scrollView.contentOffset: ", scrollView.contentOffset)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            headerViewEndAnimation()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        headerViewEndAnimation()
    }
        
    func headerViewEndAnimation(){
        if headerTopConstraint.constant < -headerHeightConstraint.constant / 2 {
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.8, options: [], animations: {
                
                self.headerTopConstraint.constant = -self.headerHeightConstraint.constant
                self.headerView.alpha = 0
                self.view.layoutIfNeeded()
                
            })
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.8, options: [], animations: {
                self.headerTopConstraint.constant = 0
                self.headerView.alpha = 1
                self.view.layoutIfNeeded()
            })
        }
    }
    
}

extension NewsListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let newsViewController = UIStoryboard(name: "News", bundle: nil).instantiateViewController(identifier: "NewsViewController") as NewsViewController
        newsViewController.modalPresentationStyle = .fullScreen
        newsViewController.selectedNews = newsContents[indexPath.row]
        self.present(newsViewController, animated: true, completion: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.view.frame.width
        
        return .init(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newsContents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = newsListCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NewsListCell
        cell.newsContent = newsContents[indexPath.row]
        return cell
    }
    
    
    
    
}
