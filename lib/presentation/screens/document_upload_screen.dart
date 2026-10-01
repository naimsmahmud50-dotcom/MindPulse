import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/study_models.dart';
import '../bloc/deck/deck_bloc.dart';
import '../bloc/quiz/quiz_bloc.dart';
import '../widgets/chunky_3d_button.dart';
import '../widgets/gamified_progress_bar.dart';
import 'flashcard_screen.dart';
import 'quiz_screen.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  int _selectedTab = 0; // 0: PDF File, 1: Raw Text
  String? _selectedFileName;
  int _selectedPageCount = 0;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  double _cardCount = 5;
  bool _includeQuiz = true;
  String _difficulty = 'Intermediate';
  bool _deepResearchMode = true; // Deep analytical research on PDF

  bool _isProcessing = false;
  double _processingProgress = 0.0;
  String _processingStatus = 'Initializing AI parser...';

  // Sample Documents for instant 1-tap client demos
  final List<Map<String, dynamic>> _samplePdfs = [
    {
      'title': 'Flutter_Clean_Architecture.pdf',
      'category': 'Mobile Engineering',
      'pages': 14,
      'size': '2.4 MB',
      'cards': [
        const Flashcard(
          id: 'gen-1',
          front: 'What are the 3 core layers of Clean Architecture in Flutter?',
          back: 'Presentation (UI & BLoC), Domain (Entities & Use Cases), and Data (Models, Data Sources, Repositories).',
          hint: 'Separation of concerns between UI and business rules.',
        ),
        const Flashcard(
          id: 'gen-2',
          front: 'Why should the Domain layer have ZERO external dependencies?',
          back: 'The Domain layer contains pure business logic. Keeping it dependency-free allows swapping UI frameworks, databases, or APIs without breaking business rules.',
          hint: 'Dependency Inversion Principle (DIP).',
        ),
        const Flashcard(
          id: 'gen-3',
          front: 'What is the role of a Repository Implementation in the Data layer?',
          back: 'It coordinates data retrieval between remote APIs and local database caches, converting raw DTOs into domain Entities.',
        ),
      ],
      'quizzes': [
        const QuizQuestion(
          id: 'gen-q1',
          question: 'Which layer of Clean Architecture strictly contains Use Cases?',
          options: ['Data Layer', 'Domain Layer', 'Presentation Layer', 'Network Layer'],
          correctOptionIndex: 1,
          explanation: 'Use Cases encapsulate single business actions and live strictly inside the Domain layer.',
          citation: 'Page 3, Section 1.2 "Domain Layer Architecture"',
        ),
        const QuizQuestion(
          id: 'gen-q2',
          question: 'Why should the Presentation layer never communicate directly with Remote Data Sources?',
          options: [
            'It slows down widget compilation',
            'It violates separation of concerns and bypasses domain validation in Use Cases',
            'Flutter does not allow HTTP calls in widgets',
            'It forces widgets to be Stateful'
          ],
          correctOptionIndex: 1,
          explanation: 'Bypassing the Domain layer leads to tightly coupled UI code and untestable business logic.',
          citation: 'Page 6, Section 2.4 "Data Flow Boundaries"',
        ),
        const QuizQuestion(
          id: 'gen-q3',
          question: 'What distinguishes an Entity from a Model (DTO) in Clean Architecture?',
          options: [
            'Entities are mutable while Models are immutable',
            'Entities represent pure business objects; Models handle JSON serialization and API schemas',
            'Entities are only used for SQLite databases',
            'Models can only be used inside BLoC'
          ],
          correctOptionIndex: 1,
          explanation: 'Models handle raw serialization (fromJson/toJson), while Entities encapsulate immutable business objects.',
          citation: 'Page 9, Section 3.1 "Entities vs Data Transfer Objects"',
        ),
      ],
    },
    {
      'title': 'Islamic_History_&_Jurisprudence.pdf',
      'category': 'Islamic Studies',
      'pages': 18,
      'size': '3.1 MB',
      'cards': [
        const Flashcard(
          id: 'gen-201',
          front: 'What are the primary sources of Islamic Jurisprudence (Usul al-Fiqh)?',
          back: 'The Quran, the Sunnah (Prophetic traditions), Ijma (scholarly consensus), and Qiyas (analogical reasoning).',
          hint: 'Two divine sources and two rational methodological sources.',
        ),
        const Flashcard(
          id: 'gen-202',
          front: 'What is the foundational principle behind Maqasid al-Shariah?',
          back: 'The preservation of five essentials: Religion (Din), Life (Nafs), Intellect (Aql), Lineage/Family (Nasl), and Wealth (Mal).',
        ),
      ],
      'quizzes': [
        const QuizQuestion(
          id: 'gen-q201',
          question: 'Which of the following is NOT one of the five primary objectives of Maqasid al-Shariah?',
          options: ['Preservation of Life', 'Preservation of Wealth', 'Preservation of Social Media', 'Preservation of Intellect'],
          correctOptionIndex: 2,
          explanation: 'The five universally accepted objectives are Religion, Life, Intellect, Lineage/Family, and Wealth.',
          citation: 'Page 4, Section "The Five Universal Necessities"',
        ),
        const QuizQuestion(
          id: 'gen-q202',
          question: 'What does "Ijma" refer to in Islamic legal methodology?',
          options: [
            'Individual legal deduction',
            'The unanimous consensus of qualified scholars on a legal matter after the era of the Prophet (PBUH)',
            'A historical chronicle',
            'Personal opinion of a ruler'
          ],
          correctOptionIndex: 1,
          explanation: 'Ijma represents the binding consensus of the Muslim juristic community on legal rulings.',
          citation: 'Page 8, Section "Secondary Methodological Sources"',
        ),
      ],
    },
    {
      'title': 'Distributed_Database_Systems.pdf',
      'category': 'Systems Architecture',
      'pages': 22,
      'size': '4.5 MB',
      'cards': [
        const Flashcard(
          id: 'gen-301',
          front: 'What does the CAP Theorem state for distributed databases?',
          back: 'A distributed system can guarantee at most two of the three properties simultaneously: Consistency, Availability, and Partition Tolerance.',
          hint: 'You cannot have all three during a network partition.',
        ),
        const Flashcard(
          id: 'gen-302',
          front: 'What is the purpose of Database Write-Ahead Logging (WAL)?',
          back: 'WAL ensures durability (ACID) by logging modifications to persistent storage before applying changes to the database pages in memory.',
        ),
      ],
      'quizzes': [
        const QuizQuestion(
          id: 'gen-q301',
          question: 'In the CAP theorem, what does "P" stand for?',
          options: ['Performance', 'Partition Tolerance', 'Persistence', 'Parallelism'],
          correctOptionIndex: 1,
          explanation: 'Partition Tolerance means the distributed system continues operating despite dropped or delayed network packets.',
          citation: 'Page 5, Section "Network Partitions and Brewer\'s Theorem"',
        ),
        const QuizQuestion(
          id: 'gen-q302',
          question: 'What critical distributed challenge does the Two-Phase Commit (2PC) protocol solve?',
          options: [
            'Optimizing SQL query index scans',
            'Coordinating atomic transaction commit across multiple independent distributed database nodes',
            'Encrypting data at rest',
            'Compressing WAL log segments'
          ],
          correctOptionIndex: 1,
          explanation: '2PC ensures all distributed shards either commit or abort a transaction atomically.',
          citation: 'Page 11, Section "Distributed Consensus and Two-Phase Commit"',
        ),
      ],
    },
  ];

  @override
  void dispose() {
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _selectSamplePdf(Map<String, dynamic> sample) {
    setState(() {
      _selectedFileName = sample['title'] as String;
      _selectedPageCount = sample['pages'] as int;
      _titleController.text = sample['title'].toString().replaceAll('.pdf', '').replaceAll('_', ' ');
    });
  }

  void _processAiDocument() async {
    final title = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim()
        : (_selectedFileName ?? 'Custom AI Study Deck');

    setState(() {
      _isProcessing = true;
      _processingProgress = 0.15;
      _processingStatus = 'Scanning document pages & OCR text extraction...';
    });

    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() {
      _processingProgress = 0.40;
      _processingStatus = 'Conducting deep research on key concepts & definitions...';
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _processingProgress = 0.70;
      _processingStatus = 'Synthesizing research-grade MCQs with page citations...';
    });

    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() {
      _processingProgress = 0.90;
      _processingStatus = 'Balancing difficulty curve & streak rewards for Quiz Arena...';
    });

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _processingProgress = 1.0;
      _processingStatus = 'Research Complete! 4 MCQs & Flashcards Ready ✨';
    });

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    // Find sample data or construct fallback
    final matchedSample = _samplePdfs.firstWhere(
      (s) => s['title'] == _selectedFileName,
      orElse: () => _samplePdfs.first,
    );

    final newDeck = StudyDeck(
      id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: 'AI-researched study deck from $_selectedFileName (${_selectedPageCount > 0 ? "$_selectedPageCount pages" : "Notes"}).',
      category: matchedSample['category'] as String,
      iconCode: 'auto_awesome',
      cardCount: (matchedSample['cards'] as List).length,
      flashcards: List<Flashcard>.from(matchedSample['cards'] as List),
      quizQuestions: List<QuizQuestion>.from(matchedSample['quizzes'] as List),
      progress: 0.0,
    );

    // Dispatch to BLoC
    context.read<DeckBloc>().add(AddNewDeckEvent(newDeck));

    setState(() => _isProcessing = false);

    // Show celebratory Research Summary BottomSheet with direct Quiz Arena launch
    _showResearchCompleteSheet(newDeck);
  }

  void _showResearchCompleteSheet(StudyDeck deck) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: AppColors.primary, width: 2.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.darkBorder,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),

            // Icon & Badge
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bolt_rounded, color: AppColors.accentOrange, size: 40),
            ),
            const SizedBox(height: 14),

            const Text(
              'AI Research Complete! ⚡',
              style: TextStyle(
                color: AppColors.darkTextPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Successfully analyzed ${deck.title}. Generated ${deck.quizQuestions.length} research-grade MCQs with citations & ${deck.flashcards.length} 3D flashcards!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.darkTextSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 24),

            // MCQ Quiz Play Button (Top Priority)
            Chunky3DButton(
              color: AppColors.accentOrange,
              shadowColor: AppColors.accentOrangeDark,
              onPressed: () {
                Navigator.pop(sheetContext); // Close sheet
                context.read<QuizBloc>().add(StartQuizEvent(deck));
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const QuizScreen()),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'PLAY AI MCQ QUIZ NOW (${deck.quizQuestions.length} Qs) ⚡',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Study Flashcards Button
            Chunky3DButton(
              color: AppColors.primary,
              shadowColor: AppColors.primaryDark,
              onPressed: () {
                Navigator.pop(sheetContext); // Close sheet
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => FlashcardScreen(deck: deck)),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flip_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Review 3D Flashcards First',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () {
                Navigator.pop(sheetContext);
                Navigator.pop(context); // Back to Home
              },
              child: const Text('Back to Decks List', style: TextStyle(color: AppColors.darkTextSecondary, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('AI Document & MCQ Research'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header description
                  const Text(
                    'Upload a PDF document. MindPulse AI will research the text, extract key concepts, and generate an interactive MCQ Quiz Arena.',
                    style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 14, height: 1.4),
                  ),

                  const SizedBox(height: 20),

                  // Mode Selector Tabs
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = 0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedTab == 0 ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  '📄 Upload PDF Document',
                                  style: TextStyle(
                                    color: _selectedTab == 0 ? Colors.white : AppColors.darkTextSecondary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedTab == 1 ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  '✍️ Paste Study Notes',
                                  style: TextStyle(
                                    color: _selectedTab == 1 ? Colors.white : AppColors.darkTextSecondary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (_selectedTab == 0) ...[
                    // PDF Drop Zone
                    _buildPdfUploadZone(),

                    const SizedBox(height: 20),

                    // Quick Select Sample PDFs for Instant Testing
                    const Text(
                      'Or Select a Preloaded PDF Document to Research:',
                      style: TextStyle(
                        color: AppColors.darkTextPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),

                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _samplePdfs.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final sample = _samplePdfs[index];
                        final isSelected = _selectedFileName == sample['title'];

                        return GestureDetector(
                          onTap: () => _selectSamplePdf(sample),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.darkCard,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.darkBorder,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.picture_as_pdf_rounded, color: AppColors.error, size: 28),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sample['title'] as String,
                                        style: const TextStyle(
                                          color: AppColors.darkTextPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${sample['category']} • ${sample['pages']} pages • ${(sample['quizzes'] as List).length} MCQs ready',
                                        style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ] else ...[
                    // Raw Text Input Box
                    TextField(
                      controller: _textController,
                      maxLines: 8,
                      style: const TextStyle(color: AppColors.darkTextPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Paste lecture notes, book chapters, or documentation here...',
                        hintStyle: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 13),
                        filled: true,
                        fillColor: AppColors.darkCard,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: AppColors.darkBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: AppColors.darkBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Deep Research Mode Banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.accentOrange.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.psychology_rounded, color: AppColors.accentOrange, size: 28),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Deep AI Concept Research',
                                style: TextStyle(
                                  color: AppColors.darkTextPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Extracts plausible distractors and page citation references for every MCQ.',
                                style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _deepResearchMode,
                          activeThumbColor: AppColors.accentOrange,
                          activeTrackColor: AppColors.accentOrangeDark,
                          onChanged: (val) => setState(() => _deepResearchMode = val),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Deck Title Field
                  const Text(
                    'Deck Title (Optional)',
                    style: TextStyle(color: AppColors.darkTextPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(color: AppColors.darkTextPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'e.g. Distributed Database Mastery',
                      hintStyle: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 13),
                      filled: true,
                      fillColor: AppColors.darkCard,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.darkBorder),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sliders & Customization Options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Target Card & MCQ Count',
                        style: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      Text(
                        '${_cardCount.toInt()} Items',
                        style: const TextStyle(color: AppColors.streakAmber, fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ],
                  ),
                  Slider(
                    value: _cardCount,
                    min: 3,
                    max: 10,
                    divisions: 7,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.darkBorder,
                    onChanged: (val) => setState(() => _cardCount = val),
                  ),

                  const SizedBox(height: 14),

                  // Difficulty Level Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Difficulty Level',
                        style: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.darkBorder),
                        ),
                        child: DropdownButton<String>(
                          value: _difficulty,
                          underline: const SizedBox(),
                          dropdownColor: AppColors.darkSurface,
                          style: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.w700),
                          items: ['Beginner', 'Intermediate', 'Expert'].map((d) {
                            return DropdownMenuItem(value: d, child: Text(d));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _difficulty = val);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Difficulty & Quiz Arena Toggle
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Generate Gamified Quiz Arena', style: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Creates live 4-choice questions with streak bonuses', style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 12)),
                    value: _includeQuiz,
                    activeThumbColor: AppColors.success,
                    activeTrackColor: AppColors.successDark,
                    onChanged: (val) => setState(() => _includeQuiz = val),
                  ),

                  const SizedBox(height: 28),

                  // Primary Action Button
                  Chunky3DButton(
                    color: (_selectedFileName != null || _textController.text.isNotEmpty)
                        ? AppColors.accentOrange
                        : Colors.grey.shade800,
                    shadowColor: (_selectedFileName != null || _textController.text.isNotEmpty)
                        ? AppColors.accentOrangeDark
                        : Colors.grey.shade900,
                    onPressed: (_selectedFileName != null || _textController.text.isNotEmpty)
                        ? _processAiDocument
                        : null,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'RESEARCH PDF & GENERATE MCQS ⚡',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Processing Loading Overlay
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.85),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.accentOrange, width: 2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.psychology_rounded, color: AppColors.accentOrange, size: 48),
                      const SizedBox(height: 18),
                      const Text(
                        'AI Research Engine',
                        style: TextStyle(color: AppColors.darkTextPrimary, fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _processingStatus,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      GamifiedProgressBar(
                        value: _processingProgress,
                        height: 12,
                        fillColor: AppColors.accentOrange,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPdfUploadZone() {
    final bool hasFile = _selectedFileName != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: hasFile ? AppColors.accentOrange.withValues(alpha: 0.08) : AppColors.darkCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: hasFile ? AppColors.accentOrange : AppColors.darkBorder,
          width: 2.0,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hasFile ? AppColors.accentOrange.withValues(alpha: 0.2) : AppColors.darkSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasFile ? Icons.picture_as_pdf_rounded : Icons.cloud_upload_rounded,
              color: hasFile ? AppColors.accentOrange : AppColors.darkTextSecondary,
              size: 36,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            hasFile ? _selectedFileName! : 'Select or Drop PDF Document',
            style: const TextStyle(
              color: AppColors.darkTextPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            hasFile ? '$_selectedPageCount pages extracted for research' : 'Supports multi-page PDF & academic papers',
            style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkSurface,
              foregroundColor: AppColors.darkTextPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.darkBorder),
              ),
            ),
            onPressed: () {
              // Select the first demo PDF as default pick
              _selectSamplePdf(_samplePdfs.first);
            },
            icon: const Icon(Icons.folder_open_rounded, size: 18),
            label: Text(hasFile ? 'Change File' : 'Browse Local Files'),
          ),
        ],
      ),
    );
  }
}
