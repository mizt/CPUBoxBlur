#import <Foundation/Foundation.h>
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcomma"
#pragma clang diagnostic ignored "-Wunused-function"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#define STB_IMAGE_IMPLEMENTATION
#define STBI_ONLY_PNG
namespace stb_image {
	#import "./libs/stb_image.h"
	#import "./libs/stb_image_write.h"
}
#pragma clang diagnostic pop

#define RADIUS 32

namespace StopWatch {
	double _then = CFAbsoluteTimeGetCurrent();	
	void start() {
		_then = CFAbsoluteTimeGetCurrent();
	}
	void stop(bool isPrint=true) {
		double current = CFAbsoluteTimeGetCurrent();
		if(isPrint) NSLog(@"%f",current-_then);
	}
}

void toYX(unsigned int *dst,unsigned int *src,int w,int h,int begin,int end) {
	for(int i=begin; i<end; i++) {
		for(int j=0; j<w; j++) {
			dst[j*h+i] = src[i*w+j];
		}
	}
}

void toXY(unsigned int *dst,unsigned int *src,int w,int h,int begin,int end) {
	for(int j=begin; j<end; j++) {
		for(int i=0; i<h; i++) {
			dst[i*w+j] = src[j*h+i];
		}
	}
}

void blurX(unsigned int *dst,unsigned int *src,int w,int h,int begin,int end) {
	
	int radius = RADIUS;
	if(radius<=1) radius = 1; 
	
	double weight = 1.0/(double)(radius*2+1);
	
	for(int i=begin; i<end; i++) {
		
		int sr = 0;
		int sg = 0;
		int sb = 0;
		
		unsigned int *p = src+i*w;
		
		for(int k=-(radius+1); k<radius; k++) {
			
			int j2 = 0+k;
			if(j2<0) j2=0;
			else if(j2>=w-1) j2=w-1;
			
			unsigned int pixel = *(p+j2);
			
			sb+=(pixel>>16)&0xFF;
			sg+=(pixel>>8)&0xFF;
			sr+=(pixel)&0xFF;
		}
		
		unsigned int *q = dst+i;
		
		for(int j=0; j<w; j++) {
// sub
			int j2 = j-(radius+1);
			if(j2<0) j2=0;
			unsigned int pixel = *(p+j2);
			sb-=(pixel>>16)&0xFF;
			sg-=(pixel>>8)&0xFF;
			sr-=(pixel)&0xFF;
// add
			j2 = j+radius;
			if(j2>=w-1) j2=w-1;
			pixel = *(p+j2);
			sb+=(pixel>>16)&0xFF;
			sg+=(pixel>>8)&0xFF;
			sr+=(pixel)&0xFF;

			unsigned char r = sr*weight;
			unsigned char g = sg*weight;
			unsigned char b = sb*weight;
								
			*q = 0xFF000000|b<<16|g<<8|r;
			q+=h;
		}
	}
}

void blurY(unsigned int *dst,unsigned int *src,int w,int h,int begin,int end) {
	
	int radius = RADIUS;
	if(radius<=1) radius = 1; 
		
	double weight = 1.0/(double)(radius*2+1);
		
	for(int j=begin; j<end; j++) {
		
		int sr = 0;
		int sg = 0;
		int sb = 0;
		
		unsigned int *p = src+j*h;
		
		for(int k=-(radius+1); k<radius; k++) {
		
			int i2 = 0+k;
			if(i2<0) i2 = 0;
			else if(i2>=h-1) i2=h-1;
			
			unsigned int pixel = *(p+i2);
			sb+=(pixel>>16)&0xFF;
			sg+=(pixel>>8)&0xFF;
			sr+=(pixel)&0xFF;
		}
		
		unsigned int *q = dst+j;
		
		for(int i=0; i<h; i++) {
// sub
			int i2 = i-(radius+1);
			if(i2<0) i2 = 0;
			unsigned int pixel = *(p+i2);
			sb-=(pixel>>16)&0xFF;
			sg-=(pixel>>8)&0xFF;
			sr-=(pixel)&0xFF;
// add
			i2 = i+radius;
			if(i2>=h) i2 = h-1; 
			pixel = *(p+i2);
			sb+=(pixel>>16)&0xFF;
			sg+=(pixel>>8)&0xFF;
			sr+=(pixel)&0xFF;
						
			unsigned char r = sr*weight;
			unsigned char g = sg*weight;
			unsigned char b = sb*weight;
			
			*q = 0xFF000000|b<<16|g<<8|r;
			q+=w;
		}
	}
}

