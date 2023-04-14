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

int delayTime = 10;


void UniCW() {
  //Serial.println('Move Unipolar Clockwise');
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

void UniACW() {
  //Serial.println('Move Unipolar Anti Clockwise');

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

void BiCW() {
  //Serial.println('Move Bipolar Clockwise');

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

void BiACW() {
  //Serial.println('Move Bipolar Anti Clockwise');

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

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);

  pinMode(BiHorizontal, INPUT);
  pinMode(BiVertical, INPUT);
  pinMode(UniHorizontal, INPUT);
  pinMode(UniVertical, INPUT);

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

  digitalWrite(enableAPin, HIGH);
  digitalWrite(enableBPin, HIGH);
}

void loop() {
  // put your main code here, to run repeatedly:
  
  BiHorizontalVal = digitalRead(BiHorizontal);
  UniHorizontalVal = digitalRead(UniHorizontal);
  while (true) {
    if(BiHorizontalVal == 1){
      BiCW();
    }
    if(UniHorizontalVal == 1){
      UniCW();
    }
    if(!BiHorizontalVal && !UniHorizontalVal){
      break;
    }
    BiHorizontalVal = digitalRead(BiHorizontal);
    UniHorizontalVal = digitalRead(UniHorizontal);
  }
  //UniOff();
  //BiOff();
  delay(1000);

  //Serial.println('Restart Done');

  BiVerticalVal = digitalRead(BiVertical);
  UniVerticalVal = digitalRead(UniVertical);

  //Serial.println('Uni Step 1');
  while(true){    
    UniVerticalVal = digitalRead(UniVertical);
    if(UniVerticalVal==0){
      break;
    }
    UniCW();
  }
  

  //Serial.println('Bi Step 1');
  while(true){

    BiVerticalVal = digitalRead(BiVertical);
    if(BiVerticalVal==0){
      break;
    }
    BiACW();
  }
  //BiOff();
  
  //Serial.println('Uni Step 2');
  while(true){
    UniHorizontalVal = digitalRead(UniHorizontal);
    if(UniHorizontalVal==0){
      break;
    }
    UniACW();
  }
  //UniOff();

  //Serial.println('Bi Step 2');
  while(true){
    BiHorizontalVal = digitalRead(BiHorizontal);
    if(BiHorizontalVal==0){
      break;
    }
    BiCW();
  }
  //BiOff();
}

