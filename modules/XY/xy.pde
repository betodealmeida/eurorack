#include <Adafruit_PS2_Trackpad.h>
#include <SoftwareSerial.h>

#define PS2_DATA 2
#define PS2_CLK 3

#define MIDI_RX 10
#define MIDI_TX 11

// http://www.ccarh.org/courses/253/handout/controllers/
#define CHANNEL_0 0x90
#define CC_21 0x15
#define CC_22 0x16
#define CC_23 0x17
#define LEFT_BUTTON 0x50
#define RIGHT_BUTTON 0x51

Adafruit_PS2_Trackpad ps2(PS2_CLK, PS2_DATA);
SoftwareSerial midi(MIDI_RX, MIDI_TX);

void setup() {
    Serial.begin(9600);
    if (ps2.begin()) 
        Serial.println("Successfully found PS2 mouse device");
    else
        Serial.println("Did not find PS2 mouse device");
    Serial.print("PS/2 Mouse with ID 0x");
    Serial.println(ps2.readID(), HEX);

    midi.begin(31250);
}

boolean left_button = false, right_button = false;

void loop() {
    if (!ps2.readData()) return;

    if (ps2.finger) {
        sendMidi(CHANNEL_0, CC_21, (int) ps2.x/2);
        sendMidi(CHANNEL_0, CC_22, (int) ps2.y/2);
        sendMidi(CHANNEL_0, CC_23, (int) ps2.z/2);
    } else if (ps2.left) {
        if (left_button) 
            sendMidi(CHANNEL_0, LEFT_BUTTON, 0);
        else
            sendMidi(CHANNEL_0, LEFT_BUTTON, 127);
        left_button = !left_button;
    } else if (ps2.right) {
        if (right_button) 
            sendMidi(CHANNEL_0, RIGHT_BUTTON, 0);
        else
            sendMidi(CHANNEL_0, RIGHT_BUTTON, 127);
        right_button = !right_button;
    }

    Serial.println();
    delay(25);
}

void sendMidi(int cmd, int pitch, int velocity) {
    midi.write(cmd);
    midi.write(pitch);
    midi.write(velocity);
}
