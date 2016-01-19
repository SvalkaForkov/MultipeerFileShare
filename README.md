# MultipeerFileShare
Simple project that reproduces a bug in Multipeer connectivity

To reproduce the bug, launch the app on two iOS devices, and select different 
tabs. Once connected, one device should be able to send the image to the other 
device. If the other device receives it properly, it should show up in the
imageView on the second device.
