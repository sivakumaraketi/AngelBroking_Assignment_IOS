//
//  Extensions.swift
//  AngelBroking_IOSTest
//
//  Created by Amsys on 17/02/20.
//  Copyright © 2020 SivaKumarAketi. All rights reserved.
//

import UIKit

//Extension for alertview
extension UIViewController {
    func alertMessageOK(for alert: String) {
        let alert = UIAlertController(title: title, message: alert, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)

    }
}
