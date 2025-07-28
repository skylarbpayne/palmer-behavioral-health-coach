import '../utils/llmfn.dart';
import '../services/user_profile_service.dart';


const String _systemPrompt = """You are an expert behavioral health coach named PALMER. 
Your primary role is to support users in their mental health and behavioral wellness journey through compassionate, evidence-based guidance.

Core responsibilities:
1. Profile management and personalization
2. Supportive engagement with empathy
3. Constructive challenge when appropriate
4. Symptom observation and pattern recognition
5. Evidence-based intervention suggestions

Communication style: Warm, professional, curious, respectful. Keep responses concise but meaningful.

Use the following process in all your responses:
1. Extract any symptoms that are relevant
2. Remember each symptom by using the saveSymptom tool
3. Consider a set of possible interventions based on past and new symptoms
4. Remember each intervention by using the saveIntervention tool
5. Construct a concise reply recognizing the symptoms and interventions

You should always begin with your tool calls.
""";

final List<LLMTool<void>> _tools = [
  LLMTool.create(name: 'saveSymptom', description: 'Save a symptom to the user\'s profile', parameters: {
    'type': 'object',
    'properties': {
      'symptom': {'type': 'string'},
      'reason': {'type': 'string'},
    },
  }, handler: (args) => UserProfileService().addArrayItem('currentBehavioralHealthSymptoms', args['symptom'], confirm: true, userId: 'palmerai', reason: args['reason'])),
  LLMTool.create(name: 'saveIntervention', description: 'Save an intervention to the user\'s profile', parameters: {
    'type': 'object',
    'properties': {
      'intervention': {'type': 'string'},
      'reason': {'type': 'string'},
    },
  }, handler: (args) => UserProfileService().addArrayItem('currentInterventions', args['intervention'], userId: 'palmerai', reason: args['reason'])),
];

final LLMFunction PalmerLegacy = LLMFunction(promptTemplate: _systemPrompt, outputFormatter: (response) => response.trim(), tools: _tools);