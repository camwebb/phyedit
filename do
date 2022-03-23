#!/usr/bin/gawk -f

BEGIN{
  
  # READ QUERY STRING
  split(ENVIRON["QUERY_STRING"], qs, "&")
  for (q in qs) {
    split(qs[q], qp, "=")
    f[qp[1]] = substr(urldecode(qp[2]),1,2000)
  }
  
  # APP FLOW
  # no apriori file...
  if (f["action"] == "create1")
    create1()
  else if (f["action"] == "create2")
    create2()
  else if (f["action"] == "delete")
    delete_file()
  else if (!f["file"])
    choose_file()
  # ... and now file-specific options
  else if (f["action"] == "newick")
    newickout()
  else if (f["actions"])
    actions()
  else defaultpage()
  
}

# ========================= COMMON PAGE HTML =================================

function actions(   n, a, i) {
  
  header()
  n = split(f["actions"], a, ",")

  print "<p>Select an action on node <b>" f["node"] "</b>:</p>"
  for (i = 1; i <= n; i++) {
    if (a[i] == "edit")
      print "<form action=\"do\"><p style=\"padding: 25px;\">"          \
        "<input type=\"hidden\" name=\"file\" value=\"" f["file"] "\"/>" \
        "<input type=\"hidden\" name=\"action\" value=\"edit\"/>"       \
        "<input type=\"hidden\" name=\"node\" value=\"" f["node"]  "\"/>" \
        "<input type=\"submit\" value=\"Change\"/> node name to: "      \
        "<input type=\"text\" name=\"new\" size=\"30\"/>"               \
        "</p></form>"
    if (a[i] == "rm")
      print "<form action=\"do\"><p style=\"padding: 25px;\">"          \
        "<input type=\"hidden\" name=\"file\" value=\"" f["file"] "\"/>" \
        "<input type=\"hidden\" name=\"action\" value=\"rm\"/>"\
        "<input type=\"hidden\" name=\"node\" value=\"" f["node"]  "\"/>"\
        "<input type=\"submit\" value=\"Delete\"/> node"\
        "</p></form>"
    if (a[i] == "insert")
      print "<form action=\"do\"><p style=\"padding: 25px;\">"\
        "<input type=\"hidden\" name=\"file\" value=\"" f["file"] "\"/>" \
        "<input type=\"hidden\" name=\"action\" value=\"insert\"/>"\
        "<input type=\"hidden\" name=\"node\" value=\"" f["node"]  "\"/>"\
        "<input type=\"submit\" value=\"Insert\"/> "\
        "an <b>intermediate node</b> rootward: "                   \
        "<input type=\"text\" name=\"new\" size=\"30\"/>"\
        "</p></form>"
    if (a[i] == "add")
      print "<form action=\"do\"><p style=\"padding: 25px;\">"\
        "<input type=\"hidden\" name=\"file\" value=\"" f["file"] "\"/>" \
        "<input type=\"hidden\" name=\"action\" value=\"add\"/>"\
        "<input type=\"hidden\" name=\"node\" value=\"" f["node"]  "\"/>"\
        "<input type=\"submit\" value=\"Add\"/> a new <b>daughter node</b>: "\
        "<input type=\"text\" name=\"new\" size=\"30\"/> </p></form>"
    if (a[i] == "spin")
      print "<form action=\"do\"><p style=\"padding: 25px;\">"\
        "<input type=\"hidden\" name=\"file\" value=\"" f["file"] "\"/>" \
        "<input type=\"hidden\" name=\"action\" value=\"spin\"/>"\
        "<input type=\"hidden\" name=\"node\" value=\"" f["node"]  "\"/>" \
        "<input type=\"submit\" value=\"Spin\"/> daughters at this node"\
        "</p></form>"
  }
  footer()
}  

function action(   error, cmd) {

  cmd = "PHYEDIT_DIR=tmp PHYEDIT_FILEBASE=" f["file"]       \
    " ./phyedit " f["action"] " " f["node"] " " f["new"]
  if (system(cmd)) {
    getline error < "tmp/error"
    Message = "Error: " error
  }
  
}

function header() {
  # version history: [chars app] -> [tcm] -> here
  
  # Use html5
  print "Content-type: text/html\n"
  print "<!DOCTYPE html>"
  print "<html xmlns=\"http://www.w3.org/1999/xhtml\">"
  print "<head><title>PhyEdit</title>"
  print "<meta http-equiv=\"Content-Type\" content=\"text/html; \
           charset=utf-8\" />"
  #print "<link href=\"../img/akflora.png\" rel=\"shortcut icon\"   \
  #         type=\"image/x-icon\"/>"
  print "<style>"
  print "body { font-size: 14px; font-family: " \
    "Verdana, Arial, Helvetica, sans-serif; }"
  print ".main {max-width: 1200px; padding-top: 30px; margin-left: auto;"   \
    "  margin-right: auto; }"
  print "a { color:#15358d; text-decoration:none; border-bottom-style:none }"
  print "a:visited { color:#9f1dbc }"
  print "a:hover {color:#15358d; border-bottom-style:solid; \
	     border-bottom-width:thin }"
  print "</style>"
  print "</head>\n<body>"
  print "<div class=\"main\">"
}

