var yes,l,t,r,b,zm;
var nomorefortnite;nomorefortnite=0

var sel_alpha; if (powersave) sel_alpha=0.5 else sel_alpha=0.5+0.25*sin(current_time/200)

draw_backgrounds(1)

//paths
draw_paths()

d3d_transform_set_identity()
d3d_end()
dx8_reset_projection()
d3d_set_depth(0)

fmx=floorto(global.mousex,gridx)
fmy=floorto(global.mousey,gridy)
tty=0
zm=max(0.5,zoom)

//grid and crosshair for object and tile mode
if (mode==0 || mode==1) {
    if (keyboard_check_direct(vk_control)) window_set_cursor(cr_size_all)
    else if (keyboard_check_direct(vk_shift)) window_set_cursor(cr_cross)
    else window_set_cursor(cr_default)

    d3d_transform_add_translation(-0.5,-0.5,0)
    texture_set_interpolation(1)

    draw_set_blend_mode_ext(10,1)
    draw_primitive_begin(pr_linelist)
        if (grid) {
            if (mousein) {
                x1=min(fmx,0)
                x2=max(roomwidth,fmx+gridx)
                y1=min(fmy,0)
                y2=max(roomheight,fmy+gridy)
            } else {
                x1=0
                y1=0
                x2=roomwidth
                y2=roomheight
            }
            vc=0
            for (i=x1;i<=x2;i+=gridx) {draw_vertex(i,y1) draw_vertex(i,y2) vc+=2 if (vc>998) {vc=0 draw_primitive_end() draw_primitive_begin(pr_linelist)}}
            for (i=y1;i<=y2;i+=gridy) {draw_vertex(x1,i) draw_vertex(x2,i) vc+=2 if (vc>998) {vc=0 draw_primitive_end() draw_primitive_begin(pr_linelist)}}
        }
        if (crosshair) {
            if (keyboard_check(vk_alt)) {
                draw_vertex(global.mousex,min(0,global.mousey)) draw_vertex(global.mousex,max(roomheight,global.mousey))
                draw_vertex(min(0,global.mousex),global.mousey) draw_vertex(max(roomwidth,global.mousex),global.mousey)
            } else {
                if (!grid) {
                    draw_vertex(fmx,fmy+gridy) draw_vertex(fmx+gridx,fmy+gridy)
                    draw_vertex(fmx+gridx,fmy) draw_vertex(fmx+gridx,fmy+gridy)
                    draw_vertex(fmx,min(0,fmy)) draw_vertex(fmx,max(roomheight,fmy))
                    draw_vertex(min(0,fmx),fmy) draw_vertex(max(roomwidth,fmx),fmy)
                }
            }
        }
    draw_primitive_end()
    draw_set_blend_mode(0)

    d3d_transform_set_identity()
} else window_set_cursor(cr_default)

//object mode
if (mode==0) {
    texture_set_interpolation(interpolation)

    with (instance) if (fieldactive) {
        //darken the room when there's fields ui up
        rect(0,0,roomwidth,roomheight,0,0.5)
        draw_self()
    }

    d3d_set_fog(1,$ff8000,0,0)
    with (instance) if (sel) {
        draw_sprite_ext(sprite_index,0,x,y,image_xscale,image_yscale,image_angle,0,sel_alpha)
    }
    d3d_set_fog(0,0,0,0)

    draw_set_color_sel()
    with (instance) if (sel) {
        draw_rectangle(bbox_left-0.5,bbox_top-0.5,bbox_right+1-0.5,bbox_bottom+1-0.5,1)
    }
    draw_set_color($ffffff)

    texture_set_interpolation(1)

    with (select) {
        event_user(0)
    }
    draw_set_color_sel()
    with (focus) {
        draw_rectangle(bbox_left-0.5,bbox_top-0.5,bbox_right+0.5,bbox_bottom+0.5,1)
        if (select!=id) event_user(5)
    }
    draw_set_color($ffffff)

    if (keyboard_check(ord("C"))) with (instance) {
        if (code!="") {
            d3d_set_fog(1,$ff,0,0)
            draw_sprite_ext(sprite_index,0,x,y,image_xscale,image_yscale,image_angle,image_blend,0.5)
            d3d_set_fog(0,0,0,0)
        }
        event_user(4)
    }

    if (crosshair) {
        with (select) if (grab || rotato || draggatto) nomorefortnite=1
        if (!keyboard_check(vk_control) && !keyboard_check(vk_shift) && !nomorefortnite && !selecting && !selsize) {
            if (objpal!=noone) {
                texture_set_interpolation(interpolation)
                if (keyboard_check(vk_alt)) draw_sprite_ext(objspr[objpal],0,global.mousex,global.mousey,1,1,0,$ffffff,0.25)
                else draw_sprite_ext(objspr[objpal],0,fmx,fmy,1,1,0,$ffffff,0.25)
                texture_set_interpolation(1)
            }
        }
    }
}

