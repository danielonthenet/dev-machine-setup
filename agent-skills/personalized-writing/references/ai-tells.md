# AI tells to check at edit time

## AI-Topic Vocabulary (Precision Check)

A separate class from generic corporate-speak: words that became disproportionately common in writing about AI, agents, and LLMs specifically, in both human and AI-generated text, since 2023. Readers pattern-match on these words even when they're used correctly, because the vocabulary itself now reads as "written with an LLM" — especially in AI strategy docs and roadmaps.

**Watch list:** substrate, rubric(s), primitive(s), scaffold(ing), ontology, flywheel, north star, orchestration (layer), harness, capability overhang, ground truth, emergent, compounding, wedge, moat, guardrails (when used as a vague safety gesture rather than a named mechanism)

**The test is precision, not a ban.** Several of these are legitimate, specific technical terms — "eval harness," "scoring rubric," "run ledger" are real things. The failure mode is using the word as unanchored abstraction instead of a defined term:

- **Fails the check:** "We need better guardrails around agent autonomy." (vague gesture, no mechanism named)
- **Passes:** "Every promotion registers the thresholds that will demote it. Autonomy expires unless the task class continues to meet them." (same idea, more specific, doesn't need the watch-list word)
- **Also passes:** a word like "substrate" used as a consistently defined label for one specific thing throughout a document — fine, because it's load-bearing, not decorative.

On a final pass, for each watch-list word: does removing it and replacing it with the concrete mechanism it's standing in for make the sentence stronger? If yes, replace it.

## Phrases to Avoid

These read as AI-generated or generic corporate writing:

- "I wanted to reach out", "Hope this finds you well"
- "I'm excited to share", "Thrilled to announce"
- "It's worth noting that", "Please note that"
- "Feel free to", "Don't hesitate to reach out"
- "Going forward", "At the end of the day", "Moving the needle"
- "It is recommended that", "It should be noted"
- "Robust solution", "Best-in-class", "Cutting-edge"
- "Leverage" (when "use" works fine), "Synergize", "Streamline" (as vague positive)
- Significance inflation: "stands as a testament to", "marks a pivotal moment", "underscores its importance", "evolving landscape"
- Vague attribution: "industry observers note", "experts argue", "some critics believe" (name the actual source or cut the claim)
- Knowledge-cutoff hedging: "as of [date]", "based on available information", "while specific details are limited"
- Excessive hedging: "could potentially possibly", "it might be worth considering" — state the claim or its actual confidence, not both softened at once
- Generic positive conclusions: "the future looks bright", "exciting times lie ahead", "a major step in the right direction"
- Filler: "in order to" → "to"; "due to the fact that" → "because"; "at this point in time" → "now"; "has the ability to" → "can"

## Mechanical Patterns to Avoid

Structural tells that read as AI-generated even when the vocabulary is clean:

- **Copula avoidance** — don't dress up "is/are" as "serves as", "stands as", "functions as", "represents a". "Gallery 825 is LAAA's exhibition space," not "serves as."
- **Negative parallelism** — cut "It's not just X, it's Y" and tailing negations like "no guessing" tacked onto a sentence end. Write the real clause instead: "without forcing the user to guess."
- **Rule-of-three padding** — don't force ideas into triplets to sound comprehensive ("innovation, inspiration, and industry insights"). Use however many items the content actually has.
- **Elegant variation** — don't cycle synonyms for the same referent across sentences ("the protagonist... the main character... the central figure..."). Repeat the noun or use "it"/"they."
- **False ranges** — "from X to Y" only when X and Y sit on an actual scale. Otherwise just list the items.
- **Em dash overuse** — see the hard default above (zero, with rare exceptions). Count them on a final pass; each one needs to earn its place.
- **Superficial "-ing" tacked-on phrases** — don't pad a sentence with a present-participle clause for fake depth ("...fostering better alignment", "...ensuring a smoother rollout", "...highlighting the need for"). If it adds no new information, cut it: "The change reduces latency" not "The change reduces latency, ensuring a smoother experience."
- **Inline-header bullet lists** — don't write bullets as `**Label:** sentence restating the label`. Either fold the point into a sentence or lead with the actual content, not a bolded restatement of it.
- **Boldface overuse** — don't bold phrases mechanically for emphasis. Bold is for something a reader needs to scan for, not decoration.
- **Persuasive authority tropes** — cut "at its core", "the real question is", "what really matters", "fundamentally", "the heart of the matter". These claim to cut through noise, then the sentence that follows is usually an ordinary point restated with ceremony. State the point directly.
- **Formulaic "despite challenges" / "future outlook" sections** — don't default a status update or roadmap to a generic "faces challenges... but continues to thrive" arc. Name the actual open problem and what happens next; drop the section if there's nothing specific to say.
- **Passive voice and subjectless fragments** — "No configuration file needed" and "The results are preserved automatically" hide the actor. Prefer "You don't need a configuration file" / "The system saves the results automatically" unless the passive is genuinely clearer.
- **Sycophantic tone and chatbot artifacts** — "Great question!", "You're absolutely right", "I hope this helps", "Let me know if you'd like me to expand" have no place in delivered writing. If one survives into a draft, it's a sign the text wasn't edited after drafting, not a stylistic choice.
- **Emojis** — don't decorate headings or bullets with emojis in technical or professional writing.
- **Signposting** — don't announce what you're about to do ("let's dive in", "here's what you need to know"). Just say the thing.
- **Fragmented headers** — don't follow a heading with a one-line restatement of the heading before the real content ("## Performance / Speed matters. / When users hit a slow page, they leave." → drop the middle sentence).
- **Hyphenated-pair overcorrection** — humans hyphenate "data-driven", "cross-functional", "real-time" inconsistently. Perfect, uniform hyphenation across every instance reads as machine-generated.
- **Title case headings** and **curly quotes** — use sentence case for headings and straight quotes ("...") throughout.

