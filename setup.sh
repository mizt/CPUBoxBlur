dir=$(cd $(dirname $0)&&pwd)
cd $dir

curl "https://raw.githubusercontent.com/nothings/stb/master/stb_image.h" > "./libs/stb_image.h"
curl "https://raw.githubusercontent.com/nothings/stb/master/stb_image_write.h" > "./libs/stb_image_write.h"
