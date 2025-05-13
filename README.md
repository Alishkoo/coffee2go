# ☕ coffee2go

**coffee2go** — это iOS-приложение, разработанное с использованием **SwiftUI** и архитектуры **MVVM**, в котором можно найти ближайшую кофейню, сделать предзаказ и по пути скоротать время, играя в встроенную мини-игру **FourElements**.


---

## Основной функционал

- Поиск ближайших кофеен по геолокации
- Предзаказ напитков и блюд
- Оповещение о готовности заказа
- Мини-игра DuoElements внутри приложения
- Авторизация через Firebase (email + пароль)
- Хранение пользовательских данных в `UserDefaults`

---

## Архитектура

Проект построен на архитектуре **MVVM**:

- Логика отображения и бизнес-логика строго разделены
- Навигация реализована через UIKit (`UIHostingController`)
- Используется `UINavigationController` как основной навигационный стек

---

## Технологии и инструменты

- **SwiftUI + MVVM**
- **UIKit Navigation**
- **Firebase Authentication**
- **Swift Concurrency** (`async/await`, `Task`)
- **Combine** и `@StateObject`, `@Published`
- **UserDefaults** для хранения данных
- **SPM (Swift Package Manager)** для управления зависимостями

---

**Авторы проекта**:  
[@Nurkenproga](https://github.com/Nurkenproga) — Нуркен Атабай  
[@Alishkoo](https://github.com/Alishkoo) — Байшоланов Алибек  
[@bagdatkamila](https://github.com/bagdatkamila) — Багдат Камила
