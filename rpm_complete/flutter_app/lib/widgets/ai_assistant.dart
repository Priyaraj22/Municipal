import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../services/validation_service.dart';
import '../models/survey_models.dart';
import '../services/auth_provider.dart';
import 'package:provider/provider.dart';

class AiAssistantFab extends StatefulWidget {
  const AiAssistantFab({super.key});

  @override
  State<AiAssistantFab> createState() => _AiAssistantFabState();
}

class _AiAssistantFabState extends State<AiAssistantFab> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAssistant() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AiAssistantBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withOpacity(0.3 * _controller.value),
                blurRadius: 15,
                spreadRadius: 5 * _controller.value,
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: _showAssistant,
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppTheme.blue, Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 30),
            ),
          ),
        );
      },
    );
  }
}

class AiAssistantBottomSheet extends StatefulWidget {
  const AiAssistantBottomSheet({super.key});

  @override
  State<AiAssistantBottomSheet> createState() => _AiAssistantBottomSheetState();
}

class _AiAssistantBottomSheetState extends State<AiAssistantBottomSheet> {
  final FlutterTts _tts = FlutterTts();
  String _lang = 'English';
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _initTts();
    _messages.add({
      'isAi': true,
      'text': '👋 Welcome Collector\n\nI can help you complete surveys accurately. Please choose your language:',
    });
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text) async {
    if (_lang == 'Tamil') await _tts.setLanguage("ta-IN");
    else await _tts.setLanguage("en-US");
    await _tts.speak(text);
  }

  @override
  void dispose() {
    _tts.stop();
    _scrollCtrl.dispose();
    super.dispose();
  }

  final TextEditingController _inputCtrl = TextEditingController();
  bool _isTyping = false;

  void _addMessage(String text, bool isAi) {
    if (!mounted) return;
    setState(() {
      _messages.add({'isAi': isAi, 'text': text});
    });
    if (isAi) _speak(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _showFaq() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Frequently Asked Questions'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _faqItem('Is ABHA ID mandatory?', 'No, you can skip it if the family doesn\'t have one.'),
              _faqItem('What if door number has alphabets?', 'You can enter alphanumeric values like 12/A.'),
              _faqItem('Tamil Language support?', 'Yes, tell the assistant "Respond in Tamil".'),
              _faqItem('How to edit records?', 'Go to "My Records" and click the blue pencil icon on the card.'),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }

  Widget _faqItem(String q, String a) => ExpansionTile(
    title: Text(q, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
    children: [Padding(padding: const EdgeInsets.all(8), child: Text(a, style: const TextStyle(fontSize: 12)))]
  );

  Future<void> _runSmartValidation() async {
    _addMessage("✓ Review Current Form", false);
    setState(() => _isTyping = true);
    
    final auth = context.read<AuthProvider>();
    final prefs = await SharedPreferences.getInstance();
    final draft = prefs.getString('draft_${auth.collectorName}');
    
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isTyping = false);

    if (draft == null) {
      _addMessage("I couldn't find an active survey draft to review. Please start filling the form first.", true);
      return;
    }

    try {
      final survey = Survey.fromJson(json.decode(draft));
      final result = ValidationService.validate(survey);
      
      if (!result.hasIssues) {
        _addMessage("✅ Survey data looks good. You can submit safely.", true);
      } else {
        String res = "I've reviewed your form and found some items that need your attention:\n\n";
        if (result.errors.isNotEmpty) {
          res += "Needs fixing:\n" + result.errors.join('\n') + "\n\n";
        }
        if (result.warnings.isNotEmpty) {
          res += "Please check:\n" + result.warnings.join('\n');
        }
        _addMessage(res, true);
      }
    } catch (e) {
      _addMessage("Sorry, I encountered an error while reviewing the form.", true);
    }
  }

  Future<void> _handleSend(String text) async {
    if (text.trim().isEmpty) return;
    if (text.contains("Review Form")) {
      _runSmartValidation();
      return;
    }
    
    _inputCtrl.clear();
    _addMessage(text, false);

    setState(() => _isTyping = true);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _isTyping = false);

    final q = text.toLowerCase();
    String res = "";

    if (_lang == 'English') {
      res = "I'm analyzing your request. As a survey assistant, I can help you with field definitions and data validation.";
      if (q.contains('bpl')) {
        res = "BPL stands for Below Poverty Line. Mark families as BPL only if they have a valid BPL/PHH ration card.";
      } else if (q.contains('abha')) {
        res = "ABHA is a 14-digit health ID. You can skip it if the family doesn't have one.";
      } else if (q.contains('tamil')) {
        _lang = 'Tamil';
        res = "சரி, நான் இனி தமிழில் பதிலளிப்பேன். உங்களுக்கு என்ன உதவி வேண்டும்?";
      }
    } else {
      res = "உங்கள் கோரிக்கையை நான் ஆய்வு செய்கிறேன். கணக்கெடுப்பு படிவத்தை நிரப்ப நான் உங்களுக்கு உதவுவேன்.";
      if (q.contains('bpl')) {
        res = "BPL என்பது வறுமைக் கோட்டிற்கு கீழ் உள்ளவர்களைக் குறிக்கும். செல்லுபடியாகும் BPL ரேஷன் கார்டு இருந்தால் மட்டுமே இதைத் தேர்ந்தெடுக்கவும்.";
      } else if (q.contains('english')) {
        _lang = 'English';
        res = "Sure, I will respond in English from now on. How can I help you?";
      }
    }
    _addMessage(res, true);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  border: Border(bottom: BorderSide(color: AppTheme.border)),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFEBF2FF),
                          child: Icon(Icons.smart_toy_rounded, color: AppTheme.blue),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Survey Assistant AI', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                              Text('Helping collectors complete surveys accurately', style: TextStyle(color: AppTheme.ink3, fontSize: 12)),
                            ],
                          ),
                        ),
                        IconButton(onPressed: _showFaq, icon: const Icon(Icons.quiz_outlined, color: AppTheme.blue)),
                        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                      ],
                    ),
                  ],
                ),
              ),

              // Chat Area
              Expanded(
                child: ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length) return const AiTypingIndicator();
                    final msg = _messages[index];
                    return AiChatMessage(
                      isAi: msg['isAi'],
                      text: msg['text'],
                      onSpeak: () => _speak(msg['text']),
                    );
                  },
                ),
              ),

              // Quick Actions
              if (_messages.length <= 2)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Choose Language / மொழியைத் தேர்ந்தெடுக்கவும்:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ActionChip(label: const Text('English'), onPressed: () => _handleSend('English')),
                          const SizedBox(width: 8),
                          ActionChip(label: const Text('தமிழ் (Tamil)'), onPressed: () => _handleSend('Tamil')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_messages.length > 1) AiQuickActions(onAction: _handleSend),
                    ],
                  ),
                ),

              // Smart Features Bar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    _smartBtn('✓ Review Form', Icons.fact_check_rounded, _runSmartValidation),
                    _smartBtn('🔍 Missing Fields', Icons.find_in_page_rounded, () => _handleSend('Missing Fields')),
                    _smartBtn('💡 Suggest Schemes', Icons.lightbulb_rounded, () => _handleSend('Suggest Schemes')),
                    _smartBtn('❓ Explain Field', Icons.help_outline_rounded, () => _handleSend('Explain Field')),
                  ],
                ),
              ),

              // Input Area
              Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).viewInsets.bottom + 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputCtrl,
                        decoration: InputDecoration(
                          hintText: 'Ask me anything about the survey...',
                          fillColor: AppTheme.surface,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        ),
                        onSubmitted: _handleSend,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: AppTheme.blue,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 20),
                        onPressed: () => _handleSend(_inputCtrl.text),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _smartBtn(String label, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(icon, size: 14, color: AppTheme.blue),
        label: Text(label, style: const TextStyle(fontSize: 11)),
        onPressed: onTap,
        backgroundColor: const Color(0xFFEBF2FF),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

class AiChatMessage extends StatelessWidget {
  final bool isAi;
  final String text;
  final VoidCallback? onSpeak;
  const AiChatMessage({super.key, required this.isAi, required this.text, this.onSpeak});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAi)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Color(0xFFEBF2FF),
                  child: Icon(Icons.smart_toy_rounded, size: 16, color: AppTheme.blue)),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment: isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isAi ? AppTheme.surface : AppTheme.blue,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isAi ? 0 : 16),
                      bottomRight: Radius.circular(isAi ? 16 : 0),
                    ),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(color: isAi ? AppTheme.ink : Colors.white, fontSize: 13, height: 1.4),
                  ),
                ),
                if (isAi && onSpeak != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: InkWell(
                      onTap: onSpeak,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.volume_up, size: 14, color: AppTheme.blue),
                          SizedBox(width: 4),
                          Text('Listen', style: TextStyle(fontSize: 10, color: AppTheme.blue, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AiQuickActions extends StatelessWidget {
  final ValueChanged<String> onAction;
  const AiQuickActions({super.key, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final actions = ['What is BPL?', 'ABHA ID', 'PHR Number', 'Eligible Schemes', 'Check Survey', 'Education Help'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: actions.map((a) => ActionChip(
        label: Text(a, style: const TextStyle(fontSize: 12)),
        onPressed: () => onAction(a),
        backgroundColor: Colors.white,
        side: BorderSide(color: AppTheme.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      )).toList(),
    );
  }
}

class AiTypingIndicator extends StatelessWidget {
  const AiTypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
              radius: 14,
              backgroundColor: Color(0xFFEBF2FF),
              child: Icon(Icons.smart_toy_rounded, size: 16, color: AppTheme.blue)),
          SizedBox(width: 8),
          Text('Assistant is typing...',
              style: TextStyle(fontSize: 11, color: AppTheme.ink3, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}
