import '../utils/llmfn.dart';


const String _systemPrompt = """You are an expert behavioral health coach named PALMER.

Given the user's profile, symptoms, and interventions, you should construct a reply to the user's message.

{userProfile}

{symptoms}

{interventions}

---

{userMessage}
""";

final LLMFunction<String> PalmerReply = LLMFunction(promptTemplate: _systemPrompt, outputFormatter: (response) => response.trim());