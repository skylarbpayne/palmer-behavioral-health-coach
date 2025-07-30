class PromptTemplate {
  final String systemPrompt;
  final List<String> inputs;

  PromptTemplate({required this.systemPrompt, required this.inputs});

  String format(Map<String, dynamic> variables) {
    String out = systemPrompt;
    for (var variable in inputs) {
      if (variables.containsKey(variable)) {
        out = out.replaceAll('{$variable}', variables[variable]?.toString() ?? '');
      } else {
        throw Exception('Variable $variable not found in variables');
      }
    }
    return out;
  }

  factory PromptTemplate.fromString(String systemPrompt) {
    final regex = RegExp(r'\{([a-zA-Z0-9_]+)\}');
    final inputs = regex
        .allMatches(systemPrompt)
        .map((match) => match.group(1)!)
        .toSet()
        .toList();
    return PromptTemplate(systemPrompt: systemPrompt, inputs: inputs);
  }
}