//tile mode
if (mode==1) {
    texture_set_interpolation(interpolation)

    draw_set_color($ff8000)
    draw_set_alpha(sel_alpha)
    with (tileholder) if (sel) {
        draw_rectangle(x-0.5,y-0.5,x+image_xscale-0.5,y+image_yscale-0.5,0)
    }
    draw_set_alpha(1)

    draw_set_color_sel()
    with (tileholder) if (sel) {
        draw_rectangle(bbox_left-0.5,bbox_top-0.5,bbox_right+1-0.5,bbox_bottom+1-0.5,1)
    }
    draw_set_color($ffffff)
    texture_set_interpolation(1)

    with (selectt) {
        event_user(0)
    }

    draw_set_color_sel()
    with (focus) draw_rectangle(bbox_left-0.5,bbox_top-0.5,bbox_right+0.5,bbox_bottom+0.5,1)
    draw_set_color($ffffff)

    if (crosshair) {
        with (selectt) if (grab || draggatto) nomorefortnite=1
        if (!keyboard_check(vk_control) && !keyboard_check(vk_shift) && !nomorefortnite && !selecting && !selsize) {
            if (curtile!=noone) {
                texture_set_interpolation(interpolation)
                tex=bg_background[tilebgpal]
                u=ds_list_find_value(curtile,0)
                v=ds_list_find_value(curtile,1)
                tw=ds_list_find_value(curtile,2)
                th=ds_list_find_value(curtile,3)

                if (keyboard_check(vk_alt)) draw_background_part_ext(tex,u,v,tw,th,global.mousex,global.mousey,1,1,$ffffff,0.25)
                else draw_background_part_ext(tex,u,v,tw,th,fmx,fmy,1,1,$ffffff,0.25)
                texture_set_interpolation(1)
            }
        }
    }
}


//selection rectangle
if (selecting) {
    draw_set_color($ff8000)
    draw_set_alpha(0.5)
    l=min(selx,global.mousex)-0.5
    t=min(sely,global.mousey)-0.5
    r=max(selx,global.mousex)+0.5
    b=max(sely,global.mousey)+0.5
    draw_rectangle(l,t,r,b,0)
    draw_rectangle(l,t,r,b,1)
    draw_set_alpha(1)
    draw_set_color($ffffff)
}


//draw clipboard dimensions
if (keyboard_check(vk_control) && !keyboard_check(vk_shift) && copyvec[0,0]) {
    draw_set_color($ff8000)
    draw_set_alpha(0.5)
    if (keyboard_check(vk_alt)) draw_rectangle(global.mousex-0.5,global.mousey-0.5,global.mousex+copyvec[0,3]-copyvec[0,1]-0.5,global.mousey+copyvec[0,4]-copyvec[0,2]-0.5,1)
    else draw_rectangle(fmx+copyvec[0,5]-0.5,fmy+copyvec[0,6]-0.5,fmx+copyvec[0,5]+copyvec[0,3]-copyvec[0,1]-0.5,fmy+copyvec[0,6]+copyvec[0,4]-copyvec[0,2]-0.5,1)
    draw_set_alpha(1)
    draw_set_color($ffffff)
}


//draw bounding selection rectangle
if (selection) {
    dx=selleft+selwidth-0.5
    dy=seltop+selheight-0.5
    draw_set_alpha(1)
    draw_set_color_sel()
    draw_roundrect(min(selleft-0.5,dx),min(seltop-0.5,dy),max(selleft-0.5,dx),max(seltop-0.5,dy),1)
    draw_rectangle(dx-8*zm,dy-8*zm,dx+8*zm,dy+8*zm,1)
    draw_rectangle(dx-4*zm,dy-4*zm,dx+4*zm,dy+4*zm,1)
}


