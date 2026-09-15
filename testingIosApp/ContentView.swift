import UIKit
import SwiftUI
import tradeableIOSWrapper

private enum PresentedTradeableScreen {
    case topic(Int)
    case course(Int)
    case dashboard
    case userProgress
}

final class ContentViewController: UIViewController {

    private let navigator = TradeableFlutterNavigator.shared
    private var sideDrawerPageId = 6

    private var isDrawerVisible = false
    private var dimmingView: UIView?
    private var drawerView: UIView?
    private var drawerHostingController: UIHostingController<TradeableFlutterView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpScrollContent()

        navigator.registerDataHandler { [weak self] payload in
            self?.handleFlutterNavigationEvent(payload)
        }
    }

    // MARK: - Layout

    private func setUpScrollContent() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])

        stack.addArrangedSubview(makeHeaderView())

        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = .separator
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        stack.addArrangedSubview(divider)

        let directSection = makeSectionView(title: "Direct Mode")
        let directContainer = UIView()
        directContainer.translatesAutoresizingMaskIntoConstraints = false
        directContainer.heightAnchor.constraint(equalToConstant: 220).isActive = true
        directSection.addArrangedSubview(directContainer)
        embed(
            TradeableFlutterView(
                mode: .direct,
                width: 320,
                height: 220,
                data: ["text": "Trading Widget"]
            ),
            in: directContainer
        )
        stack.addArrangedSubview(directSection)

        let cardFlipSection = makeSectionView(title: "Card Flip Mode")
        let cardFlipContainer = UIView()
        cardFlipContainer.translatesAutoresizingMaskIntoConstraints = false
        cardFlipContainer.heightAnchor.constraint(equalToConstant: 220).isActive = true
        cardFlipSection.addArrangedSubview(cardFlipContainer)
        embed(
            TradeableFlutterView(
                mode: .cardFlip,
                width: 320,
                height: 220,
                data: ["text": "Tap to Flip"]
            ),
            in: cardFlipContainer
        )
        stack.addArrangedSubview(cardFlipSection)

        let fullscreenSection = makeSectionView(title: "Fullscreen Mode")
        let fullscreenContainer = UIView()
        fullscreenContainer.translatesAutoresizingMaskIntoConstraints = false
        fullscreenContainer.heightAnchor.constraint(equalToConstant: 60).isActive = true
        fullscreenSection.addArrangedSubview(fullscreenContainer)
        embed(
            TradeableFlutterView(
                mode: .fullscreen,
                data: ["text": "Open Fullscreen"],
                topicId: 6
            ),
            in: fullscreenContainer
        )
        stack.addArrangedSubview(fullscreenSection)

        let drawerButton = UIButton(type: .system)
        drawerButton.setTitle("Open Tradeable Side Drawer", for: .normal)
        drawerButton.setTitleColor(.white, for: .normal)
        drawerButton.backgroundColor = .systemPink
        drawerButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
        drawerButton.layer.cornerRadius = 10
        drawerButton.translatesAutoresizingMaskIntoConstraints = false
        drawerButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        drawerButton.addTarget(self, action: #selector(openDrawerTapped), for: .touchUpInside)
        stack.addArrangedSubview(drawerButton)

        let userProgressSection = makeSectionView(title: "User Progress")
        let userProgressContainer = UIView()
        userProgressContainer.translatesAutoresizingMaskIntoConstraints = false
        userProgressContainer.heightAnchor.constraint(equalToConstant: 400).isActive = true
        userProgressSection.addArrangedSubview(userProgressContainer)
        embed(
            TradeableFlutterView(
                mode: .userProgress,
                width: 360,
                height: 400
            ),
            in: userProgressContainer
        )
        stack.addArrangedSubview(userProgressSection)
    }

    private func makeHeaderView() -> UIStackView {
        let header = UIStackView()
        header.axis = .vertical
        header.spacing = 8
        header.alignment = .center

        let imageView = UIImageView(image: UIImage(systemName: "chart.line.uptrend.xyaxis"))
        imageView.image = imageView.image?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 50))
        imageView.tintColor = view.tintColor
        imageView.contentMode = .scaleAspectFit
        header.addArrangedSubview(imageView)

        let titleLabel = UILabel()
        titleLabel.text = "Tradeable iOS Wrapper Demo"
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        header.addArrangedSubview(titleLabel)

        return header
    }

    private func makeSectionView(title: String) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill

        let label = UILabel()
        label.text = title
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        stack.addArrangedSubview(label)

        return stack
    }

    @discardableResult
    private func embed<Content: View>(_ rootView: Content, in container: UIView) -> UIHostingController<Content> {
        let hostingController = UIHostingController(rootView: rootView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        addChild(hostingController)
        container.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: container.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return hostingController
    }

    // MARK: - Side Drawer

    @objc private func openDrawerTapped() {
        guard !isDrawerVisible else { return }

        let drawerWidth = view.bounds.width - 32
        let drawerHeight = view.bounds.height

        let dimming = UIView()
        dimming.translatesAutoresizingMaskIntoConstraints = false
        dimming.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        dimming.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeDrawer)))
        view.addSubview(dimming)

        NSLayoutConstraint.activate([
            dimming.topAnchor.constraint(equalTo: view.topAnchor),
            dimming.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimming.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimming.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        dimmingView = dimming

        let drawer = UIView()
        drawer.translatesAutoresizingMaskIntoConstraints = false
        drawer.backgroundColor = .white
        drawer.layer.shadowColor = UIColor.black.cgColor
        drawer.layer.shadowOpacity = 0.2
        drawer.layer.shadowRadius = 12
        drawer.layer.shadowOffset = CGSize(width: -3, height: 0)
        view.addSubview(drawer)

        NSLayoutConstraint.activate([
            drawer.topAnchor.constraint(equalTo: view.topAnchor),
            drawer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            drawer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            drawer.widthAnchor.constraint(equalToConstant: drawerWidth)
        ])
        drawerView = drawer

        drawerHostingController = embed(
            TradeableFlutterView(
                mode: .sideDrawer,
                width: drawerWidth,
                height: drawerHeight,
                data: ["text": "Native Side Drawer"],
                pageId: sideDrawerPageId,
                onCloseSideDrawer: { [weak self] in
                    self?.closeDrawer()
                }
            ),
            in: drawer
        )

        isDrawerVisible = true
        dimming.alpha = 0
        drawer.transform = CGAffineTransform(translationX: drawerWidth, y: 0)
        view.layoutIfNeeded()

        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            dimming.alpha = 1
            drawer.transform = .identity
        })
    }

    @objc private func closeDrawer() {
        guard isDrawerVisible, let dimming = dimmingView, let drawer = drawerView else { return }

        isDrawerVisible = false
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            dimming.alpha = 0
            drawer.transform = CGAffineTransform(translationX: drawer.bounds.width, y: 0)
        }, completion: { _ in
            self.drawerHostingController?.willMove(toParent: nil)
            self.drawerHostingController?.view.removeFromSuperview()
            self.drawerHostingController?.removeFromParent()
            self.drawerHostingController = nil
            dimming.removeFromSuperview()
            drawer.removeFromSuperview()
            self.dimmingView = nil
            self.drawerView = nil
        })
    }

    // MARK: - Fullscreen Content

    private func presentFullscreen(_ rootView: TradeableFlutterView) {
        let hostingController = UIHostingController(rootView: rootView)
        hostingController.view.backgroundColor = .white
        hostingController.modalPresentationStyle = .fullScreen
        present(hostingController, animated: true)
    }

    // MARK: - Flutter Navigation Events

    private func handleFlutterNavigationEvent(_ payload: [String: Any]) {
        guard let action = payload["action"] as? String else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.closeDrawer()

            let screenSize = UIScreen.main.bounds.size

            switch action {
            case "openTopic":
                let topicId = payload["topicId"] as? Int ?? 0
                if topicId > 0 {
                    self.presentFullscreen(
                        TradeableFlutterView(
                            mode: .fullscreenContent,
                            width: screenSize.width,
                            height: screenSize.height,
                            data: ["text": "Topic Detail"],
                            topicId: topicId,
                            onCloseFullscreen: { [weak self] in
                                self?.dismiss(animated: true)
                            }
                        )
                    )
                }
            case "openCourseDetails":
                let courseId = payload["courseId"] as? Int ?? 0
                if courseId > 0 {
                    self.presentFullscreen(
                        TradeableFlutterView(
                            mode: .courseDetailsContent,
                            width: screenSize.width,
                            height: screenSize.height,
                            data: ["text": "Course Details"],
                            courseId: courseId,
                            onCloseFullscreen: { [weak self] in
                                self?.dismiss(animated: true)
                            }
                        )
                    )
                }
            case "openDashboard":
                self.presentFullscreen(
                    TradeableFlutterView(
                        mode: .dashboardContent,
                        width: screenSize.width,
                        height: screenSize.height,
                        data: ["text": "Learn Dashboard"],
                        onCloseFullscreen: { [weak self] in
                            self?.dismiss(animated: true)
                        }
                    )
                )
            case "openUserProgress":
                self.presentFullscreen(
                    TradeableFlutterView(
                        mode: .userProgressContent,
                        width: screenSize.width,
                        height: screenSize.height,
                        data: ["text": "My Activity"],
                        onCloseFullscreen: { [weak self] in
                            self?.dismiss(animated: true)
                        }
                    )
                )
            default:
                break
            }
        }
    }
}