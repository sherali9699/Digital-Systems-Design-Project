import os
import re


EOW = "</w>" # BPE end-of-word marker
CONT = "##" # WordPiece continuation prefix


# ----------------------------- BASIC CORPUS HELPERS -------------

def read_text_file(path):
  with open(path, "r", encoding="utf-8") as f:
    return f.read()


# Simple whitespace tokenizer (keeps punctuation attached; deterministic)
whitespace_words = re.compile(r"\S+")


def _words(text, lowercase=False):
  if lowercase:
    text = text.lower()
  return whitespace_words.findall(text)


def _word_freqs(text, lowercase=False):
  d = {}
  for w in _words(text, lowercase=lowercase):
    d[w] = d.get(w, 0) + 1
  return d

def print_top_k(tokens, k=10):
  c = {}
  for t in tokens:
    c[t] = c.get(t, 0) + 1
  # sort by count desc, then token asc for stability
  items = sorted(c.items(), key=lambda it: (-it[1], it[0]))[:k]
  for tok, cnt in items:
    print(f"{tok}\t{cnt}")


# --------------------------- BPE ENGINE -------------------------------------------------

# intitializing BPE
def _bpe_init(word_freqs):
  vocab = set()
  tokenized = {}
  for w in word_freqs:
    tokenized[w] = [i for i in w] + [EOW]
    for ch in w:
        vocab.add(ch)
  return {"tokenized": tokenized, "freqs": word_freqs, "vocab": vocab, "merges": []}

# counting pairs
def _bpe_pair_counts(state):
  counts = {}
  for w, seq in state["tokenized"].items():
    f = state["freqs"][w]
    for i in range(len(seq) - 1):
      pair = (seq[i], seq[i+1])
      counts[pair] = counts.get(pair, 0) + f
  
  return counts

# applying the merge
def _bpe_apply_merge(seq, a, b):
  out = []
  i = 0
  while i < len(seq):
    if i + 1 < len(seq) and seq[i] == a and seq[i+1] == b:
      out.append(a + b)
      i += 2
    else:
      out.append(seq[i])
      i += 1
  return out

# applying merging
def bpe_merge_once(state):
  """(Required) ONE merge step for BPE. Return ((a,b), count) or None if no pairs.
  Steps: count pairs → pick max (tie: lexicographic) → merge everywhere → update vocab+merges.
  """
  counts = _bpe_pair_counts(state)
  # print(f'Pair counts are as follows: {counts}')
  if not counts:
    return None

  # choose best pair: highest count, then lexicographically smallest pair
  best_pair = None
  best_count = -1
  for pair, c in counts.items():
    if (c > best_count) or (c == best_count and (best_pair is None or pair < best_pair)):
      best_pair, best_count = pair, c
      
  a, b = best_pair
  # print(f'best pair: {best_pair} and best_count {best_count}')

  # apply merge
  new_tok = {}
  for w, seq in state["tokenized"].items():
    new_tok[w] = _bpe_apply_merge(seq, a, b)
  state["tokenized"] = new_tok
  state["vocab"].add(a + b)
  # print(f'state["merges"] {state["merges"]}')
  state["merges"].append((a, b))
  return (a, b), best_count


def _bpe_encode_word(word, merges):
  seq = list(word) + [EOW]
  for a, b in merges:
    seq = _bpe_apply_merge(seq, a, b)
  return seq

def _bpe_encode_text(text, merges, lowercase=True):
  out = []
  for w in _words(text, lowercase=lowercase):
    out.extend(_bpe_encode_word(w, merges))
  return out

# ------------------trainig loops --------------
def _train_bpe(word_freqs, cap=100, first_n=10):
  state = _bpe_init(word_freqs)
  printed = 0
  while len(state["vocab"]) < cap:
      # print(len(state["vocab"]))
      step = bpe_merge_once(state)
      if not step:
        break
      (a, b), c = step
      if printed < first_n:
        print(f"[BPE] {printed+1:02d}: ({a!r},{b!r}) -> {a+b!r}\tcount={c}")
        printed += 1
  return state



# ---------------------------------- BPE ENGINE Ended ---------------------------------------



# -------------------------Wordpice Engine Starts -------------------------------------------

def _wp_strip_cont(tok):
  # print("wp_strip_cont is in process -------")
  return tok[len(CONT):] if tok.startswith(CONT) else tok

def _wp_greedy_tokenize_word(word, vocab):
  # print("wp_greedy_tokenize_word is in process -------")
  pieces = []
  i = 0
  L = len(word)
  while i < L:
    best = None
    # Try longest candidate in vocab
    for j in range(L, i, -1):
      cand = word[i:j]
      if cand in vocab:
        best = cand
        break
    if best is None:
      best = word[i] # fallback to one char
    pieces.append(best if not pieces else (CONT + best))
    i += len(best)
  return pieces

