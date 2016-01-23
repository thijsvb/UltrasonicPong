/*
 * Ultrasonic Pong
 * Thijs van Beers, 2016
 * 
 * Most of this code is the NewPing15Sensors example from the NewPing library.
 * http://playground.arduino.cc/Code/NewPing
 */

#include <NewPing.h>

//Connect two ultrasonic distance sensors.
//The first with trigger to pin 7 and echo to pin 8,
//the second with trigger to pin 9 and echo to pin 10.
#define SONAR_NUM     2
#define PING_INTERVAL 33  
#define MAX_DISTANCE  50
#define TRIGGER_PIN   7  
#define ECHO_PIN      8
#define TRIGGER_PIN2  9  
#define ECHO_PIN2     10

unsigned long pingTimer[SONAR_NUM];
unsigned int cm[SONAR_NUM];
uint8_t currentSensor = 0;

NewPing sonar[SONAR_NUM] = {
  NewPing(7, 8, MAX_DISTANCE),
  NewPing(9, 10, MAX_DISTANCE)
};

void setup() {
  Serial.begin(115200);
  pingTimer[0] = millis() + 75;           // First ping starts at 75ms, gives time for the Arduino to chill before starting.
  for (uint8_t i = 1; i < SONAR_NUM; i++) // Set the starting time for each sensor.
    pingTimer[i] = pingTimer[i - 1] + PING_INTERVAL;
}

void loop() {
  for (uint8_t i = 0; i < SONAR_NUM; i++) { // Loop through all the sensors.
    if (millis() >= pingTimer[i]) {         // Is it this sensor's time to ping?
      pingTimer[i] += PING_INTERVAL * SONAR_NUM;  // Set next time this sensor will be pinged.
      if (i == 0 && currentSensor == SONAR_NUM - 1) oneSensorCycle(); // Sensor ping cycle complete, do something with the results.
      sonar[currentSensor].timer_stop();          // Make sure previous timer is canceled before starting a new ping (insurance).
      currentSensor = i;                          // Sensor being accessed.
      cm[currentSensor] = 0;                      // Make distance zero in case there's no ping echo for this sensor.
      sonar[currentSensor].ping_timer(echoCheck); // Do the ping (processing continues, interrupt will call echoCheck to look for echo).
    }
  }
}

void echoCheck() { // If ping received, set the sensor distance to array.
  if (sonar[currentSensor].check_timer())
    cm[currentSensor] = sonar[currentSensor].ping_result / US_ROUNDTRIP_CM;
}

void oneSensorCycle() { // Sensor ping cycle complete, now send it over the serial port.
  Serial.print(cm[0]);
  Serial.print(",");
  Serial.println(cm[1]);
}