function footer() {
  print "</div>"
  print "</body>\n</html>";
}

function defaultpage(   i) {

  # run action first
  action()
  
  header()
  system("cat tmp/" f["file"] ".map")

  print "<table><tr><td style=\"width: 820px;\">"
  print "<img src=\"tmp/" f["file"] ".jpg?" systime() "\" usemap=\"#phy\"/>"
  print "</td><td style=\"vertical-align: top;\">"
  if (Message)
    print Message "<br/><br/>"
  print "[ <a href=\"do\">Choose another file</a> ]<br/><br/>"
  print "[ <a href=\"do?action=newick&file=" f["file"] \
    "\">Export Newick notation</a> ]<br/><br/>"
  print "[ <a href=\"do?action=pretty&file=" f["file"] \
    "\">Prettify tree</a> ]"
  print "</td></tr></table>"

  footer()
}

function urldecode(text,   hex, i, hextab, decoded, len, c, c1, c2, code) {
# decode urlencoded string
# urldecode function from Heiner Steven
#   http://www.shelldorado.com/scripts/cmds/urldecode
# version 1
	
  split("0 1 2 3 4 5 6 7 8 9 a b c d e f", hex, " ")
  for (i=0; i<16; i++) hextab[hex[i+1]] = i
  
  decoded = ""
  i = 1
  len = length(text)
  
  while ( i <= len ) {
    c = substr (text, i, 1)
    if ( c == "%" ) {
      if ( i+2 <= len ) {
        c1 = tolower(substr(text, i+1, 1))
        c2 = tolower(substr(text, i+2, 1))
        if ( hextab [c1] != "" || hextab [c2] != "" ) {
          # print "Read: %" c1 c2;
          # Allow: 
          # 20 begins main chars, but dissallow 7F (wrong in orig code!)
          #   tab, newline, formfeed, carriage return
          if ( ( (c1 >= 2) && ((c1 c2) != "7f") )   \
               || (c1 == 0 && c2 ~ "[9acd]") )
            {
              code = 0 + hextab [c1] * 16 + hextab [c2] + 0
              # print "Code: " code
              c = sprintf ("%c", code)
            } else {
            # for dissallowed chars
            c = " "
          }
          i = i + 2
        }
      }
    } else if ( c == "+" ) 	# special handling: "+" means " "
      c = " "
    decoded = decoded c
    ++i
  }
  
  # change linebreaks to \n
  gsub(/\r\n/, "\n", decoded);
  # remove last linebreak
  gsub(/[\n\r]*$/,"",decoded);
  return decoded
}

function choose_file(   cmd, file) {

  header()

  cmd = "find tmp -name '*.fy' | sed -e 's|tmp/||g' -e 's/.fy//g'"
  while ((cmd | getline)>0)
    file[$0]++

  print "<p><b>PHYEDIT web-based phylogeny editor</b><br/>"\
    "<i>Please download your phylogeny frequently as a Newick file, as a backup</i></p>"
  print "<form action=\"do\"><p style=\"margin-top: 30px\">"
  print "<b>1</b>. Choose a file to work on:"
  print "<select name=\"file\" autocomplete=\"off\">"
  print "<option value=\"NULL\" selected=\"selected\"></option>"
  for (i in file)
    print "<option value=\"" i "\">" i "</option>"
  print "</select>&#160;&#160;"
  print "<input type=\"submit\" value=\"Use\"/>"
  print "</p></form>"

  print "<form action=\"do\"><p style=\"margin-top: 30px\">"
  print "<b>2</b>. Or make a new two-node tree from a single name of root node " \
    "(allowed characters are 'A-Za-z0-9_-'):<br/><br/>"
  print "<input type=\"text\" name=\"rootnode\" style=\"width:300px;\"/>"
  print "<input type=\"hidden\" name=\"action\" value=\"create1\"/>&#160;&#160;"
  print "<input type=\"submit\" value=\"Create\"/>"
  print "</p></form>"

  print "<form action=\"do\"><p style=\"margin-top: 30px\">"
  print "<b>3</b>. Or make a new tree from Newick format"                  \
    " phylogeny (allowed characters are '(),;A-Za-z0-9_-]'):<br/><br/>"
  print "<textarea style=\"height:50px;width:300px;\" name=\"newick\">" \
    "</textarea>"
  print "<input type=\"hidden\" name=\"action\" value=\"create2\"/>&#160;&#160;"
  print "<input type=\"submit\" value=\"Create\"/>"
  print "</p></form>"
  
  if (length(file)) {
    print "<form action=\"do\"><p style=\"margin-top: 30px\">"
    print "<b>4</b>. Or delete a file (CAUTION!): "
    print "<input type=\"hidden\" name=\"action\" value=\"delete\"/>"
    print "<select name=\"file\" autocomplete=\"off\">"
    print "<option value=\"NULL\" selected=\"selected\"></option>"
    for (i in file)
      print "<option value=\"" i "\">" i "</option>"
    print "</select>&#160;&#160;"
    print "<input type=\"submit\" value=\"Delete\"/>"
    print "</p></form>"
  }

  footer()
}

