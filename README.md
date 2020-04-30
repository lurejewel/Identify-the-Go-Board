# Identify-the-Go-Board
Identify the horizental and vertical lines as well as intersections

Preparation for RoboCup@Home Shaoxing 2020 OPL Final. A small task aiming at a 19x19 chessboard with MATlAB R2018a. 

Main idea:
* Get the rgb photo from camera
* adaptive binarization -> Gaussian Filtering
* get Hough space metrix
* find the top 500 largest points from the space metrix, and divide them into horizontal and vertical ones
* fit out 45 horizontal and vertical lines respectively using kmeans algorithm
* ulteriorly merge the lines that are very close to each other
* draw the lines and the intersections
