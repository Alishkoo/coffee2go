





import UIKit

class OrderNowBottomSheetViewController: UIViewController {

    private let name: String
    private let address: String
    private let workingHours: String?
    private let router: AppRouter

    init(name: String, address: String, workingHours: String?, router: AppRouter) {
        self.name = name
        self.address = address
        self.workingHours = workingHours
        self.router = router
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
                if #available(iOS 16.0, *) {
                    sheet.detents = [.custom(resolver: { _ in return 350 })] 
                } else {
                    sheet.detents = [.medium()]
                }
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 30
            }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @objc private func orderButtonTapped() {
        dismiss(animated: true) {
            self.router.navigateTo(.coffeeMenu, backButtonMode: .show)
        }
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 46/255, green: 27/255, blue: 14/255, alpha: 1) // #2E1B0E

        let imageView = UIImageView(image: UIImage(named: "starbucks"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 100),
            imageView.widthAnchor.constraint(equalToConstant: 100)
        ])

      
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = .boldSystemFont(ofSize: 30)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center

        let addressLabel = UILabel()
        addressLabel.text = address
        addressLabel.font = .systemFont(ofSize: 18)
        addressLabel.textColor = .white
        addressLabel.textAlignment = .center

        let hoursLabel = UILabel()
        hoursLabel.text = workingHours ?? "No hours info"
        hoursLabel.font = .systemFont(ofSize: 18)
        hoursLabel.textColor = .white
        hoursLabel.textAlignment = .center


        let infoStack = UIStackView(arrangedSubviews: [imageView, nameLabel, addressLabel, hoursLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 12
        infoStack.alignment = .center
        infoStack.translatesAutoresizingMaskIntoConstraints = false


        let orderButton = UIButton(type: .system)
        orderButton.setTitle("Order now", for: .normal)
        orderButton.setTitleColor(.black, for: .normal)
        orderButton.backgroundColor = UIColor(red: 244/255, green: 234/255, blue: 218/255, alpha: 1) // #F4EADA
        orderButton.layer.cornerRadius = 25
        orderButton.titleLabel?.font = .boldSystemFont(ofSize: 22)
        orderButton.translatesAutoresizingMaskIntoConstraints = false
        orderButton.addTarget(self, action: #selector(orderButtonTapped), for: .touchUpInside)

        view.addSubview(infoStack)
        view.addSubview(orderButton)


        NSLayoutConstraint.activate([
            infoStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            infoStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            orderButton.topAnchor.constraint(equalTo: infoStack.bottomAnchor, constant: 50),
            orderButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            orderButton.heightAnchor.constraint(equalToConstant: 50),
            orderButton.widthAnchor.constraint(equalToConstant: 220)
        ])
    }
}
