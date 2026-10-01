import '../models/study_models.dart';

class MockStudyRepository {
  List<StudyDeck> getDecks() {
    return [
      StudyDeck(
        id: 'deck-1',
        title: 'Flutter Architecture & Performance',
        description: 'Master widget lifecycle, BLoC state flow, const tree optimizations, and memory profiling.',
        category: 'Mobile Dev',
        iconCode: 'flutter',
        cardCount: 5,
        progress: 0.6,
        flashcards: const [
          Flashcard(
            id: 'fc-1',
            front: 'What is the exact purpose of the "const" constructor in Flutter widgets?',
            back: 'It creates a compile-time constant widget. Flutter can short-circuit rebuilds for const widgets because their instance never changes between frame builds.',
            hint: 'Think about rebuild performance and memory allocation.',
            codeSnippet: 'const MyStaticCard({super.key});',
          ),
          Flashcard(
            id: 'fc-2',
            front: 'How does BLoC enforce unidirectional data flow (UDF)?',
            back: 'UI triggers Events -> BLoC processes business logic and interacts with data repositories -> BLoC emits immutable States -> UI rebuilds via BlocBuilder.',
            hint: 'Events in, States out.',
          ),
          Flashcard(
            id: 'fc-3',
            front: 'What is the difference between StatefulWidget lifecycle initState() and didChangeDependencies()?',
            back: 'initState() runs once when the widget enters the tree before build. didChangeDependencies() runs immediately after initState() AND whenever an InheritedWidget it depends on changes.',
            hint: 'Safe to access context with InheritedWidgets in didChangeDependencies.',
          ),
          Flashcard(
            id: 'fc-4',
            front: 'Why should you avoid calling setState() during build()?',
            back: 'It triggers an infinite rebuild loop or causes the "setState() called during build" framework assertion error, breaking the rendering pipeline.',
            hint: 'State mutations must happen in callbacks or async handlers.',
          ),
          Flashcard(
            id: 'fc-5',
            front: 'What does RepaintBoundary do in complex Flutter layouts?',
            back: 'It isolates a subtree into its own separate display list layer, preventing sibling widgets or parent repaints from forcing expensive re-rendering.',
            hint: 'Essential for high-FPS animations and heavy custom paints.',
          ),
        ],
        quizQuestions: const [
          QuizQuestion(
            id: 'q-1',
            question: 'Which method is called only once in the lifetime of a State object?',
            options: ['build()', 'initState()', 'didUpdateWidget()', 'didChangeDependencies()'],
            correctOptionIndex: 1,
            explanation: 'initState() is called exactly once when the State object is first inserted into the tree.',
          ),
          QuizQuestion(
            id: 'q-2',
            question: 'What is the primary benefit of using Equatable with BLoC states?',
            options: [
              'Enables value comparison without boilerplate operator == overrides',
              'Automatically caches images',
              'Converts JSON to Dart models',
              'Manages navigation routing'
            ],
            correctOptionIndex: 0,
            explanation: 'Equatable compares instances by their props values rather than memory references, preventing redundant UI rebuilds.',
          ),
          QuizQuestion(
            id: 'q-3',
            question: 'In Flutter, which widget isolates an animation so it does not trigger entire screen repaints?',
            options: ['SizedBox', 'RepaintBoundary', 'Container', 'Stack'],
            correctOptionIndex: 1,
            explanation: 'RepaintBoundary creates a separate layer in the render tree to avoid repainting unchanged siblings.',
          ),
        ],
      ),
      StudyDeck(
        id: 'deck-2',
        title: 'AI Engineering & Modern LLMs',
        description: 'Understand RAG pipelines, token economics, embeddings, vector databases, and system prompts.',
        category: 'Artificial Intelligence',
        iconCode: 'ai',
        cardCount: 4,
        progress: 0.25,
        flashcards: const [
          Flashcard(
            id: 'fc-201',
            front: 'What is Retrieval-Augmented Generation (RAG)?',
            back: 'RAG retrieves relevant external domain knowledge (from vector DBs or search APIs) and injects it into the LLM context prompt before generation to prevent hallucinations.',
            hint: 'Search first, then feed context to LLM.',
          ),
          Flashcard(
            id: 'fc-202',
            front: 'What does "Temperature" control in LLM sampling?',
            back: 'It scales logits before softmax. Lower temperature (0.0 - 0.2) produces deterministic, analytical output. Higher temperature (0.7 - 1.0) increases creativity and randomness.',
            hint: 'Higher = more creative, Lower = more exact.',
          ),
          Flashcard(
            id: 'fc-203',
            front: 'What is an "Embedding" in vector space?',
            back: 'A dense numerical vector representation of semantic text or media where concepts with similar meanings are geometrically close in N-dimensional space.',
            hint: 'Cosine similarity between semantic vectors.',
          ),
          Flashcard(
            id: 'fc-204',
            front: 'Why is System Prompt anchoring important in AI Agents?',
            back: 'It defines the persona, boundaries, available tools, safety guardrails, and reasoning format before any user input is processed.',
            hint: 'Sets root operational constraints.',
          ),
        ],
        quizQuestions: const [
          QuizQuestion(
            id: 'q-201',
            question: 'Which technique is best for grounding an LLM on private enterprise documents without re-training?',
            options: ['Fine-Tuning', 'RAG (Retrieval-Augmented Generation)', 'Prompt Compression', 'Quantization'],
            correctOptionIndex: 1,
            explanation: 'RAG dynamically retrieves documents at query time without expensive model retraining or weights modification.',
          ),
          QuizQuestion(
            id: 'q-202',
            question: 'What happens when an LLM prompt exceeds the maximum context window?',
            options: [
              'The server deletes the model',
              'Tokens are truncated or an out-of-context error is thrown',
              'The output becomes faster',
              'GPU memory decreases automatically'
            ],
            correctOptionIndex: 1,
            explanation: 'Exceeding the context window results in token truncation or context length errors from the API.',
          ),
        ],
      ),
      StudyDeck(
        id: 'deck-3',
        title: 'Full-Stack Systems & Cloud Ops',
        description: 'Microservices, Docker containerization, REST API security, caching layers, and database indexing.',
        category: 'Systems',
        iconCode: 'cloud',
        cardCount: 4,
        progress: 0.0,
        flashcards: const [
          Flashcard(
            id: 'fc-301',
            front: 'What is the primary difference between SQL B-Tree indexes and Hash indexes?',
            back: 'B-Tree indexes support range queries (<, >, BETWEEN) and order-by sorting. Hash indexes only support fast exact match (=) lookups.',
            hint: 'B-Tree preserves sorted ordering.',
          ),
          Flashcard(
            id: 'fc-302',
            front: 'Why use Redis as a cache-aside layer in high-traffic APIs?',
            back: 'Redis keeps data in in-memory RAM, responding in sub-millisecond latency and shielding the primary relational database from read bottlenecks.',
            hint: 'RAM is orders of magnitude faster than SSD disk I/O.',
          ),
          Flashcard(
            id: 'fc-303',
            front: 'What is the role of an API Gateway in microservices?',
            back: 'It acts as a single entry point providing reverse-proxy routing, rate limiting, authentication verification, and SSL termination.',
            hint: 'Centralized guard at the entrance of microservices.',
          ),
          Flashcard(
            id: 'fc-304',
            front: 'How does JWT (JSON Web Token) achieve stateless authentication?',
            back: 'The payload and cryptographic signature are held on the client side. The server verifies integrity using its secret key without querying session storage.',
            hint: 'Cryptographic signature verification.',
          ),
        ],
        quizQuestions: const [
          QuizQuestion(
            id: 'q-301',
            question: 'Which HTTP status code signifies that a rate limit has been exceeded?',
            options: ['401 Unauthorized', '429 Too Many Requests', '503 Service Unavailable', '403 Forbidden'],
            correctOptionIndex: 1,
            explanation: 'HTTP 429 Too Many Requests indicates the user has sent too many requests in a given amount of time.',
          ),
        ],
      ),
    ];
  }
}
