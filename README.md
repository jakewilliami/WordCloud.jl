# WordCloud
wordcloud in Julia
---
![wordcloud](res/guxiang.png)

* [x] 排序 & 预放置
* [x] 基于四叉树碰撞检测
* [x] 根据局部灰度梯度位置调整（训练迭代）
* [x] 引入动量加速训练
* [x] 分代调整以优化性能
* [x] 控制字体大小和填充密度的策略
* [ ] 重新放置、旋转和缩放的策略
* [x] 文字颜色和方向
* [ ] 并行计算

# 训练过程
![training](res/training.gif)
***
linux添加中文字体  
> mv wqy-microhei.ttc ~/.fonts  
> fc-cache -vf  

配置ffmpeg环境
> add /mnt/lustre/share/ffmpeg-4.2.1/lib to ENV["LD_LIBRARY_PATH"]  
> add /mnt/lustre/share/ffmpeg-4.2.1/bin to ENV["PATH"]  