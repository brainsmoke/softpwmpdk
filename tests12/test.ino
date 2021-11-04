
void setup()
{
	Serial.begin(38400);
}

void rgb(uint16_t r, uint16_t g, uint16_t b)
{
	Serial.write(r&0xff);
	Serial.write(r>>8);
	Serial.write(g&0xff);
	Serial.write(g>>8);
	Serial.write(b&0xff);
	Serial.write(b>>8);
}

int wave[] ={
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 3, 4, 6, 9, 13, 18, 24, 32, 41, 53, 67, 85, 105, 129, 157, 190, 228, 272, 322, 379, 443, 516, 597, 688, 790, 902, 1026, 1162, 1312, 1476, 1655, 1849, 2060, 2288, 2534, 2799, 3084, 3388, 3714, 4062, 4432, 4825, 5241, 5682, 6148, 6638, 7155, 7697, 8266, 8861, 9483, 10133, 10809, 11512, 12242, 13000, 13784, 14594, 15431, 16293, 17180, 18092, 19028, 19987, 20968, 21972, 22995, 24038, 25100, 26178, 27273, 28382, 29504, 30638, 31783, 32936, 34096, 35261, 36430, 37601, 38772, 39941, 41106, 42266, 43418, 44560, 45692, 46809, 47912, 48997, 50062, 51107, 52128, 53124, 54094, 55034, 55944, 56822, 57666, 58474, 59245, 59978, 60670, 61321, 61929, 62493, 63012, 63485, 63910, 64288, 64616, 64896, 65125, 65304, 65432, 65509, 65535, 65509, 65432, 65304, 65125, 64896, 64616, 64288, 63910, 63485, 63012, 62493, 61929, 61321, 60670, 59978, 59245, 58474, 57666, 56822, 55944, 55034, 54094, 53124, 52128, 51107, 50062, 48997, 47912, 46809, 45692, 44560, 43418, 42266, 41106, 39941, 38772, 37601, 36430, 35261, 34096, 32936, 31783, 30638, 29504, 28382, 27273, 26178, 25100, 24038, 22995, 21972, 20968, 19987, 19028, 18092, 17180, 16293, 15431, 14594, 13784, 13000, 12242, 11512, 10809, 10133, 9483, 8861, 8266, 7697, 7155, 6638, 6148, 5682, 5241, 4825, 4432, 4062, 3714, 3388, 3084, 2799, 2534, 2288, 2060, 1849, 1655, 1476, 1312, 1162, 1026, 902, 790, 688, 597, 516, 443, 379, 322, 272, 228, 190, 157, 129, 105, 85, 67, 53, 41, 32, 24, 18, 13, 9, 6, 4, 3, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
};
//wave = [ int(( (1-math.cos(i/256*2*math.pi))/2)**2.6 * 0x8000) for i in range(256) ]

void loop()
{
	uint16_t i;

	for(;;)
	{
		for (i=0; i<0x100; i++)
		{
			rgb(i,0,0);
			rgb(0,0,i);
			rgb(0,0,i);
			rgb(0,0,i);
			rgb(wave[i], wave[(i+85)&0xff], wave[(i+170)&0xff]);
			rgb(0,0,i);
			rgb(0,0,i);
			rgb(0,0,i);
			rgb(0,0,i);

			Serial.flush();
			delay(2);
		}
	}
}