//draw views
if (view[4] || mode==3) {
    if (mode==3) rect(0,0,roomwidth,roomheight,0,0.5)
    d3d_transform_add_translation(-0.5,-0.5,0)
    for (i=0;i<8;i+=1) {
        if (vw_visible[i] || (vw_current==i && mode==3)) {
            dx=vw_x[i]+vw_w[i]
            dy=vw_y[i]+vw_h[i]
            if (vw_current==i && vw_visible[i] && mode==3) {
                draw_set_color($ff8000)
                draw_set_alpha(0.5)
                draw_roundrect(vw_x[i],vw_y[i],dx,dy,0)
                draw_set_alpha(1)
                draw_set_color_sel()
            }
            draw_roundrect(vw_x[i],vw_y[i],dx,dy,1)
            if (vw_current==i && mode==3) {
                zm=max(0.5,zoom)
                draw_rectangle(dx-8*zm,dy-8*zm,dx+8*zm,dy+8*zm,1)
                draw_rectangle(dx-4*zm,dy-4*zm,dx+4*zm,dy+4*zm,1)
            }
            draw_set_color($ffffff)
            draw_text_transformed(vw_x[i]+8+0.5*zoom,vw_y[i]+8+0.5*zoom,"View "+string(i),zoom,zoom,0)
        }
    }
    d3d_transform_set_identity()
}

if (mode==4) {
    rect(roomleft,roomtop,roomwidth-roomleft,roomheight-roomtop,0,0.5)
    d3d_transform_add_translation(-0.5,-0.5,0)
    draw_set_color_sel()
    draw_rectangle(roomleft,roomtop,roomwidth,roomheight,1)
    if (chunkcrop) {
        dx=chunkleft+chunkwidth
        dy=chunktop+chunkheight
        draw_set_color($ff8000)
        draw_set_alpha(0.5)
        draw_roundrect(chunkleft,chunktop,dx,dy,0)
        draw_set_alpha(1)
        draw_set_color_sel()
        draw_roundrect(chunkleft,chunktop,dx,dy,1)
        draw_resize_handle(dx,dy)
        if (chunkloaded) draw_text_transformed(chunkleft+8+0.5*zoom,chunktop+8+0.5*zoom,"Chunk loaded:#"+chunkname,zoom,zoom,0)
    } else {
        draw_resize_handle(roomleft,roomtop)
        draw_resize_handle(roomwidth,roomtop)
        draw_resize_handle(roomleft,roomheight)
        draw_resize_handle(roomwidth,roomheight)
    }
    draw_set_color($ffffff)
    d3d_transform_set_identity()
}

//this is where the room space ends and the hud space starts================================================
d3d_set_projection_ortho(0,0,width,height,0)

if (messagetime>0) {
    draw_set_alpha(messagetime)
    draw_set_halign(2)
    draw_text_outline(width-160-16,48,messagestr,$ffff)
    draw_set_halign(0)
    draw_set_alpha(1)
}

focus=noone
if (mousein) {
    if (mode==0) {
        focus=instance_position(global.mousex,global.mousey,instance)
    }
    if (mode==1) focus=instance_position(global.mousex,global.mousey,tileholder)
}

actionx=160
actiony=0
actionw=width-320
actionh=32

statusx=160
statusy=height-32
statusw=width-320
statush=32

rect(0,0,160,height,global.col_main,1)
rect(160,0,width-320,32,global.col_main,1)
draw_button_ext(160,32,width-320,height-64,0,noone)

