function [ resource_url ] = hs_create( title, abstract, keywords, filepaths )
% hs_create Creates a HydroShare resource 
%   Takes a title, abstract, keywords, filepaths

% authentication
auth = jsondecode(fileread('/code/.hs_auth'));
access_token = auth.('access_token');
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
