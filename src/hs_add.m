function [ ] = hs_addfile( resourceid, filepaths, overwrite )
% HS_ADDFILE is a utility function for adding content from the MATLAB Online environment to existing HydroShare resources.
% Usage: hs_addfile(<resourceid>, <filepaths>, <overwrite>)
% Args:
%   resourceid  Unique GUID of the target HydroShare resource (string)
%   filepaths   Paths of files that will be added to the resource (string array)
%   overwrite   Flag that indicates if existing files will be overwritten (boolean, default=false, optional)
%   Takes a resourceid, filepath, overwrite (optional, default=FALSE)


% get hydroshare authentication
access_token = hs_auth();

% check optional arguments
if (~exist('overwrite', 'var'))
    overwrite = false; 
end

% check object types
if ~(class(filepaths) == "string")
    fprintf('Error: filepaths must be an array of strings, i.e. ["val1", "val2", etc]')
    return
end

% build URL path
url = strcat('https://www.hydroshare.org/hsapi/resource/', resourceid, '/files/');


% set http headers for GET/POST
headerFields = {'Authorization', ['Bearer ', access_token]};
headerFields = string(headerFields);
options = weboptions('HeaderFields', headerFields, 'ContentType','json');
options.RequestMethod = 'get';

% set http headers for DELETE
del_options = weboptions('HeaderFields', headerFields, 'ContentType','json');
del_options.RequestMethod = 'delete';

% query the files that already exist on HS
existing_files = strings();
file_paths = string();
resp = webread(url, options);
files = resp.('results');
for i=1:length(files)
    url_path = split(files(i).('url'),'/data/contents/');
    file_path = url_path(end);
    file_paths(i) = file_path;
    existing_files(i) = files.('file_name');
end

% add/replace/skip each file to HS resource
for i=1:length(filepaths)
    
    % todo: check if file exists before attempting upload
    
    addfile = true;
    removefile = false;
    if any(strcmp(existing_files, filepaths(i)))
        if ~overwrite
            fprintf("- file already exists, skipping (%s) %s", filepaths(i), newline); 
            addfile = false;
        else
            removefile = true;
        end
    end
    if removefile
        fprintf("! removing file (%s) %s", filepaths(i), newline);
        del_url = strcat("https://www.hydroshare.org/hsapi/resource/", ...
            resourceid, ...
            "/files/", ... 
            file_paths(i), ...
            "/");
        response = webread(del_url, del_options);
        if ~any(strcmp('file_name', fieldnames(response)))
            fprintf('  Error: failed to delete file from resource (%s) %s', filepaths(i), newline)
        end
        
    end
    if addfile
        fprintf("+ adding file (%s) %s", filepaths(i), newline); 
        headers = [strcat("Authorization: Bearer ", access_token)];
        datafile = fullfile(filepaths(i));
        if isfile(datafile)
        
            response = curlpost(url, headers, datafile);
            if ~any(strcmp('resource_id', fieldnames(response)))
                fprintf('  Error: failed to upload file (%s) %s', filepaths(i), newline)
            end
        else
            fprintf(' Error: file not found %s, skipping%s', filepaths(i), newline)
        end
    end
   
end

end