void blurX2(unsigned int *dst,unsigned int *src,unsigned int *buffer,int w,int h,int begin,int end) {
	
	int radius = RADIUS;
	if(radius<=1) radius = 1; 
	
	double weight = 1.0/(double)(radius*2+1);
	
	unsigned int sr = 0;
	unsigned int sg = 0;
	unsigned int sb = 0;
	
	unsigned int *buf = buffer;

	for(int i=begin; i<end; i++) {
		
		sr = sg = sb = 0;
		
		unsigned int *p = src+i*w;
		
		for(int k=-(radius+1); k<radius; k++) {
			
			int j2 = 0+k;
			if(j2<0) j2=0;
			else if(j2>=w-1) j2=w-1;
			
			unsigned int pixel = *(p+j2);
			
			sb+=(pixel>>16)&0xFF;
			sg+=(pixel>>8)&0xFF;
			sr+=(pixel)&0xFF;
		}
				
		for(int j=0; j<w; j++) {
// sub
			int j2 = j-(radius+1);
			if(j2<0) j2=0;
			unsigned int pixel = *(p+j2);
			sb-=(pixel>>16)&0xFF;
			sg-=(pixel>>8)&0xFF;
			sr-=(pixel)&0xFF;
// add
			j2 = j+radius;
			if(j2>=w-1) j2=w-1;
			pixel = *(p+j2);
			sb+=(pixel>>16)&0xFF;
			sg+=(pixel>>8)&0xFF;
			sr+=(pixel)&0xFF;

			unsigned char r = sr*weight;
			unsigned char g = sg*weight;
			unsigned char b = sb*weight;
								
			*buf++ = 0xFF000000|b<<16|g<<8|r;
		}
	}
	
	for(int i=begin; i<end; i++) {
		
		unsigned int *p = buffer+(i-begin)*w;
			
		sr = sg = sb = 0;
		
		for(int k=-(radius+1); k<radius; k++) {
			
			int j2 = 0+k;
			if(j2<0) j2=0;
			else if(j2>=w-1) j2=w-1;
			
			unsigned int pixel = *(p+j2);
			
			sb+=(pixel>>16)&0xFF;
			sg+=(pixel>>8)&0xFF;
			sr+=(pixel)&0xFF;
		}
		
		unsigned int *q = dst+i;
		
		for(int j=0; j<w; j++) {
// sub
			int j2 = j-(radius+1);
			if(j2<0) j2=0;
			unsigned int pixel = *(p+j2);
			sb-=(pixel>>16)&0xFF;
			sg-=(pixel>>8)&0xFF;
			sr-=(pixel)&0xFF;
// add
			j2 = j+radius;
			if(j2>=w-1) j2=w-1;
			pixel = *(p+j2);
			sb+=(pixel>>16)&0xFF;
			sg+=(pixel>>8)&0xFF;
			sr+=(pixel)&0xFF;

			unsigned char r = sr*weight;
			unsigned char g = sg*weight;
			unsigned char b = sb*weight;
								
			*q = 0xFF000000|b<<16|g<<8|r;
			q+=h;
		}
	}
}

