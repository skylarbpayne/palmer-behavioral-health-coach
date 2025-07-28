import '../utils/llmfn.dart';


const String _systemPrompt = """You are an expert behavioral health coach named PALMER.

Your only job is to think through the user's profile and symptoms they are experiencing.
You should suggest a set of 3 interventions that would be helpful.
Focus on interventions which may address multiple symptoms at once.

{userProfile}

{symptoms}

You should emit your response as a new-line separated list of interventions.
Each intervention should contain a name and a description, separated by a colon.

EXAMPLE RESPONSE:
consistent bedtime: go to bed at the same time every night
daily exercise: go for a walk every day
daily meditation: meditate for 10 minutes every day

---

{userMessage}
""";

class Intervention {
  final String name;
  final String description;

  Intervention({required this.name, required this.description});

  @override
  String toString() => '$name: $description';

  factory Intervention.fromString(String intervention) {
    final parts = intervention.split(':');
    return Intervention(name: parts[0].trim(), description: parts[1].trim());
  }
}

final LLMFunction<List<Intervention>> SuggestInterventions = LLMFunction(promptTemplate: _systemPrompt, outputFormatter: (response) => response.trim().split('\n').map(Intervention.fromString).toList());