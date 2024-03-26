SELECT word, '(German translation: missing)' AS German_Translation, usages
FROM (
    SELECT
        MIN(WORDS.word) OVER(PARTITION BY WORDS.stem) as word, -- Select the first word for each stem
        GROUP_CONCAT('"' || REPLACE(RTRIM(LOOKUPS.usage), WORDS.word, '<b>' || WORDS.word || '</b>') || '" (' || BOOK_INFO.authors || ': ' || BOOK_INFO.title || ')', '<br>') OVER(PARTITION BY WORDS.stem) as usages, -- Concatenate all usages for the same stem
        ROW_NUMBER() OVER(PARTITION BY WORDS.stem ORDER BY LOOKUPS.timestamp) as rn -- For selecting the first row per stem group
    FROM LOOKUPS
    LEFT JOIN WORDS ON WORDS.id = LOOKUPS.word_key
    LEFT JOIN BOOK_INFO ON BOOK_INFO.id = LOOKUPS.book_key
    WHERE WORDS.lang = 'en'
) WHERE rn = 1
ORDER BY word;