void blurY2(unsigned int *dst,unsigned int *src,unsigned int *buffer,int w,int h,int begin,int end) {
	
	int radius = RADIUS;
	if(radius<=1) radius = 1; 
		
	double weight = 1.0/(double)(radius*2+1);
		
	unsigned int sr = 0;
	unsigned int sg = 0;
	unsigned int sb = 0;
	
	unsigned int *buf = buffer;

	for(int j=begin; j<end; j++) {
		
		sr = sg = sb = 0;
		
		unsigned int *p = src+j*h;
		
		for(int k=-(radius+1); k<radius; k++) {
		
			int i2 = 0+k;
			if(i2<0) i2 = 0;
			else if(i2>=h-1) i2=h-1;
			
			unsigned int pixel = *(p+i2);
			sb+=(pixel>>16)&0xFF;
			sg+=(pixel>>8)&0xFF;
			sr+=(pixel)&0xFF;
		}
		
		for(int i=0; i<h; i++) {
// sub
			int i2 = i-(radius+1);
			if(i2<0) i2 = 0;
			unsigned int pixel = *(p+i2);
			sb-=(pixel>>16)&0xFF;
			sg-=(pixel>>8)&0xFF;
			sr-=(pixel)&0xFF;
// add
			i2 = i+radius;
			if(i2>=h) i2 = h-1; 
			pixel = *(p+i2);
			sb+=(pixel>>16)&0xFF;
			sg+=(pixel>>8)&0xFF;
			sr+=(pixel)&0xFF;
						
			unsigned char r = sr*weight;
			unsigned char g = sg*weight;
			unsigned char b = sb*weight;
			
			*buf++ = 0xFF000000|b<<16|g<<8|r;
		}
	}
	
	for(int j=begin; j<end; j++) {
			
		sr = sg = sb = 0;
		
		unsigned int *p = buffer+(j-begin)*h;
		
		for(int k=-(radius+1); k<radius; k++) {
		
			int i2 = 0+k;
			if(i2<0) i2 = 0;
			else if(i2>=h-1) i2=h-1;
			
			unsigned int pixel = *(p+i2);
			sb+=(pixel>>16)&0xFF;
			sg+=(pixel>>8)&0xFF;
			sr+=(pixel)&0xFF;
		}
		
		unsigned int *q = dst+j;
		
		for(int i=0; i<h; i++) {
// sub
			int i2 = i-(radius+1);
			if(i2<0) i2 = 0;
			unsigned int pixel = *(p+i2);
			sb-=(pixel>>16)&0xFF;
			sg-=(pixel>>8)&0xFF;
			sr-=(pixel)&0xFF;
// add
			i2 = i+radius;
			if(i2>=h) i2 = h-1;
			pixel = *(p+i2);
			sb+=(pixel>>16)&0xFF;
			sg+=(pixel>>8)&0xFF;
			sr+=(pixel)&0xFF;

			unsigned char r = sr*weight;
			unsigned char g = sg*weight;
			unsigned char b = sb*weight;
			
			*q = 0xFF000000|b<<16|g<<8|r;
			q+=w;
		}
	}
}

void sumX(unsigned int *dst,unsigned int *src,unsigned int *rgb,int w,int h,int begin, int end) {
	
	int radius = RADIUS;
	if(radius<=1) radius = 1;

	for(int i=begin; i<end; i++) {

		unsigned int *sum = rgb;
		
		unsigned int sr = 0;
		unsigned int sg = 0;
		unsigned int sb = 0;
		
		unsigned int *p = src+i*w;
		
		for(int j=0; j<w; j++) {
			
			unsigned int pixel = *p++;
			
			unsigned char b = (pixel>>16)&0xFF;
			unsigned char g = (pixel>>8)&0xFF;
			unsigned char r = (pixel)&0xFF;
			
			sb+=b;
			sg+=g;
			sr+=r;
			
			*sum++=sb;
			*sum++=sg;
			*sum++=sr;
		}
		
		unsigned int *q = dst+i;
		
		for(int j=0; j<w; j++) {
		
			int left = j-radius;
			if(left<0) left = 0;
			
			int right = j+radius;
			if(right>=w) right = w-1;

			double weight = 1.0/(double)((right-left)+1);
			
			unsigned int *L = rgb+left*3;
			unsigned int *R = rgb+right*3;
			
			unsigned char b = ((*R++)-(*L++))*weight;
			unsigned char g = ((*R++)-(*L++))*weight;
			unsigned char r = ((*R)-(*L))*weight;
			
			*q = 0xFF000000|b<<16|g<<8|r;
			q+=h;
		}
	}
}

