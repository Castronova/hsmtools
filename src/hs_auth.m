function access_token = hs_auth( )
%HS_AUTH is a utility function for obtaining HydroShare authentication 
%       token for the current user. This is necessary to overcome a 
%       current limitation of MO.
%
%Usage: hs_auth()
%
%Returns: 
%  HydroShare Authentication Token


% list of foldernames to ignore
ignores = [".", "..", "matlab"];

% look for the authfile
folders = dir('/home');
children = convertCharsToStrings({folders(:).name});
parent_folder = convertCharsToStrings({folders(:).folder});



% loop through all folders in /home, peek inside and look for .hs_auth
% exit with the first hs_auth file that is found.
for k = 1 : length(children)
    if ~any(ignores(:) == children{k})
         subfolders = dir( join( [parent_folder(k), children(k) ], "/") );
         subchildren = convertCharsToStrings({subfolders(:).name});
         basefolder = convertCharsToStrings({subfolders(1).folder});
         
         % check if hs_auth is found in this directory
         if any(".hs_auth" == subchildren(:))
             authfile = join([basefolder, ".hs_auth"], "/");
	     auth = jsondecode(fileread(authfile));
	     access_token = auth.('access_token');
             return;
         end

    end
end

% raise an exception if .hs_auth isn't found
errid = "hs_auth:HydroShare_Auth_NotFound";
ME = MException(errid, ...
        ['%s: Could not authenticate with HydroShare. ' ...
        'Please contact help@cuahsi.org for assistance.'], errid);
throw(ME);


end
