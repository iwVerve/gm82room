var i;

i=ds_list_find_index(objects,argument0)
if (!objloaded[i]) {
    object[i]=ds_map_create() ds_map_read_ini(object[i],root+"objects\"+argument0+".txt")
    objspr[i]=get_sprite(ds_map_find_value(object[i],"sprite"))
    objvis[i]=real(ds_map_find_value(object[i],"visible"))
    objdepth[i]=real(ds_map_find_value(object[i],"depth"))
    objloaded[i]=1
    palettesize+=1
}
objpal=i
return i
