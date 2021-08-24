//
//  BoardViewController.swift
//  1024Demo
//
//  Created by Vishnu  Nair on 23/08/21.
//

import UIKit

class BoardViewController: UIViewController{
    

    
    @IBOutlet weak var board: BoardView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var bestLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    
    fileprivate let game: GameModel
    fileprivate var bestScore = 0
    fileprivate var autoTimer: Timer?
    fileprivate var presentedMessages = [UIButton]()
    fileprivate var swipeStart: CGPoint?
    fileprivate var lastMove = 0
    
    required init?(coder aDecoder: NSCoder) {
        if let persisted = UserDefaults.standard.object(forKey: "kPersistedModelKey") as? [Int] {
            game = GameModel(gameModel: persisted)
        } else {
            game = GameModel()
        }
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        game.delegate = self
        board.size = game.boardSize
        board.updateValuesWithModel(game.model, canSpawn: true)

        if let score = UserDefaults.standard.object(forKey: "k2048CloneHighscore") as? Int {
            bestScore = score
        }
        self.titleLabel.text = "Target :    2048"
        updateScoreLabel()
    }
    

    
    @IBAction func resetGame(_ sender: AnyObject) {
        dismissMessages()
        game.reset()
    }
    
    fileprivate func updateScoreLabel() {
        if (game.score > bestScore) {
            bestScore = game.score
            UserDefaults.standard.set(bestScore, forKey: "k2048CloneHighscore")
            UserDefaults.standard.synchronize()
        }
        
        scoreLabel.attributedText = attributedText("Score", value: "\(game.score)")
        bestLabel.attributedText = attributedText("Best", value: "\(bestScore)")
    }
    
    fileprivate func attributedText(_ title: String, value: String) -> NSAttributedString {
        let res = NSMutableAttributedString(string: title, attributes: [
            .foregroundColor : UIColor.lightGray
            ])
        res.append(NSAttributedString(string: "\n\(value)", attributes: [
            .foregroundColor : UIColor.white
            ]))
        return res
    }
    
    @objc func newGameButtonTapped(_ sender: AnyObject) {
        resetGame(sender)
    }
    
    @objc func continuePlayingButtonTapped(_ sender: AnyObject) {
        dismissMessages()
    }
    
    @objc func autoMove() {
        if autoTimer == nil || autoTimer!.isValid == false {
            autoTimer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(BoardViewController.autoMove), userInfo: nil, repeats: true)
        }
        switch(arc4random_uniform(4)) {
        case 0: shortUp()
        case 1: shortDown()
        case 2: shortRight()
        case 3: shortLeft()
        default: break
        }
    }
    
    @objc func shortUp() { game.swipe(.y(.decrease)) }
    @objc func shortDown() { game.swipe(.y(.increase)) }
    @objc func shortLeft() { game.swipe(.x(.decrease)) }
    @objc func shortRight() { game.swipe(.x(.increase)) }
}

// MARK: Touch handling
extension BoardViewController{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            swipeStart = touch.location(in: view)
            lastMove = 0
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let swipeStart = swipeStart, let touch = touches.first else { return }
        
        let treshold: CGFloat = 250.0
        let loc = touch.location(in: view)
        let diff = CGPoint(x: loc.x - swipeStart.x, y: loc.y - swipeStart.y)
        
        func evaluateDirection(_ a: CGFloat, _ b: CGFloat, _ sensitivity: CGFloat) -> Bool {
            let delta = sensitivity * max(abs(b)/(abs(a)+abs(b)), 0.05)
            return sensitivity >= 0 ? a > delta : a < delta
        }
        
        if diff.x > 0 && evaluateDirection(diff.x, diff.y, treshold) && lastMove != 1 {
            shortRight()
            lastMove = 1
        } else if diff.x < 0 && evaluateDirection(diff.x, diff.y, -treshold) && lastMove != 2 {
            shortLeft()
            lastMove = 2
        } else if diff.y > 0 && evaluateDirection(diff.y, diff.x, treshold) && lastMove != 3 {
            shortDown()
            lastMove = 3
        } else if diff.y < 0 && evaluateDirection(diff.y, diff.x, -treshold) && lastMove != 4 {
            shortUp()
            lastMove = 4
        }
        
        self.swipeStart = loc
    }
}

