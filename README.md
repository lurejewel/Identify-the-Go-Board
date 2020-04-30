# Identify-the-Go-Board
Identify the horizental and vertical lines as well as intersections

Preparation for RoboCup@Home Shaoxing 2020 OPL Final. A small task aiming at a 19x19 chessboard with MATlAB R2018a. 

## Main idea:
* Get the rgb photo from camera
* adaptive binarization -> Gaussian Filtering
* get Hough space metrix
* find the top 500 largest points from the space metrix, and divide them into horizontal and vertical ones
* fit out 45 horizontal and vertical lines respectively using kmeans algorithm
* ulteriorly merge the lines that are very close to each other
* draw the lines and the intersections

## Result
Chess:
![chess](https://github.com/lurejewel/Identify-the-Go-Board/blob/master/chess.jpg)
Lines:
![lines](https://github.com/lurejewel/Identify-the-Go-Board/blob/master/lines.jpg)
intersections:
![intersections](https://github.com/lurejewel/Identify-the-Go-Board/blob/master/intercestions.jpg)

## Attentions & Shortcomings:
* Sensitive to noise; Low robustness. High image quality needed. Adjust the viariance of Gaussian Filter (sigma) according to the condition.
* Keep the lines as horizontal and vertical as posisble. Because the program assumes that the slope of lines are either ∞ or zero.
* Long time waiting before the result comes out.

May try using Corner Detection Method some day, which is also not easy to get good results according to a friend of mine. :( Some papers said using the two methods together would be fine (but I doubt it).
