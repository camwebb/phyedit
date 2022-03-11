# phyedit: tools for editing phylogenies

`phyedit` is a simple CLI phylogeny editor and `do` is a web app for
browser-based use of `phyedit`

Dependencies: 

 * Gawk
 * Graphviz and GD, for creating images of the phylogeny
 * Apache web server, for web app

## Phylogeny file format

A pipe-delimited list of child-parent pairs. Order of the parents is
uninformative, but order of children sharing a parent is
preserved. All node names must be unique. No branch lengths or other
node-related information. E.g.,

```
a|root                    a  y
c|root                   /  /
b|root     is       root --c 
y|c                      \  \
x|c                       b  x
```

## phyedit

``` 
$ phyedit help

 Usage: phyedit [ <action> | help ] [ <node1> [ <node2> ]] 
  Actions 
    <none> : just create image 
    add    : add terminal <node2> to <node1> 
    insert : add <node2> in parent edge of <node1> 
    rm     : delete <node1> if terminal or single-daughter-node 
    spin   : rearrange order of daughters for bifurcating <node1> 
    edit   : change node label for <node1> 
      (all the above also output updated image of phylo) 
    newick : output Newick for input fy-format 
  Input file
    default = phy.fy ; other files can be supplied via environment 
      variables PHYEDIT_DIR and PHYEDIT_FILEBASE (omit suffix .fy)
```

Note: If `dot` (Graphviz) is not in `$PATH`, create a symlink called
`dot` in the same directory as `phyedit` and edit the code, replacing
calls to `dot` with `./dot`.

## do

Installation as web app: within a path viewable via apache:

```
git clone https://github.com/camwebb/phyedit.git
cd phyedit
cp htaccess_template .htaccess
# uncomment .htaccess authentication lines, create password file with htpasswd
mkdir tmp
# if http cgi owner is not same as filesytem owner:
# chmod a+w tmp
```