function newickout() {
  header()

  print "<p>"
  system("PHYEDIT_DIR=tmp PHYEDIT_FILEBASE=" f["file"]  \
         " ./phyedit " f["action"] )
  print "</p>"
  print "<p>[ <a href=\"do?file=" f["file"] "\">BACK</a> ]</p>"
  
  footer()
}

function create1(   cmd, file) {

  header()
  
  # get existing files
  cmd = "find tmp -name '*.fy' | sed -e 's|tmp/||g' -e 's/.fy//g'"
  while ((cmd | getline)>0)
    file[$0]++
  
  if (length(file) > 10)
    print "<p>Error: maximum number of files exceeded</p>"
  else if (f["rootnode"] !~ /^[A-Za-z0-9_-]+$/)
    print "<p>Error: root name must only consist of these characters: A-Z a-z 0-9 or _ or - </p>"
  else if (file[f["rootnode"]])
    print "<p>Error: root name exists</p>"
  else {
    if(system("echo 'dummy|" f["rootnode"] "' > tmp/" f["rootnode"] ".fy"))
      print "<p>Error: could not create new file</p>"
    else
      print "<p>Success</p>"
  }
  
  print "<p>[ <a href=\"do\">BACK</a> ]</p>"

  footer()
}

function create2(   cmd, file, rootname) {

  header()
  
  # get existing files
  cmd = "find tmp -name '*.fy' | sed -e 's|tmp/||g' -e 's/.fy//g'"
  while ((cmd | getline)>0)
    file[$0]++

  gsub(/[ \t\r\f\n]/, "", f["newick"])
  if (length(file) > 10)
    print "<p>Error: maximum number of files exceeded</p>"
  else if (f["newick"] !~ /^[(),;A-Za-z0-9_-]+$/)
    print "<p>Error: Newick must only consist of these characters: "    \
      "() ; , A-Z a-z 0-9 _ -</p>"
  else {
    # find the root name
    rootname = gensub(/.*\)([A-Za-z0-9_-]+);$/, "\\1","G", f["newick"])
    if (!rootname)
      print "<p>Error: could not find root name/p>"
    else if (file[rootname])
      print "<p>Error: root name '" rootname "' exists</p>"
    else if(system("echo '" f["newick"] "' > tmp/_tmp.new"))
      print "<p>Error: could not create _tmp.fy file</p>"
    else if (system("PHYEDIT_DIR=tmp PHYEDIT_FILEBASE=_tmp ./phyedit new2fy" \
                    " > tmp/_tmp.fy")) {
      print "<p>Error: could not convert _tmp.fy file (1)<br/>Error: "
      system("cat tmp/error")
      print "</p>"
    }
    else if (system("mv tmp/_tmp.fy tmp/" rootname ".fy"))
      print "<p>Error: could not convert _tmp.fy file (2)</p>"
    else
      print "<p>Success</p>"
  }

  system("rm tmp/_tmp* &> /dev/null")
  
  print "<p>[ <a href=\"do\">BACK</a> ]</p>"

  footer()
}


function delete_file(   cmd, file) {
  
  header()
  
  # get existing files
  cmd = "find tmp -name '*.fy' | sed -e 's|tmp/||g' -e 's/.fy//g'"
  while ((cmd | getline)>0)
    file[$0]++
  
  if (!file[f["file"]])
    print "<p>Error: file '" f["file"] "' does no exist</p>"
  else {
    if(system("rm tmp/" f["file"] ".*"))
      print "<p>Error: could not delete file</p>"
    else
      print "<p>Success</p>"
  }
  
  print "<p>[ <a href=\"do\">BACK</a> ]</p>"
  
  footer()
}
