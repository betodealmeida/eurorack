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
#define BUTTON_0 0x50
#define BUTTON_1 0x51

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

boolean button_0 = false, button_1 = false;

void loop() {
    if (!ps2.readData()) return;

    if (ps2.finger) {
        sendMidi(CHANNEL_0, CC_21, (int) ps2.x/2);
        sendMidi(CHANNEL_0, CC_22, (int) ps2.y/2);
        sendMidi(CHANNEL_0, CC_23, (int) ps2.z/2);
    } else if (ps2.left) {
        if (button_0) 
            sendMidi(CHANNEL_0, BUTTON_0, 0);
        else
            sendMidi(CHANNEL_0, BUTTON_0, 127);
        button_0 = !button_0;
    } else if (ps2.right) {
        if (button_1) 
            sendMidi(CHANNEL_0, BUTTON_1, 0);
        else
            sendMidi(CHANNEL_0, BUTTON_1, 127);
        button_1 = !button_1;
    }

    Serial.println();
    delay(25);
}

void sendMidi(int cmd, int pitch, int velocity) {
    midi.write(cmd);
    midi.write(pitch);
    midi.write(velocity);
}
