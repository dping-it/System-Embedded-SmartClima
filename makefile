EMBEDDED: ans.f gpio.f i2c.f lcd.f led.f pad.f hdmi.f timer.f button.f main.f
	rm -f embedded.f
	rm -f final.f
	cat ans.f >> embedded.f
	cat gpio.f >> embedded.f
	cat i2c.f >> embedded.f
	cat lcd.f >> embedded.f
	cat led.f >> embedded.f
	cat pad.f >> embedded.f
	cat hdmi.f >> embedded.f
	cat timer.f >> embedded.f
	cat button.f >> embedded.f
	cat main.f >> embedded.f
	grep -v '^ *\\' embedded.f > final.f