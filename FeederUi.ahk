#HotIf WinActive("Ephinea: Phantasy Star Online Blue Burst")
SendMode("Event")
SetKeyDelay 200,100

;########################## Global Vars ###################################
global magFeedingDelay := 220000 ;milliseconds
global FeedReady := 1

;########################## UI Setup ###################################
MyGui := Gui()
MyGui.SetFont("s20", "Verdana")
MyGui.Add("Text", "", "Ephinea Mag Feeder")
MyGui.SetFont("s8", "Verdana")

;Groupbox Info
MyGui.SetFont("bold", "Verdana")
MyGui.Add("GroupBox", "w180 r2 Section", "Info")
MyGui.SetFont("Norm", "Verdana")
MyGui.Add("Text", "xs+10 ys+20", "Feeding Time:")
txtMinutesTotal := MyGui.Add("Text", "xs+100 ys+20", "xxxxxxxx Minutes")
MyGui.Add("Text", "xs+10 ys+50", "Meseta needed:")
txtMesetaTotal := MyGui.Add("Text", "xs+100 ys+50", "xxxxxxxxx Meseta")

;Groupbox Step1
MyGui.SetFont("bold", "Verdana")
MyGui.Add("GroupBox", "xs+0 ys+100 w240 r3 Section", "Mags and Food")
MyGui.SetFont("Norm", "Verdana")
MyGui.Add("Text", "xs+10 ys+20", "Number of Mags:")
MyGui.Add("Edit", "xs+110 ys+18")
spnNumberMags := MyGui.Add("UpDown", "Range1-15", 1) ; 15 is perfect number for KeyDelay 100,60
MyGui.Add("Text", "xs+10 ys+50", "Food:")
cmbFoodSelector := MyGui.Add("DropDownList", "xs+110 ys+48", ["Monomate","Dimate","Trimate","Monofluid","Difluid","Trifluid","Antidote","Antiparalysis"])
cmbFoodSelector.Value := 1
MyGui.Add("Text", "xs+10 ys+80", "Feeding Cycles:")
MyGui.Add("Edit", "xs+110 ys+78")
spnFeedingCycles := MyGui.Add("UpDown", "Range1-20000", 1)

;Groupbox Step 2
MyGui.SetFont("bold", "Verdana")
MyGui.Add("GroupBox", "xs+0 ys+120 w240 r2 Section", "Options")
MyGui.SetFont("Norm", "Verdana")
chkShutdownAfterFeed := MyGui.Add("CheckBox", "xs+10 ys+20", "Shutdown PC after feeding")
chkWaitForFirstCycle := MyGui.Add("CheckBox", "xs+10 ys+50", "Wait for first Feeding Cycle")
chkWaitForFirstCycle.Value := 1

;Progressbar
MyGui.Add("Text", "xs+0 ys+90 Section", "Start Script: CTRL + J")
MyGui.Add("Text", "xs+0 ys+20", "End Script: CTRL + E")
progressbar := MyGui.Add("Progress", "xs+0 ys+40 w300 BackgroundGray cBlue Section", 0)



;########################## On Event Callbacks ###################################
spnNumberMags.OnEvent("Change", (*) => CalculateInfo())
spnFeedingCycles.OnEvent("Change", (*) => CalculateInfo())
cmbFoodSelector.OnEvent("Change", (*) => CalculateInfo())


;########################## Refreshing and Rendering UI ###################################
CalculateInfo()
MyGui.Show




;########################## Functions ###################################
;Feed Mags
FeedMags() {
	lFeedingCycles := spnFeedingCycles.Value
	lNumberMags := spnNumberMags.Value
	lfoodType := cmbFoodSelector.Text
	lcurrentLoop := 0
	Loop lFeedingCycles{
		lcurrentLoop++
		;Wait 1 Feed cycle if checked
		if (chkWaitForFirstCycle.Value == 1) {
			if(lcurrentLoop = 1) {
				global FeedReady := 0
				SetTimer(FeedTimer, magFeedingDelay)
			}
		}

		Loop {
			if (FeedReady == 1) {
				break
			}
			Sleep(1000)
		}
		global FeedReady := 0

		;Feed routine
		FeedRoutine(lNumberMags, lfoodType)

		percentdone := (100 / lFeedingCycles) * lcurrentLoop
		progressbar.Value := String(percentdone)
	}

	if (chkShutdownAfterFeed.Value == 1) {
		Sleep(1500)
		Shutdown(1)
	}
	Return
}

