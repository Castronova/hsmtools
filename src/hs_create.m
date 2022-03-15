function [ resource_url ] = hs_create( title, abstract, keywords, filepaths )
% HS_CREATE is a utility function for creating new HydroShare resources from
%           content in your MATLAB Online workspace
% Usage: hs_create(<title>, <abstract>, <keywords>, <filepaths>)
% Args:  
%   title       The title for the new resource (string)
%   abstract    The abstract for the new resource (string)
%   keywords    Keywords that will be added to the new resource (string array)
%   filepaths   Paths of files to add to the new resource (string array)
% Returns: 
%   url of the newly created HydroShare resource 

% authentication
access_token = hs_auth();
headerFields = {'Authorization', ['Bearer ', access_token]};
opt = weboptions;
opt.RequestMethod = 'post';
opt.HeaderFields = headerFields;

% encode the data for upload to HydroShare
% define the content to be downloaded
url = 'https://www.hydroshare.org/hsapi/resource/';
response = webwrite(url, ...
                   'title', title, ...
                   'abstract', abstract, ...
                   'keywords', keywords, ...
                   'resource_type', 'CompositeResource', ...
                   opt);

% check to see if the POST was successful
if ~any(strcmp("resource_id", fieldnames(response)))
    fprintf('  Error: failed to create resource ');
    return
end
resource_id = response.('resource_id');

% build resource url that will be returned
resource_url = strcat("https://www.hydroshare.org/resource/", resource_id);

fprintf('Resource created: %s%s', resource_url, newline)

% add files to the resource
hs_addfile(resource_id, filepaths, false);



end
