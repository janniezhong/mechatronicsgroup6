int BiHorizontal = A1; //left left
int BiHorizontalVal = 0;
int BiVertical = A2; //left mid
int BiVerticalVal = 0;
int UniHorizontal = A3; // right mid
int UniHorizontalVal = 0;
int UniVertical = A4; // right right
int UniVerticalVal = 0;

int enableAPin = 4;
int enableBPin = 9;
int In4 = 5;
int In3 = 7;
int In2 = 6;
int In1 = 8;

int UniApin = 10;
int UniBpin = 11;
int UniCpin = 12;
int UniDpin = 13; 

int delayTime = 10;
int delayTime2 = 500;
int n = 0; // count

int Vals[] = {BiHorizontalVal, BiVerticalVal, UniHorizontalVal, UniVerticalVal};

void setup() {
  Serial.begin(9600);
  // put your setup code here, to run once:
  pinMode(BiHorizontal, INPUT);
  pinMode(BiVertical, INPUT);
  pinMode(UniHorizontal, INPUT);
  pinMode(UniVertical, INPUT);

  pinMode(enableAPin, OUTPUT);
  pinMode(enableBPin, OUTPUT);

  pinMode(UniApin, OUTPUT);
  pinMode(UniBpin, OUTPUT);
  pinMode(UniCpin, OUTPUT);
  pinMode(UniDpin, OUTPUT);

  pinMode(In4, OUTPUT);
  pinMode(In3, OUTPUT);
  pinMode(In2, OUTPUT);
  pinMode(In1, OUTPUT);

  digitalWrite(enableAPin, HIGH);
  digitalWrite(enableBPin, HIGH);
}

void loop() {
  // put your main code here, to run repeatedly:
  while(true) {
    BiHorizontalVal = digitalRead(BiHorizontal);
    BiVerticalVal = digitalRead(BiVertical);
    UniVerticalVal = digitalRead(UniVertical);
    UniHorizontalVal = digitalRead(UniHorizontal);
    
    if ((BiHorizontalVal) != 0) {
      Bipolar_StepCW();
    }
    if ((UniVerticalVal) != 0) {
      Unipolar_StepCW();
    }
    if ((BiHorizontalVal) == 0 && (UniVerticalVal) == 0) {
      delay(delayTime2);
      break;
    }
  }
  while(true) {
    while(true) {
      BiHorizontalVal = digitalRead(BiHorizontal);
      BiVerticalVal = digitalRead(BiVertical);
      UniVerticalVal = digitalRead(UniVertical);
      UniHorizontalVal = digitalRead(UniHorizontal);
      if ((BiVerticalVal) != 0) {
        Bipolar_StepCW();
    }
      if ((UniHorizontalVal) != 0) {
        Unipolar_StepCW();
    }
      if (BiVerticalVal == 0 && UniHorizontalVal == 0) {
        break;
    }
  }
    while (true) {
      BiHorizontalVal = digitalRead(BiHorizontal);
      BiVerticalVal = digitalRead(BiVertical);
      UniVerticalVal = digitalRead(UniVertical);
      UniHorizontalVal = digitalRead(UniHorizontal);
      if ((BiHorizontalVal) != 0) {
        Bipolar_StepCCW();
    }
      if ((UniVerticalVal) != 0) {
        Unipolar_StepCCW();
    }
      if (BiHorizontalVal == 0 && UniVerticalVal == 0) {
        break;
      }
    }
  }
}
   
void Bipolar_StepCW() {
  digitalWrite(enableAPin, HIGH);
  digitalWrite(enableBPin, HIGH);
  
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

void Bipolar_StepCCW() {
  digitalWrite(enableAPin, HIGH);
  digitalWrite(enableBPin, HIGH);
  
  digitalWrite(In4, HIGH);
  digitalWrite(In3, HIGH);
  digitalWrite(In2, LOW);
  digitalWrite(In1, LOW);
  delay(delayTime);    
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
  
}

void Unipolar_StepCW() {
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

void Unipolar_StepCCW() {
  digitalWrite(UniApin, HIGH);
  digitalWrite(UniCpin, HIGH);
  digitalWrite(UniBpin, LOW);
  digitalWrite(UniDpin, LOW);
  delay(delayTime);
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
  
}
