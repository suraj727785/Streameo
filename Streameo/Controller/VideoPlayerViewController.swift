import UIKit
import AVKit
import AVFoundation

class VideoPlayerViewController: UIViewController {

    var mediaItemId: String?
    var videoURL: URL?
    var player: AVPlayer?
    var playerViewController: AVPlayerViewController?
    var currentWatchedDuration: CMTime = .zero

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        guard let mediaItemId = mediaItemId,
              let mediaItem = MediaDataManager.shared.getMediaItem(by: mediaItemId),
              let videoURLString = mediaItem.url?.replacingOccurrences(of: "http", with: "https"),
              let videoURL = URL(string: videoURLString) else {
            print("Invalid video URL")
            return
        }

        self.videoURL = videoURL
        self.currentWatchedDuration = CMTime(seconds: Double(mediaItem.lastPlayedDuration), preferredTimescale: 1)
        setupPlayer(with: videoURL)
    }

    func setupPlayer(with url: URL) {
        player = AVPlayer(url: url)
        playerViewController = AVPlayerViewController()
        playerViewController?.player = player

        guard let playerViewController = playerViewController else { return }

        addChild(playerViewController)
        view.addSubview(playerViewController.view)
        playerViewController.view.frame = view.bounds
        playerViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        playerViewController.didMove(toParent: self)
        
        player?.seek(to: currentWatchedDuration, completionHandler: { [weak self] _ in
            self?.player?.play()
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
        saveCurrentWatchedDuration()
    }

    func saveCurrentWatchedDuration() {
        guard let player = player, let mediaItemId = mediaItemId else { return }
        currentWatchedDuration = player.currentTime()
        MediaDataManager.shared.updateLastPlayedDuration(lastPlayed: Int(currentWatchedDuration.seconds), id: mediaItemId)
    }
}
