function [ sloth ] = readsloth( filename )
%PARSESLOTH Parses a sloth label file and imports the data as a struct
%   Uses the jsonlab parser and additionally adds information about
%   the path of the json file and the json file itself.

json = loadjson(filename);
sloth = struct();
[pathstr, name, ext] = fileparts(filename);
sloth.path = pathstr;
sloth.json = [name ext];
sloth.annotations = json;

end