//draw statusbar
draw_button_ext(statusx,height-32,144,32,0,global.col_main)
draw_button_ext(statusx+144,height-32,296,32,0,global.col_main)
draw_button_ext(statusx+440,height-32,48,32,0,pick(overmode,global.col_main,$ff))
draw_button_ext(statusx+488,height-32,width-320-488,32,0,global.col_main)
draw_set_color(global.col_text)
draw_text(statusx+448,statusy+6,pick(overmode,"INS","OVR"))
if (keyboard_check(vk_alt)) draw_text(statusx+8,statusy+6,string(global.mousex)+","+string(global.mousey))
else draw_text(statusx+8,statusy+6,string(fmx)+","+string(fmy))
if (mode==0) {
    num=instance_number(instance)
    if (num<instancecount) draw_text(statusx+152,statusy+6,string(num)+" instances ("+string(instancecount-num)+" hidden)")
    else draw_text(statusx+152,statusy+6,string(instancecount)+" instances")
    if (focus) draw_text(statusx+496,statusy+6,focus.objname+" ("+focus.uid+") "+string(focus.x)+","+string(focus.y))
}
if (mode==1) {
    num=instance_number(tileholder)
    if (view[1]) draw_text(statusx+152,statusy+6,string(tilecount)+" tiles")
    else if (num<tilecount) draw_text(statusx+152,statusy+6,string(num)+" tiles ("+string(tilecount-num)+" hidden)")
    else draw_text(statusx+152,statusy+6,string(num)+" tiles")
    if (focus) draw_text(statusx+496,statusy+6,string(focus.bgname)+" "+string(focus.x)+","+string(focus.y))
}
draw_set_color($ffffff)

//draw inspector rectangle after statusbar to hide any leaking text
//usually i'd put care into cropping the string but this is literally faster
rect(width-160,0,160,height,global.col_main,1)


//draw object tab
if (mode=0) {
    //palette
    posx=0
    posy=0
    paltooltip=0
    for (i=0;i<objects_length;i+=1) if (objloaded[i]) {
        dx=20+40*posx
        dy=140+40*posy+palettescroll
        if (dy>100 && dy<height-80) {
            draw_button_ext(dx-20,dy-20,40,40,objpal!=i,pick(objpal==i,global.col_main,$c0c0c0))
            if (objpal==i) {
                draw_set_color_sel()
                draw_rectangle(dx-20,dy-20,dx+19,dy+19,1)
                draw_set_color($ffffff)
            }
            if (!point_in_rectangle(mouse_wx,mouse_wy,dx-20,dy-20,dx+20,dy+20)) {
                w=sprite_get_width(objspr[i])
                h=sprite_get_height(objspr[i])
                if (w>h) {h=h/w*32 w=32} else {w=w/h*32 h=32}
                draw_sprite_stretched(objspr[i],0,dx-w/2,dy-h/2,w,h)
            }
        }
        posx+=1 if (posx=4) {posx=0 posy+=1}
    }

    if (objects_length) {
        dx=20+40*posx
        dy=140+40*posy+palettescroll
        draw_button_ext(dx-20,dy-20,40,40,1,global.col_main)
        draw_sprite(sprMenuButtons,18,dx,dy)
        if (mouse_wx<160 && mouse_wy>120 && mouse_wy<height-136) {
            if (point_in_rectangle(mouse_wx,mouse_wy,dx-20,dy-20,dx+20,dy+20)) {
                paltooltip=1
            }
        }
    } else {
        draw_set_color(global.col_text)
        draw_text(8,126,"Project#contains no#objects.")
        draw_set_color($ffffff)
    }

    //inspector
    dx=width-160
    draw_button_ext(dx,32,160,100,1,global.col_main)
    draw_button_ext(dx,128+4,160,100,1,global.col_main)
    draw_button_ext(dx,228+4,160,72,1,global.col_main)
    draw_button_ext(dx,304,160,72,1,global.col_main)
    draw_set_color(global.col_text)
    draw_text(dx+12,32+8,"Position")
    draw_text(dx+12,128+12,"Scale")
    draw_text(dx+12,228+12,"Rotation")
    draw_text(dx+12,304+8,"Blend")
    draw_set_color($ffffff)
}

