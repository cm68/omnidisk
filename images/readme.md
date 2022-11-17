Mods for revision 1.3 firmware to allow SOD to reset NEC, and SIB to get NEC DRQ status

1. On front of board cut first diagonal trace between 8085 and NEC-765.  See picture CUT_TOP
   where I have high-lighted where cut is.
   You can verify by checking with ohm meter that 8085 pin #3 (RESET-OUT) is no longer going
   to NEC-765 pin #1 (reset)

2. On back of board follow trace from pin 1 of NEC-765 down to first VIA hole, and cut the
   trace just above the hole.  See picture CUT_BOTTOM where I have high-lighted where cut is.
   You can verify by checking with ohm meter that NEC-765 pin #1 is no longer going to the VIA hole.

3. Jumper 8085 pin #3 (RESET-OUT) to the VIA hole.  This connect RESET-OUT back to the circuit.

4. Jumper 8085 pin #5 (SID) to NEC-765 pin #14 (DRQ)

5. Install 3-pin block into spare holes of U21. I use holes #12-14.  See picture JMP_BLOCK.

6.  Jumper 8085 pin #3 (RESET-OUT) to BOTTOM pin of the 3-pin block.

7.  Jumper 8085 pin #4 (SOD) to UPPER pin of the 3-pin block.

8.  Jumper NEC-765 pin #1 (RESET) to MIDDLE pin of 3-pin block.

See picture JUMPERS.  The WHITE high-light is pin #1 of NEC-765 to middle pin of 3-pin block.
The RED high-light is 8085 pin #4 to NEC-765 pin #14.
Between the two high-lights is jumper from 8085 pin #3 to VIA hole.

Verify wiring now.  Install a shorting-plug between BOTTOM and MIDDLE pin of 3-pin block and
verify that pin #3 of 8085 is connected to pin #1 of NEC-765.
Now move shorting-plug to connect UPPER and MIDDLE pins of 3-pin block and verify that
pin #4 of 8085 is connected to pin #1 of NEC-765 chip, if this checks out you are all done.

