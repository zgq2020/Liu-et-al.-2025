# Liu-et-al.-2025
Code used in Liu et al. (2025)
--------------------------------------------
This script modified from Chandel et al. (2024), to automatically track mosquito and calculate preference.

From https://github.com/Craig-Montell-Lab/Chandel_DeBeaubien_2023

Chandel, A., Debeaubien, N. A., Ganguly, A., Meyerhof, G. T., Krumholz, A. A., Liu, J., et al. （2024）. Thermal infrared directs host-seeking behaviour in Aedes aegypti mosquitoes. Nature, 633, 615-623.

--------------------------------------------
Usage Steps:
1. Open the IR_launch.m script.

   Replace the content within single quotes in YourPath = 'YourPath' with the directory where your script is located (line 2 of IR_lanch.m).

2. Place the '.mov' or '.mp4' video files in a folder named v.

   You can modify the code fileList = dir('*.mp4') to recognize different video types (line 25 of IR_lanuch.m).

3. Run the IR_launch.m script, and a window will pop up for you to select the directory, and just click to 'select folder'.
   
The code will continue to run automatically, and a window will prompt you to select the two zones.

The default configuration is to capture two zones (left and right) by selecting the left zone vertices in clockwise fashion starting at the top left, followed by the right zone in the same manner.

4. Generate the background model (ModeBackgroundModel2.m).
   
The code will continue to run, and a window will display the current background model. The command line window will prompt 'Do you want to modify the background model? (y/n):' to ask if you need to modify the background model.

If the generated background model meets your requirements, enter 'n' to skip the step of modifying the background model. 

Conversely, if 'y' is entered, the background model will be modified.

Background model modification steps:

- Hold down the left mouse button and drag to select the area to be modified.

- When the mouse cursor is in the selected area of the box, it will become a cross. Double-click the left mouse button.

- In the MATLAB command line window, enter the time point (in seconds) to replace the video, and press Enter.

- MATLAB will display the modified background image. If you need to continue modifying, input 'y' and repeat the first three steps; otherwise, input 'n' to exit the background modification.

5. Run display_data_save_video.m, which can visualize mosquito tracking and save the video.
   
Replace the content within single quotes in saveDir = 'Your save video path' with the directory where you want to save the video (line 22 of display_data_save_video.m). 

Alternatively, you can change the first line from 'true' to 'false' to not save the video.

6. The results obtained from video analysis are saved in the working 'masterData' structure and in '.mat' files under the video directory.

使用步骤：
1、打开IR_launch.m脚本

将YourPath = 'YourPath'单引号内容替换为你的脚本所在目录（IR_launch.m的2行）

2、将.mov或.mp4的视频文件放在名为v的文件夹中

可通过修改代码 fileList = dir('*.mp4')'，识别不同的视频类型(IR_launch.m的25行）

3、运行IR_launch.m脚本，弹出窗口让你选择目录，直接点选择即可

代码继续自动运行，弹出窗口让你选择两个区域(zone)的坐标，

默认配置是捕获两个区域（左和右），从左上角开始以顺时针方式选择左区域顶点，然后以相同的方式选择右区域。

4、生成背景模型（ModeBackgroundModel2.m)

代码继续运行，弹出窗口显示当前的背景模型，命令行窗口会弹出'Do you want to modify the background model? (y/n):'以提示你是否需要修改背景模型

如果生成的背景模型满足您的要求，请输入 'n' 跳过修改背景模型的步骤。

相反，如果输入 'y'，背景模型将被修改。

背景模型修改步骤：

1. 按住左键并拖动以选择要修改的区域。
   
2. 当鼠标光标位于选定区域的框内时，它将变为十字形。双击左键。
   
3. 在 MATLAB 命令行窗口中，输入要替换视频的时间点（以秒为单位），然后按 Enter。
   
4. MATLAB 将显示修改后的背景图像。如果需要继续修改，请输入 'y' 并重复步骤 1-3；否则，输入 'n' 以退出背景修改
   
5. 运行display_data_save_video.m，能够可视化蚊子追踪和保存视频

将saveDir = 'Your save video path'将单引号内容替换为你保存视频的目录（display_data_save_video.m的22行），

或者将第1行的‘true’修改为'false'则不保存视频

6. 视频分析所得的结果被保存在工作的'masterData'结构体及视频目录下的'.mat'文件
--------------------------------------------
Correlation parameter:

erode = 2 % The parameters of the white-and-black model are used for erosion operations in image processing to reduce the size of detected objects.

sens = 0.48 % A sensitivity parameter of the white-and-black model is used for image segmentation to control the threshold of binarization. 

MinimumBlobArea % Minimum Blob Area     

MaximumBlobArea % Maximum Blob Area

start_time_min = 0 % min, start time of the video

end_time_min = 1 % min, end time of the video

Thresh = meanIntensity * coeff % line 25 of extractForeground2.m, thresholds for video frames and background models

speedThresh % line 25 of assignDetection2.m, used to distinguish between moving objects and stationary objects in object tracking.

frame_id % line 2 of ModeBackgroundModel2.m, used to select video frame from a specified range or entire video

--------------------------------------------

You can uncomment lines 77-88 of IR_trax.m to visualize the effect of blob extraction.

If you want to save the video of blob extraction, you can uncomment lines 51, 52, 87, and 103 of IR_trax.m. 

However, it is worth noting that the visualized video displays the original video frames and the frames with identified blobs, which differs from the data in data. 

This is because data saves the information that meets the criteria of being greater than MinimumBlobArea and less than MaximumBlobArea.

--------------------------------------------
An example video can be found in our manuscript (Video S1).

Elimination of ultraviolet light-mediated attraction behavior in Culex quinquefasciatus via dsRNA-mediated knockdown of Opsins
