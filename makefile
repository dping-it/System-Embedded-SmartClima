EMBEDDED: ans.f gpio.f i2c.f lcd.f pad.f set.f main.f
	rm -f embedded.f
	rm -f final.f
	cat ans.f >> embedded.f
	cat gpio.f >> embedded.f
	cat i2c.f >> embedded.f
	cat lcd.f >> embedded.f
	cat set.f >> embedded.f
	cat pad.f >> embedded.f
	cat main.f >> embedded.f
	grep -v '^ *\\' embedded.f > final.f
