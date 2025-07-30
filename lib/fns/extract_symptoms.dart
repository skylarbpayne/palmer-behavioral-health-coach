import '../utils/llmfn.dart';
import '../utils/symptoms.dart';

final String _symptoms = SYMPTOMS.map((s) => "${s.id}: ${s.name}").join('\n');

final String _systemPrompt = """You are an expert behavioral health coach named PALMER.

Your only job is to think about the user's message and extract any symptoms they may be experiencing, either directly or indirectly.
For each symptom discovered, you should use the saveSymptom tool to save it to the user's profile.
You may end your response after you have saved all the symptoms you found.

You should emit your response as a comma separated list of symptom ids.
NOTHING else. Do not include the name of the symptom, only the id.

EXAMPLE RESPONSE: 1,2,3

---
SYMPTOMS:
$_symptoms
---
{userMessage}
""";

final Map<int, Symptom> symptomMap = Map.fromEntries(SYMPTOMS.map((s) => MapEntry(s.id, s)));

List<Symptom> mapSymptoms(String response) {
  final ids = response.trim().split('\n');
  final symptoms = ids.map((id) => symptomMap[int.parse(id)]).where((s) => s != null).toList();
  return symptoms.cast<Symptom>();
}

final LLMFunction<List<Symptom>> ExtractSymptoms = LLMFunction(promptTemplate: _systemPrompt, outputFormatter: mapSymptoms);