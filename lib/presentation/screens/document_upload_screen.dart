import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/study_models.dart';
import '../bloc/deck/deck_bloc.dart';
import '../widgets/chunky_3d_button.dart';
import '../widgets/gamified_progress_bar.dart';
import 'flashcard_screen.dart';

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
          question: 'Which layer of Clean Architecture contains Use Cases?',
          options: ['Data Layer', 'Domain Layer', 'Presentation Layer', 'Network Layer'],
          correctOptionIndex: 1,
          explanation: 'Use Cases encapsulate single business actions and live strictly inside the Domain layer.',
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
          explanation: 'The five objectives are Religion, Life, Intellect, Lineage, and Wealth.',
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
          explanation: 'Partition Tolerance means the system continues to operate despite network messages being dropped or delayed.',
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
      _processingStatus = 'Scanning document and extracting text...';
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _processingProgress = 0.45;
      _processingStatus = 'Extracting core definitions and high-yield concepts...';
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _processingProgress = 0.80;
      _processingStatus = 'Synthesizing 3D interactive flashcards & hints...';
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _processingProgress = 1.0;
      _processingStatus = 'Generating gamified quiz arena... Done! ✨';
    });

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // Find sample data or construct fallback
    final matchedSample = _samplePdfs.firstWhere(
      (s) => s['title'] == _selectedFileName,
      orElse: () => _samplePdfs.first,
    );

    final newDeck = StudyDeck(
      id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: 'AI-generated study deck from $_selectedFileName (${_selectedPageCount > 0 ? "$_selectedPageCount pages" : "Notes"}).',
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

    // Direct transition to flashcards
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => FlashcardScreen(deck: newDeck)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('AI Document Ingestion'),
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
                    'Upload a PDF or paste notes to automatically generate tactile 3D flashcards and quizzes.',
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
                                  '📄 Upload PDF File',
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
                                  '✍️ Paste Raw Notes',
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
                      'Or Select a Demo Document:',
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
                                        '${sample['category']} • ${sample['pages']} pages • ${sample['size']}',
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
                        hintText: 'Paste lecture notes, book summaries, or documentation here...',
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
                      hintText: 'e.g. Clean Architecture Mastery',
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
                        'Target Card Count',
                        style: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      Text(
                        '${_cardCount.toInt()} Cards',
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
                        ? AppColors.primary
                        : Colors.grey.shade800,
                    shadowColor: (_selectedFileName != null || _textController.text.isNotEmpty)
                        ? AppColors.primaryDark
                        : Colors.grey.shade900,
                    onPressed: (_selectedFileName != null || _textController.text.isNotEmpty)
                        ? _processAiDocument
                        : null,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'SYNTHESIZE STUDY DECK ⚡',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 0.8),
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
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 48),
                      const SizedBox(height: 18),
                      const Text(
                        'AI Document Engine',
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
                        fillColor: AppColors.primary,
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
        color: hasFile ? AppColors.primary.withValues(alpha: 0.08) : AppColors.darkCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: hasFile ? AppColors.primary : AppColors.darkBorder,
          width: 2.0,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hasFile ? AppColors.primary.withValues(alpha: 0.2) : AppColors.darkSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasFile ? Icons.file_present_rounded : Icons.cloud_upload_rounded,
              color: hasFile ? AppColors.primary : AppColors.darkTextSecondary,
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
            hasFile ? '$_selectedPageCount pages extracted' : 'Supports searchable PDF & markdown notes',
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
