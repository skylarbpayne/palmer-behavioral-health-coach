import '../utils/llmfn.dart';
import '../utils/interventions.dart';

final _interventions = INTERVENTIONS.map((i) => "${i.id}: ${i.name}").join('\n');

final String _systemPrompt = """You are an expert behavioral health coach named PALMER.

Your only job is to think through the user's profile and symptoms they are experiencing.
You should suggest a set of 3 interventions that would be helpful.
Focus on interventions which may address multiple symptoms at once.

{userProfile}

{symptoms}

You should emit your response as a comma separated list of intervention ids.
Do not include the name of the intervention, only the id.
---
EXAMPLE RESPONSE: 1,2,3
---
INTERVENTIONS:
$_interventions
---

{userMessage}
""";

final Map<int, Intervention> interventionMap = Map.fromEntries(INTERVENTIONS.map((i) => MapEntry(i.id, i)));
List<Intervention> mapInterventions(String response) {
  final ids = response.trim().split('\n');
  final interventions = ids.map((id) => interventionMap[int.parse(id)]).where((i) => i != null).toList();
  return interventions.cast<Intervention>();
}

final LLMFunction<List<Intervention>> SuggestInterventions = LLMFunction(promptTemplate: _systemPrompt, outputFormatter: mapInterventions);