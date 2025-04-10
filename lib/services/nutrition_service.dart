import 'dart:convert';
import 'package:http/http.dart' as http;

class NutritionService {
  static Future<String> getNutritionMessage(String userNutrition) async {
    final String apiKey = '';
    final String apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';

    final String prompt = '''
        Baseado na alimentação: "$userNutrition"
        
        Crie uma rotina de alimentação diária personalizada com base na alimentação do usuário, com foco em alimentos saudáveis, nutritivos e acessíveis, encontrados com facilidade em mercados e feiras no Brasil. A rotina deve abranger todas as principais refeições do dia (café da manhã, almoço, jantar e lanches intermediários) e deve ser composta por parágrafos curtos, diretos e objetivos. Para cada refeição, inclua sugestões específicas de alimentos e formas simples de preparo, destacando os benefícios de cada opção. Evite ingredientes difíceis de encontrar ou termos excessivamente técnicos. O objetivo é fornecer um plano alimentar prático, realista e fácil de seguir para quem busca melhorar a alimentação, com ingredientes comuns e de fácil acesso no Brasil. Ao final de cada sugestão, enfatize como as opções ajudam a promover uma alimentação equilibrada e saudável.

    ''';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
        "generationConfig": {
          "temperature": 0.7,
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 800,
        },
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final String content =
          jsonResponse['candidates'][0]['content']['parts'][0]['text'];
      return content;
    } else {
      throw Exception('Erro ao obter mensagem: ${response.statusCode}\n${response.body}');
    }
  }
}
