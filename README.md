# FemmeFatale - Relationship Advice App

FemmeFatale is a relationship and dating advice app, designed to provide personalized, supportive, and empowering advice specifically for women. It takes on the persona of a "big sister," offering concise and helpful insights while maintaining an empathetic and relatable tone.

## Features

- **Anonymous Authentication**: Users can sign in anonymously to maintain privacy.
- **Custom Relationship Advice**: Get advice tailored to your personal needs with the persona of a supportive, non-judgmental "big sister."
- **Empathy-Focused Responses**: The assistant acknowledges and validates emotions while offering practical, actionable steps.
- **AI-Driven Conversations**: Built with OpenAI's GPT-4 model, fine-tuned through system prompts to provide relatable, friendly, and concise advice.

## Tech Stack

- **Frontend**: Flutter, for a smooth cross-platform mobile experience.
- **State Management**: Riverpod, for efficient and reactive UI updates.
- **Backend**: Firebase for authentication, Firestore for storing user data.
- **AI Integration**: OpenAI API for generating advice responses.
- **HTTP Requests**: Using the `http` package for seamless communication with the AI backend.

## Getting Started

### Prerequisites

- **Flutter**: Install Flutter SDK by following the [official documentation](https://flutter.dev/docs/get-started/install).
- **Firebase Account**: Set up a Firebase project and connect it to the app.
- **OpenAI API Key**: Obtain an API key from OpenAI to enable AI-driven conversations.

### Installation

1. **Clone the Repository**:
   ```sh
   git clone https://github.com/username/femmefatale.git
   ```

2. **Navigate to the Project Directory**:
   ```sh
   cd femmefatale
   ```

3. **Install Dependencies**:
   ```sh
   flutter pub get
   ```

4. **Set Up Firebase**:
   - Add your `google-services.json` for Android and `GoogleService-Info.plist` for iOS to the respective folders.

5. **Configure OpenAI API Key**:
   - Add your OpenAI API key to the `Constants` class.

### Running the App

Run the app using the following command:
```sh
flutter run
```

## Usage

- **Anonymous Sign-In**: Users can sign in anonymously to start using the app immediately without sharing personal information.
- **Get Advice**: Ask questions about relationships or dating, and receive friendly, concise, and actionable advice from the AI.
- **Friendly Conversations**: Experience the app's empathetic tone, with responses crafted to make you feel supported and understood.

## Project Structure

- **lib/**: Main source code directory
  - **auth_provider.dart**: Handles Firebase authentication using Riverpod.
  - **chat_provider.dart**: Manages chat messages and interactions with OpenAI's API.
  - **home_page.dart**: Displays the main chat interface.
  - **onboard_page.dart**: Onboarding screen for new users.
  - **agent_service.dart**: Manages requests to the OpenAI API.

## Customization

To customize the behavior of the AI agent, you can modify the system message in `agent_service.dart` to adjust the tone, style, or response behavior of the assistant.

## Future Enhancements

- **User Profiles**: Allow users to save preferences and track conversation history.
- **In-App Purchases**: Offer premium advice or additional features.
- **Notification System**: Remind users to check in or provide new conversation starters.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for improvements or new features.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

For questions or feedback, feel free to reach out:
- **Developer**: Yusuf Özmavi
- **Email**: [ozmaviyusuf@gmail.com](mailto:ozmaviyusuf@gmail.com)


