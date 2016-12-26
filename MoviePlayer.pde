import processing.video.*;

MoviePlayer[] moviePlayer;

class MoviePlayer {
  
  Movie movie;
  PImage frame;
  boolean firstRun = true;
  boolean ready = false;
  boolean resizeStage = false;
  
  MoviePlayer(String fileName, PApplet pApplet) {
    movie = new Movie(pApplet, fileName);
    movie.loop();
    movie.volume(0);
    frame = createImage(movie.width, movie.height, RGB);
  }
  
}

void setupMoviePlayer(String fileName) {
  moviePlayer = new MoviePlayer[1];
  moviePlayer[0] = new MoviePlayer(fileName, this);
  println("Loaded " + moviePlayer.length + " movie.");
}

void setupMoviePlayer(String[] fileName) {
  moviePlayer = new MoviePlayer[fileName.length];
  for (int i=0; i<fileName.length; i++) {
    moviePlayer[i] = new MoviePlayer(fileName[i], this);
  }
  println("Loaded " + moviePlayer.length + " movies.");
}

void drawMoviePlayer() {
  for (int i=0; i<moviePlayer.length; i++) {    
    if (moviePlayer[i].ready) {
      if (moviePlayer[i].resizeStage) {
        surface.setSize(moviePlayer[i].movie.width, moviePlayer[i].movie.height);
      }
      moviePlayer[i].ready = false;
    }
    if (moviePlayer[i].movie.available()) {
      image(moviePlayer[i].frame, 0, 0);
    }  
  }
}

void movieEvent(Movie m) {
  for (int i=0; i<moviePlayer.length; i++) {
    if (m == moviePlayer[i].movie) { // modify for multiple movies
      moviePlayer[i].movie.read();
      if (moviePlayer[i].movie.available()) {
        if (moviePlayer[i].firstRun) {
          moviePlayer[i].ready = true;
          moviePlayer[i].firstRun = false;
        }
        moviePlayer[i].frame = moviePlayer[i].movie.get(0, 0, m.width, m.height); 
      } 
    }
  }
}