// MARK: External keyboard handling
extension BoardViewController {
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    override var keyCommands : [UIKeyCommand]? {
        get {
            return [
                UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [], action: #selector(BoardViewController.shortUp)),
                UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [], action: #selector(BoardViewController.shortDown)),
                UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: [], action: #selector(BoardViewController.shortLeft)),
                UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: [], action: #selector(BoardViewController.shortRight)),
                UIKeyCommand(input: " ", modifierFlags: [], action: #selector(BoardViewController.shortReset))]
        }
    }
    
    @objc func shortReset() {
        game.reset()
        
    }
}



extension BoardViewController:GameModelDelegate{
    func GameModelDidProcessMove(_ game: GameModel) {
        board.updateValuesWithModel(game.model, canSpawn: false)
        board.animateTiles()
        
        UserDefaults.standard.set(game.model, forKey: "kPersistedModelKey")
        UserDefaults.standard.synchronize()
    }
    
    func game2048GameOver(_ game: GameModel) {
        self.displayMessage("Game over!",
                            subtitle: "Tap to try again",
                            action: #selector(BoardViewController.newGameButtonTapped(_:)))
        
    }
    
    func game2048Reached2048(_ game: GameModel) {
        self.displayMessage("You win!",
                            subtitle: "Tap to continue playing",
                            action: #selector(BoardViewController.continuePlayingButtonTapped(_:)))
    }
    
    func GameModelScoreChanged(_ game: GameModel, score: Int) {
        updateScoreLabel()
        if score > 0 {
            displayScoreChangeNotification("+ \(score)")
        }
    }
    
    func GameModelTileMerged(_ game: GameModel, from: CGPoint, to: CGPoint) {
        board.moveAndRemoveTile(from: from.boardPosition, to: to.boardPosition)
    }
    
    func GameModelTileSpawnedAtPoint(_ game: GameModel, point: CGPoint) {
        board.updateValuesWithModel(game.model, canSpawn: true)
    }
    
    func GameModelTileMoved(_ game: GameModel, from: CGPoint, to: CGPoint) {
        board.moveTile(from: from.boardPosition, to: to.boardPosition)
    }
    
    func dismissMessages() {
        for message in presentedMessages {
            UIView.animate(withDuration: 0.1, animations: {
                message.alpha = 0
                }, completion: { _ in
                    message.removeFromSuperview()
            })
        }
        presentedMessages.removeAll()
    }
    
    private func displayScoreChangeNotification(_ text: String) {
        let label = UILabel(frame: scoreLabel.frame)
        label.text = text
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = scoreLabel.font
        scoreLabel.superview!.addSubview(label)
        UIView.animate(withDuration: 0.8, animations: {
            label.alpha = 0
            var rect = label.frame
            rect.origin.y += 50
            label.frame = rect
            }, completion: { _ in
                label.removeFromSuperview()
        })
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

extension BoardViewController{
    
    func showAlert(_ title: String, subtitle: String, action: Selector){
        
        let refreshAlert = UIAlertController(title: title, message: subtitle, preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action: UIAlertAction!) in
              print("Proceed to Selector")
    
        }))

        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
              print("Dismiss Alert")
        }))

        present(refreshAlert, animated: true, completion: nil)
    
    }
    
    
    func displayMessage(_ title: String, subtitle: String, action: Selector) {
        let messageButton = UIButton(type: .custom)
        
        presentedMessages.append(messageButton)
        
        messageButton.translatesAutoresizingMaskIntoConstraints = false
        messageButton.backgroundColor = UIColor(white: 1, alpha: 0.5)
        messageButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 36)
        messageButton.addTarget(self, action: action, for: .touchUpInside)
        
        let str = NSMutableAttributedString(string: "\(title)\n", attributes: [.font: UIFont.boldSystemFont(ofSize: 36)])
        str.append(NSAttributedString(string: subtitle, attributes: [
            .font : UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor : UIColor(white: 0, alpha: 0.3)
            ]))

        messageButton.setAttributedTitle(str, for: UIControl.State())
        messageButton.alpha = 0
        view.addSubview(messageButton)
        
        messageButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        messageButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1).isActive = true
        messageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        messageButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        UIView.animate(withDuration: 0.2) { messageButton.alpha = 1 }
        
        if autoTimer != nil {
            autoTimer!.invalidate()
            autoTimer = nil
        }
    }
    
}
