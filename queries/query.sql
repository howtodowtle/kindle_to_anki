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