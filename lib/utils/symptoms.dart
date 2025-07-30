class Symptom {
  final int id;
  final String name;
  final String description;

  const Symptom({required this.id, required this.name, required this.description});

  @override
  String toString() => '$name: $description';
}

const List<Symptom> SYMPTOMS = [
  Symptom(
    id: 1,
    name: "Anxiety",
    description: "Feelings of worry, nervousness, or unease about something with an uncertain outcome"
  ),
  Symptom(
    id: 2,
    name: "Depression",
    description: "Persistent feelings of sadness, hopelessness, and loss of interest in activities"
  ),
  Symptom(
    id: 3,
    name: "Insomnia",
    description: "Difficulty falling asleep, staying asleep, or getting restful sleep"
  ),
  Symptom(
    id: 4,
    name: "Panic Attacks",
    description: "Sudden episodes of intense fear or discomfort with physical symptoms"
  ),
  Symptom(
    id: 5,
    name: "Mood Swings",
    description: "Rapid changes in emotional state or mood"
  ),
  Symptom(
    id: 6,
    name: "Irritability",
    description: "Increased sensitivity to stimuli and tendency to react with anger or frustration"
  ),
  Symptom(
    id: 7,
    name: "Fatigue",
    description: "Persistent tiredness or lack of energy not relieved by rest"
  ),
  Symptom(
    id: 8,
    name: "Concentration Problems",
    description: "Difficulty focusing, paying attention, or making decisions"
  ),
  Symptom(
    id: 9,
    name: "Social Withdrawal",
    description: "Avoiding social interactions and isolating from others"
  ),
  Symptom(
    id: 10,
    name: "Appetite Changes",
    description: "Significant increase or decrease in appetite or eating patterns"
  ),
  Symptom(
    id: 11,
    name: "Guilt or Shame",
    description: "Persistent feelings of guilt, shame, or worthlessness"
  ),
  Symptom(
    id: 12,
    name: "Restlessness",
    description: "Feeling unable to sit still or relax, constant need to move"
  ),
  Symptom(
    id: 13,
    name: "Negative Thoughts",
    description: "Persistent pessimistic or self-critical thinking patterns"
  ),
  Symptom(
    id: 14,
    name: "Physical Symptoms",
    description: "Unexplained physical symptoms like headaches, muscle tension, or digestive issues"
  ),
  Symptom(
    id: 15,
    name: "Substance Use",
    description: "Using alcohol, drugs, or other substances to cope with emotions"
  )
];