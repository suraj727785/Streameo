import UIKit

class DetailViewController: UIViewController {
    
    var mediaItem: MediaItem?
    var relatedItems: [MediaItem]?

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.numberOfLines = 3
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let relatedLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.text = "Related"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let relatedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        setupCollectionView()
    }
    
    private func setupUI() {
        guard let mediaItem = mediaItem else { return }
        
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(relatedLabel)
        view.addSubview(relatedCollectionView)
        let tapGesture = UITapGestureRecognizer(target: self, action:  #selector(handleVideoTapImageTap(_:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            relatedLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            relatedLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            relatedCollectionView.topAnchor.constraint(equalTo: relatedLabel.bottomAnchor, constant: 8),
            relatedCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            relatedCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            relatedCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        titleLabel.text = mediaItem.title
        descriptionLabel.text = mediaItem.descriptionText
        
        if let thumbUrl = URL(string: mediaItem.thumb!) {
            downloadImage(from: thumbUrl, for: imageView)
        }
    }
    @objc func handleVideoTapImageTap(_ sender: UITapGestureRecognizer) {
        if sender.view is UIImageView{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let videoVC = storyboard.instantiateViewController(withIdentifier: "videoVC") as? VideoPlayerViewController else {
                print("Failed to instantiate Detail ViewController")
                return
            }
            videoVC.mediaItemId = self.mediaItem?.id
            self.navigationController?.pushViewController(videoVC, animated: false)
        }
    }
    @objc func handleRelatedItemsImageTap(_ sender: UITapGestureRecognizer) {
        if let collectionView = sender.view?.superview as? UICollectionView,
           let indexPath = collectionView.indexPath(for: sender.view as! UICollectionViewCell){
            let mediaItem = relatedItems![indexPath.item]
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let detailVC = storyboard.instantiateViewController(withIdentifier: "detailVC") as? DetailViewController else {
                print("Failed to instantiate Detail ViewController")
                return
            }
            relatedItems = relatedItems!.filter({$0.id! != mediaItem.id!})
            relatedItems?.append(self.mediaItem!)
            detailVC.mediaItem = mediaItem
            detailVC.relatedItems = relatedItems
            self.navigationController?.pushViewController(detailVC, animated: false)
        }
    }
    private func setupCollectionView() {
        relatedCollectionView.delegate = self
        relatedCollectionView.dataSource = self
        relatedCollectionView.register(RelatedCollectionViewCell.self, forCellWithReuseIdentifier: "RelatedCell")
        
        if let layout = relatedCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = (view.frame.width - 60) / 3 // 16 for leading + 16 for trailing + 16 for spacing
            layout.itemSize = CGSize(width: width, height: 180)
        }
    }
    
    private func downloadImage(from url: URL, for imageView: UIImageView) {
        let url = URL(string: url.absoluteString.replacingOccurrences(of: "http", with: "https"))!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                imageView.image = image
            }
        }.resume()
    }
}

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return relatedItems?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RelatedCell", for: indexPath) as! RelatedCollectionViewCell
        cell.configure(with: relatedItems![indexPath.item])
        let tapGesture = UITapGestureRecognizer(target: self, action:  #selector(handleRelatedItemsImageTap(_:)))
        cell.isUserInteractionEnabled = true
        cell.addGestureRecognizer(tapGesture)
        return cell
    }
}

class RelatedCollectionViewCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with mediaItem: MediaItem) {
        if let thumbUrl = URL(string: mediaItem.thumb!) {
            CommonUtilityFunctions.shared.downloadImage(from: thumbUrl, for: self.imageView)
        }
    }
}
