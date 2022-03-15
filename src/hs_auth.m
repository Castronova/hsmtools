function authfile = hs_auth( )
%HS_AUTH is a utility function for obtaining HydroShare authentication 
%       token for the current user. This is necessary to overcome a 
%       current limitation of MO.
%
%Usage: hs_auth()
%
%Returns: 
%  path to auth file or null


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
             return;
         end

    end
end

% return null if hs_auth is not found
authfile = "";

end
