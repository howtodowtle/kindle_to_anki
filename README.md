# Kindle to Anki

## Idea

__Create Anki flashcards from all the words I look up on my Kindle__:
- I look up a lot of words on my Kindle.
- These are saved in a database on the Kindle.
- So I can get these out of the Kindle and create flashcards.

_NB: This is a personal collection of thoughts, including my personal recipe/algorithm. I'm mostly creating this so I can repeat the same procedure. But I am sharing it in case it helps anyone—and to make sure I document more precisely._

## Solution

### General usage

1. Make a local copy of the Kindle's `vocab.db` from `/Volumes/Kindle/system/vocabulary`.
2. Write or refine a SQL query (in `./queries`).
3. Run the query on the database using `sqlite3` (preinstalled on Macs): `sqlite3 -separator "|" path_to_local_db.db < path_to_query.sql > path_to_output.csv`
4. Import into Anki:
    - Separator: Pipe (any separator is fine; I chose | because it is unlikely to appear in context)
    - Allow HTML
    - Preserve existing notes (do not overwrite or create duplicates)
    - Tag `kindle_vocab`, `incomplete` for later manipulation/deletion.

### Queries

My current query:
- no translations (will be added later, see below)
- groups/deduplicates words with the same stem
- but keeps all contexts (including book, author, and the lookup date)
- formats the word in question bold where it appears in the context

```sql
SELECT word, '(German translation: missing)' AS German_Translation, usages
FROM (
    SELECT
        MIN(WORDS.word) OVER(PARTITION BY WORDS.stem) as word,
        GROUP_CONCAT(
            '"' || REPLACE(TRIM(LOOKUPS.usage), WORDS.word, '<b>' || WORDS.word || '</b>') || 
            '" (' || BOOK_INFO.authors || ': ' || BOOK_INFO.title || 
            ' — looked up ' || strftime('%m/%Y', LOOKUPS.timestamp / 1000, 'unixepoch') || ')', 
            '<br>'
        ) OVER(PARTITION BY WORDS.stem) as usages,
        ROW_NUMBER() OVER(PARTITION BY WORDS.stem ORDER BY LOOKUPS.timestamp) as rn
    FROM LOOKUPS
    LEFT JOIN WORDS ON WORDS.id = LOOKUPS.word_key
    LEFT JOIN BOOK_INFO ON BOOK_INFO.id = LOOKUPS.book_key
    WHERE WORDS.lang = 'en'
) WHERE rn = 1
ORDER BY word;
```

Example command: `sqlite3 -separator "|" vocab_dbs/kindle_vocab_2024_03_26.db < queries/query.sql > output/kindle_vocab_en_dedup_2024_03_26.csv`

Example output (see multiple contexts):

```
clemency|(German translation: missing)|"When, on 8 June, the inevitable death sentence came (for her and three others), Winston Churchill, Albert Einstein and Eleanor Roosevelt were among those who pleaded for <b>clemency</b>." (Askwith, Richard: Today We Die a Little: The Rise and Fall of Emil Zátopek, Olympic Legend — looked up 05/2016)<br>"Children can be harsh judges when it comes to their parents, disinclined to grant <b>clemency</b>, and this was especially true in Chris’s case." (Jon Krakauer: Into the wild — looked up 02/2018)
```

### Translations

#### Translate when learning

This creates flashcards where the German translations are missing. That's actually not bad (for me): When I learn a word for the first (or second, after looking it up) time, I want to spend a bit of effort. So whenever the card is scheduled for the first time, I will:
1. Screen the card if I still want to learn it (exlcusion causes can be: too simple, too rare).
2. Look at the context and try to figure out the translation myself.
3. Add the correct German translation(s).

#### ChatGPT translations

I initially used ChatGPT for custom context and translation. Quality is great, and it understands the format. However, it does only 50–100 words at a time, which is slow. Might be an option for updates after short intervals, but not for a big vocab dump (~2000–4000 words). Also, I prefer the true context from the books to new context: It triggers connections and (potentially) emotions, which help learning.

#### Automatic translations

Options:
- DeepL
- Google Translate
- GPT-4

Advantage:
- automatic
- With a generic API (not translation-only), I could generate more context or add secondary translations (I can do that manually, too).

Disadvantages:
- I think less about the word compared to trying to understand it and looking it up manually.
- Would need to program and test.

## Other tools

- `KindleVocabToAnki` by Kasia Gąsiorek ([app](https://kindle-vocab-to-anki.vercel.app/), [repo](https://github.com/hebiscus/KindleVocabToAnki), [YouTube vid](https://www.youtube.com/watch?v=oYFIydvBSEk))
    - Does not provide translations but instead English-to-English definition.
    - Cleverly uses Princeton's WordNet via `nltk.corpus.wordnet` so looking up definitions is super fast.
    - No customization possible, creates ready-to-import Anki deck.
    - My verdict:
        - Found this _after_ building my own solution but I think it's great.
        - It works, it's quick, it's sensible.
        - Things I am missing:
            - deduplication (In these results, I'd have four different cards for "prevaricate", "prevaricated", "prevarication", and "prevariations".)
            - formatting (not super important)
- `KindleVocabToAnki` (same name, different project) by Andrew Lukyanenko ([app](https://kindlevocabtoanki.streamlit.app/), [repo](https://github.com/Erlemar/KindleVocabToAnki), [blog post](https://artgor.medium.com/kindlevocabtoanki-app-importing-words-from-your-kindle-to-anki-for-language-learning-40e062bfc04e))
    - Some nice stats.
    - Lots of interactive customization.
    - Translations are awkward (seems like context is being translated word by word) and extremely slow.
    - Nice but not usable for my large database.
- Fluentcards ([app](https://fluentcards.com/kindle))
    - Groups vocabulary nicely by book.
    - Fetching translations did not work for me.
