CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW gametracker.games_dv AS
SELECT JSON {
    '_id' : g.id,
    'grouveeGameId' : g.grouvee_game_id,
    'name' : g.name,
    'rating' : g.rating,
    'reviewTitle' : g.review_title,
    'review' : g.review,
    'releaseDate' : g.release_date,
    'dateAddedToCollection' : g.date_added_to_collection,
    'timePlayedSeconds' : g.time_played,
    'levelOfCompletion' : g.level_of_completion,
    'grouveeUrl' : g.grouvee_url,
    'igdbId' : g.igdb_id,
    'giantbombId' : g.giantbomb_id
}
FROM gametracker.games g WITH NOINSERT NOUPDATE NODELETE;