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

int delayTime = 500;
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

}

void loop() {
  // put your main code here, to run repeatedly:
  digitalWrite(enableAPin, HIGH);
  digitalWrite(enableBPin, HIGH);

  digitalWrite(UniApin, LOW);
  digitalWrite(UniBpin, LOW);
  digitalWrite(UniCpin, LOW);
  digitalWrite(UniDpin, LOW);

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

  n+=1;
  Serial.println(n);
}
