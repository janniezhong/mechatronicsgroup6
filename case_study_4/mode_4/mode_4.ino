int enableAPin = 4;
int enableBPin = 9;
int In4 = 5; // bipolar motor pins
int In3 = 7;
int In2 = 6;
int In1 = 8;

int UniApin = 10; // unipolar motor pins
int UniBpin = 11;
int UniCpin = 12;
int UniDpin = 13; 

int BiHorizontal = A1; //left left <- photo interrupter pins
int BiHorizontalVal = 0;
int BiVertical = A2; //left mid
int BiVerticalVal = 0;
int UniHorizontal = A3; // right mid
int UniHorizontalVal = 0;
int UniVertical = A4; // right right
int UniVerticalVal = 0;

int delayTime = 20;
int n = 0; // count

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(enableAPin, OUTPUT);
  pinMode(enableBPin, OUTPUT);

  pinMode(In4, OUTPUT);
  pinMode(In3, OUTPUT);
  pinMode(In2, OUTPUT);
  pinMode(In1, OUTPUT);

  pinMode(UniApin, OUTPUT);
  pinMode(UniBpin, OUTPUT);
  pinMode(UniCpin, OUTPUT);
  pinMode(UniDpin, OUTPUT);

  pinMode(BiHorizontal, INPUT);
  pinMode(BiVertical, INPUT);
  pinMode(UniHorizontal, INPUT);
  pinMode(UniVertical, INPUT);

  digitalWrite(enableAPin, HIGH);
  digitalWrite(enableBPin, HIGH);

  Serial.begin(9600);

}

void bipolar_wave_cw(){
  digitalWrite(In4, HIGH);
  digitalWrite(In3, LOW);
  digitalWrite(In2, LOW);
  digitalWrite(In1, LOW);
  delay(delayTime);
  digitalWrite(In4, LOW);
  digitalWrite(In3, HIGH);
  digitalWrite(In2, LOW);
  digitalWrite(In1, LOW);
  delay(delayTime);
  digitalWrite(In4, LOW);
  digitalWrite(In3, LOW);
  digitalWrite(In2, HIGH);
  digitalWrite(In1, LOW);
  delay(delayTime);
  digitalWrite(In4, LOW);
  digitalWrite(In3, LOW);
  digitalWrite(In2, LOW);
  digitalWrite(In1, HIGH);
  delay(delayTime);
}

void bipolar_wave_ccw(){
  digitalWrite(In4, HIGH);
  digitalWrite(In3, LOW);
  digitalWrite(In2, LOW);
  digitalWrite(In1, LOW);
  delay(delayTime);
  digitalWrite(In4, LOW);
  digitalWrite(In3, LOW);
  digitalWrite(In2, LOW);
  digitalWrite(In1, HIGH);
  delay(delayTime);
  digitalWrite(In4, LOW);
  digitalWrite(In3, LOW);
  digitalWrite(In2, HIGH);
  digitalWrite(In1, LOW);
  delay(delayTime);
  digitalWrite(In4, LOW);
  digitalWrite(In3, HIGH);
  digitalWrite(In2, LOW);
  digitalWrite(In1, LOW);
  delay(delayTime);
}

void unipolar_wave_cw(){
  digitalWrite(UniApin, HIGH);
  digitalWrite(UniCpin, LOW);
  digitalWrite(UniBpin, LOW);
  digitalWrite(UniDpin, LOW);
  delay(delayTime);
  digitalWrite(UniApin, LOW);
  digitalWrite(UniCpin, HIGH);
  digitalWrite(UniBpin, LOW);
  digitalWrite(UniDpin, LOW);
  delay(delayTime);
  digitalWrite(UniApin, LOW);
  digitalWrite(UniCpin, LOW);
  digitalWrite(UniBpin, HIGH);
  digitalWrite(UniDpin, LOW);
  delay(delayTime);
  digitalWrite(UniApin, LOW);
  digitalWrite(UniCpin, LOW);
  digitalWrite(UniBpin, LOW);
  digitalWrite(UniDpin, HIGH);
  delay(delayTime);  
}

void unipolar_wave_ccw(){
  digitalWrite(UniApin, HIGH);
  digitalWrite(UniCpin, LOW);
  digitalWrite(UniBpin, LOW);
  digitalWrite(UniDpin, LOW);
  delay(delayTime);
  digitalWrite(UniApin, LOW);
  digitalWrite(UniCpin, LOW);
  digitalWrite(UniBpin, LOW);
  digitalWrite(UniDpin, HIGH);
  delay(delayTime);
  digitalWrite(UniApin, LOW);
  digitalWrite(UniCpin, LOW);
  digitalWrite(UniBpin, HIGH);
  digitalWrite(UniDpin, LOW);
  delay(delayTime);
  digitalWrite(UniApin, LOW);
  digitalWrite(UniCpin, HIGH);
  digitalWrite(UniBpin, LOW);
  digitalWrite(UniDpin, LOW);
  delay(delayTime); 
}

void loop() {
  // put your main code here, to run repeatedly:

  // move motors to start position (horizontal interrupter position)
  while(true){
    BiHorizontalVal = digitalRead(BiHorizontal);
    if (BiHorizontalVal){ // assuming that 0 is not-interrupted, 1 is interrupted
      bipolar_wave_cw();
    }
    UniHorizontalVal = digitalRead(UniHorizontal);
    if (UniHorizontalVal){
      unipolar_wave_cw();
    }

    if (!BiHorizontalVal && !UniHorizontalVal){
      break;
    }
  }

  // loop

  while(true){
  // start moving bi clockwise and uni ccw until uni interacts with vertical interrupter and bipolar interacts with its vertical
    while(true){
      BiVerticalVal = digitalRead(BiVertical);
      if (BiVerticalVal){
        bipolar_wave_ccw();
      }

      UniVerticalVal = digitalRead(UniVertical);
      if (UniVerticalVal){
        unipolar_wave_cw();
      }

      if (!BiVerticalVal && !UniVerticalVal){
        break;
      }
    }
  // switch directions, wait until both uni and bipolar hit horizontal interrupter
    while(true){
      BiHorizontalVal = digitalRead(BiHorizontal);
      if (BiHorizontalVal){
        bipolar_wave_cw();
      }

      UniHorizontalVal = digitalRead(UniHorizontal);
      if (UniHorizontalVal){
        unipolar_wave_ccw();
      }

      if (!BiHorizontalVal && !UniHorizontalVal){
        break;
      }
    }
  }

}