//draw tiles tab
if (mode==1) {
    //palette
    posx=0
    posy=0
    paltooltip=0
    if (tilebgpal!=noone) {
        tex=bg_background[tilebgpal]
        map=bg_tilemap[tilebgpal]
        len=ds_map_size(map)

        key=ds_map_find_first(map)
        for (i=0;i<len;i+=1) {
            tile=ds_map_find_value(map,key)
            key=ds_map_find_next(map,key)
            dx=20+40*posx
            dy=172+40*posy+tpalscroll
            if (dy>132 && dy<height-196) {
                u=ds_list_find_value(tile,0)
                v=ds_list_find_value(tile,1)
                tw=ds_list_find_value(tile,2)
                th=ds_list_find_value(tile,3)
                draw_button_ext(dx-20,dy-20,40,40,tilepal!=i,pick(tilepal==i,global.col_main,$c0c0c0))
                if (tilepal==i) {
                    draw_set_color_sel()
                    draw_rectangle(dx-20,dy-20,dx+19,dy+19,1)
                    draw_set_color($ffffff)
                }
                if (!point_in_rectangle(mouse_wx,mouse_wy,dx-20,dy-20,dx+20,dy+20)) {
                    w=tw
                    h=th
                    if (w>h) {h=h/w*32 w=32} else {w=w/h*32 h=32}
                    draw_background_part_ext(tex,u,v,tw,th,dx-w/2,dy-h/2,w/tw,h/th,$ffffff,1)
                }
            }
            posx+=1 if (posx=4) {posx=0 posy+=1}
        }
    }
    if (backgrounds_length) {
        dx=20+40*posx
        dy=172+40*posy+tpalscroll
        draw_button_ext(dx-20,dy-20,40,40,1,global.col_main)
        draw_sprite(sprMenuButtons,24,dx,dy)
        if (mouse_wx<160 && mouse_wy>=152 && mouse_wy<height-216) {
            if (point_in_rectangle(mouse_wx,mouse_wy,dx-20,dy-20,dx+20,dy+20)) {
                paltooltip=1
            }
        }
    } else {
        draw_set_color(global.col_text)
        draw_text(8,158,"Project#contains no#backgrounds.")
        draw_set_color($ffffff)
    }

    draw_button_ext(0,height-192,160,192,1,global.col_main)
    draw_button_ext(4,height-160-28,152,152,0,global.col_main)

    if (tilebgpal!=noone && curtile!=noone) {
        u=ds_list_find_value(curtile,0)
        v=ds_list_find_value(curtile,1)
        tw=ds_list_find_value(curtile,2)
        th=ds_list_find_value(curtile,3)

        //cut up a preview rectangle around the selected tile
        bw=background_get_width(tex)
        bh=background_get_height(tex)

        nw=max(min(bw,144),tw)
        nh=max(min(bh,144),th)

        left=max(0,min(u+tw/2-nw/2,bw-nw))
        top=max(0,min(v+th/2-nh/2,bh-nh))
        lewidth=min(nw,bw-left)
        leheight=min(nh,bh-top)

        scale=min(1,144/max(lewidth,leheight))

        dx=8+72-lewidth/2*scale
        dy=height-184+72-leheight/2*scale
        draw_background_part_ext(tex,left,top,lewidth,leheight,dx,dy,scale,scale,$ffffff,1)
        draw_set_color_sel()
        draw_rectangle(dx+(u-left),dy+(v-top),dx+(u-left)+tw*scale-1,dy+(v-top)+th*scale-1,1)
        draw_set_color($ffffff)
    }

    //inspector

    dx=width-160

    draw_button_ext(dx,32,160,100,1,global.col_main)
    draw_button_ext(dx,128+4,160,100,1,global.col_main)
    draw_button_ext(dx,228+4,160,72,1,global.col_main)
    draw_set_color(global.col_text)
    draw_text(dx+12,32+8,"Position")
    draw_text(dx+12,128+12,"Scale")
    draw_text(dx+12,228+12,"Blend")
    draw_set_color($ffffff)

    for (i=0;i<layersize;i+=1) {
        dy=360+i*32+layerscroll
        if (dy>360-32 && dy<height-100+32) {
            draw_button_ext(dx,dy,160,32,ly_current!=i,global.col_main)
            draw_set_color(global.col_text)
            draw_text(dx+12,dy+6,ds_list_find_value(layers,i))
            draw_set_color($ffffff)
        }
    }
    draw_button_ext(dx,360+i*32+layerscroll,160,32,ly_current!=i,global.col_main)
    draw_sprite(sprMenuButtons,23,dx+80,360+i*32+layerscroll+16)

    draw_button_ext(dx,304,160,32,1,global.col_main)
    draw_set_color(global.col_text)
    draw_text(dx+12,310,"Layers")
    draw_set_color($ffffff)

    draw_button_ext(dx,height-76,160,76,1,global.col_main)
    draw_set_color(global.col_text)
    draw_text(dx+12,height-64,"Depth")
    draw_set_color($ffffff)
}


