int UniApin = 10;
int UniBpin = 11;
int UniCpin = 12;
int UniDpin = 13;
int delayTime = 500;
int n = 0; // count

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(UniApin, OUTPUT);
  pinMode(UniBpin, OUTPUT);
  pinMode(UniCpin, OUTPUT);
  pinMode(UniDpin, OUTPUT);
}

void loop() {
  // put your main code here, to run repeatedly:
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
  n += 1;
  Serial.println(n);
}
