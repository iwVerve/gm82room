var yes;

if (resizecount<10) {
    if (window_get_width()!=width || window_get_height()!=height) {
        with (Button) {
            if (anchor==1 || anchor==3) offx=width-x
            if (anchor==2 || anchor==3) offy=height-y
        }
        width=max(min_width,window_get_width())
        height=max(min_height,window_get_height())
        window_set_size(width,height)
        window_set_region_size(width,height,0)
        dx8_resize_buffer(width,height)
        view_wport[0]=width
        view_hport[0]=height
        with (Button) {
            if (anchor==1 || anchor==3) x=width-offx
            if (anchor==2 || anchor==3) y=height-offy
        }
        resizecount+=1
        if (resizecount>=10) show_message("Resizing the window failed multiple times. Do you have some sort of weird DPI settings? Either way, I'm disabling resizing for now.")
    } else resizecount=0
}

if (window_has_focus()) {
    window_focused=true
    room_speed=maxfps
    powersave=false
    selcol=merge_color($ff0000,$ffffff,dsin((0.5+0.5*sin(current_time/200))*90))
} else if (window_focused) {
    window_focused=false
    with (TextField) if (active) {dtext=oldtext active=0}
    room_speed=5
    powersave=true
    selcol=$ff8000
    save_room(1)
}

if (messagetime>0) {
    messagetime-=1/room_speed
    if (messagetime<=0) {
        messagetime=0
        messagestr=""
    }
}

if (current_time>autosave_timer+autosave_interval) {
    if (!mouse_check_button(mb_any) && !keyboard_check(vk_anykey)) {
        autosave_timer=current_time
        save_room(1)
    }
}

mouse_wx=window_mouse_get_x()
mouse_wy=window_mouse_get_y()
mousein=(point_in_rectangle(mouse_wx,mouse_wy,160,32,width-160,height-32))

if (keyboard_check_pressed(vk_insert)) overmode=!overmode

//zooming
if (grabknob) {
    if (mouse_wheel_down() || keyboard_check_pressed(vk_subtract) || keyboard_check_pressed(vk_minus)) {
        knobzgo/=1.2
        keyboard_clear(vk_subtract)
        keyboard_clear(vk_minus)
    }
    if (mouse_wheel_up() || keyboard_check_pressed(vk_add) || (keyboard_check_pressed(vk_equals))) {
        knobzgo*=1.2
        keyboard_clear(vk_add)
        keyboard_clear(vk_equals)
    }
} else if (mousein) {
    if (mouse_wheel_down() || keyboard_check_pressed(vk_subtract) || keyboard_check_pressed(vk_minus)) {
        zoomgo*=1.2
        keyboard_clear(vk_subtract)
        keyboard_clear(vk_minus)
        zoomcenter=0
    }
    if (mouse_wheel_up() || keyboard_check_pressed(vk_add) || (keyboard_check_pressed(vk_equals))) {
        zoomgo/=1.2
        keyboard_clear(vk_add)
        keyboard_clear(vk_equals)
        zoomcenter=0
    }
}
if (keyboard_check_pressed(ord("0"))) {
    yes=1
    with (TextField) if (active) yes=0
    if (yes) {
        xgo=roomwidth/2
        ygo=roomheight/2
        zoomgo=1
        zoomcenter=1
    }
}

zoomold=zoom
if (abs(zoom-1)<0.1) {
    if ((zoomgo>1 && zoom<1) || (zoomgo<1 && zoom>1) || (zoom==1 && zoomgo==1)) {
        zoomgo=1
        zoom=1
    }
}

zoomgo=median(1/8,zoomgo,32)
zoom=inch((zoom*9+zoomgo)/10,zoomgo,0.02)

if (!zoomcenter) {
    xgo-=(mouse_wx-width*0.5)*(zoom-zoomold)
    ygo-=(mouse_wy-height*0.5)*(zoom-zoomold)
}

//panning
if (mouse_check_button_pressed(mb_middle) || keyboard_check_pressed(vk_space)) {
    //yeah i know i called pan zooming but ok just think like youre zooming around im sorry
    if (keyboard_check(vk_control)) {
        if (mode==0) with (focus) focus_object(obj)
        if (mode==1) with (focus) focus_tile(tile)
    }
    zooming=1
    grabx=mouse_wx
    graby=mouse_wy
    grabxgo=xgo
    grabygo=ygo
}
if (zooming) {
    xgo=round(grabxgo+(grabx-mouse_wx)*zoom)
    ygo=round(grabygo+(graby-mouse_wy)*zoom)
    if (!mouse_check_direct(mb_middle) && !keyboard_check(vk_space)) {
        zooming=0
    }
}