//draw backgrounds tab
if (mode==2) {
    draw_button_ext(0,96,160,40,1,global.col_main)
    draw_button_ext(0,200,160,308,1,global.col_main)
    draw_set_color(global.col_text)
    draw_text(12,384,"Position")
    draw_text(12,444,"Speed")
    draw_set_color($ffffff)
}


//draw views tab
if (mode==3) {
    draw_button_ext(0,96,160,40,1,global.col_main)
    draw_button_ext(0,200,160,348,1,global.col_main)
    draw_set_color(global.col_text)
    draw_text(12,236,"Room")
    draw_text(12,328,"Window")
    draw_text(12,420,"Following")
    draw_set_color($ffffff)

    draw_button_ext(width-160,0,160,216,1,global.col_main)
    draw_set_color(global.col_text)
    draw_text(width-160+12,8,"Window")
    draw_set_color($ffffff)
    draw_button_ext(width-160+4,32,160-8,160-8,0,0)

    yes=0
    if (vw_enabled) {
        //first we calculate the total view bounding box
        l=max_uint
        t=max_uint
        r=0
        b=0
        for (i=0;i<8;i+=1) if (vw_visible[i]) {
            yes=1
            l=min(l,vw_xp[i])
            t=min(t,vw_yp[i])
            r=max(r,vw_xp[i]+vw_wp[i])
            b=max(b,vw_yp[i]+vw_hp[i])
        }
        w=r-l
        h=b-t
    } else {
        w=roomwidth
        h=roomheight
        yes=1
    }

    //viewport preview box
    draw_set_halign(1)
    draw_set_valign(1)
    if (yes) {
        if (w>h) {dh=h*144/w dw=144}
        else {dw=w*144/h dh=144}
        dx=width-80-dw/2
        dy=32+76-dh/2
        rect(dx,dy,dw,dh,$808080,1)
        if (vw_enabled) {
            //draw each view
            for (i=0;i<8;i+=1) if (vw_visible[i]) {
                draw_set_color(pick(vw_current==i,$ffffff,$ff8000))
                x1=dx+(vw_xp[i]-l)/w*dw
                y1=dy+(vw_yp[i]-t)/h*dh
                x2=dx+(vw_xp[i]+vw_wp[i]-l)/w*dw
                y2=dy+(vw_yp[i]+vw_hp[i]-t)/h*dh
                draw_rectangle(x1,y1,x2,y2,0)
                draw_set_color(0)
                draw_rectangle(x1,y1,x2,y2,1)
                draw_text(mean(x1,x2),mean(y1,y2),i)
                draw_set_color($ffffff)
            }
        } else {
            draw_text(width-80,32+76,"Whole Room")
        }
    } else {
        draw_text(width-80,32+76,"No views are#visible.##Game will#not display#correctly.")
    }
    draw_set_halign(0)
    draw_set_valign(0)
    if (yes) {
        draw_set_color(global.col_text)
        draw_text(width-160+12,188,string(w)+" x "+string(h))
        draw_set_color($ffffff)
    }
}


//draw settings tab
if (mode==4) {
    draw_button_ext(0,128,160,72,1,global.col_main)
    draw_button_ext(0,200,160,164,1,global.col_main)
    draw_set_color(global.col_text)
    draw_text(12,136,"Caption")
    draw_text(12,208,"Size")
    draw_text(12,273,"Speed")
    draw_set_color($ffffff)

    dx=width-160
    draw_button_ext(dx,0,160,32,1,global.col_main)
    draw_button_ext(dx,32,160,148,1,global.col_main)
    draw_set_color(global.col_text)
    draw_text(dx+12,6,"Chunk tools")
    draw_set_color($ffffff)
}

tooltiptext=""

