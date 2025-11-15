PImage img;
PImage sortedImg;

ArrayList<int[]> processImgsPixels = new ArrayList();
int imageCounter = 0;
int processImgsSize = 0;

float fps = 10;
int mergeCounterMax = 300;
int mergeCounter = 0;

void setup() {
  size(800, 600);
  frameRate(120);
  background(255);
  smooth();
  
  img = loadImage("cat.jpg");
  sortedImg = createImage(img.width, img.height, RGB);
  sortedImg = img.get();
  //sortedImg.loadPixels();
  
  windowResize(img.width * 2, img.height);

  println("starting reverse mergesort");
  int mergesortTime = millis() / 1000;
  
  mergesort(sortedImg.pixels, 0, sortedImg.pixels.length - 1); //-------- mergesort start
  
  mergesortTime = (millis() / 1000) - mergesortTime;
  println("reverse mergesort done in " + mergesortTime + " seconds!");
  
  snapshotImage(sortedImg.pixels, true);
  processImgsSize = processImgsPixels.size();
}

void mergesort(int[] a, int left, int right) {
  if (left < right) {
    int middle = (left + right) / 2;
    mergesort(a, left, middle);
    mergesort(a, middle + 1, right);
    mergeTogether(a, left, middle, right);
    
    snapshotImage(a, false);
  } //<>//
}

void mergeTogether(int[] a, int left, int middle, int right) {
  int[] sortedArray = new int[right + 1];

  reverseArray(a, middle + 1, right);

  int iL = left;
  int iR = right;

  for (int i = left; i <= right; i++) {

    if (compareBright(a[iL], a[iR]) <= 0) { //------------------------------------ hier ist compare
      sortedArray[i] = a[iL];
      iL++;
    } else {
      sortedArray[i] = a[iR];
      iR--;
    }
  }

  for (int i = left; i <= right; i ++) {
    a[i] = sortedArray[i];
  }
}

void reverseArray(int[] numbers, int from, int to) {
  int left = from;
  int right = to;

  while (left < right) {
    int tmp = numbers[left];
    numbers[left] = numbers[right];
    numbers[right] = tmp;

    left++;
    right--;
  }
}

void snapshotImage(int[] a, boolean isLastImg) {
      if (mergeCounter > mergeCounterMax || isLastImg) {
      mergeCounter = 0;
      processImgsPixels.add(a.clone());
    }
    
    mergeCounter++;
}
  

int compareBright(int a, int b) {
  float brightnessA = brightness(a);
  float brightnessB = brightness(b);

  if (brightnessA > brightnessB) {
    return 1;
  } else if (brightnessA < brightnessB) {
    return -1;
  }
  return 0;
}

int compareHue(int a, int b) {
  float hueA = hue(color(a));
  float hueB = hue(color(b));

  if (hueA > hueB) {
    return 1;
  } else if (hueA < hueB) {
    return -1;
  }
  return 0;
}

int compareSat(int a, int b) {
  float satA = saturation(color(a));
  float satB = saturation(color(b));

  if (satA > satB) {
    return 1;
  } else if (satA < satB) {
    return -1;
  }
  return 0;
}

int compareRed(int a, int b) {
  float r1 = red(a);
  float r2 = red(b);

  if (r1 > r2) {
    return 1;
  } else if (r1 < r2) {
    return -1;
  }
  return 0;
}

int compareGreen(int a, int b) {
  float g1 = green(a);
  float g2 = green(b);

  if (g1 > g2) {
    return 1;
  } else if (g1 < g2) {
    return -1;
  }
  return 0;
}

int compareBlue(int a, int b) {
  float b1 = blue(a);
  float b2 = blue(b);

  if (b1 > b2) {
    return 1;
  } else if (b1 < b2) {
    return -1;
  }
  return 0;
}

void draw() {
  
  if (imageCounter >= processImgsSize - 1) {
    imageCounter = processImgsSize - 1;
  }
  
  PImage img2 = createImage(img.width, img.height, RGB);
  img2.pixels = processImgsPixels.get(imageCounter);
  imageCounter ++;

  image(img, 0, 0);
  image(img2, img.width, 0);
}
