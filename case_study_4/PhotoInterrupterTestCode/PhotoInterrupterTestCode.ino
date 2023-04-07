int BiHorizontal = A1; //left left
int BiHorizontalVal = 0;
int BiVertical = A2; //left mid
int BiVerticalVal = 0;
int UniHorizontal = A3; // right mid
int UniHorizontalVal = 0;
int UniVertical = A4; // right right
int UniVerticalVal = 0;

int Vals[] = {BiHorizontalVal, BiVerticalVal, UniHorizontalVal, UniVerticalVal};

void setup() {
  Serial.begin(9600);
  // put your setup code here, to run once:
  pinMode(BiHorizontal, INPUT);
  pinMode(BiVertical, INPUT);
  pinMode(UniHorizontal, INPUT);
  pinMode(UniVertical, INPUT);
}

void loop() {
  
  // put your main code here, to run repeatedly:
  BiHorizontalVal = digitalRead(BiHorizontal);
  BiVerticalVal = digitalRead(BiVertical);
  UniHorizontalVal = digitalRead(UniHorizontal);
  UniVerticalVal = digitalRead(UniVertical);

//  Serial.println(BiHorizontalVal);
//  Serial.println(BiVerticalVal);
//  Serial.println(UniHorizontalVal);
//  Serial.println(UniVerticalVal);
  
}
