# Anti-AI Patterns — Full Reference

The main `SKILL.md` covers the rules you need every time. This file is the
deep reference: full vocabulary tables, per-pattern explanations, and the
edge cases. Open it when reviewing or rewriting prose, or when a specific
pattern needs more context than the SKILL gives.

---

## Vocabulary, by tier

Three tiers based on how reliably each word signals AI-generated text.

- **Tier 1 — always flag.** 5–20× more common in AI text than human text.
  Replace on sight.
- **Tier 2 — flag in clusters.** Fine alone; two or more in the same
  paragraph is a strong AI signal.
- **Tier 3 — flag by density.** Common words AI simply overuses. Flag
  only when they make up roughly 3%+ of total words.

### Tier 1 — always replace

| Replace | With |
|---|---|
| delve / delve into | explore, dig into, look at |
| landscape (metaphor) | field, space, industry, world |
| tapestry | (describe the actual complexity) |
| realm | area, field, domain |
| paradigm | model, approach, framework |
| embark | start, begin |
| beacon | (rewrite entirely) |
| testament to | shows, proves, demonstrates |
| robust | strong, reliable, solid |
| comprehensive | thorough, complete, full |
| cutting-edge | latest, newest, advanced |
| leverage (verb) | use |
| pivotal | important, key, critical |
| underscores | highlights, shows |
| meticulous / meticulously | careful, detailed, precise |
| seamless / seamlessly | smooth, easy, without friction |
| game-changer / game-changing | describe what specifically changed and why |
| hit differently / hits different | say what changed, or cut |
| utilize | use |
| watershed moment | turning point, shift |
| marking a pivotal moment | (state what happened) |
| the future looks bright | (cut — say something specific or nothing) |
| only time will tell | (cut — say something specific or nothing) |
| nestled | is located, sits, is in |
| vibrant | (describe what makes it active, or cut) |
| thriving | growing, active (or cite a number) |
| despite challenges… continues to thrive | (name the challenge and the response) |
| showcasing | showing, demonstrating (or cut) |
| deep dive / dive into | look at, examine, explore |
| unpack / unpacking | explain, break down, walk through |
| bustling | busy, active (or cite what makes it busy) |
| intricate / intricacies | complex, detailed (or name the complexity) |
| complexities | (name the actual complexities) |
| ever-evolving | changing, growing (or describe how) |
| enduring | lasting, long-running (or cite how long) |
| daunting | hard, difficult, challenging |
| holistic / holistically | complete, full, whole |
| actionable | practical, useful, concrete |
| impactful | effective, significant (or describe the impact) |
| learnings | lessons, findings, takeaways |
| thought leader / thought leadership | expert, authority |
| best practices | what works, proven methods, standard approach |
| at its core | (cut — just state the thing) |
| synergy / synergies | (describe the actual combined effect) |
| interplay | relationship, connection, interaction |
| in order to | to |
| due to the fact that | because |
| serves as | is |
| features (verb) | has, includes |
| boasts | has |
| presents (inflated) | is, shows, gives |
| commence | start, begin |
| ascertain | find out, determine, learn |
| endeavor | effort, attempt, try |
| keen (as intensifier) | interested, eager, enthusiastic |
| symphony (metaphor) | (describe the actual coordination) |
| embrace (metaphor) | adopt, accept, use, switch to |

### Tier 2 — flag when 2+ appear in the same paragraph

Legitimate on their own. Two or more together usually means a rewrite is needed.

| Replace | With |
|---|---|
| harness | use, take advantage of |
| navigate / navigating | work through, handle, deal with |
| foster | encourage, support, build |
| elevate | improve, raise, strengthen |
| unleash | release, enable, unlock |
| streamline | simplify, speed up |
| empower | enable, let, allow |
| bolster | support, strengthen, back up |
| spearhead | lead, drive, run |
| resonate / resonates with | connect with, appeal to, matter to |
| revolutionize | change, transform, reshape |
| facilitate / facilitates | enable, help, allow, run |
| underpin | support, form the basis of |
| nuanced | specific, subtle, detailed |
| crucial | important, key, necessary |
| multifaceted | (describe the actual facets, or cut) |
| ecosystem (metaphor) | system, community, network, market |
| myriad | many, numerous (or give a number) |
| plethora | many, a lot of (or give a number) |
| encompass | include, cover, span |
| catalyze | start, trigger, accelerate |
| reimagine | rethink, redesign, rebuild |
| galvanize | motivate, rally, push |
| augment | add to, expand, supplement |
| cultivate | build, develop, grow |
| illuminate | clarify, explain, show |
| elucidate | explain, clarify, spell out |
| juxtapose | compare, contrast, set side by side |
| paradigm-shifting | (describe what actually shifted) |
| transformative / transformation | (describe what changed and how) |
| cornerstone | foundation, basis, key part |
| paramount | most important, top priority |
| poised (to) | ready, set, about to |
| burgeoning | growing, emerging (or cite a number) |
| nascent | new, early-stage, emerging |
| quintessential | typical, classic, defining |
| overarching | main, central, broad |
| underpinning / underpinnings | basis, foundation, what supports |

