//
//  SplashViewController.swift
//  1024Demo
//
//  Created by Vishnu  Nair on 23/08/21.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor("#26495c")
        self.perform(#selector(loadNextViewController), with: nil, afterDelay: 3)
    }
    
    @objc func loadNextViewController(){
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let boardViewController = mainStoryboard.instantiateViewController(withIdentifier: "BoardViewController") as! BoardViewController
        boardViewController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        self.present(boardViewController, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
