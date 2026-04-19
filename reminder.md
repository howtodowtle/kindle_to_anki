How to get my looked up vocabulary from my Kindle into Anki
Connect Kindle to MacBook using a USB-C **data** cable (not charge-only).
Old Kindles: mount as `/Volumes/Kindle`, copy `vocab.db` from `system/vocabulary/`.
Newer Kindles (Paperwhite 2022+, Scribe, Colorsoft): use MTP, no `/Volumes/Kindle` on macOS.
  - Quit Calibre first (it grabs exclusive USB ownership).
  - Install openMTP (https://openmtp.ganeshrvel.com/) or Android File Transfer.
  - Browse to `system/vocabulary/vocab.db` and drag to `vocab_dbs/`.
Extract words from database: https://github.com/howtodowtle/kindle_to_anki
DIY:
This is a SQLite database. We can access it using `sqlite3` which is preinstalled on the Mac.
The db has six tables, of which 1–2 are interesting for us: WORDS, and maybe LOOKUPS.
Get whatever you need: all the words; all the words looked up at least twice, etc. (queries: in extra)
Filter by language via `WHERE WORDS.lang = 'xx'` (e.g., 'en', 'ca', 'de'). Check with `SELECT DISTINCT lang FROM WORDS;`.
Translations:
Either: Use ChatGPT to create translations and example sentences. Store in a csv file.
Or: Leave blank and fill in when studying for the first time.
Other tools:
https://github.com/howtodowtle/kindle_to_anki?tab=readme-ov-file#other-tools
https://kindle-vocab-to-anki.vercel.app/ works well but zero customization (no translation, just definition)
Import to my English deck. Important: For existing notes, select "Preserve". — Do not overwrite ("Update") or create new notes ("Duplicate"): it's not worth it.
Learn and enjoy.

DIY:
This is a SQLite database. We can access it using `sqlite3` which is preinstalled on the Mac::How to install?.
The db has six tables, of which 1–2 are interesting for us: WORDS, and maybe LOOKUPS.
Get whatever you need: all the words; all the words looked up at least twice, etc. (queries: in extra)
Use ChatGPT to create translations and example sentences. Store in a csv file.
available tables: BOOK_INFO DICT_INFO LOOKUPS METADATA VERSION WORDS
queries:
All the words (stems) from WORDS: sqlite3 vocab.db "SELECT DISTINCT stem FROM WORDS WHERE lang = 'en' ORDER BY stem ASC;" > all_english_word_stems.csv
All words (stems) that I looked up more than once: sqlite3 vocab.db "SELECT W.stem, COUNT(L.word_key) as lookup_count FROM WORDS W INNER JOIN LOOKUPS L ON W.id = L.word_key WHERE W.lang = 'en' GROUP BY W.stem HAVING lookup_count > 1 ORDER BY lookup_count DESC;" > english_word_stems_looked_up_more_than_once.csv