if (mode==0) {
    //object tab tooltips
    posx=0
    posy=0
    if (mouse_wy>120 && mouse_wy<height-136) for (i=0;i<objects_length;i+=1) if (objloaded[i]) {
        dx=20+40*posx
        dy=140+40*posy+palettescroll
        if (point_in_rectangle(mouse_wx,mouse_wy,dx-20,dy-20,dx+20,dy+20)) {
            w=sprite_get_width(objspr[i])
            h=sprite_get_height(objspr[i])
            if (w>32 || h>32) {
                dx=floor(max(1,dx-w/2)+w/2)+frac(w/2)
                dy=floor(max(1,dy-h/2)+h/2)+frac(h/2)
                draw_set_color_sel() d3d_set_fog(1,draw_get_color(),0,0) draw_set_color($ffffff)
                draw_sprite_stretched_ext(objspr[i],0,dx-w/2+1,dy-h/2+1,w,h,0,1)
                draw_sprite_stretched_ext(objspr[i],0,dx-w/2+1,dy-h/2-1,w,h,0,1)
                draw_sprite_stretched_ext(objspr[i],0,dx-w/2-1,dy-h/2+1,w,h,0,1)
                draw_sprite_stretched_ext(objspr[i],0,dx-w/2-1,dy-h/2-1,w,h,0,1)
                d3d_set_fog(0,0,0,0)
            }
            draw_sprite_stretched(objspr[i],0,dx-w/2,dy-h/2,w,h)
            tooltiptext=ds_list_find_value(objects,i)
            if (objdesc[i]!="") tooltiptext=tooltiptext+lf+lf+objdesc[i]
        }
        posx+=1 if (posx=4) {posx=0 posy+=1}
    }

    if (paltooltip && !paladdbuttondown) tooltiptext="Add more..."

    //bottom panel
    draw_button_ext(0,height-112,160,112,1,global.col_main)
}

if (mode==1 && tilebgpal!=noone) {
    //tile tab tooltips
    posx=0
    posy=0
    if (mouse_wy>=152 && mouse_wy<height-216 && tilebgpal!=noone) {
        tex=bg_background[tilebgpal]
        map=bg_tilemap[tilebgpal]
        len=ds_map_size(map)
        key=ds_map_find_first(map)
        for (i=0;i<len;i+=1) {
            tile=ds_map_find_value(map,key)
            key=ds_map_find_next(map,key)
            dx=20+40*posx
            dy=172+40*posy+tpalscroll
            if (point_in_rectangle(mouse_wx,mouse_wy,dx-20,dy-20,dx+20,dy+20)) {
                u=ds_list_find_value(tile,0)
                v=ds_list_find_value(tile,1)
                tw=ds_list_find_value(tile,2)
                th=ds_list_find_value(tile,3)
                if (tw>32 || th>32) {
                    dx=floor(max(1,dx-tw/2)+tw/2)+frac(tw/2)
                    dy=floor(max(1,dy-th/2)+th/2)+frac(th/2)
                    draw_set_color_sel() d3d_set_fog(1,draw_get_color(),0,0) draw_set_color($ffffff)
                    draw_background_part(tex,u,v,tw,th,dx-tw/2+1,dy-th/2+1)
                    draw_background_part(tex,u,v,tw,th,dx-tw/2+1,dy-th/2-1)
                    draw_background_part(tex,u,v,tw,th,dx-tw/2-1,dy-th/2+1)
                    draw_background_part(tex,u,v,tw,th,dx-tw/2-1,dy-th/2-1)
                    d3d_set_fog(0,0,0,0)
                }
                draw_background_part(tex,u,v,tw,th,dx-tw/2,dy-th/2)
            }
            posx+=1 if (posx=4) {posx=0 posy+=1}
        }

        if (paltooltip && !paladdbuttondown) tooltiptext="Add tiles..."
    }

    if (mouse_wx>=width-160 && mouse_wy>=360 && mouse_wy<height-100) {
        mem=ly_current
        if (median(0,floor((mouse_wy-360-layerscroll)/32),layersize+1)==layersize) {
            tooltiptext="Add layer..."
        }
    }
}

draw_knob()

with (Button) button_draw()
with (Button) if (focus && alt!="" && (tagmode==mode || tagmode==-1)) drawtooltip(alt)

if (mousein && mode==0) {
    with (select) {
        if (fieldactive) {
            draw_instance_fields(0)
        } else if (abs(global.mousex-fieldhandx)<9*zm && abs(global.mousey-fieldhandy)<9*zm) {
            draw_instance_fields(1)
        }
    }
    if (keyboard_check(ord("C"))) {
        with (instance) if (abs(global.mousex-fieldhandx)<9*zm && abs(global.mousey-fieldhandy)<9*zm || other.focus==id && !fieldactive) {
            draw_instance_fields(1)
        }
    } else {
        with (focus) if (!fieldactive) {
            draw_instance_fields(1)
        }
    }
}

if (tooltiptext!="") drawtooltip(tooltiptext)