### Tier 3 — flag only at high density

Normal words. Flag only when the text is saturated with them — a sign that
AI filled space with vague praise instead of specifics.

| Word | What to do |
|---|---|
| significant / significantly | Replace some with specifics: numbers, comparisons, examples |
| innovative / innovation | Describe what's actually new |
| effective / effectively | Say how or cite a metric |
| dynamic / dynamics | Name the actual forces or changes |
| scalable / scalability | Describe what scales and to what |
| compelling | Say why it compels |
| unprecedented | Name the precedent it breaks (or cut) |
| exceptional / exceptionally | Cite what makes it an exception |
| remarkable / remarkably | Say what's worth remarking on |
| sophisticated | Describe the sophistication |
| instrumental | Say what role it played |
| world-class / state-of-the-art / best-in-class | Cite a benchmark or comparison |

---

## Sentence patterns and structural tells

### Template phrases
Slot-fill constructions that work no matter what nouns you drop in. Sign the
sentence was generated, not written.

- "a [adjective] step towards [adjective] AI infrastructure"
- "a [adjective] step forward for [noun]"
- "Whether you're [X] or [Y]" — false breadth. Pick the audience or cut.
- "I recently had the pleasure of [verb]-ing" — just say what happened.

### Transition phrases
- "Moreover" / "Furthermore" / "Additionally" — restructure so the
  connection is obvious, or use "and" / "also".
- "In today's [X]" / "In an era where" — cut or state specific context.
- "It's worth noting that" / "Notably" — just state the fact.
- "Here's what's interesting" / "Here's what caught my eye" — reader-steering
  frames. Let the content signal its own importance.
- "In conclusion" / "In summary" — your conclusion should be obvious.
- "When it comes to" — just talk about the thing directly.
- "At the end of the day" — cut.
- "That said" / "That being said" — cut or use "but" / "yet" / "however".

### Significance inflation
Phrases that inflate routine events into history-making ones: "marking a
pivotal moment in the evolution of…", "a watershed moment for the industry".
State what happened and let the reader judge significance. If the sentence
still works after you delete the inflation clause, delete it.

### Copula avoidance
AI text avoids "is" and "has" by substituting fancier verbs: "serves as",
"features", "boasts", "presents", "represents". These sound like a press
release. Default to "is" or "has" unless a more specific verb genuinely adds
meaning.

### Synonym cycling
AI rotates synonyms to avoid repeating a word: "developers… engineers…
practitioners… builders" in the same paragraph. Human writers repeat the
clearest word. If the same noun appears three times in a paragraph and that's
the right word, keep all three. Forced variation reads as thesaurus abuse.

### Vague attributions
"Experts believe", "Studies show", "Research suggests", "Industry leaders
agree" — without naming the expert, study, or leader. Either cite a specific
source or drop the attribution and state the claim directly.

### Generic conclusions
"The future looks bright", "Only time will tell", "One thing is certain", "As
we move forward". Filler disguised as conclusions. Cut them.

### Chatbot artifacts
"I hope this helps!", "Certainly!", "Absolutely!", "Great question!", "Feel
free to reach out", "Let me know if you need anything else", "In this article
we'll explore…", "Let's dive in!". Remove entirely.

### "Let's" constructions
"Let's explore", "Let's take a look", "Let's break this down". False-collaborative
opener that delays the point. Just start with the point.

### Notability name-dropping
Piling on prestigious citations to manufacture credibility: "cited in The
NYT, BBC, Financial Times, and The Hindu". One specific reference with
context beats four name-drops: "In a 2024 NYT interview, she argued…".

### Superficial -ing analyses
Strings of present participles used as pseudo-analysis: "symbolizing the
region's commitment to progress, reflecting decades of investment, and
showcasing a new era of collaboration." These say nothing.

### Promotional language
Tourism-brochure prose: "nestled within the breathtaking foothills", "a
vibrant hub of innovation", "a thriving ecosystem". Replace with plain
description.

### Formulaic challenges
"Despite challenges, X continues to thrive" / "While facing headwinds, the
organization remains resilient." Non-statement. Name the actual challenge
and the actual response, or cut.

### False ranges
Pairing unrelated extremes to create false breadth: "from the Big Bang to
dark matter", "from ancient civilizations to modern startups". List the
actual topics or pick the one that matters.

### Inline-header lists
Bullet lists where each item starts with a bold header that just repeats
itself: "**Performance:** Performance improved by…". Strip the bold header
and write the point directly.

### Title-case headings
AI over-capitalizes: "Strategic Negotiations And Key Partnerships". Use
sentence case for subheadings.

### Cutoff disclaimers
"While specific details are limited based on available information", "As of
my last update", "I don't have access to real-time data". Model limitations
leaking into prose. Either find the information or remove the hedge.

### Novelty inflation
Treating established concepts as if the speaker invented them: "She coined
the phrase", "He introduced a term I hadn't heard before". Most ideas are
applications of existing concepts, not inventions. Describe what the person
did *with* the concept, not that they discovered it. Related: "the failure
mode nobody's naming", "the insight everyone's missing" — engagement-bait
framings that claim scarcity of knowledge where none exists.

