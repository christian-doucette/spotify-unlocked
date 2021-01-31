# Spotify, Unlocked
Spotify Unlocked is live on Heroku [here](https://spotify-unlocked.herokuapp.com/)!  
&nbsp;  

## Summary
Spotify Unlocked is a Ruby on Rails web application created by Christian and James Doucette that integrates with the Spotify API. You can:
- Get detailed information about any song, artist or album on Spotify
- See Spotify user data, including hidden gems, highest energy favorite songs, and more
- Generate the chords for a song using chord recognition from pitch vectors
- Get song recommendations based off specific qualities, like high energy  
&nbsp;  
&nbsp;  


## Motivation
The motivation of this project was to gain experience with:
- Designing and implementing a web application
- Full Stack Development with Ruby on Rails
- Setting up a local environment and version control
- DevOps using Heroku
- RESTful API integrations

We also wanted to create tools we would actually use.

We both love Spotify, and always enjoy seeing the user data that Spotify shares at the end of the year. Since the Spotify API allows developers to access this data and much more, we decided to create a web application focused on data and tools that make use of the Spotify API.  
&nbsp;  
&nbsp;  

## Chord Recognition
One of our favorite tools of Spotify Unlocked is chord recognition.

The Spotify API provides an array of pitch vectors for every song. These pitch vectors are 12-dimensional, with each dimension corresponding to the relative strength of a specific note in the chromatic scale. For example [1,0,0,0,0,0,0,0,0,0,0,0] corresponds to a sound only containing the note C (more info [here](https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-analysis/#pitch)).

The Spotify API also breaks songs down into time intervals called bars, and provides the timestamp for these breakdowns. To recognize chords, we first determined the pitch vector for each bar. This is a sum of the pitch vectors occuring during that bar, weighted by how long they co-occur. This weighted sum then represent the average pitch vector over the duration of the bar (code [here](https://github.com/christian-doucette/cnjmusic/blob/895f84ae855e22a9aa3fcc07746472bfbbb61e9f/app/controllers/songs_controller.rb#L65)).

Since cosine similarity measures how much two vectors point in the same direction, we decided to use it as a metric of similarity among pitch vectors. Then, we created a list of "canonical" pitch vectors for each major and minor chord. For example,
- C major is [1,0,0,0,1,0,0,1,0,0,0,0]
- D major is [0,0,1,0,0,0,1,0,0,1,0,0]
- C minor is [1,0,0,1,0,0,0,1,0,0,0,0].

Using the list of all 12 major and 12 minor chords, we chose the chord that has the highest cosine similarity to the average pitch vector for the bar. This choice is the best fit chord for that bar (code [here](https://github.com/christian-doucette/cnjmusic/blob/895f84ae855e22a9aa3fcc07746472bfbbb61e9f/app/controllers/songs_controller.rb#L156)).

One idea for improving this chord recognition is employing some system to decide when the chord changes occur (rather than assuming they happen on each bar change). Another idea is making use of the timbre vector provided alongside the pitch vector (more info [here](https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-analysis/#timbre)). Since timbre can help distinguish different instruments, it could potentially help separate vocals and drums (less helpful for determining chord) from guitar and bass (more helpful for determining chord). Machine learning would be the best way to accomplish both of these, but we had trouble finding large labelled training datasets dealing with the chords in real songs.