void sumY(unsigned int *dst,unsigned int *src,unsigned int *rgb,int w,int h,int begin, int end) {
	
	int radius = RADIUS;
	if(radius<=1) radius = 1;
	
	for(int j=begin; j<end; j++) {
		
		unsigned int *sum = rgb;
		
		unsigned int sr = 0;
		unsigned int sg = 0;
		unsigned int sb = 0;
		
		unsigned int *p = src+j*h;
		
		for(int i=0; i<h; i++) {
			
			unsigned int pixel = *p++;
			
			unsigned char b = (pixel>>16)&0xFF;
			unsigned char g = (pixel>>8)&0xFF;
			unsigned char r = (pixel)&0xFF;
			
			sb+=b;
			sg+=g;
			sr+=r;
			
			*sum++=sb;
			*sum++=sg;
			*sum++=sr;
		}
		
		unsigned int *q = dst+j;
		
		for(int i=0; i<h; i++) {
			
			int left = i-radius;
			if(left<0) left = 0;
			
			int right = i+radius;
			if(right>=h) right = h-1;

			double weight = 1.0/(double)((right-left)+1);
			
			unsigned int *L = rgb+left*3;
			unsigned int *R = rgb+right*3;
			
			unsigned char b = ((*R++)-(*L++))*weight;
			unsigned char g = ((*R++)-(*L++))*weight;
			unsigned char r = ((*R)-(*L))*weight;
			 			
			*q = 0xFF000000|b<<16|g<<8|r;
			q+=w;
		}
	}
}

void sumX2(unsigned int *dst,unsigned int *src,unsigned int *buffer,unsigned int *rgb,int w,int h,int begin, int end) {
	
	int radius = RADIUS;
	if(radius<=1) radius = 1;

	unsigned int *buf = buffer;
	
	for(int i=begin; i<end; i++) {
		
		unsigned int *sum = rgb;
		
		unsigned int sr = 0;
		unsigned int sg = 0;
		unsigned int sb = 0;
		
		unsigned int *p = src+i*w;
		
		for(int j=0; j<w; j++) {
			
			unsigned int pixel = *p++;
			
			unsigned char b = (pixel>>16)&0xFF;
			unsigned char g = (pixel>>8)&0xFF;
			unsigned char r = (pixel)&0xFF;
			
			sb+=b;
			sg+=g;
			sr+=r;
			
			*sum++=sb;
			*sum++=sg;
			*sum++=sr;
		}
		
		for(int j=0; j<w; j++) {
		
			int left = j-radius;
			if(left<0) left = 0;
			
			int right = j+radius;
			if(right>=w) right = w-1;

			double weight = 1.0/(double)((right-left)+1);
			
			unsigned int *L = rgb+left*3;
			unsigned int *R = rgb+right*3;
			
			unsigned char b = ((*R++)-(*L++))*weight;
			unsigned char g = ((*R++)-(*L++))*weight;
			unsigned char r = ((*R)-(*L))*weight;
			
			*buf++ = 0xFF000000|b<<16|g<<8|r;
		}
	}
	
	buf = buffer;
	
	for(int i=begin; i<end; i++) {

		unsigned int *sum = rgb;
		
		unsigned int sr = 0;
		unsigned int sg = 0;
		unsigned int sb = 0;
		
		for(int j=0; j<w; j++) {
			
			int i2 = i-begin;
			
			unsigned int pixel = *buf++;
			
			unsigned char b = (pixel>>16)&0xFF;
			unsigned char g = (pixel>>8)&0xFF;
			unsigned char r = (pixel)&0xFF;
			
			sb+=b;
			sg+=g;
			sr+=r;
			
			*sum++=sb;
			*sum++=sg;
			*sum++=sr;
		}
		
		unsigned int *q = dst+i;

		for(int j=0; j<w; j++) {
		
			int left = j-radius;
			if(left<0) left = 0;
			
			int right = j+radius;
			if(right>=w) right = w-1;

			double weight = 1.0/(double)((right-left)+1);
			
			unsigned int *L = rgb+left*3;
			unsigned int *R = rgb+right*3;
			
			unsigned char b = ((*R++)-(*L++))*weight;
			unsigned char g = ((*R++)-(*L++))*weight;
			unsigned char r = ((*R)-(*L))*weight;
			
			*q = 0xFF000000|b<<16|g<<8|r;
			q+=h;
		}
	}
}

