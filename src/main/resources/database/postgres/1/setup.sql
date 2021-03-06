CREATE SEQUENCE shep_quotes.authors_id_seq
    AS INTEGER;

CREATE TABLE shep_quotes.source
(
    id       INTEGER DEFAULT NEXTVAL('shep_quotes.authors_id_seq'::regclass) NOT NULL,
    name     TEXT                                                            NOT NULL,
    guild_id BIGINT                                                          NOT NULL,
    CONSTRAINT source_pk
        UNIQUE (id)
);

ALTER SEQUENCE shep_quotes.authors_id_seq OWNED BY shep_quotes.source.id;

CREATE INDEX source_guild_id_index
    ON shep_quotes.source (guild_id);

CREATE UNIQUE INDEX "source_guild_id_lower(name)_uindex"
    ON shep_quotes.source (guild_id, LOWER(name));

CREATE TABLE shep_quotes.quote
(
    id       SERIAL,
    created  TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::TEXT, NOW()) NOT NULL,
    modified TIMESTAMP WITH TIME ZONE DEFAULT NOW()                        NOT NULL,
    owner    BIGINT                                                        NOT NULL,
    guild_id BIGINT                                                        NOT NULL,
    CONSTRAINT quote_pk
        PRIMARY KEY (id)
);

CREATE TABLE shep_quotes.content
(
    quote_id INTEGER,
    content  TEXT,
    CONSTRAINT content_quote_id_fk
        FOREIGN KEY (quote_id) REFERENCES shep_quotes.quote
            ON DELETE CASCADE
);

CREATE UNIQUE INDEX content_quote_id_uindex
    ON shep_quotes.content (quote_id);

CREATE TABLE shep_quotes.source_links
(
    quote_id  INTEGER,
    source_id INTEGER,
    CONSTRAINT source_links_quote_id_fk
        FOREIGN KEY (quote_id) REFERENCES shep_quotes.quote
            ON DELETE CASCADE,
    CONSTRAINT source_links_source_id_fk
        FOREIGN KEY (source_id) REFERENCES shep_quotes.source (id)
            ON DELETE CASCADE
);

CREATE INDEX author_links_author_id_index
    ON shep_quotes.source_links (source_id);

CREATE UNIQUE INDEX author_links_quote_id_author_id_uindex
    ON shep_quotes.source_links (quote_id, source_id);

CREATE INDEX author_links_quote_id_index
    ON shep_quotes.source_links (quote_id);

CREATE TABLE shep_quotes.quotes_old
(
    quote_id INTEGER NOT NULL,
    quote    TEXT    NOT NULL,
    guild_id BIGINT  NOT NULL,
    source   TEXT,
    created  TIMESTAMP DEFAULT NOW(),
    edited   TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (quote_id, guild_id)
);

CREATE TABLE shep_quotes.settings
(
    guild_id      BIGINT NOT NULL,
    quote_channel BIGINT,
    CONSTRAINT settings_pk
        PRIMARY KEY (guild_id)
);

CREATE UNIQUE INDEX settings_guild_id_uindex
    ON shep_quotes.settings (guild_id);

CREATE TABLE shep_quotes.quote_posts
(
    quote_id   INTEGER NOT NULL,
    message_id BIGINT,
    CONSTRAINT quote_posts_quote_id_fk
        FOREIGN KEY (quote_id) REFERENCES shep_quotes.quote
            ON DELETE CASCADE
);

CREATE UNIQUE INDEX quote_posts_quote_id_uindex
    ON shep_quotes.quote_posts (quote_id);

CREATE VIEW shep_quotes.source_ids(quote_id, ids) AS
SELECT source_links.quote_id,
       ARRAY_AGG(source_links.source_id) AS ids
FROM shep_quotes.source_links
GROUP BY source_links.quote_id;

CREATE VIEW shep_quotes.local_ids(quote_id, local_id) AS
SELECT quote.id                                                          AS quote_id,
       ROW_NUMBER() OVER (PARTITION BY quote.guild_id ORDER BY quote.id) AS local_id
FROM shep_quotes.quote
ORDER BY quote.id;
