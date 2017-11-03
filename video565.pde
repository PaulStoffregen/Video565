import processing.video.*; // click: Sketch > Import Library > Add Library
import java.io.*;

Movie myMovie;
FileOutputStream myFile;
PImage myImage;
boolean fileopen=true;

void setup() {
  try {
    myMovie = new Movie(this, "/Users/paul/Downloads/Flame_Sensor_Test.mov");
    myFile = new FileOutputStream("/Users/paul/Downloads/Flame_Sensor_Test.raw");
  } catch (Exception e) {
    println("unable to read or write files");
    exit();
  }
  myImage = createImage(128, 128, RGB);
  size(800, 560);  // create the window
  myMovie.play();  // start the movie :-)
}

// movieEvent runs for each new frame of movie data
// scale to a 128x128 image
void movieEvent(Movie m) {
  // read the movie's next frame
  m.read();
  // copy & scale the movie's image to myImage
  myImage.copy(m, 0, 0, m.width, m.height, 0, 0, 128, 128);
  // grab and convery all its pixels to 565 format
  byte[] myData =  new byte[128 * 128 * 2];
  int x, y, index, myPixel, r, g, b;
  for (y = 0; y < 128; y++) {
    for (x = 0; x < 128; x++) {
      index = y * 128 + x;
      myPixel = myImage.pixels[index];
      // 8 bit pixels
      r = (myPixel >> 16) & 0xFF;
      g = (myPixel >> 8) & 0xFF;
      b = (myPixel >> 0) & 0xFF;
      // discard bits, to 5 6 5
      r = (r >> 3) & 0x1F;
      g = (g >> 2) & 0x3F;
      b = (b >> 3) & 0x1F;
      // pack into output array
      myData[index * 2 + 0] = byte(((g << 5) & 0xE0) | (b));
      myData[index * 2 + 1] = byte((r << 3) | (g >> 3));
    }
  }
  // Write to the output file
  try {
    myFile.write(myData);
  } catch (Exception e) {
    exit();
  }
}

// draw runs every time the screen is redrawn - show the movie...
void draw() {
  if (myMovie.time() < myMovie.duration()) {
    image(myMovie, 0, 138);
    image(myImage, 334, 4);
  } else {
    if (fileopen) {
      println("movie stop, closing output file");
      try {
        myFile.close();
      } catch (Exception e) {
        exit();
      }
      fileopen = false;
    }
  }
}