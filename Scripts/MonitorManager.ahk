Class MonitorManager
{
	GetResolution()
	{
		SysGet, MonitorName, MonitorName, %A_Index%
		SysGet, Monitor, Monitor, %A_Index%
		SysGet, MonitorWorkArea, MonitorWorkArea, %A_Index%
	}

	ChangeResolution(Screen_Width := 1920, Screen_Height := 1080, Color_Depth := 32)
	{
		VarSetCapacity(Device_Mode,156,0) 
		NumPut(156,Device_Mode,36) 
		DllCall( "EnumDisplaySettingsA", UInt,0, UInt,-1, UInt,&Device_Mode )
		NumPut(0x5c0000,Device_Mode,40) 
		NumPut(Color_Depth,Device_Mode,104)
		NumPut(Screen_Width,Device_Mode,108)
		NumPut(Screen_Height,Device_Mode,112)
		Return DllCall( "ChangeDisplaySettingsA", UInt,&Device_Mode, UInt,0 )
	}
	
	ToggleAutohideTaskbar(Mode := -1)
	{
		VarSetCapacity( APPBARDATA, 48, 0 )
		NumPut(48, APPBARDATA, 0, "UInt")
		bits := DllCall("Shell32.dll\SHAppBarMessage"
				 ,"UInt", 4
				 ,"Ptr", &APPBARDATA )
		NumPut( Mode == -1 ? (bits ^ 0x1) : Mode, APPBARDATA, 40, "UInt" )
		DllCall("Shell32.dll\SHAppBarMessage"
				 ,"UInt", ( ABM_SETSTATE := 0xA )
				 ,"Ptr", &APPBARDATA )
	}

	ToggleTabletMode(TabletMode := -1)
	{	 

		TABLETMODESTATE_DESKTOPMODE := 0x0
		TABLETMODESTATE_TABLETMODE := 0x1
		 
		ImmersiveShell := ComObjCreate("{C2F03A33-21F5-47FA-B4BB-156362A2F239}", "{00000000-0000-0000-C000-000000000046}")
		TabletModeController := ComObjQuery(ImmersiveShell, "{4fda780a-acd2-41f7-b4f2-ebe674c9bf2a}", "{4fda780a-acd2-41f7-b4f2-ebe674c9bf2a}")
			
		if (TabletModeController_GetMode(TabletModeController, mode) == 0)
		{
			if(TabletMode == -1)
				TabletModeController_SetMode(TabletModeController, mode == TABLETMODESTATE_DESKTOPMODE ? TABLETMODESTATE_TABLETMODE : TABLETMODESTATE_DESKTOPMODE)
			else if(TabletMode == 0 || TabletMode == 1)
				TabletModeController_SetMode(TabletModeController, TabletMode)
		}

		ObjRelease(TabletModeController), TabletModeController := 0
		ObjRelease(ImmersiveShell), ImmersiveShell := 0 ; Can be freed after TabletModeController is created, instead	
	}
	

	; ===== PRIVATE FUNCTIONS =====
	
	
	TabletModeController_GetMode(TabletModeController, ByRef mode) {
		return DllCall(NumGet(NumGet(TabletModeController+0),3*A_PtrSize), "Ptr", TabletModeController, "UInt*", mode)
	}
	 
	TabletModeController_SetMode(TabletModeController, _TABLETMODESTATE, _TMCTRIGGER := 4) {
		return DllCall(NumGet(NumGet(TabletModeController+0),4*A_PtrSize), "Ptr", TabletModeController, "UInt", _TABLETMODESTATE, "UInt", _TMCTRIGGER)	
	}
}

; ==3:2==
; 800	450
; 1080	720
; 1624	1080

; ==16:9==
; 640	360
; 1280	720
; 1920	1080