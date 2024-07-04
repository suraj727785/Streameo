import UIKit

class HomeViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bannerTitle: UILabel!
    @IBOutlet weak var BannerPlayButton: UIButton!
    @IBOutlet weak var popularSectionTitle: UILabel!
    @IBOutlet weak var newReleaseSectionTitle: UILabel!
    @IBOutlet weak var newReleasesCollectionView: UICollectionView!
    @IBOutlet weak var popularCollectionView: UICollectionView!
    
    var imageViews: [UIImageView] = []
    var bannerData: [MediaItem] = []
    var newReleasesData: [MediaItem] = []
    var popularData: [MediaItem] = []
    var completeData: [MediaItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        setupScrollView()
        fetchMediaData()
        setupNewReleasesSection()
        setupPopularSection()
        setupConstraints()
        
        scrollView.tag = 1
        newReleasesCollectionView.tag = 2
        popularCollectionView.tag = 3
    }
    
    func setupScrollView() {
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func fetchMediaData() {
        MediaDataManager.shared.fetchDataFromAPI() {
            let mediaData = MediaDataManager.shared.fetchAllMediaItems()
            self.newReleasesData = Array(mediaData.prefix(5))
            self.popularData = Array(mediaData.suffix(from: 5))
            self.bannerData = Array(mediaData.shuffled().prefix(5))
            self.completeData = Array(mediaData)
            DispatchQueue.main.async {
                self.loadScrollViewWithImages()
                self.newReleasesCollectionView.reloadData()
                self.popularCollectionView.reloadData()
            }
        }
    }
    
    func loadScrollViewWithImages() {
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(newReleasesData.count), height: 250)
        
        for (index, mediaItem) in bannerData.enumerated() {
            if let thumbUrl = URL(string: mediaItem.thumb!) {
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.layer.cornerRadius = 10
                imageView.translatesAutoresizingMaskIntoConstraints = false
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBannerImageTap(_:)))
                imageView.isUserInteractionEnabled = true
                imageView.addGestureRecognizer(tapGesture)
                imageView.tag = index
                
                CommonUtilityFunctions.shared.downloadImage(from: thumbUrl, for: imageView)
                
                bannerTitle.text = mediaItem.title
                bannerTitle.textColor = .white
                bannerTitle.font = UIFont.boldSystemFont(ofSize: 16)
                bannerTitle.numberOfLines = 2
                bannerTitle.translatesAutoresizingMaskIntoConstraints = false
                BannerPlayButton.translatesAutoresizingMaskIntoConstraints = false
                BannerPlayButton.layer.zPosition = 1
                bannerTitle.layer.zPosition = 1
                scrollView.addSubview(imageView)
                imageViews.append(imageView)
                
                NSLayoutConstraint.activate([
                    imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: CGFloat(index) * view.frame.width),
                    imageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: CGFloat(5)),
                    imageView.widthAnchor.constraint(equalTo: view.widthAnchor),
                    imageView.heightAnchor.constraint(equalToConstant: 250),
                ])
            }
        }
    }
    
    @objc func handleBannerImageTap(_ sender: UITapGestureRecognizer) {
        if let index = sender.view?.tag {
            let mediaItem = bannerData[index]
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let detailVC = storyboard.instantiateViewController(withIdentifier: "detailVC") as? DetailViewController else {
                print("Failed to instantiate Detail ViewController")
                return
            }
            completeData = completeData.filter({$0.id! != mediaItem.id!})
            detailVC.mediaItem = mediaItem
            detailVC.relatedItems = completeData
            self.navigationController?.pushViewController(detailVC, animated: false)
        }
    }
    
    @objc func handlePopularOrNewReleaseImageTap(_ sender: UITapGestureRecognizer) {
        if let collectionView = sender.view?.superview?.superview?.superview as? UICollectionView,
           let indexPath = collectionView.indexPath(for: sender.view!.superview?.superview as! UICollectionViewCell){
            let mediaItem = collectionView == newReleasesCollectionView ? newReleasesData[indexPath.item] : popularData[indexPath.item]
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let detailVC = storyboard.instantiateViewController(withIdentifier: "detailVC") as? DetailViewController else {
                print("Failed to instantiate Detail ViewController")
                return
            }
            completeData = completeData.filter({$0.id! != mediaItem.id!})
            detailVC.mediaItem = mediaItem
            detailVC.relatedItems = completeData
            self.navigationController?.pushViewController(detailVC, animated: false)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.tag != 1 {
            return
        }
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        let currentPage = Int(pageIndex)
        
        guard currentPage >= 0 && currentPage < newReleasesData.count else {
            return
        }
        
        for (index, imageView) in imageViews.enumerated() {
            if index != currentPage {
                imageView.transform = .identity
            }
        }
        
        let offset = scrollView.contentOffset.x - view.frame.width * CGFloat(currentPage)
        let absOffset = abs(offset)
        
        let scale = max(0.6, 1 - 0.4 * absOffset / view.frame.width)
        
        if currentPage < imageViews.count - 1 {
            let nextImageView = imageViews[currentPage + 1]
            let nextMediaData = bannerData[currentPage + 1]
            bannerTitle.text = nextMediaData.title
            nextImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        
        if currentPage > 0 {
            let previousImageView = imageViews[currentPage - 1]
            let previousMediaData = bannerData[currentPage - 1]
            bannerTitle.text = previousMediaData.title
            previousImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    func setupNewReleasesSection() {
        newReleaseSectionTitle.text = "New Releases"
        newReleaseSectionTitle.textColor = .white
        newReleaseSectionTitle.font = UIFont.boldSystemFont(ofSize: 20)
        newReleaseSectionTitle.translatesAutoresizingMaskIntoConstraints = false
        
        newReleasesCollectionView.backgroundColor = .black
        newReleasesCollectionView.showsHorizontalScrollIndicator = false
        newReleasesCollectionView.delegate = self
        newReleasesCollectionView.dataSource = self
        newReleasesCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "NewReleaseCell")
        newReleasesCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupPopularSection() {
        popularSectionTitle.text = "Popular"
        popularSectionTitle.textColor = .white
        popularSectionTitle.font = UIFont.boldSystemFont(ofSize: 20)
        popularSectionTitle.translatesAutoresizingMaskIntoConstraints = false
        
        popularCollectionView.backgroundColor = .black
        popularCollectionView.showsHorizontalScrollIndicator = false
        popularCollectionView.delegate = self
        popularCollectionView.dataSource = self
        popularCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "PopularCell")
        popularCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 250),
            
            newReleasesCollectionView.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 20),
            newReleasesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newReleasesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newReleasesCollectionView.heightAnchor.constraint(equalToConstant: 240),
            
            popularCollectionView.topAnchor.constraint(equalTo: newReleasesCollectionView.bottomAnchor, constant: 20),
            popularCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            popularCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            popularCollectionView.heightAnchor.constraint(equalToConstant: 240)
        ])
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == newReleasesCollectionView {
            return newReleasesData.count
        } else if collectionView == popularCollectionView {
            return popularData.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionView == newReleasesCollectionView ? "NewReleaseCell" : "PopularCell", for: indexPath)
        
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let imageView = UIImageView(frame: cell.contentView.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        
        let tapGesture = UITapGestureRecognizer(target: self, action:  #selector(handlePopularOrNewReleaseImageTap(_:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
        
        let mediaItem = collectionView == newReleasesCollectionView ? newReleasesData[indexPath.item] : popularData[indexPath.item]
        
        if let thumbUrl = URL(string: mediaItem.thumb!) {
            CommonUtilityFunctions.shared.downloadImage(from: thumbUrl, for: imageView)
        }
        cell.contentView.addSubview(imageView)
        return cell
    }
}
