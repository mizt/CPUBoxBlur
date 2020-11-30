# CPUBoxBlur

![](./images/test.png)
[laser height_test](https://vimeo.com/93992919)  
1920×1080 px

	MacBook Air (M1, 2020)
	Chip: M1
	Memory: 16GB

vs.

	MacBook Air (Retina, 13-inch, 2019)
	Processor: 1.6GHz Dual Intel Core i5
	Memory: 8GB 2133 MHz LPDDR3
	Graphics: Intel UHD Graphics 617 1536MB


### Build

`clang++ -std=c++17 -Wc++17-extensions -fobjc-arc -O3 -framework Cocoa ./main.mm -o ./main`

### Parameter

Radius is 32 px  
Increasing the radius does not change the process speed.

### result

##### blur  

M1: 0.003sec  
Intel: 0.015sec

![](./images/blur.png)

##### sum  

M1: 0.004sec  
Intel: 0.018sec

![](./images/blur.png)

##### Photoshop 2020 (Box Blur)

![](./images/photoshop-box-blur.png)

##### blur2

M1: 0.005sec  
Intel: 0.03sec

![](./images/blur2.png)

##### sum2   

M1: 0.007sec  
Intel: 0.035sec

![](./images/blur2.png)

##### Photoshop 2020 (Gaussian Blur)

![](./images/photoshop-gaussian-blur.png)

