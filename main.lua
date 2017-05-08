local firebaseStorage = require "plugin.firebaseStorage"
timer.performWithDelay( 100, function()
    firebaseStorage.init("gs://corona-sdk-4-82825584.appspot.com")
end)
local widget = require("widget")

local bg = display.newRect( display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight )
bg:setFillColor( 1,.5,0 )

local function doesFileExist( fname, path )
 
    local results = false
 
    -- Path for the file
    local filePath = system.pathForFile( fname, path )
 
    if ( filePath ) then
        local file, errorString = io.open( filePath, "r" )
 
        if not file then
            -- Error occurred; output the cause
            print( "File error: " .. errorString )
        else
            -- File exists!
            print( "File found: " .. fname )
            results = true
            -- Close the file handle
            file:close()
        end
    end
 
    return results
end
function copyFile( srcName, srcPath, dstName, dstPath, overwrite )
 
    local results = false
 
    local fileExists = doesFileExist( srcName, srcPath )
    if ( fileExists == false ) then
        return nil  -- nil = Source file not found
    end
 
    -- Check to see if destination file already exists
    if not ( overwrite ) then
        if ( fileLib.doesFileExist( dstName, dstPath ) ) then
            return 1  -- 1 = File already exists (don't overwrite)
        end
    end
 
    -- Copy the source file to the destination file
    local rFilePath = system.pathForFile( srcName, srcPath )
    local wFilePath = system.pathForFile( dstName, dstPath )
 
    local rfh = io.open( rFilePath, "rb" )
    local wfh, errorString = io.open( wFilePath, "wb" )
 
    if not ( wfh ) then
        -- Error occurred; output the cause
        print( "File error: " .. errorString )
        return false
    else
        -- Read the file and write to the destination directory
        local data = rfh:read( "*a" )
        if not ( data ) then
            print( "Read error!" )
            return false
        else
            if not ( wfh:write( data ) ) then
                print( "Write error!" )
                return false
            end
        end
    end
 
    results = 2  -- 2 = File copied successfully!
 
    -- Close file handles
    rfh:close()
    wfh:close()
 
    return results
end
copyFile(  "coronaIcon.png.txt", nil, "coronaIcon.png", system.DocumentsDirectory, true )

local title = display.newText( {text = "Firebase Storage", fontSize = 30} )
title.width, title.height = 300, 168
title.x, title.y = display.contentCenterX, 168*.5
title:setFillColor(1,0,0)
local urlForImage
local uploadFile
print("hello124", doesFileExist("coronaIcon.png", system.DocumentsDirectory))
uploadFile = widget.newButton( {
        x = display.contentCenterX,
        y = display.contentCenterY-100,
        id = "Upload File",
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        label = "Upload File",
        onEvent = function ( e )
                if (e.phase == "ended") then
                    firebaseStorage.upload( system.pathForFile("coronaIcon.png", system.DocumentsDirectory), "coronaIcon.png", function(e)
                            if (not e.error) then
                                urlForImage = e.downloadURL
                                native.showAlert( "Image Uploaded","", {"Ok"} )
                            else
                                native.showAlert( "Error",e.error, {"Ok"} )
                            end
                    end)
                end
        end
} )
local downloadFile
downloadFile = widget.newButton( {
  x = display.contentCenterX,
  y = display.contentCenterY-50,
  id = "Download File",
  labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
  label = "Download File",
  onEvent = function ( e )
    if (e.phase == "ended") then
        if (urlForImage) then
            network.download(  urlForImage, "GET", function(e)
                if (e.isError == false) then
                    local displayDownload = display.newImageRect("coronaIcon.png", system.TemporaryDirectory, 50, 50 )
                    displayDownload.x, displayDownload.y =display.contentCenterX, display.contentCenterY+50
                end
            end, "coronaIcon.png", system.TemporaryDirectory )
        else
            native.showAlert( "Upload Image", "You need to upload image first", {"Ok"} )
        end
    end
  end
} )
