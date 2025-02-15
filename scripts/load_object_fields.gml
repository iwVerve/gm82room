///load_object_fields(object,objname)
//scan an object's event code for field declarations

//i know this looks kind of nasty but we need to consider speed here, as this
//can potentially read through thousands of lines of gml when loading a room
//so it's been written for speed in most places

var i,f,reading,str,p,linec,actionc,line,fp;

i=argument0

reading=0
actionc=0
f=file_text_open_read_safe(root+"objects\"+argument1+".gml") if (f) {do {
    line=file_text_read_string(f)
    file_text_readln(f)
    str=line
    if (!reading) {
        if (string_pos("#define Other_4",str)) {
            //only look for fields in room start events
            reading=1
            linec=-5
            actionc=0
        }
    } else {
        //expect end of room start event
        if (string_pos("#define",str)) {
            reading=0 break
        }

        //expect drag and drop action header
        if (string_pos("/*"+qt+"/*'/**//*",str)) {
            actionc+=1
            //jump to where the action id is
            file_text_readln(f)
            //look for "call event" action
            if (string_pos("action_id=604",file_text_read_string(f))) {
                parent=get_object_parent(argument1)
                if (parent!="") load_object_fields(i,parent)
            }
            //skip the rest of the action block
            do {file_text_readln(f) str=file_text_read_string(f)} until (str=="*/" || file_text_eof(f))
            linec=0
        }

        //expect field inheritance
        if (string_pos("event_inherited()",str)) {
            parent=get_object_parent(argument1)
            if (parent!="") load_object_fields(i,parent)
        }

        //expect description field
        linec+=1
        fp=string_pos("/*desc",str)
        if (fp) {
            while (1) {
                str=file_text_read_string(f)
                file_text_readln(f)
                if (string_pos("*/",str) || file_text_eof(f)) break
                //delete indentation
                if (str!="") {
                    p=1 while (string_char_at(str,p)==" ") do p+=1
                    objdesc[i]+=string_delete(str,1,p-1)+lf
                }
            }
            objdesc[i]=string_copy(objdesc[i],1,string_length(objdesc[i])-1)
        }

        //expect field
        fp=string_pos("//field ",str)
        if (fp) {
            //all the errors start with this so we cache it now
            error="Error in action "+string(actionc)+" of Room Start event for "+qt+argument1+qt+":"+crlf+crlf+string(linec)+" | "+line+crlf+crlf
            //found a field signature; parse it

            //find annotations
            objfielddef[i,objfields[i]]=""
            p=string_pos("-",str)
            if (p) {
                objfielddef[i,objfields[i]]=" - "+string_delete_edge_spaces(string_delete(str,1,p))
                str=string_delete_edge_spaces(string_copy(str,1,p-1))
            }

            p=string_pos(": ",str)
            if (p) {
                fieldname=string_delete_edge_spaces(string_copy(str,fp+8,p-(fp+8)))
                if (invalid_variable_name(fieldname)) {
                    show_message(error+"Field name "+qt+fieldname+qt+" contains invalid characters.")
                } else {
                    objfieldname[i,objfields[i]]=fieldname
                    str=string_delete_edge_spaces(string_delete(str,1,p+1))

                    if (string_pos("enum",str)) {
                        //enums are parsed differently due to option list
                        if (string_count("(",str)==1 && string_count(")",str)==1 && string_pos("(",str)<string_pos(")",str)) {
                            objfieldtype[i,objfields[i]]="enum"
                            //get the enum list from within the ()'s
                            str=string_delete(string_copy(str,1,string_pos(")",str)-1),1,string_pos("(",str))
                            if (str="") {
                                show_message(error+"Enum declaration has empty option list.")
                            } else {
                                objfieldargs[i,objfields[i]]=str
                                objfields[i]+=1
                            }
                        } else {
                            show_message(error+"Enum declaration missing list of options in parenthesis.")
                        }
                    } else if (string_pos("number",str)) {
                        //numbers are parsed differently due to range list
                        if (string_count("(",str)==1 && string_count(")",str)==1 && string_pos("(",str)<string_pos(")",str)) {
                            objfieldtype[i,objfields[i]]="number_range"
                            //get the range from within the ()'s
                            str=string_delete(string_copy(str,1,string_pos(")",str)-1),1,string_pos("(",str))
                            if (str="") {
                                show_message(error+"Number declaration has empty range.")
                            } else {
                                string_token_start(str,",")
                                __left=string_number(string_token_next())
                                __right=string_number(string_token_next())

                                if (__left=="" || __right=="") {
                                    show_message(error+"Number declaration has invalid range:#"+str)
                                } else {
                                    objfieldargs[i,objfields[i]]=__left+","+__right
                                    objfields[i]+=1
                                }
                            }
                        } else {
                            objfieldtype[i,objfields[i]]="number"
                            objfields[i]+=1
                        }
                    } else {
                        if (invalid_field_type(str)) {
                            show_message(error+"Field type "+qt+str+qt+" is not recognized.")
                        } else {
                            objfieldtype[i,objfields[i]]=str
                            objfields[i]+=1
                        }
                    }
                }
            } else {
                //default to "value" type when no type is present
                fieldname=string_delete_edge_spaces(string_delete(str,1,fp+7))
                if (invalid_variable_name(fieldname)) {
                    show_message(error+"Field name "+qt+fieldname+qt+" contains invalid characters.")
                } else {
                    objfieldname[i,objfields[i]]=fieldname
                    objfieldtype[i,objfields[i]]="value"
                    objfields[i]+=1
                }
            }
        }
    }
} until (file_text_eof(f)) file_text_close(f)}

//load parent's fields if there was no room start event
if (actionc==0) {
    parent=get_object_parent(argument1)
    if (parent!="") load_object_fields(i,parent)
}
