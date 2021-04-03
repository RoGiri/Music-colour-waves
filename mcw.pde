
import ddf.minim.*;
import ddf.minim.analysis.*;
import controlP5.*;

//audio----------
Minim m; 
AudioPlayer playSong;
AudioInput input;

// initial play and paused variable is set to true.
boolean isPaused;
//beat
BeatDetect beat;
BeatListener listen;

//control
ControlP5 button;
Button play; 
Button pause; 
Button rewind; 
Button chooseFile; 

//Song------------------------
String Path; 
String Song = "lefthand.mp3"; 

int white =color(255, 255, 255);
int red = color(255, 0, 0);  
int blue = color(0, 0, 255); 
int green = color(0, 255, 0);
int orange =  color(235, 131, 52);
int yellow =  color(252, 186, 3);
int lightgreen =  color(0, 255, 213);


int l1 = white;
int l2 = white; 
int l3 = white;


//fft--------------------------------
FFT fft;

// beat class----------------------------
class BeatListener implements AudioListener
{
  private BeatDetect beat;
  private AudioPlayer song;

  BeatListener(BeatDetect beat, AudioPlayer song)
  {
    this.song = song;
    this.song.addListener(this);
    this.beat = beat;
  }

  public void samples(float[] samps)
  {
    beat.detect(song.mix);
  }

  public void samples(float[] sampsL, float[] sampsR)
  {
    beat.detect(song.mix);
  }
}

//setup--------------------------------
void setup()
{
  size(512, 500, P3D);
  smooth();


  //define buttons ---------------------
  button = new ControlP5(this);
  // set button background
  button.setColorBackground( color( 255, 255, 255));   



  // chosse button
  chooseFile =  button.addButton("Choose")
    .setColorLabel(color(0, 0, 0))
    .setPosition(100, 280)
    .setSize(80, 50)
    ;

  play =  button.addButton("Play")
    .setColorLabel(color(0, 0, 0))
    .setPosition(200, 280)
    .setSize(80, 50)
    ; 
  pause =  button.addButton("Pause")
    .setColorLabel(color(0, 0, 0))
    .setPosition(300, 280)
    .setSize(80, 50)
    ;
  rewind =  button.addButton("Rewind")
    .setColorLabel(color(0, 0, 0))
    .setPosition(400, 280)
    .setSize(80, 50)
    ;

  m = new Minim(this);
  playSong = m.loadFile(Song);


  fft = new FFT( playSong.bufferSize(), playSong.sampleRate() );
  beat = new BeatDetect(playSong.bufferSize(), playSong.sampleRate());
  beat.setSensitivity(300); 
  listen = new BeatListener(beat, playSong);  


  // text font 
  PFont pfont = createFont("TimesRoman", 18, true); 
  ControlFont font = new ControlFont(pfont, 241);


// button for choose 
  button.getController("Choose")
    .getCaptionLabel()
    .setFont(font)
    .toUpperCase(false)
    .setSize(24)
    ;
// button for play
  button.getController("Play")
    .getCaptionLabel()
    .setFont(font)
    .toUpperCase(false)
    .setSize(24)
    ;
    
//button for pause
  button.getController("Pause")
    .getCaptionLabel()
    .setFont(font)
    .toUpperCase(false)
    .setSize(24)
    ;
    
//button for rewind
  button.getController("Rewind")
    .getCaptionLabel()
    .setFont(font)
    .toUpperCase(false)
    .setSize(24)
    ;
}


/**
 * draw in the sktech 
 */

void draw()
{
  background(0);
  stroke(#FFFFFF);


  for (int i = 0; i < playSong.bufferSize() - 1; i++)
  {
    float x1 = map( i, 0, playSong.bufferSize(), 0, width );
    float x2 = map( i+1, 0, playSong.bufferSize(), 0, width );
    float x3 = map( i+2, 0, playSong.bufferSize(), 0, width );


    //first line
    stroke(l1);
    line( x1, 50 + playSong.left.get(i)*50, x2, 50 + playSong.left.get(i+1)*50 );

    //second line 
    stroke(l2);
    line( x1, 150 + playSong.right.get(i)*50, x2, 150 + playSong.right.get(i+1)*50 );

    //third line
    stroke(l3);
    line( x1, 250 + playSong.right.get(i)*50, x3, 250 + playSong.right.get(i+1)*50 );

    // verticle line-----------------------
    float posx = map(playSong.position(), 0, playSong.length(), 0, width);
    stroke(255, 255, 255);
    line(posx, 30, posx, 270);

    // band and set the color red 
    fft.forward(playSong.mix);
    if ( fft.getBand(i) > 1 && fft.getBand(i) < 2 ) { 
      l1 =  white;
    } else if (fft.getBand(i) > 2) {
      l1 = red;
    }
  }
  
// get the beatsize and if the beat is onset then second line turn green 
  for (int j = 0; j < beat.detectSize(); ++j)
  {
    // test one frequency band for an onset
    if ( beat.isOnset(j) )
    {
      l2 = green;
    }
  }


  int lowBand = 2; //initial lowband variable 
  int highBand = 10;//initial highband variable 
  
  // this shows at least this many bands must have an onset 
  int OnsetsThreshold = 5;
  if ( beat.isRange(lowBand, highBand,OnsetsThreshold) )
  {
    l3 = lightgreen;
  }
  if ( beat.isKick() ) l2 = orange; // if the beat is kick then second line will trun orange
  if ( beat.isSnare() )l2 = yellow;// if the beat is snare then second line will trun yellow
  if ( beat.isHat() ) l3 = blue;// if the beat is hat then third line will trun blue


  //fft music
  fft.forward( playSong.mix );

  for (int k = 0; k < fft.specSize(); k++)
  {
    line( k, height, k, height - fft.getBand(k)*4 );
  }


  /**
   * text 
   */

  if ( playSong.isPlaying() )
  {
    text("Press Pause to stop.", 20, 20 );
  } else
  {
    text("Press Play to start.", 20, 20 );
  }
}


/**
 * mouse clicked 
 * if any of the button is pressed, it will play,
 * pause or rewind based on the button selected
 */

void mousePressed() {
  if (play.isPressed()) {
    playSong.play();
  } else if (pause.isPressed()) {
    playSong.pause();
  } else if (rewind.isPressed()) {
    playSong.rewind();
  } else if (chooseFile.isPressed()) {
    selectInput("Select a file to process:", "fileSelected");
  }
}

/**
 * select file 
 * @param file
 *
 */

void fileSelected(File file) {
  if (file == null) {
    println("you havenot selected th file");
  } else {
    println("User selected " + file.getAbsolutePath());
    Path = file.getAbsolutePath(); 
    playSong.pause();
    Song = Path ;
    playSong = m.loadFile(Song);
    playSong.play();
  }
}
