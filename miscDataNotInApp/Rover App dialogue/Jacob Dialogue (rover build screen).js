{//VARIABLES
	{//WEIGHT 
	currentWeight;
	baseWeight = 105;
	maxWeight = 185;
	}
	{//PORTS
	portA = false; //the upper right (half circle)
	portB = false; //trapezoidal (for vertical tools)
	portsCandD = 0; //bottom left, upper right (arm tools)
	portE = false; //locomotion
	}
	{//COMMUNICATION
	highGain = false;
	lowGain = false;
	}
	{//ANALYSIS (B)
	panCam = false;
	spectrometer = false;
	weatherStation = false;
	chemCam = false;
	}
	{//ANALYSIS (CorD)
	rockGrinder = false;
	microscope = false;
	laserDrill = false;
	}
	{//LOCOMOTION TOOLS
	hovercraft = false;
	wheels = false;
	treads = false;
	}
}

{//MISSION REQUIREMENTS
	moon = body + highGain + wheels + weatherStation;
	mars = body + highGain + (treads or wheels) + (rockGrinder or chemCam or microscope or spectrometer);
	titan = body + highGain + hovercraft + laserDrill + microscope;
	pluto = body + highGain + treads + panCam;
	all = currentWeight <= maxWeight;
}

{//MISSIONS
	{//MOON
		{//AT SCREEN START
		//These should start displaying when the screen is loaded. 
		//After each one types out, it should stay long enough to read (maybe 2 seconds?), and then the next one should start typing out.
		//The user can interrupt this at any time by clicking on a tool button or by selecting a tool.
			"Hi, engineer! Jacob here, and I'm going to help you build your rover for your Moon mission!"
			"Look through the tools, and drag the ones you need for your mission onto your rover body." 
			"If your rover weighs more than 185kg, it will be too heavy to launch!" 
			"Ready to build? Let's get started!" 
		}
		{//RESPONSIVE
			if ("tool is needed for the mission AND rover is not overweight"){
				if ("tool is highGain"){"Great! Now you will be able to send instructions to your rover."}
				if ("tool is wheels"){"Excellent! Those wheels will work well on the Moon's rocky and dusty surface."}
				if ("tool is weatherStation"){"Fantastic! Now your rover will be able to take temperature readings!"}
			}
			if ("tool is needed for the mission AND rover IS overweight"){
				if ("tool is highGain, wheels, or weatherStation"){
					"You need that tool, but your rover is over the 185kg weight limit! Better take something off."
					//OR, depending on how easy this would be: 
					"You need that tool, but your rover is " + currentWeight-maxWeight + "kg over the weight limit!"
				}
			}
			if ("tool is not needed for mission AND rover is not overweight"){
				if ("tool is panCam, spectrometer, chemCam, rockGrinder, microscope, or laserDrill"){
					"That tool doesn’t help with your primary mission, but bring it along if you want!"
				}
				if ("tool is lowGain and highGain IS on rover"){"That tool doesn’t help with your primary mission, but bring it along if you want!"}
				if ("tool is lowGain and highGain IS NOT on rover"){"That’s a backup tool. You still need the high gain antenna to send the rover instructions!"}
				if ("tool is treads"){"Those treads won't work very well on the Moon. Try a different locomotion tool!"}
				if ("tool is hovercraft"){"The hovercraft won't work very well on the Moon. Try a different locomotion tool!"}
			}
			if ("tool is not needed for mission AND rover is overweight"){
				if ("tool is lowGain or panCam or spectrometer or chemCam or rockGrinder or microscope or laserDrill"){
					"It would be nice to have that tool, but your rover is over the 185kg weight limit!"
					//OR 
					"It would be nice to have that tool, but now your rover is " + currentWeight-maxWeight + "kg over the weight limit!"
					}
				if ("tool is treads"){"Those treads won't work very well on the Moon. Try a different locomotion tool!"}
				if ("tool is hovercraft"){"The hovercraft won't work very well on the Moon. Try a different locomotion tool!"}
			}
		}
		{//GENERAL
			if ("you have all required tools for the mission"){
				"Those are all the tools your rover needs to complete its Moon mission! Ready to launch?"
			}
			if ("you still need highGain, wheels, and weatherStation"){
				"Your rover still needs tools for communication, analysis, and locomotion."					
				"Your rover isn't ready for launch. What tools does it need?"
				}
			if ("you still need wheels"){
				"Your rover still needs a locomotion tool."
				"How will your rover move around on the rocky and dusty surface of the Moon?"
			}
			if ("you still need highGain"){
				"Your rover still needs a communication tool."
				"Make sure to include the tool that will allow you to send instructions to your rover!"
			}
			if ("you still need weatherStation"){
				"Your rover still needs an analysis tool."
				"What tool will let your rover to take the temperature on the Moon?"
			}
			if ("any condition"){
				"Remember, your mission is to take temperature readings from the dark side of the moon."
				"The Moon is 240,000 miles from earth!"
				"Because there is no wind on the Moon, footprints and tracks last for years and years!"
				
			}
		}
	}
	{//MARS
				
		{//AT SCREEN START
			"Hi, engineer! Jacob here, and I'm going to help you build your rover for your Mars mission!"
			"Look through the tools, and drag the ones you need for your mission onto your rover body." 
			"If your rover weighs more than 185kg, it will be too heavy to launch!" 
			"Ready to build? Let's get started!" 
		}
	
		{//RESPONSIVE
			if ("tool is needed for the mission AND rover is not overweight"){
				if ("tool is highGain"){"Great! Now you will be able to send instructions to your rover."}
				if ("tool is wheels"){"Excellent! Those wheels will work well on the rocky and dusty surface of Mars."}
				if ("tool is treads"){"Nice! Those treads will work well on the rocky and dusty surface of Mars."}
				if ("tool is rockGrinder"){"Good choice! With the rock grinder, your rover will be able to check for liquid water on Mars!"}
				if ("tool is chemCam"){"Wonderful! The ChemCam will let your rover detect tiny fossils of ancient life!"}
				if ("tool is microscope"){"Fantastic! The microscope will let your rover detect tiny fossils of ancient life!"}
				if ("tool is spectrometer"){"Sweet! The spectrometer will let your rover detect tiny fossils of ancient life!"}
			}
			if ("tool is needed for the mission AND rover IS overweight"){
				if ("tool is highGain, (wheels OR treads), rockGrinder, or chemCam"){
					"You need that tool, but your rover is over the 185kg weight limit! Better take something off."
					//OR, depending on how easy this would be: 
					"You need that tool, but your rover is " + currentWeight-maxWeight + "kg over the weight limit!"
				}
			}
			if ("tool is not needed for mission AND rover is not overweight"){
				if ("tool is panCam, weatherStation, or laserDrill"){
					"That tool doesn’t help with your primary mission, but bring it along if you want!"
				}
				if ("tool is lowGain and highGain IS on rover"){"That tool doesn’t help with your primary mission, but bring it along if you want!"}
				if ("tool is lowGain and highGain IS NOT on rover"){"That’s a backup tool. You still need the high gain antenna to send the rover instructions!"}
				if ("tool is hovercraft"){"The hovercraft won't work very well on Mars. Try a different locomotion tool!"}
			}
			if ("tool is not needed for mission AND rover is overweight"){
				if ("tool is lowGain or panCam or weatherStation or laserDrill"){
					"It would be nice to have that tool, but your rover is over the 185kg weight limit!"
					//OR 
					"It would be nice to have that tool, but now your rover is " + currentWeight-maxWeight + "kg over the weight limit!"
					}
				if ("tool is hovercraft"){"The hovercraft won't work very well on Mars. Try a different locomotion tool!"}
			}
		}
		{//GENERAL
		//mars = body + highGain + (treads or wheels) + (rockGrinder) + (chemCam or microscope or spectrometer);
			if ("you have all required tools for the mission"){
				"Those are all the tools your rover needs to complete its Mars mission! Ready to launch?"
			}
			if ("you still need (highGain), (wheels OR treads), (rockGrinder), and (ChemCam OR microscope OR spectrometer)"){
				"Your rover still needs tools for communication, analysis, and locomotion."			
				"Your rover isn't ready for launch. What tools does it need?"
			}
			if ("you still need (highGain)"){
				"Your rover still needs a communication tool."
				"Make sure to include the tool that will allow you to send instructions to your rover!"
			}
			if ("you still need (wheels OR treads)"){
				"Your rover still needs a locomotion tool."
				"How will your rover move around on the dusty and rocky surface of Mars?"
			}
			if ("you still need (rockGrinder)"){
				"Your rover still needs an analysis tool."
				"How will your rover detect evidence of liquid water?"
			}
			if ("you still need (chemCam OR microscope OR spectrometer)"){
				"Your rover still needs an analysis tool."
				"What does your rover need to look for tiny fossils?"
			}
			if ("any condition"){
				"Your mission: examine rocks for traces of liquid water and look for ancient fossils."
				"It may be possible for humans to go to Mars within the next ten years!" 
				"'The Martian Chronicles' by Ray Bradbury is one of my favorite science fiction books!"
				"It can take a radio message up to 20 minutes to travel from Mars back to Earth!"
				"Mars is about 200 million miles away from Earth!"
			}
		}
	}
	{//TITAN		
		{//AT SCREEN START
			"Hi, engineer! Jacob here, and I'm going to help you build your rover for your Titan mission!"
			"Look through the tools, and drag the ones you need for your mission onto your rover body." 
			"If your rover weighs more than 185kg, it will be too heavy to launch!" 
			"Ready to build? Let's get started!" 
		}
		
		{//RESPONSIVE
		if ("tool is needed for the mission AND rover is not overweight"){
				if ("tool is highGain"){"Great! Now you will be able to send instructions to your rover."}
				if ("tool is hovercraft"){"Excellent! The hovercraft will let your rover move around on Titan's icy surface."}
				if ("tool is laserDrill"){"Awesome! This will allow your rover to drill through the thick ice on Titan."}
				if ("tool is microscope"){"Nice! With the microscope, your rover might be able to detect evidence of life!"}
			}
			if ("tool is needed for the mission AND rover IS overweight"){
				if ("tool is highGain OR hovercraft OR laserDrill OR microscope"){
					"You need that tool, but your rover is over the 185kg weight limit! Better take something off."
					//OR, depending on how easy this would be: 
					"You need that tool, but your rover is " + currentWeight-maxWeight + "kg over the weight limit!"
				}
			}
			if ("tool is not needed for mission AND rover is not overweight"){ //lowgain, rock grinder, chemCam, weatherStation, spectrometer, panCam, treads, wheels
				if ("tool is rockGrinder, panCam, chemCam, weatherStation, or spectrometer"){
					"That tool doesn’t help with your primary mission, but bring it along if you want!"
				}
				if ("tool is lowGain and highGain IS on rover"){"That tool doesn’t help with your primary mission, but bring it along if you want!"}
				if ("tool is lowGain and highGain IS NOT on rover"){"That’s a backup tool. You still need the high gain antenna to send the rover instructions!"}
				if ("tool is wheels"){"Wheels won't work very well on Titan's icy surface. Try a different locomotion tool!"}
				if ("tool is treads"){"Treads won't work very well on Titan's icy surface. Try a different locomotion tool!"}
				}
			if ("tool is not needed for mission AND rover is overweight"){
				if ("tool is lowGain or rockGrinder or panCam or chemCam or weatherStation or spectrometer"){
					"It would be nice to have that tool, but your rover is over the 185kg weight limit!"
					//OR 
					"It would be nice to have that tool, but now your rover is " + currentWeight-maxWeight + "kg over the weight limit!"
					}
				if ("tool is wheels"){"Wheels won't work very well on Titan's icy surface. Try a different locomotion tool!"}
				if ("tool is treads"){"Treads won't work very well on Titan's icy surface. Try a different locomotion tool!"}
			}
		}
		{//GENERAL
		//titan = body + highGain + hovercraft + laserDrill + microscope;
		if ("you have all required tools for the mission"){
				"Those are all the tools your rover needs to complete its mission on Titan! Ready to launch?"
			}
			if ("you still need (highGain), (hovercraft), (laserDrill), and (microscope)"){
				"Your rover still needs tools for communication, analysis, and locomotion."			
				"Your rover isn't ready for launch. What tools does it need?"
			}
			if ("you still need highGain"){
				"Your rover still needs a communication tool."
				"Make sure to include the tool that will allow you to send instructions to your rover!"
			}
			if ("you still need hovercraft"){
				"Your rover still needs a locomotion tool."
				"How will your rover move around on the icy surface of Titan?"
			}
			if ("you still need laserDrill"){
				"Your rover still needs an analysis tool."
				"How will your rover get to the soil underneath the thick ice on Titan?"
			}
			if ("you still need microscope"){
				"Your rover still needs an analysis tool."
				"How can you analyze the soil under the ice for evidence of life?"
			}
			if ("any condition"){
				"Remember, your mission is to study the soil underneath the ice for evidence of life."
				"It takes about 10 times longer to travel to Titan than to travel to the Sun!" 
				"A year on Titan is almost 44 Earth-years long!"
				"Titan is so cold, water on its surface is as hard as rock."
			}
		}
	}
	{//PLUTO
			
		{//AT SCREEN START
			"Hi, engineer! Jacob here, and I'm going to help you build your rover for your Pluto mission!"
			"Look through the tools, and drag the ones you need for your mission onto your rover body." 
			"If your rover weighs more than 185kg, it will be too heavy to launch!" 
			"Ready to build? Let's get started!" 
		}
	
		{//RESPONSIVE
			if ("tool is needed for the mission AND rover is not overweight"){
				if ("tool is highGain"){"Great! Now you will be able to send instructions to your rover."}
				if ("tool is treads"){"Excellent! The treads will let your rover move around on Pluto's icy and rocky surface."}
				if ("tool is panCam"){"Awesome! The PanCam will let your rover take pictures of Pluto's unexplored surface!"}
			}
			if ("tool is needed for the mission AND rover IS overweight"){
				if ("tool is highGain OR treads OR panCam"){
					"You need that tool, but your rover is over the 185kg weight limit! Better take something off."
					//OR, depending on how easy this would be: 
					"You need that tool, but your rover is " + currentWeight-maxWeight + "kg over the weight limit!"
				}
			}
			if ("tool is not needed for mission AND rover is not overweight"){ 
				if ("tool is rockGrinder, chemCam, weatherStation, spectrometer, or laserDrill"){
					"That tool doesn’t help with your primary mission, but bring it along if you want!"
				}
				if ("tool is lowGain and highGain IS on rover"){"That tool doesn’t help with your primary mission, but bring it along if you want!"}
				if ("tool is lowGain and highGain IS NOT on rover"){"That’s a backup tool. You still need the high gain antenna to send the rover instructions!"}
				if ("tool is wheels"){"Wheels won't work very well on Pluto's surface. Try a different locomotion tool!"}
				if ("tool is hovercraft"){"The hovercraft won't work very well on Pluto. Try a different locomotion tool!"}
				}
			if ("tool is not needed for mission AND rover is overweight"){
				if ("tool is lowGain or rockGrinder or panCam or chemCam or weatherStation or spectrometer or laserDrill"){
					"It would be nice to have that tool, but your rover is over the 185kg weight limit!"
					//OR 
					"It would be nice to have that tool, but now your rover is " + currentWeight-maxWeight + "kg over the weight limit!"
					}
				if ("tool is wheels"){"Wheels won't work very well on Pluto's surface. Try a different locomotion tool!"}
				if ("tool is hovercraft"){"The hovercraft won't work very well on Pluto. Try a different locomotion tool!"}
			}
		}
		{//GENERAL
			if ("you have all required tools for the mission"){
				"Those are all the tools your rover needs to complete its mission on Pluto! Ready to launch?"
			}
			if ("you still need highGain, treads, and panCam"){
				"Your rover still needs tools for communication, analysis, and locomotion."			
				"Your rover isn't ready for launch. What tools does it need?"
			}
			if ("you still need highGain"){
				"Your rover still needs a communication tool."
				"Make sure to include the tool that will allow you to send instructions to your rover!"
			}
			if ("you still need treads"){
				"Your rover still needs a locomotion tool."
				"Pluto's surface is rocky and icy. What would be the best locomotion tool for that?"
			}
			if ("you still need panCam"){
				"Your rover still needs an analysis tool."
				"What can your rover use to take a picture of Pluto's surface?"
			}
			if ("any condition"){
				"Remember, your mission is to take a picture of Pluto’s surface!"
				"Pluto is about 3 BILLION miles away from Earth!"
				"Pluto has 5 moons that we know about. Two were discovered in the past 5 years!"
				"I have two dogs, and their names are Pluto and Rover. What a coincidence!" 
			}
		}
	}
}