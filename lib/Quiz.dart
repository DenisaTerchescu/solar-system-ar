import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestionIndex = 0;
  int score = 0;
  String? selectedOption;

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Which planet is known as the Red Planet?',
      'options': ['Mars', 'Venus', 'Jupiter', 'Saturn'],
      'answer': 'Mars'
    },
    {
      'question': 'What is the largest planet in the solar system?',
      'options': ['Earth', 'Saturn', 'Jupiter', 'Uranus'],
      'answer': 'Jupiter'
    },
    {
      'question': 'Which planet is the closest to the Sun?',
      'options': ['Mercury', 'Venus', 'Earth', 'Mars'],
      'answer': 'Mercury'
    },
    {
      'question': 'Which planet has the most rings?',
      'options': ['Jupiter', 'Saturn', 'Uranus', 'Neptune'],
      'answer': 'Saturn'
    },
    {
      'question': 'What is the name of Earth’s natural satellite?',
      'options': ['Moon', 'Phobos', 'Europa', 'Io'],
      'answer': 'Moon'
    },
    {
      'question': 'Which planet is known for its Great Red Spot?',
      'options': ['Mars', 'Jupiter', 'Neptune', 'Venus'],
      'answer': 'Jupiter'
    },
    {
      'question': 'Which planet is tilted on its side and rotates differently from others?',
      'options': ['Uranus', 'Neptune', 'Saturn', 'Mars'],
      'answer': 'Uranus'
    },
    {
      'question': 'Which planet is known as the "Morning Star" or "Evening Star"?',
      'options': ['Mercury', 'Venus', 'Mars', 'Jupiter'],
      'answer': 'Venus'
    },
    {
      'question': 'Which is the coldest planet in the solar system?',
      'options': ['Neptune', 'Uranus', 'Saturn', 'Pluto'],
      'answer': 'Neptune'
    },
    {
      'question': 'What is the name of the dwarf planet in our solar system?',
      'options': ['Pluto', 'Ceres', 'Eris', 'All of the above'],
      'answer': 'All of the above'
    },
  ];

  void _checkAnswer(String selectedOption) {
    setState(() {
      this.selectedOption = selectedOption;

      if (selectedOption == questions[currentQuestionIndex]['answer']) {
        score++;
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (currentQuestionIndex < questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          this.selectedOption = null;
        });
      } else {
        _showFinalScoreDialog();
      }
    });
  }

  void _showFinalScoreDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quiz Completed!'),
          content: Text('Your score is $score/${questions.length}.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solar System Quiz'),
        backgroundColor: Colors.pink,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Question ${currentQuestionIndex + 1}/${questions.length}:',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                questions[currentQuestionIndex]['question'],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 3,
                  children: questions[currentQuestionIndex]['options'].map<Widget>((option) {
                    final bool isCorrect = option == questions[currentQuestionIndex]['answer'];
                    final bool isSelected = option == selectedOption;

                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? (isCorrect ? Colors.green : Colors.red)
                            : Colors.pink,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      onPressed: selectedOption == null
                          ? () => _checkAnswer(option)
                          : null,
                      child: Text(option),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
