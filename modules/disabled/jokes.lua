--Joke modul

local jokes={	"Me: should I get into trouble for something I didn't do?\nTeacher: No\nMe: Good, because I didn't do my homework.",
				"Election and Erection are spelled almost exactly the same. They both mean the same thing too. A dick rising to power.",
				"Wifi went down for five minutes, so i had to talk to my family. They seem like nice people.",
				"Imagine if your fridge did what you do to it everyday. Every half hour it goes to your room opens the door, and stares at you for 5 minutes then leaves.",
				"I was just sitting around, doing nothing, when I was arrested for impersonating the President of the United States.",
				"The only thing I use BING for is to search Google.",
				"Boyfriend: Bitch\nGirlfriend: I been called worse\nBoyfriend: Like what\nGirlfriend: your girlfriend",
				}

local alleKinder = {"Alle Kinder rennen aus dem brennenden Kino, nur nicht Abdul, der klemmt im Klappstuhl.",
					"Alle Kinder verließen das E-Werk, nur nicht Abel, der fasste ans Kabel.",
					"Alle Kinder spielen mit dem Messer, nur nicht Adele, der steckt's in der Kehle.",
					"Alle Kinder bleiben am Abgrund stehen, nur nicht Adelheid, die geht zu weit.",
					"Alle Kinder fürchten sich vor Udo, nur nicht Agathe, die kann Karate.",
					"Alle Kinder überlebten die Bombe, nur nicht Alexander, den riss es auseinander.",
					"Alle Kinder nehmen Aspirin, nur nicht Ali, der isst Zyankali.",
					"Alle Kinder klettern aus der Schlangengrube, nur nicht Amanda, die hängt am Expander.",
					"Alle Kinder fahren an das Mittelmeer, nur nicht Andrea, die fährt nach Korea.",
					"Alle Kinder beobachten den hungrigen Löwen, nur nicht Andrea, die geht etwas näher.",
					"Alle Kinder hören die harte Musik, nur nicht Anabell, der platzt das Trommelfell.",
					"Alle Kinder spenden für Behinderte, nur nicht Anke, die sagt: Danke."
					}
					
local mamimami = {	"“Mami Mami, wieso rennt Papi so im Zickzack?” – “Sei ruhig Kind und gib mir das andere Gewehr!”",
					"“Mami, Mami, was sind eigentlich Vampire?” – “Sei still und trink dein Blut aus, bevor es gerinnt.”",
					"“Mami, Mami. Darf ich die Schüssel jetzt auslecken?” – “Nein, du wartest, bis Pappi gepinkelt hat.”",
					"“Mami, Mami, alle sagen ich wäre ein Monster.” – “Aber nein mein Schatz, schließe deine drei Augen und schlaf.”",
					"“Mami, Mami, kann ich noch so ein leckeres Bonbon bekommen?” – “Nein, Opa hatte nur zwei Augen!”",
					"“Mami, Mami, alle sagen ich hätte so große Zähne!” – “Aber Kind, dass stimmt doch gar nicht. Mach’ schnell den Mund zu, sonst verkratzt du den Boden!”",
					"“Mami, Mami, muss ich immer noch im Kreis rumlaufen?” – “Sei ruhig, sonst nagele ich dir den anderen Fuß auch noch fest!”",
					"“Mami Mami, haben wir noch so leckere blaue Nudeln?” – “Nein die Oma hat ihre Krampfadern doch veröden lassen.”",
					"“Mami, Mami warum schieben wir den Wagen über die Klippe?” – “Psst! Sei still Vati wird wach!”",
					"“Mami, Mami, ich will nicht nach Australien.” – “Sei still und grab weiter.",
					"“Mami, Mami, ich hab heute wieder mit Opa gespielt!” – “Aber Kindchen, du sollst doch nicht so tief im Sandkasten buddeln!”",
					"“Mami, Mami. Alle in der Klasse sagen ich hätte so große Füße!” “Ach Quatsch! Red nicht so lang , stell deine Schuhe in die Garage und komm rein, es gibt essen!”",
					"“Mami, Mami mir ist ganz schwindlig!” – “Sei still! Das ist erst der Vorwaschgang!”",
					"“Mami, Mami, was ist eigentlich ein Engel?” – “Das ist jemand, der nicht ordentlich nach rechts und links geguckt hat, als er über die Strasse gegangen ist!”",
					"“Mami, Mami, ich mag Opa nicht mehr!” – “Sei ruhig und iss weiter!”"
					}
					
--addCommand("showjokes", function(msg, args)
	--for a=1 #args[1] do
		--send_text(msg.to.print_name,list[a])
	--end
--end)
					

addCommand("mamimami", function(msg,args)
	a=math.random(#mamimami)
	send_text(msg.to.print_name,mamimami[a])
end)

addCommand("allekinder", function(msg,args)
	a=math.random(#alleKinder)
	send_text(msg.to.print_name,alleKinder[a])
end)

addCommand("joke", function(msg,args)
	a=math.random(#jokes)
	send_text(msg.to.print_name,jokes[a])
end)