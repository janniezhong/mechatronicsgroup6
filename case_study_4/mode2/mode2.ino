// Unipolar motor pins (digital 10-13)
int UniApin = 10;
int UniBpin = 11;
int UniCpin = 12;
int UniDpin = 13;

// Bipolar motor pins (digital 5-8)
int In4 = 5;
int In3 = 7;
int In2 = 6;
int In1 = 8;
int enableAPin = 4; // h-bridge digital pin 4
int enableBPin = 9; // h-bridge digital pin 9

// PhotoInterrupters
int BiHorizontal = A1; // biploar horizontal photo interrupter is in Analog Pin 1; left left
int BiHorizontalVal; // initialize variable to store value of bipolar horizontal photo interrupter
int BiVertical = A2; // biploar vertical photo interrupter is in Analog Pin 2; left mid
int BiVerticalVal; // initialize variable to store value of bipolar vertical photo interrupter
int UniHorizontal = A3; // unipolar horizontal photo interrupter is in Analog Pin 3; right mid
int UniHorizontalVal; // initialize variable to store value of unipolar horizontal photo interrupter
int UniVertical = A4; // unipolar vertical photo interrupter is in Analog Pin 4; right right
int UniVerticalVal; // initialize variable to store value of unipolar vertical photo interrupter

// Variables
int delayTime = 10; // milliseconds delay time
int initialized = 0; // variable holds initialization state

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);

  // Unipolar pins set to output
  pinMode(UniApin, OUTPUT);
  pinMode(UniBpin, OUTPUT);
  pinMode(UniCpin, OUTPUT);
  pinMode(UniDpin, OUTPUT);

  //Bipolar pins set to output
  pinMode(enableAPin, OUTPUT);
  pinMode(enableBPin, OUTPUT);

  pinMode(In4, OUTPUT);
  pinMode(In3, OUTPUT);
  pinMode(In2, OUTPUT);
  pinMode(In1, OUTPUT);

  // PhotoInterrupter pins set to input
  pinMode(BiHorizontal, INPUT);
  pinMode(BiVertical, INPUT);
  pinMode(UniHorizontal, INPUT);
  pinMode(UniVertical, INPUT);
}

void loop() {
  // put your main code here, to run repeatedly:
  digitalWrite(enableAPin, HIGH); // set to true to enable bipolar motor thru h-bridge
  digitalWrite(enableBPin, HIGH); // set to true to enable bipolar motor thru h-bridge


  // read in all photo-interrupter values to get info on position of each motor
  BiHorizontalVal = digitalRead(BiHorizontal);
  BiVerticalVal = digitalRead(BiVertical);
  UniHorizontalVal = digitalRead(UniHorizontal);
  UniVerticalVal = digitalRead(UniVertical);
  
/////////////// INITIALIZATION ///////////////////////////////////////////////
  if (initialized == 0) {
     // While UniHorizontalVal =/= 1, keep turning the motor CW and updating the photo interrupter value
    while (UniHorizontalVal == 1) { // exits loop if UniHorizontal photo interrupter value == 0
      UniFullStepCW();
      UniHorizontalVal = digitalRead(UniHorizontal);
      }
    // While BiHorizontal =/= 1, keep turning the motor CW and updating the photo interrupter value
    while (BiHorizontalVal == 1) { // exits loop if BiHorizontal photo interrupter value == 0
      BiFullStepCW();
      BiHorizontalVal = digitalRead(BiHorizontal);
    }
    initialized = 1; // set initialized state to 1 so that it does not run again in the main loop
  }
  
  /////////////////////////// BEGIN DRIVING ////////////////////////////////////
  delay(1000); // pause for effect
  while(true) { // do this for the rest of the time (this loop contains other loops which are broken out of periodically)
    
    while(true) { // drive motors to the vertical positions (pendulum dropping down)
      UniVerticalVal = digitalRead(UniVertical); // read vertical photo interruptor value
      BiVerticalVal = digitalRead(BiVertical); // read vertical photo interruptor value
      if (UniVerticalVal == 1) {
        UniFullStepCW(); // drive unipolar motor clockwise one step
        UniVerticalVal = digitalRead(UniVertical); // update vertical photo interruptor value
      } // alternate 
      if (BiVerticalVal == 1) {
         BiFullStepCCW(); // drive bipolar motor counterclockwise one step
         BiVerticalVal = digitalRead(BiVertical); // update vertical photo interruptor value
      }
      if (UniVerticalVal == 0 && BiVerticalVal == 0) { // if motors are at the vertical interrupters, exit this loop and enter next one
         break;
      }
    }
  
    while(true) { // drive motors to the horizontal positions (pendulum swinging up)
      UniHorizontalVal = digitalRead(UniHorizontal); // read horizontal photo interruptor value
      BiHorizontalVal = digitalRead(BiHorizontal); // read horizontal photo interruptor value
      if (UniHorizontalVal == 1) {
        UniFullStepCCW(); // drive bipolar motor counterclockwise one step
        UniHorizontalVal = digitalRead(UniHorizontal); // update horizontal photo interruptor value
      }
      if (BiHorizontalVal == 1) {
         BiFullStepCW(); // drive bipolar motor clockwise one step
         BiHorizontalVal = digitalRead(BiHorizontal); // update horizontal photo interruptor value
      }
      if (UniHorizontalVal == 0 && BiHorizontalVal == 0) { // if motors are at the horizontal interrupters, exit this loop and enter next one
         break;
      }
    }
    }
  }

