import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let viewController = ViewController()
        
        let navigationController = UINavigationController(rootViewController: viewController)
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        window.frame = UIScreen.main.bounds
        
        self.window = window
        window.makeKeyAndVisible()
    }
}

// Sources:
// https://developer.apple.com/documentation/uikit
//https://developer.apple.com/documentation/uikit/uiwindow
//https://developer.apple.com/documentation/uikit/uiwindowscene
