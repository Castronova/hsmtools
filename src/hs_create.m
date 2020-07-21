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
auth = jsondecode(fileread('/code/.hs_auth'));
access_token = auth.('access_token');
headerFields = {'Authorization', ['Bearer ', access_token]};
opt = weboptions;
opt.RequestMethod = 'post';
opt.HeaderFields = headerFields;

% build a cell array for the keywords in a format that HydroShare is expecting
% the format is
% keyword[0] = "keyword value 1"
% keyword[1] = "keyword value 2"
% keyword[2] = "keyword value 3"
kw = {};
for i=1:1:keywords.length
    idx = i-1;
    label = char("keywords["+idx+"]");
    kw{end+1} = label;
    kw{end+1} = keywords(i);
    
end

% encode the data for upload to HydroShare
url = 'https://www.hydroshare.org/hsapi/resource/';
args = {url ...
    'title' title ...
    'abstract' abstract ...
    'resource_type', 'CompositeResource' ...
    opt};

% append the keyword cell array to args
args = [args, kw];

% call the create resource endpoint using the args in the
% cell array defined previously
response = webwrite(args{:});

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
