import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/nutrition_service.dart';

class NutriacaoScreen extends StatefulWidget {
  const NutriacaoScreen({super.key});

  @override
  State<NutriacaoScreen> createState() => _NutriacaoScreenState();
}

class _NutriacaoScreenState extends State<NutriacaoScreen> {
  final TextEditingController _nutritionController = TextEditingController();
  String _motivationalMessage = '';
  bool _isLoading = false;
  bool _isListening = false;
  final stt.SpeechToText _speech = stt.SpeechToText();

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (errorNotification) {
        setState(() {
          _isListening = false;
        });
      },
    );
    if (!available) {}
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
        });
        _speech.listen(
          onResult: (result) {
            setState(() {
              _nutritionController.text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() {
        _isListening = false;
        _speech.stop();
      });
    }
  }

  Future<void> _getNutritionMessage() async {
    if (_nutritionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, Insira sua alimentação no campo correto!'),
          backgroundColor: Color(0xFF1E3A8A),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String response = await NutritionService.getNutritionMessage(_nutritionController.text);
      setState(() {
        _motivationalMessage = response;
      });
    } catch (e) {
      setState(() {
        _motivationalMessage = 'Erro ao conectar com a API: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('NutriAção'),
              SizedBox(width: 8),
              Icon(Icons.fastfood, size: 30, color: Colors.white),
            ],
          ),
        ),
        backgroundColor: Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Como voce se alimentou hoje?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nutritionController,
                    decoration: const InputDecoration(
                      hintText: 'Conte sua rotina de alimentação diária:',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF0047AB), width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF0047AB), width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF0047AB), width: 2),
                      ),
                    ),
                    maxLines: 3,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _listen,
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? Colors.red : Color(0xFF1E3A8A),
                    size: 30,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _getNutritionMessage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF0047AB),
                side: BorderSide(color: Color(0xFF0047AB), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Receber Dicas',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
            const SizedBox(height: 24),
            if (_motivationalMessage.isNotEmpty) ...[
              const Text(
                'Rotina para sua alimentação:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF1E3A8A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _motivationalMessage,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nutritionController.dispose();
    super.dispose();
  }
}
