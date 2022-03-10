#!/usr/bin/gawk -f

BEGIN{
  
  # READ QUERY STRING
  split(ENVIRON["QUERY_STRING"], qs, "&")
  for (q in qs) {
    split(qs[q], qp, "=")
    f[qp[1]] = substr(urldecode(qp[2]),1,2000)
  }
  
  # DETERMINE AND EXECUTE METHOD
  if (f["actions"])
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
      print "<form action=\"do\"><p style=\"padding: 25px;\"><input type=\"hidden\" "            \
        "name=\"action\" value=\"edit\"/><input type=\"hidden\" "       \
        "name=\"node\" value=\"" f["node"]  "\"/><input type=\"submit\" " \
        "value=\"Change\"/> node name to: " \
        "<input "                                        \
        "type=\"text\" name=\"new\" size=\"30\"/> </p></form>"
    if (a[i] == "rm")
      print "<form action=\"do\"><p style=\"padding: 25px;\"><input type=\"hidden\" "           \
        "name=\"action\" value=\"rm\"/><input type=\"hidden\" "         \
        "name=\"node\" value=\"" f["node"]  "\"/><input type=\"submit\" " \
        "value=\"Delete\"/> node</p></form>"
    if (a[i] == "insert")
      print "<form action=\"do\"><p style=\"padding: 25px;\"><input type=\"hidden\" "            \
        "name=\"action\" value=\"insert\"/><input type=\"hidden\" "     \
        "name=\"node\" value=\"" f["node"]  "\"/><input type=\"submit\" " \
        "value=\"Insert\"/> an <b>intermediate node</b> rootward: <input " \
        "type=\"text\" name=\"new\" size=\"30\"/> </p></form>"
    if (a[i] == "add")
      print "<form action=\"do\"><p style=\"padding: 25px;\"><input type=\"hidden\" "            \
        "name=\"action\" value=\"add\"/><input type=\"hidden\" "     \
        "name=\"node\" value=\"" f["node"]  "\"/><input type=\"submit\" " \
        "value=\"Add\"/> a new <b>daughter node</b>: <input " \
        "type=\"text\" name=\"new\" size=\"30\"/> </p></form>"
  }
  footer()
}  

function action(   error, cmd) {

  cmd = "./phyedit " f["action"] " " f["node"] " " f["new"]
  if (system(cmd)) {
    getline error < "tmp/error"
    Message = "Error: " error
  }
  else
    Message = "Success"
  
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
  print ".main {width: 1000px; padding-top: 30px; margin-left: auto;"   \
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
  # if (f["action"])
  action(f["action"])
  
  header()
  system("cat tmp/phy.map")

  print "<table><tr><td style=\"width: 820px;\">"
  print "<img src=\"tmp/phy.jpg?" systime() "\" usemap=\"#phy\"/>"
  print "</td><td style=\"vertical-align: top;\">"
  if (Message)
    print Message
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