/////////////////////// FULL STEP DRIVING FUNCTIONS /////////////////////////////////////

void UniFullStepCW() { // function to drive unipolar motor one step clockwise using fullstep drive
  digitalWrite(UniApin, HIGH);
  digitalWrite(UniCpin, HIGH);
  digitalWrite(UniBpin, LOW);
  digitalWrite(UniDpin, LOW);
  delay(delayTime);
  digitalWrite(UniApin, LOW);
  digitalWrite(UniCpin, HIGH);
  digitalWrite(UniBpin, HIGH);
  digitalWrite(UniDpin, LOW);
  delay(delayTime);
  digitalWrite(UniApin, LOW);
  digitalWrite(UniCpin, LOW);
  digitalWrite(UniBpin, HIGH);
  digitalWrite(UniDpin, HIGH);
  delay(delayTime);
  digitalWrite(UniApin, HIGH);
  digitalWrite(UniCpin, LOW);
  digitalWrite(UniBpin, LOW);
  digitalWrite(UniDpin, HIGH);
  delay(delayTime);  
}

void BiFullStepCW() { // function to drive bipolar motor one step clockwise using fullstep drive
  digitalWrite(In4, HIGH);
  digitalWrite(In3, HIGH);
  digitalWrite(In2, LOW);
  digitalWrite(In1, LOW);
  delay(delayTime);
  digitalWrite(In4, LOW);
  digitalWrite(In3, HIGH);
  digitalWrite(In2, HIGH);
  digitalWrite(In1, LOW);
  delay(delayTime);
  digitalWrite(In4, LOW);
  digitalWrite(In3, LOW);
  digitalWrite(In2, HIGH);
  digitalWrite(In1, HIGH);
  delay(delayTime);
  digitalWrite(In4, HIGH);
  digitalWrite(In3, LOW);
  digitalWrite(In2, LOW);
  digitalWrite(In1, HIGH);
  delay(delayTime);
}

void UniFullStepCCW() { // function to drive unipolar motor one step counterclockwise using fullstep drive
  digitalWrite(UniApin, HIGH);
  digitalWrite(UniCpin, LOW);
  digitalWrite(UniBpin, LOW);
  digitalWrite(UniDpin, HIGH);
  delay(delayTime);  
  digitalWrite(UniApin, LOW);
  digitalWrite(UniCpin, LOW);
  digitalWrite(UniBpin, HIGH);
  digitalWrite(UniDpin, HIGH);
  delay(delayTime);
  digitalWrite(UniApin, LOW);
  digitalWrite(UniCpin, HIGH);
  digitalWrite(UniBpin, HIGH);
  digitalWrite(UniDpin, LOW);
  delay(delayTime);
  digitalWrite(UniApin, HIGH);
  digitalWrite(UniCpin, HIGH);
  digitalWrite(UniBpin, LOW);
  digitalWrite(UniDpin, LOW);
  delay(delayTime);
  
}

void BiFullStepCCW() { // function to drive bipolar motor one step clockwise using fullstep drive
  digitalWrite(In4, HIGH);
  digitalWrite(In3, LOW);
  digitalWrite(In2, LOW);
  digitalWrite(In1, HIGH);
  delay(delayTime);
  digitalWrite(In4, LOW);
  digitalWrite(In3, LOW);
  digitalWrite(In2, HIGH);
  digitalWrite(In1, HIGH);
  delay(delayTime);
  digitalWrite(In4, LOW);
  digitalWrite(In3, HIGH);
  digitalWrite(In2, HIGH);
  digitalWrite(In1, LOW);
  delay(delayTime);
  digitalWrite(In4, HIGH);
  digitalWrite(In3, HIGH);
  digitalWrite(In2, LOW);
  digitalWrite(In1, LOW);
  delay(delayTime); 
  
}