def _wp_greedy_tokenize_all(word_freqs, vocab):
  # print("wp_greedy_tokenize_all is in process -------")
  return {w: _wp_greedy_tokenize_word(w, vocab) for w in word_freqs}

def _wp_counts(tokenized, word_freqs):
  # print("wp_counts is in process -------")
  tokc = {}
  bigc = {}
  for w, toks in tokenized.items():
    f = word_freqs[w]
    for t in toks:
      tokc[t] = tokc.get(t, 0) + f
    for i in range(len(toks) - 1):
      pair = (toks[i], toks[i+1])
      bigc[pair] = bigc.get(pair, 0) + f
  return tokc, bigc

def wordpiece_merge_once(state):
  # print("wordpiece_merge_once is in process -------")
  """(Required) ONE merge step for WordPiece. Return ((x,y), score) or None if stuck.
  Steps: greedy tokenize → counts → score = count(x▷y)/(count(x)*count(y)) → add raw concat to vocab.
  """
  tokenized = _wp_greedy_tokenize_all(state["freqs"], state["vocab"])
  tokc, bigc = _wp_counts(tokenized, state["freqs"])
  if not bigc:
    return None
  best_pair, best_s, best_xy = None, -1.0, -1
  for (x, y), xy in bigc.items():
    cx, cy = tokc.get(x, 0), tokc.get(y, 0)
    if cx * cy == 0:
      continue
    s = xy / (cx * cy)
    # tie-break: higher numerator, then lexicographic
    if (s > best_s) or (s == best_s and (xy > best_xy or (xy == best_xy and (best_pair is None or (x, y) < best_pair)))):
      best_pair, best_s, best_xy = (x, y), s, xy
  if best_pair is None:
    return None
  x, y = best_pair
  z = _wp_strip_cont(x) + _wp_strip_cont(y) # raw merged string
  if z not in state["vocab"]:
    state["vocab"].add(z)
  state["merges"].append((x, y))
  # print(f'state vocab --- {state["vocab"]}')
  return (best_pair, best_s)

def _train_wp(word_freqs, cap=100, first_n=10):
  # print("train_wp is in process -------")
  # Start vocab with ALL characters seen in corpus
  vocab = set()
  for w in word_freqs:
    for ch in w:
      vocab.add(ch)

  state = {"freqs": word_freqs, "vocab": vocab, "merges": []}
  printed = 0
  while len(state["vocab"]) < cap:
    step = wordpiece_merge_once(state)
    if not step:
      break
    (x, y), s = step
    raw = _wp_strip_cont(x) + _wp_strip_cont(y)
    if printed < first_n:
      print(f"[WP ] {printed+1:02d}: ({x!r},{y!r}) -> {raw!r}\tscore={s:.6f}")
      printed += 1
  # print(f'state vocab of wp after tarining {state["vocab"]}')
  return state


# -------------------------------------- wordpice Engine Ends here ---------------------------------------------------




if __name__ == "__main__":

  # 1) Load corpus (set Q1_CORPUS to a path; else we use a tiny fallback)
  path = os.environ.get("Q1_CORPUS", "q1_corpus_near1000.txt")
  if os.path.exists(path):
    text = read_text_file(path)
  else:
    text = "low lower newer low"
    print("[WARN] Using tiny fallback corpus. Set Q1_CORPUS to your file path.")


  # 2) Word frequencies (document your lowercase choice in report)
  freqs = _word_freqs(text, lowercase=True)
  # print(f'freqs {freqs}')

  # 3) Train both models
  print("\n=== Train BPE ===")
  bpe_state = _train_bpe(freqs)
  # print(f'bpe_final_State {bpe_state}')
  # print(f'bpe_final_State Vocab  ---- {bpe_state["vocab"]}')

  print("\n=== Train WordPiece ===")
  wp_state = _train_wp(freqs)
  # print(f'WP_final_State Vocab  ---- {wp_state["vocab"]}')

  # 4) Re-tokenize ORIGINAL corpus and print Top‑10
  print("\n=== Top-10 (BPE) ===")
  bpe_tokens = _bpe_encode_text(text, bpe_state["merges"], lowercase=True)
  print_top_k(bpe_tokens, k=10)

  print("\n=== Top-10 (WordPiece) ===")
  wp_tokens = []
  for w in _words(text, lowercase=True):
    wp_tokens.extend(_wp_greedy_tokenize_word(w, wp_state["vocab"]))
  print_top_k(wp_tokens, k=10)