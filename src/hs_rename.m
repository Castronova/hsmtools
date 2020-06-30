function [ ] = hs_rename( directory )
% hs_pretty_name Renames all HS resources in a given directory to the resource's title.
%   Takes a directory

% check optional arguments
if (~exist('directory', 'var'))
    error('Missing parameter: directory');
end

paths = dir(directory);
nonpaths = ['.','..'];
for i = 1:numel(paths)
   if ~ismember(paths(i).name, nonpaths)
       if regexp(paths(i).name, '^[a-z0-9]{32}$')
           flder = strcat(paths(i).folder, '/', paths(i).name);
           metadata = strcat(flder, '/data/resourcemetadata.xml');
           if exist(metadata, 'file') == 2
               try
                   d = xmlread(metadata);
                   e = d.getElementsByTagName('dc:title').item(0).getTextContent;
                   pretty_name = regexprep(char(e), ' +', '_');
                   eidx = min(length(pretty_name), 45);
                   pretty_name = pretty_name(1:eidx);
                    
                   % adjust the name if this file already exists
                   orig_name = pretty_name;
                   k = 1;
                   while exist(pretty_name, 'dir') == 7
                       pretty_name = strcat(num2str(k), '_', orig_name);
                       k = k + 1;
                   end
                    
                   % move the resource to a pretty named directory
                   movefile(flder, pretty_name);
                   
                   % print message
                   fprintf('Successfully renamed %s -> %s \n', flder, pretty_name);
               catch
                   fprintf('Failed to rename folder: %s \n', flder);
               end
           end
       end
   end
end
