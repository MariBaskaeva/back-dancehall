--liquibase formatted sql

--changeset basma:insert-steps

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'bitter-sweet',
           'Bitter Sweet',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'kayti-insanity'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'naughty-or-nice',
           'Naughty or nice',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'kayti-insanity'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'dancehall-vogue',
           'Dancehall vogue',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'kayti-insanity'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'unfold',
           'Unfold',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'kayti-insanity'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'uppercut',
           'Uppercut',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'smilez-topnotch'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'mush-up',
           'Mush up',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'smilez-topnotch'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'pully',
           'Pully',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'dancing-rebel'),
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'a-dat-that-u-want',
           'A dat that u want',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'dancing-rebel'),
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'non-stop',
           'Non stop',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'dancing-rebel'),
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'swiss',
           'Swiss',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'dancing-rebel'),
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'still-in-love',
           'Still in love',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'inspire'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'excuse-me',
           'Excuse me',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'nieka-og'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'flossy-whine',
           'Flossy whine',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'nieka-og'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'hot-flash',
           'Hot flash',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'nieka-og'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'prada',
           'Prada',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'wazzi'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'badish',
           'Badish',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'darkie'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'motion',
           'Motion',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'kayburr'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'strawberry',
           'Strawberry',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'mama-blazzaz'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'sweet-whine',
           'Sweet whine',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'mama-blazzaz'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'attitude',
           'Attitude',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'mama-blazzaz'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'copycat',
           'Copycat',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'mama-blazzaz'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'o-mama',
           'O mama',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'mama-blazzaz'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'aquatic',
           'Aquatic',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'mama-blazzaz'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'bounce-clap',
           'Bounce&Clap',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'mama-blazzaz'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'affi-touch',
           'Affi touch',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'mama-blazzaz'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'gyal-wine',
           'Gyal wine',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'reda-topnotch'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'versatile',
           'Versatile',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'latonya-style'),
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'original-rude-gyal',
           'Original rude gyal',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'latonya-style'),
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'nuff-respect',
           'Nuff respect',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'latonya-style'),
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'mush-up-2',
           'Mush up',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'latonya-style'),
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'back-forth',
           'Back&Forth',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'dancing-rebel'),
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'couple-up-juk',
           'Couple up (juk)',
           'FEMALE',
           NULL,
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'sexy-body-gyal',
           'Sexy body gyal',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'latonya-style'),
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'hardcore',
           'Hardcore',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'latonya-style'),
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'above-average',
           'Above average',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'latonya-style'),
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'badaboom',
           'Badaboom',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'kimiko-versatile'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'sweet-like-sugar',
           'Sweet like sugar',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'kimiko-versatile'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'cocky-broka',
           'Cocky broka',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'kimiko-versatile'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'wind-speed',
           'Wind speed',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'inspire'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'immortality',
           'Immortality',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'baby-girl'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'outshine',
           'Outshine',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'outshine-team'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'perfect',
           'Perfect',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'kissy-mckoy'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'shapeylous',
           'Shapeylous',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'kayti-insanity'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'chrome-whine',
           'Chrome whine',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'nikki-chromaz'),
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'tilt-and-whine',
           'Tilt and whine',
           'FEMALE',
           NULL,
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'skettle',
           'Skettle',
           'FEMALE',
           NULL,
           'OLD'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'dutty-whine',
           'Dutty whine',
           'FEMALE',
           NULL,
           'MIDDLE'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'big-nasty',
           'Big&Nasty',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'xpressionz'),
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'go-go-whine',
           'Go go whine',
           'FEMALE',
           NULL,
           'OLD'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'hot-wuk',
           'Hot wuk',
           'FEMALE',
           NULL,
           'MIDDLE'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'hula-hoop',
           'Hula hoop',
           'FEMALE',
           NULL,
           'MIDDLE'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'steady-wine',
           'Steady wine',
           'FEMALE',
           NULL,
           'MIDDLE'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'tempa-wine',
           'Tempa wine',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'kartoon'),
           'MIDDLE'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'tic-toc',
           'Tic Toc',
           'FEMALE',
           NULL,
           'MIDDLE'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'walk-shake',
           'Walk&Shake',
           'FEMALE',
           NULL,
           'MIDDLE'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'butterfly',
           'Butterfly',
           'FEMALE',
           NULL,
           'OLD'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'slide-and-wine',
           'Slide and wine',
           'FEMALE',
           NULL,
           'OLD'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'wata-pumpie',
           'Wata pumpie',
           'FEMALE',
           NULL,
           'OLD'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'juk-it',
           'Juk it',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'xpressionz'),
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'naked',
           'Naked',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'xpressionz'),
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'one-knock',
           'One knock',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'xpressionz'),
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'good-body',
           'Good body',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'xpressionz'),
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'tender-touch',
           'Tender touch',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'xpressionz'),
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'clap-yuself',
           'Clap Yuself',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'latonya-style'),
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'jiggle-it',
           'Jiggle it',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'latonya-style'),
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'pretty-wine',
           'Pretty wine',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'latonya-style'),
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'dig-it',
           'Dig it',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'kimiko-versatile'),
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'jafrican-whine',
           'Jafrican whine',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'kimiko-versatile'),
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'fabulus',
           'Fabulus',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'stacya-fia'),
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'i-bless',
           'I-bless',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'stacya-fia'),
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'ketch-a-fire',
           'Ketch a fire',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'kim-weezy'),
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'weezy-wine',
           'Weezy wine',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'kim-weezy'),
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'close-up',
           'Close up',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'dancing-rebel'),
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'pon-di-spot',
           'Pon di spot',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'dancing-rebel'),
           'EARLY_NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'xo-motion',
           'XO motion',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'sara-bendii'),
           'NEW'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'happy-jook',
           'Happy jook',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'happyfeet'),
           'UNKNOWN'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'badumboom',
           'Badumboom',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'xqlusiv'),
           'UNKNOWN'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'cursive',
           'Cursive',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'team-cautiion'),
           'UNKNOWN'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'sneak-peak',
           'Sneak Peak',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'team-cautiion'),
           'UNKNOWN'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'lowkey',
           'Lowkey',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'ultimate-girlz'),
           'UNKNOWN'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'hanky-panky',
           'Hanky panky',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'barbie-chelsea'),
           'UNKNOWN'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'shorty-infinity',
           'Shorty Infinity',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'shorty-dancershine'),
           'UNKNOWN'
       );

INSERT INTO step (id, slug, name, style, author_id, era)
VALUES (
           gen_random_uuid(),
           'hurricane-bendii',
           'Hurricane Bendii',
           'FEMALE',
           (SELECT id FROM author WHERE slug = 'sara-bendii'),
           'UNKNOWN'
       );