;Feeding Routine
FeedRoutine(numberMags, foodType) {
	lFirstLoopDone := 0
	lCurrentMag := 0
	Loop numberMags {
		Send "{F4}"

		;Select Mag
		Loop lcurrentMag {
			Send "{Down}"
		}
		;Select Mag End

		;Feed 1st time
		Send "{Enter}"
		Send "{Enter}"
		Send "{Enter}"
		Send "{F4}"
		Send "{F4}"

		;Select Mag
		Loop lcurrentMag {
			Send "{Down}"
		}
		;Select Mag End

		;Feed 2nd time
		Send "{Enter}"
		Send "{Enter}"
		Send "{Enter}"
		Send "{F4}"
		Send "{F4}"

		;Select Mag
		Loop lcurrentMag {
			Send "{Down}"
		}
		;Select Mag End

		;Feed 3rd time
		Send "{Enter}"
		Send "{Enter}"
		Send "{Enter}"
		Send "{F4}"

		;Buy food
		Send "{Enter}"
		Send "{Enter}"

		;Select food
		switch(foodType) {
			case "Monomate":
			case "Dimate":
				Send "{Down}"
			case "Trimate":
				Send "{Down}"
				Send "{Down}"
			case "Monofluid":
				Send "{Down}"
				Send "{Down}"
				Send "{Down}"
			case "Difluid":
				Send "{Down}"
				Send "{Down}"
				Send "{Down}"
				Send "{Down}"
			case "Trifluid":
				Send "{Down}"
				Send "{Down}"
				Send "{Down}"
				Send "{Down}"
				Send "{Down}"
			case "Antidote":
				Send "{Up}"
				Send "{Up}"
				Send "{Up}"
				Send "{Up}"
			case "Antiparalysis":
				Send "{Up}"
				Send "{Up}"
				Send "{Up}"
		}
		;Select food end
		Send "{Enter}"
		Send "{Up}"
		Send "{Up}"
		Send "{Enter}"
		Send "{Enter}"
		Send "{Backspace}"
		Send "{Backspace}"
		Send "{Backspace}"

		if(lCurrentMag == 0) {
			SetTimer(FeedTimer, magFeedingDelay)
		}

		lCurrentMag++



	}


}

;Calculate Info
CalculateInfo(){
	feedingTime := ((magFeedingDelay * spnFeedingCycles.Value) / 1000) / 60
	feedingTimeString := String(Ceil(feedingTime)) . " Minutes"
	txtMinutesTotal.Text := feedingTimeString
	mesetaPerFood := 0
	Switch cmbFoodSelector.Text {
	case "Monomate":
		mesetaPerFood := 50
	case "Dimate":
		mesetaPerFood := 300
	case "Trimate":
		mesetaPerFood := 2000
	case "Monofluid":
		mesetaPerFood := 100
	case "Difluid":
		mesetaPerFood := 500
	case "Trifluid":
		mesetaPerFood := 3600
	case "Antidote":
		mesetaPerFood := 60
	case "Antiparalysis":
		mesetaPerFood := 60
	}
	totalMeseta := mesetaPerFood * spnFeedingCycles.Value * spnNumberMags.Value * 3
	txtMesetaTotal.Text := String(totalMeseta)
	Return
}

;FeedTimer
FeedTimer() {
	SetTimer(FeedTimer, 0)
	global FeedReady := 1
	Return
}

;########################## Hotkeys ###################################
;Start Feeding - CTRL + j
^j:: FeedMags()

;Exit App - CTRL + e
^e::ExitApp