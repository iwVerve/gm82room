globalvar sprites,backgrounds,objects,sprloaded,bgloaded,objloaded,objspr,roomcode,settings,gridx,gridy;
var f,p,i,inst,layer;

roomwidth=800
roomheight=608

loadtext="Loading project..."
progress=0
screen_redraw()

//find room
if (parameter_count()) {
    dir=parameter_string(1)
} else {
    //dir=get_open_filename("GM8.2 Room|room.txt","room.txt")
    dir="C:\Stuff\github\renex-engine\rooms\rmDemo3\room.txt"
    dir=filename_dir(dir)
}
roomname=filename_name(dir)
if (roomname="") {
    game_end()
    exit
}

dir+="\"
root=dir+"..\..\"
room_caption+=" - "+roomname
set_application_title(roomname+" - Room Editor")

//load assets
sprites=file_text_read_list(root+"sprites\index.yyd")
backgrounds=file_text_read_list(root+"backgrounds\index.yyd")
objects=file_text_read_list(root+"objects\index.yyd")

sprloaded[ds_list_size(sprites)]=0
bgloaded[ds_list_size(backgrounds)]=0
objloaded[ds_list_size(objects)]=0

//init room properties
roomcode=""
settings=ds_map_create()
ds_map_read_ini(settings,dir+"room.txt")

//load room properties
background_color=real(ds_map_find_value(settings,"bg_color"))
backvisible=real(ds_map_find_value(settings,"clear_screen"))
roomwidth=real(ds_map_find_value(settings,"width"))
roomheight=real(ds_map_find_value(settings,"height"))
gridx=real(ds_map_find_value(settings,"snap_x"))
gridy=real(ds_map_find_value(settings,"snap_y"))

loadtext="Loading tiles..."
progress=0.25
screen_redraw()

time=current_time

//load tiles
layers=file_text_read_list(dir+"layers.txt")
l=ds_list_size(layers) for (i=0;i<l;i+=1) {
    layer=real(ds_list_find_value(layers,i))
    f=file_text_open_read(dir+string(layer)+".txt") do {str=file_text_read_string(f) file_text_readln(f)
        p=string_pos(",",str) tileb=string_copy(str,1,p-1) str=string_delete(str,1,p)
        p=string_pos(",",str) tilex=real(string_copy(str,1,p-1)) str=string_delete(str,1,p)
        p=string_pos(",",str) tiley=real(string_copy(str,1,p-1)) str=string_delete(str,1,p)
        p=string_pos(",",str) tileu=real(string_copy(str,1,p-1)) str=string_delete(str,1,p)
        p=string_pos(",",str) tilev=real(string_copy(str,1,p-1)) str=string_delete(str,1,p)
        p=string_pos(",",str) tilew=real(string_copy(str,1,p-1)) str=string_delete(str,1,p)
        p=string_pos(",",str) tileh=real(string_copy(str,1,p-1))
        o=instance_create(tilex,tiley,tileholder)
        o.bgname=tileb o.depth=layer-0.01 o.tilew=tilew o.tileh=tileh o.tileu=tileu o.tilev=tilev
        o.tile=tile_add(get_background(tileb),tileu,tilev,tilew,tileh,tilex,tiley,layer)
        if (current_time>time) {
            time=current_time
            progress=(progress*9+0.25+0.5*i/l)/10
            screen_redraw()
        }
    } until (file_text_eof(f)) file_text_close(f)
}
/*
loadtext="Loading dynamic tiles..."
progress=0.5

mode=0

f=file_text_open_read(dir+"code.gml") do {str=file_text_read_string(f) file_text_readln(f)
    if (string_pos("/"+"*gm82tile*"+"/",str)) mode=1
    if (mode) {
        str=file_text_read_string(f) file_text_readln(f)
        if (string_pos("/"+"*end gm82tile*"+"/",str)) {
            mode=0
        } else {
            str=string_delete(str,1,9)
            p=string_pos(",",str) tileb=string_copy(str,1,p-1) str=string_delete(str,1,p)
            p=string_pos(",",str) tileu=real(string_copy(str,1,p-1)) str=string_delete(str,1,p)
            p=string_pos(",",str) tilev=real(string_copy(str,1,p-1)) str=string_delete(str,1,p)
            p=string_pos(",",str) tilew=real(string_copy(str,1,p-1)) str=string_delete(str,1,p)
            p=string_pos(",",str) tileh=real(string_copy(str,1,p-1)) str=string_delete(str,1,p)
            p=string_pos(",",str) tilex=real(string_copy(str,1,p-1)) str=string_delete(str,1,p)
            p=string_pos(",",str) tiley=real(string_copy(str,1,p-1)) str=string_delete(str,1,p)
            p=string_pos(")",str) layer=real(string_copy(str,1,p-1))
            o=instance_create(tilex,tiley,tileholder)
            o.bgname=tileb o.depth=layer-0.01 o.tilew=tilew o.tileh=tileh o.tileu=tileu o.tilev=tilev
            o.tile=tile_add(get_background(tileb),tileu,tilev,tilew,tileh,tilex,tiley,layer)
            if (current_time>time) {
                time=current_time
                progress=(progress*9+0.75)/10
                screen_redraw()
            }
        }
    } else roomcode+=str+chr(10)
} until (file_text_eof(f)) file_text_close(f)
*/
time=current_time
loadtext="Loading instances..."

//load instances
f=file_text_open_read(dir+"instances.txt") do {str=file_text_read_string(f) file_text_readln(f)
    o=instance_create(0,0,instance)
    p=string_pos(",",str) o.objname=string_copy(str,1,p-1) str=string_delete(str,1,p)
    p=string_pos(",",str) o.x=real(string_copy(str,1,p-1)) str=string_delete(str,1,p)
    p=string_pos(",",str) o.y=real(string_copy(str,1,p-1)) str=string_delete(str,1,p)
    p=string_pos(",",str) o.code=string_copy(str,1,p-1)
    if (o.code!="") {o.code=file_text_read_all(dir+o.code+".gml") parsecode(o)}
    o.obj=get_object(o.objname)
    o.sprite_index=objspr[o.obj]
    o.sprw=sprite_get_width(o.sprite_index)
    o.sprh=sprite_get_height(o.sprite_index)
    o.sprox=sprite_get_xoffset(o.sprite_index)
    o.sproy=sprite_get_yoffset(o.sprite_index)
    if (current_time>time) {
        time=current_time
        progress=(progress*9+1)/10
        screen_redraw()
    }
} until (file_text_eof(f)) file_text_close(f)
