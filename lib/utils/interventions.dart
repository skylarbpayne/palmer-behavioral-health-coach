class Intervention {
  final int id;
  final String name;
  final String description;
  final String technique;
  final int durationMinutes;
  final List<String> targetSymptoms;

  const Intervention({
    required this.id,
    required this.name,
    required this.description,
    required this.technique,
    required this.durationMinutes,
    required this.targetSymptoms,
  });

  @override
  String toString() => '$name: $description';
}

const List<Intervention> INTERVENTIONS = [
  Intervention(
    id: 1,
    name: "Deep Breathing Exercise",
    description: "Focused breathing technique to reduce anxiety and promote relaxation",
    technique: "Breathe in for 4 counts, hold for 4 counts, breathe out for 6 counts. Repeat 5-10 times.",
    durationMinutes: 5,
    targetSymptoms: ["anxiety", "panic_attacks", "restlessness"],
  ),
  Intervention(
    id: 2,
    name: "Progressive Muscle Relaxation",
    description: "Systematic tensing and relaxing of muscle groups to reduce physical tension",
    technique: "Starting with toes, tense each muscle group for 5 seconds, then relax for 10 seconds. Work up through the body.",
    durationMinutes: 15,
    targetSymptoms: ["anxiety", "physical_symptoms", "restlessness"],
  ),
  Intervention(
    id: 3,
    name: "Mindfulness Meditation",
    description: "Present-moment awareness practice to reduce stress and improve emotional regulation",
    technique: "Sit comfortably, focus on breath, notice thoughts without judgment, gently return attention to breath.",
    durationMinutes: 10,
    targetSymptoms: ["anxiety", "negative_thoughts", "concentration_problems"],
  ),
  Intervention(
    id: 4,
    name: "Cognitive Restructuring",
    description: "Identifying and challenging negative thought patterns",
    technique: "Write down the negative thought, examine evidence for/against it, develop a balanced alternative thought.",
    durationMinutes: 20,
    targetSymptoms: ["depression", "negative_thoughts", "guilt_shame"],
  ),
  Intervention(
    id: 5,
    name: "Behavioral Activation",
    description: "Scheduling pleasant and meaningful activities to combat depression",
    technique: "List enjoyable activities, schedule 1-2 per day, start with small manageable tasks, track mood changes.",
    durationMinutes: 30,
    targetSymptoms: ["depression", "social_withdrawal", "fatigue"],
  ),
  Intervention(
    id: 6,
    name: "Sleep Hygiene Protocol",
    description: "Establishing healthy sleep habits and routines",
    technique: "Set consistent bedtime, avoid screens 1 hour before bed, create cool dark environment, limit caffeine after 2pm.",
    durationMinutes: 60,
    targetSymptoms: ["insomnia", "fatigue", "concentration_problems"],
  ),
  Intervention(
    id: 7,
    name: "Grounding Technique (5-4-3-2-1)",
    description: "Sensory grounding exercise to manage panic and dissociation",
    technique: "Name 5 things you see, 4 things you can touch, 3 things you hear, 2 things you smell, 1 thing you taste.",
    durationMinutes: 3,
    targetSymptoms: ["panic_attacks", "anxiety", "negative_thoughts"],
  ),
  Intervention(
    id: 8,
    name: "Thought Record",
    description: "Structured approach to examining and reframing negative thoughts",
    technique: "Record situation, emotion, automatic thought, evidence for/against, balanced thought, new emotion rating.",
    durationMinutes: 25,
    targetSymptoms: ["depression", "anxiety", "negative_thoughts"],
  ),
  Intervention(
    id: 9,
    name: "Social Connection Activity",
    description: "Gradual re-engagement with social support networks",
    technique: "Start with low-pressure contact (text/call), plan brief social activity, practice active listening skills.",
    durationMinutes: 45,
    targetSymptoms: ["social_withdrawal", "depression", "guilt_shame"],
  ),
  Intervention(
    id: 10,
    name: "Energy Management Technique",
    description: "Balancing activity and rest to manage fatigue and mood",
    technique: "Rate energy levels hourly, schedule demanding tasks during high-energy times, build in regular breaks.",
    durationMinutes: 15,
    targetSymptoms: ["fatigue", "mood_swings", "concentration_problems"],
  ),
  Intervention(
    id: 11,
    name: "Emotional Regulation Skills",
    description: "Techniques for managing intense emotions and mood swings",
    technique: "Name the emotion, rate intensity 1-10, use opposite action or self-soothing, practice distress tolerance.",
    durationMinutes: 10,
    targetSymptoms: ["mood_swings", "irritability", "anxiety"],
  ),
  Intervention(
    id: 12,
    name: "Values Clarification Exercise",
    description: "Identifying personal values to guide decision-making and increase motivation",
    technique: "List core values, rank by importance, identify actions aligned with top values, set value-based goals.",
    durationMinutes: 40,
    targetSymptoms: ["depression", "guilt_shame", "negative_thoughts"],
  ),
  Intervention(
    id: 13,
    name: "Appetite Regulation Strategy",
    description: "Mindful eating practices to normalize eating patterns",
    technique: "Eat regular meals, practice mindful eating, identify hunger/fullness cues, address emotional eating triggers.",
    durationMinutes: 30,
    targetSymptoms: ["appetite_changes", "anxiety", "depression"],
  ),
  Intervention(
    id: 14,
    name: "Body Scan Meditation",
    description: "Mindfulness practice focusing on physical sensations to reduce somatic symptoms",
    technique: "Lie down, systematically focus attention on each body part, notice sensations without trying to change them.",
    durationMinutes: 20,
    targetSymptoms: ["physical_symptoms", "anxiety", "restlessness"],
  ),
  Intervention(
    id: 15,
    name: "Urge Surfing",
    description: "Technique for managing cravings and impulses without acting on them",
    technique: "Notice the urge, observe it like a wave, breathe through it, remind yourself urges are temporary.",
    durationMinutes: 8,
    targetSymptoms: ["substance_use", "irritability", "restlessness"],
  ),
];