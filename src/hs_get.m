function outpath = hs_get( resource_id, pretty_naming, replace )
%HS_GET is a utility function for downloading HydroShare resources into 
%       your MATLAB workspace. 
%
%Usage: hs_get(<resource_id>, <pretty_name>, <replace>)
%Args:
%  resource_id      The GUID of the Hydroshare resource to download (string)
%  pretty_naming    Renames the download using the resource title, default=false (boolean)
%  replace          Replaces existing data if it exists, default=false (boolean)
%Returns: 
%  path to downloaded resource

% authentication
access_token = hs_auth();
headerFields = {'Authorization', ['Bearer ', access_token]};
options = weboptions('HeaderFields', headerFields, 'ContentType','json');

% check optional arguments
if (~exist('pretty_naming', 'var'))
    pretty_naming = false; 
end
if (~exist('replace', 'var'))
    replace = false;
end

% generate a random id to save the resource under
zid = char(java.util.UUID.randomUUID);

% check if the file exists
if (~pretty_naming)
    if (replace)
        % remove existing directory
        rmdir(resource_id, 's');
    else
        if exist(resource_id, 'dir') == 7
            error('Resource already exists, please remove before proceeding:\n\ndelete(%s)', resource_id);
        end
    end
end


% define the content to be downloaded
base_url = 'https://hydroshare.org/hsapi/resource/';
full_url = strcat(base_url, resource_id);
zip_path = strcat(zid, '.zip');

% download the resource
dfile = websave(zip_path, full_url, options);

% unzip the data
rehash;
data_files = unzip(dfile, zid);

if pretty_naming
    
    % extract resource title from metadata
    [dpath, name, ext] = fileparts(dfile);
    metadata_path = strcat(dpath, '/', zid, '/', resource_id, '/data/resourcemetadata.xml');
    d = xmlread(char(metadata_path));
    e = d.getElementsByTagName('dc:title').item(0).getTextContent;
    pretty_name = regexprep(char(e), ' +', '_');
    eidx = min(length(pretty_name), 45);
    pretty_name = pretty_name(1:eidx);
    
    if(~replace)
        % adjust the name if this file already exists
        orig_name = pretty_name;
        i = 1;
        while exist(pretty_name, 'dir') == 7
            pretty_name = strcat(num2str(i), '_', orig_name);
            i = i + 1;
        end
    else
        % remove existing directory
        rmdir(pretty_name, 's');
    end
    
    
    % move the resource to a pretty named directory
    base_resource_path = strcat(zid, '/', resource_id);
    movefile(base_resource_path, pretty_name);
    
    % remove temporary path
    rmdir(zid);
    
    % set return value
    s = what(pretty_name);
    outpath = s.path;
else
    % remove the nested resource guids
    base_resource_path = strcat(zid, '/', resource_id);
    movefile(base_resource_path, resource_id);
    
    % remove the empty directory
    rmdir(zid);
    
    % set return value
    s = what(resource_id);
    outpath = s.path;
end

% cleanup
delete(zip_path);

end