### Emotional flatline
Claiming emotions as a structural crutch without conveying them: "What
surprised me most", "I was fascinated to discover", "What struck me was",
"The most interesting part". Tell-don't-show. If the thing is genuinely
surprising, the reader should feel that from the content, not from the
writer announcing it.

### False concession
"While X is impressive, Y remains a challenge" / "Although X has made
strides, Y is still an open question". Sounds balanced without weighing
anything. Make the concession specific or pick a side and argue it.

### Rhetorical question openers
"But what does this mean for developers?" / "So why should you care?". AI
uses these to stall before the actual point. If you know the answer, say it.

### Parenthetical hedging
"(and, increasingly, Z)" / "(or, more precisely, Y)". Inserted to sound
nuanced without committing. If the aside matters, give it its own sentence.

### Numbered-list inflation
"Three key takeaways", "Five things to know". AI defaults to numbered lists
because they're structurally safe. Only use them when the content genuinely
has that many discrete, parallel items.

### Reasoning-chain artifacts
"Let me think step by step", "Breaking this down", "To approach this
systematically", "Here's my thought process". Chain-of-thought scaffolding
leaking into published prose. State the conclusion and the evidence.

### Sycophantic tone
"Great question!", "Excellent point!", "You're absolutely right!" Remove
entirely. Distinct from chatbot artifacts: sycophancy specifically validates
the reader rather than just performing helpfulness.

### Acknowledgment loops
"You're asking about", "The question of whether", "To answer your question".
AI restates the prompt before answering. In writing, this is pure filler.

### Confidence calibration phrases
"Interestingly", "Surprisingly", "Importantly", "Notably", "Certainly",
"Undoubtedly". AI uses these to signal how the reader should feel about a
fact instead of letting the fact speak for itself. One in a 2,000-word piece
is fine. Three in 500 words is AI-style emphasis stacking.

### Excessive structure
- More than 3 headings in under 300 words: almost always AI trying to look
  organized.
- 8+ bullet points in under 200 words: should be a paragraph.
- Formulaic headers ("Overview", "Key Points", "Summary"): default AI
  scaffolding. Use headers that tell the reader something specific.

---

## Rhythm and uniformity

Structure is the #1 detection signal. AI detection tools (Pangram and similar)
weight structural regularity higher than vocabulary. Consistent sentence
construction, uniform pacing, and symmetrical phrasing are harder to mask
than swapping a few flagged words. Fix every word on the Tier 1 list and
leave the rhythm untouched, and the text still reads as AI-generated.

- **Sentence length uniformity.** If most sentences are 15–25 words, the text
  sounds robotic. Mix short punchy sentences (3–8 words) with longer flowing
  ones (20+). Fragments work. Questions break the monotony.
- **Paragraph length uniformity.** If every paragraph is 3–5 sentences and
  roughly the same size, vary deliberately. Some paragraphs should be one
  sentence; some should be longer.
- **Vocabulary repetition vs. synonym cycling.** Human writers repeat when
  the word is right and vary when it's natural. No formula.
- **Read-aloud test.** If the text sounds like it could be read by a TTS
  engine without sounding weird, it's probably too uniform.
- **Missing first-person perspective.** Where appropriate, the writer should
  have opinions, preferences, reactions. Relentless neutrality is itself a
  tell.
- **Over-polishing.** Aggressively editing out every irregularity can push
  human writing *toward* AI statistical profiles. Don't sand away all
  personality in pursuit of clean prose.

---

## Severity tiers (for triage)

Not all AI-isms are equal. When doing a quick pass, prioritize by tier:

### P0 — credibility killers (fix immediately)
- Cutoff disclaimers ("As of my last update")
- Chatbot artifacts ("I hope this helps!", "Great question!")
- Vague attributions without sources ("Experts believe")
- Significance inflation on routine events

### P1 — obvious AI smell (fix before publishing)
- Word-list violations (delve, leverage, harness, robust, etc.)
- Template phrases and slot-fill constructions
- "Let's" transition openers
- Synonym cycling within a paragraph
- Formulaic openings ("In the rapidly evolving world of…")
- Bold overuse
- Em dash frequency (above 1 per 1,000 words)

### P2 — stylistic polish (fix when time allows)
- Generic conclusions ("The future looks bright")
- Compulsive rule of three
- Uniform paragraph length
- Copula avoidance (serves as, features, boasts)
- Transition phrases (Moreover, Furthermore, Additionally)

Quick pass: P0 + P1. Full audit: all three.

---

## When to rewrite from scratch vs. patch

If the text has 5+ flagged vocabulary hits across multiple categories, 3+
distinct pattern categories triggered, and uniform sentence/paragraph length,
patching individual phrases won't fix it — the structure itself is
AI-generated. Advise a full rewrite: state the core point in one sentence,
then rebuild from there.

---

## Self-reference escape hatch

When writing *about* AI writing patterns (this file, tutorials, the SKILL.md
itself), quoted examples are exempt from flagging. Text inside quotation
marks, code blocks, or explicitly marked as illustrative should not be
rewritten. Only flag patterns that appear in the author's own prose, not in
cited examples of bad writing.
