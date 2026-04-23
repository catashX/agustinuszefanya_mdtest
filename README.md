# FANINTEK Mobile Developer Test

A complete Flutter application developed for the FANINTEK Mobile Developer Technical Test. This project showcases a robust, production-ready architecture employing Clean Architecture principles, the BLoC pattern for state management, and comprehensive integration with Firebase Authentication and Cloud Firestore.

## 🌟 Features Completed

### 1. Authentication (20 Points)
- Fully functional Login, Registration, and Forgot Password screens.
- Secure credential handling utilizing Firebase Authentication.

### 2. Home Page (40 Points)
- Displays the authenticated user's name and email verification status.
- Retrieves and displays a real-time list of all registered users directly from Cloud Firestore.
- Advanced local filtering functionality allowing users to filter by email verification status.
- Search functionality to locate users by their name or email address seamlessly.

### 3. Email Verification (15 Points)
- Automatically triggers a verification email to the user upon successful registration.
- Dynamic UI updates reflecting the user's real-time verification status on the Home Page.

### 4. Password Reset (15 Points)
- Users can securely request a password reset link sent to their registered email address via the dedicated Forgot Password screen.

### 5. Unit Tests (10 Points)
- Contains critical unit tests for Use Cases, BLoCs, and Repositories utilizing robust mocking strategies. (Run with `flutter test`).

---

## 🏗️ Architecture & Project Structure

This project strictly adheres to **Clean Architecture** principles to separate concerns, improve maintainability, and ensure the codebase is highly testable. The application is divided into feature-based modules (`auth` and `home`), each containing three primary layers:

### 1. Domain Layer (The Core)
The most independent layer, containing the core business logic. It has no dependencies on external frameworks or packages (except `dartz` and `equatable`).
- **Entities**: Pure data objects representing the core business models (e.g., `UserEntity`).
- **Repositories (Interfaces)**: Abstract contracts defining the required data operations (e.g., `AuthRepository`).
- **Use Cases**: Encapsulate specific, single-responsibility business rules (e.g., `LoginUseCase`, `GetUsersUseCase`).

### 2. Data Layer
Responsible for data retrieval and manipulation. It implements the contracts defined in the Domain layer.
- **Models**: Extensions of Entities that include serialization logic (e.g., `UserModel.fromJson`).
- **Data Sources**: Handle direct communication with external APIs or databases (e.g., `AuthRemoteDataSource` interacting with Firebase).
- **Repositories (Implementations)**: Concrete implementations of the Domain Repository interfaces. They coordinate data sources and handle error catching, converting raw exceptions into standardized `Failure` objects using the `dartz` package.

### 3. Presentation Layer
Handles the user interface and state management.
- **BLoC (Business Logic Component)**: Manages state transitions. It listens to UI events, executes the appropriate Use Cases, and yields new states back to the UI.
- **Pages/Widgets**: Pure UI components that observe BLoC states and dispatch events based on user interactions.

---

## 🔄 State Management & Data Flow

The application utilizes the **BLoC (Business Logic Component)** pattern to ensure a unidirectional data flow:

1. **User Interaction**: The user interacts with the UI (e.g., taps the "Login" button).
2. **Event Dispatch**: The UI dispatches an event (e.g., `LoginButtonPressed`) to the corresponding BLoC.
3. **Use Case Execution**: The BLoC processes the event and calls the necessary Use Case from the Domain layer.
4. **Data Fetching**: The Use Case requests data via the Repository interface.
5. **Remote Communication**: The Repository Implementation delegates the request to the Remote Data Source (Firebase Auth/Firestore), handles exceptions, and returns an `Either<Failure, Success>` object.
6. **State Yielding**: The BLoC interprets the result and yields a new State (e.g., `AuthLoading`, followed by `AuthAuthenticated` or `AuthError`).
7. **UI Rebuild**: The UI (`BlocBuilder` / `BlocConsumer`) observes the new state and rebuilds accordingly, showing a success message, navigating to a new screen, or displaying an error snackbar.

---

## 💉 Dependency Injection (DI)

To loosely couple our classes and enable seamless testing, the project utilizes `get_it` for Dependency Injection.
All dependencies are registered in `lib/injection_container.dart` in a specific order:
1. **External**: Firebase instances (`FirebaseAuth.instance`, `FirebaseFirestore.instance`).
2. **Data Sources**: Remote data sources receiving the external instances.
3. **Repositories**: Repository implementations receiving data sources.
4. **Use Cases**: Use cases receiving the repository interfaces.
5. **BLoCs**: BLoCs receiving the necessary use cases.

This setup ensures that we can easily swap out production implementations with mocks during unit testing.

---

## 🛠️ Third-Party Libraries & Justification

- **`flutter_bloc` / `bloc`**: Standardized, predictable state management separating business logic from the UI.
- **`firebase_core` / `firebase_auth` / `cloud_firestore`**: Essential SDKs providing the backend infrastructure for authentication and scalable NoSQL database storage.
- **`get_it`**: A robust Service Locator for clean Dependency Injection.
- **`dartz`**: Introduces functional programming concepts (specifically `Either`), forcing developers to handle both Success and Failure paths explicitly at compile-time.
- **`equatable`**: Eliminates boilerplate code when overriding `==` and `hashCode`, crucial for efficient BLoC state comparisons.
- **`mocktail` / `bloc_test`**: Essential dev-dependencies for creating mocks and writing streamlined, readable unit tests for BLoCs.

---

## 🚀 Installation & Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/agustinuszefanya_mdtest.git
   cd agustinuszefanya_mdtest
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase (Required)**
   Since this application is heavily dependent on Firebase, you must connect it to your own Firebase Project.
   Ensure you have the Firebase CLI installed and are authenticated.
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   *Follow the terminal prompts to link your Firebase project. Ensure you enable both **Email/Password Authentication** and **Cloud Firestore** in your Firebase console.*

4. **Run the Application**
   ```bash
   flutter run
   ```

5. **Run Unit Tests**
   Execute the suite of unit tests to verify the core logic:
   ```bash
   flutter test
   ```

---

## ✅ Requirements Checked
- [x] Login Screen
- [x] Registration Screen
- [x] Forgot Password Screen
- [x] Display user's name and email verification status on Home
- [x] Display list of users from Firestore
- [x] Filter users by email verification status
- [x] Search user by name or email
- [x] Verification email upon registration
- [x] Reset password via email
- [x] Unit tests for critical components
- [x] Clean Architecture implementation
