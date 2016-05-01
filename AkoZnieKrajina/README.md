Project 5 - You Decide!
=======================

Run the project
---------------
In order to run the project, you need to fork/clone/download the project and open the file `AkoZnieKrajina.xcodeproj` in Xcode and run it. You can also visit my github webapge and get the latest version. (https://github.com/peter-krajcir/SoundMap)

Description
-----------
The application is a native app for webpage http://www.akozniekrajina.sk/. The webpage is Sound Map for Slovak Republic (Eastern Europe). It contains pins on the map. The users can select desired one and play the sound. They have 2 options - directly stream it from the webpage or download it to the device. When they decide to download it to the device, it uses CoreData to store the information about the sound permanently and downloads the sound to the phone. Users can browse the downloaded sounds.

Application Navigation
----------------------
The Application uses 2 Navigation elements:
* TabBar Controller
* Navigation Controller

TabBar
------
TabBar is located in the bottom part of the application and it's divided into 2 sections:
* Map
* Downloads

In the Map section, users can find available sounds. The region of the map is persistant so users can continue their work with the application when they quit it. There is an annotation with the sound details for every pin. When the annotation is selected, the player is available for the user.

In the Downloads section, users can find previously downloaded sounds. When the item is selected, the player is available for the user.

Anytime, users can use Navigation controller in the top part of the application and return back to the previous screen so they don't get lost in the application.

The Player
----------
In the Player, users see the details of the selected Pin from the Map, specifically:
* Title
* Address
* Image
* Action buttons for controlling the sound

Users can either stream the sound directly from the webpage or download it to the device. In order to stream the sound directly from the webpage, the users have to first turn on the switch next to Stream option. This is to prevent them stream the big files from the webpage by accident. When users enable the sound for stream or download the sound to the device, they can control the sound using standard buttons - Play & Pause.

When users download the sound to the device, it's permanently stored in the phone's database using CoreData and it's immediately available for them in the Downloads section of the Application (located in TabBar)

Target Devices
--------------
The Application is optimized for all the iPhones starting with 4S and newer.