void sumY2(unsigned int *dst,unsigned int *src,unsigned int *buffer,unsigned int *rgb,int w,int h,int begin, int end) {
	
	int radius = RADIUS;
	if(radius<=1) radius = 1;
	
	unsigned int *buf = buffer;
	
	for(int j=begin; j<end; j++) {
				
		unsigned int *sum = rgb;
		
		unsigned int sr = 0;
		unsigned int sg = 0;
		unsigned int sb = 0;
		
		unsigned int *p = src+j*h;
		
		for(int i=0; i<h; i++) {
			
			unsigned int pixel = *p++;
			
			unsigned char b = (pixel>>16)&0xFF;
			unsigned char g = (pixel>>8)&0xFF;
			unsigned char r = (pixel)&0xFF;
			
			sb+=b;
			sg+=g;
			sr+=r;
			
			*sum++=sb;
			*sum++=sg;
			*sum++=sr;
		}
		
		for(int i=0; i<h; i++) {
			
			int left = i-radius;
			if(left<0) left = 0;
			
			int right = i+radius;
			if(right>=h) right = h-1;

			double weight = 1.0/(double)((right-left)+1);
			
			unsigned int *L = rgb+left*3;
			unsigned int *R = rgb+right*3;
			
			unsigned char b = ((*R++)-(*L++))*weight;
			unsigned char g = ((*R++)-(*L++))*weight;
			unsigned char r = ((*R)-(*L))*weight;
			
			*buf++ = 0xFF000000|b<<16|g<<8|r;
		}
	}
	
	buf = buffer;
	
	for(int j=begin; j<end; j++) {
		
		int j2 = j-begin;
		
		unsigned int *sum = rgb;
		
		unsigned int sr = 0;
		unsigned int sg = 0;
		unsigned int sb = 0;
				
		for(int i=0; i<h; i++) {
			
			unsigned int pixel = *buf++;
			
			unsigned char b = (pixel>>16)&0xFF;
			unsigned char g = (pixel>>8)&0xFF;
			unsigned char r = (pixel)&0xFF;
			
			sb+=b;
			sg+=g;
			sr+=r;
			
			*sum++=sb;
			*sum++=sg;
			*sum++=sr;
		}
		
		unsigned int *q = dst+j;
		
		for(int i=0; i<h; i++) {
			
			int left = i-radius;
			if(left<0) left = 0;
			
			int right = i+radius;
			if(right>=h) right = h-1;

			double weight = 1.0/(double)((right-left)+1);
			
			unsigned int *L = rgb+left*3;
			unsigned int *R = rgb+right*3;
			
			unsigned char b = ((*R++)-(*L++))*weight;
			unsigned char g = ((*R++)-(*L++))*weight;
			unsigned char r = ((*R)-(*L))*weight;
			 			
			*q = 0xFF000000|b<<16|g<<8|r;
			q+=w;
		}
	}
}

int main(int argc, char *argv[]) {

	@autoreleasepool {
		
		int w;
		int h;
		int bpp;
		
		unsigned int *xy = (unsigned int *)stb_image::stbi_load("./images/test.png",&w,&h,&bpp,4);
		
		if(RADIUS==0) return 0;
		
		unsigned int *yx = new unsigned int[w*h];
		
		dispatch_group_t _group = dispatch_group_create();
		dispatch_queue_t _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0);
		
		// sysctl -n hw.ncpu
		NSUInteger processorCount = [[NSProcessInfo processInfo] processorCount];
		NSUInteger activeProcessorCount = [[NSProcessInfo processInfo] activeProcessorCount];

		NSLog(@"%d,%d",w,h);
		NSLog(@"%lu,%lu",processorCount,activeProcessorCount);
		
		int thread = activeProcessorCount; // >>1;
		
		NSLog(@"%d",thread);
		
		unsigned int **rgb = new unsigned int *[thread];

		for(int k=0; k<thread; k++) {
			rgb[k] = new unsigned int[(w>h)?w*3:h*3];
		}
		
		unsigned int **buffer = new unsigned int *[thread];
		
		for(int k=0; k<thread; k++) {
			buffer[k] = new unsigned int[(int)(ceil((w*h)/(double)thread))];
		}
		
		if(xy) {
	
			int col = h/thread;
			
StopWatch::start();
		
			for(int k=0; k<thread; k++) {
				
				if(k==thread-1) {
					dispatch_group_async(_group,_queue,^{
						//toYX(yx,xy,w,h,col*k,h);
						//blurX(yx,xy,w,h,col*k,h);
						blurX2(yx,xy,buffer[k],w,h,col*k,h);
						//sumX(yx,xy,rgb[k],w,h,col*k,h);
						//sumX2(yx,xy,buffer[k],rgb[k],w,h,col*k,h);
					});
				}
				else {
					dispatch_group_async(_group,_queue,^{
						//toYX(yx,xy,w,h,col*k,col*(k+1));
						//blurX(yx,xy,w,h,col*k,col*(k+1));
						blurX2(yx,xy,buffer[k],w,h,col*k,col*(k+1));
						//sumX(yx,xy,rgb[k],w,h,col*k,col*(k+1));
						//sumX2(yx,xy,buffer[k],rgb[k],w,h,col*k,col*(k+1));
					});
				}
			}
			
			dispatch_group_wait(_group,DISPATCH_TIME_FOREVER);

			// stb_image::stbi_write_png("./yx.png",h,w,4,(void const*)yx,h<<2);
			
			int row = w/thread;
		
			for(int k=0; k<thread; k++) {
				
				if(k==thread-1) {
					dispatch_group_async(_group,_queue,^{
						//toXY(xy,yx,w,h,row*k,w);
						//blurY(xy,yx,w,h,row*k,w);
						blurY2(xy,yx,buffer[k],w,h,row*k,w);
						//sumY(xy,yx,rgb[k],w,h,row*k,w);
						//sumY2(xy,yx,buffer[k],rgb[k],w,h,row*k,w);
					});
				}
				else {
					dispatch_group_async(_group,_queue,^{
						//toXY(xy,yx,w,h,row*k,row*(k+1));
						//blurY(xy,yx,w,h,row*k,row*(k+1));
						blurY2(xy,yx,buffer[k],w,h,row*k,row*(k+1));
						//sumY(xy,yx,rgb[k],w,h,row*k,row*(k+1));
						//sumY2(xy,yx,buffer[k],rgb[k],w,h,row*k,row*(k+1));
					});
				}
				
			}
			dispatch_group_wait(_group,DISPATCH_TIME_FOREVER);
		}

StopWatch::stop();
		
		stb_image::stbi_write_png("./blur.png",w,h,4,(void const*)xy,w<<2);
		
		for(int k=0; k<thread; k++) {
			delete[] rgb[k];
		}
		
		for(int k=0; k<thread; k++) {
			delete[] buffer[k];
		}
		
		delete[] yx;
		delete[] xy;
	}
}