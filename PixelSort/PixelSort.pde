PImage img;
PImage sortedImg;

boolean isAnimationEnabled = true;
int sortCriteria = 0;                     //sortCriteria: 0 brightness, 1 HUE, 2 saturation, 3 red value, 4 blue value, 5 green value
int sortingAlgorithm = 0;                 //sortingAlgorithm: 0 mergeSort (reverse), 1 dictatorSort, 2 binary insertion sort
String imageName = "butterfly.jpg";             //imageSizes: test5=5x5, test=10x10, bee=200x200, catS=300x300, fish=500x500, cat=600x600, foxS=600x600, flowers=800x800, butterfly=800x1200, frog=800x1200, fox=1300x1300, kingfisher= 2200x2200

ArrayList<int[]> processImgsPixels = new ArrayList();
int imageCounter = 0;
int processImgsSize = 0;

float fpsAnimation = 30;
float fps = 1;

int snapshotEachIteration = -1; //should be adjusted, if 0 defaults to width+height/2
int frameCounter = 0;

void setup() {
  size(800, 600);
  frameRate(fps);
  background(255);
  smooth();
  
  if (isAnimationEnabled) {
    frameRate(fpsAnimation);
  }
  
  img = loadImage(imageName);
  sortedImg = createImage(img.width, img.height, RGB);
  sortedImg = img.get();
  
  if (snapshotEachIteration <= 0) snapshotEachIteration = (img.width + img.height) / 2 + 100;
  
  windowResize(img.width * 2, img.height);
  
  //------------------------------------------------------------------------------------------------------------------------
  
  println("starting sorting algorithm: " + sortingAlgorithm);
  float sortTime = millis() / 1000f;
  
  
  switch (sortingAlgorithm) {
  case 0: 
    mergesort(sortedImg.pixels, 0, sortedImg.pixels.length - 1);
    break;
  case 1:
    dictatorSort(sortedImg.pixels);
    break;
  case 2:
    binaryInsertionSort(sortedImg.pixels);
    break;
  default:
    mergesort(sortedImg.pixels, 0, sortedImg.pixels.length - 1);
    break;
  }
  
  sortTime = (millis() / 1000f) - sortTime;
  println("done in " + sortTime + " seconds!");
  confirmSort(sortedImg.pixels);

  if (isAnimationEnabled) {
    snapshotImage(sortedImg.pixels, true);
    processImgsSize = processImgsPixels.size();
  }
}

//merge sort
void mergesort(int[] a, int left, int right) {
  if (left < right) {
    int middle = (left + right) / 2;
    mergesort(a, left, middle);
    mergesort(a, middle + 1, right);
    mergeTogether(a, left, middle, right);
    
    if (isAnimationEnabled) {
      snapshotImage(a, false);
    }
  }
}

void mergeTogether(int[] a, int left, int middle, int right) {
  int[] sortedArray = new int[right + 1];

  reverseArray(a, middle + 1, right);

  int iL = left;
  int iR = right;

  for (int i = left; i <= right; i++) {

    if (comparePixel(a[iL], a[iR], sortCriteria) <= 0) {
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

//Dictator Sort
void dictatorSort(int[] a) {
  int lastBestPixel = a[0];
  
  for (int i = 1; i < a.length; i++) {
    if (comparePixel(lastBestPixel, a[i], sortCriteria) == 1) {
      a[i] = 0; //= lastBestPixel;
    }
    else {
      lastBestPixel = a[i];
    }
    snapshotImage(a, false);
  }
  snapshotImage(a, true);
}

//binary insertion sort
void binaryInsertionSort(int[] a) {
  ArrayList<Integer> b = new ArrayList<>();
  int[] snapshotBackgr = a.clone();
  b.add(a[0]);
  
  for (int i = 1; i < a.length; i++) {
    int closeValueIndex = binarySearch(toArray(b), 0, b.size() - 1, a[i]);
    
    if (comparePixel(a[i], b.get(closeValueIndex), sortCriteria) < 0) {
      b.add(closeValueIndex, a[i]);
    } else {
      b.add(closeValueIndex + 1, a[i]);
    }
    
    if(isAnimationEnabled) {
      int[] progress = toArray(b); //<>// //<>//
      for (int k = 0; k < progress.length; k++) { //<>//
          snapshotBackgr[k] = progress[k]; //<>//
      }
      snapshotImage(snapshotBackgr, false);
    }
  }
    
  int[] result = toArray(b);
  for (int i = 0; i < a.length; i++) {
    a[i] = result[i];
  }
  snapshotImage(a, true);
}

int[] toArray(ArrayList<Integer> arrList) {
  int[] a = new int[arrList.size()];
  for(int i = 0; i < a.length; i++) {
    a[i] = arrList.get(i);
  }
  return a;
}

int binarySearch(int[] b, int low, int high, int value) {
  int middle = low + (high - low) / 2;

  if (comparePixel(value, b[middle], sortCriteria) == -1) {
    if (middle == low) return middle;
    
    return binarySearch(b, low, middle - 1, value);
  }
  else if (comparePixel(value, b[middle], sortCriteria) == 1) {
    if (middle == high) return middle;

    return binarySearch(b, middle + 1, high, value);
  }
  
  return middle;
}

int comparePixel(int a, int b, int sortCriteria) { //<>//
  switch (sortCriteria) {
  case 0: 
    return compareBright(a, b);
  case 1:
    return compareHue(a, b);
  case 2:
    return compareSat(a, b);
  case 3:
    return compareRed(a, b);
  case 4:
    return compareGreen(a, b);
  case 5:
    return compareBlue(a, b);
  default:
      return compareBright(a, b);
  }
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

void snapshotImage(int[] a, boolean isLastImg) {
    if (frameCounter > snapshotEachIteration || isLastImg) {
      frameCounter = 0;
      processImgsPixels.add(a.clone());
    }
    
    frameCounter++;
}

void confirmSort(int[] a) {
  int[] arrayToConfirm;
  int[] dictSortArr;
  
  if (sortingAlgorithm == 1) {
    ArrayList<Integer> dsAL = new ArrayList<>();
    for (int i = 0; i < a.length; i++) {
      if (a[i] != 0) dsAL.add(a[i]);
    }
    dictSortArr = toArray(dsAL);
    arrayToConfirm = dictSortArr;
    
  } else {
    arrayToConfirm = a.clone();
  }
  
  int positives = 0;
  int negatives = 0;
  
  for (int i = 0; i <  arrayToConfirm.length - 1; i++) {
    int res = comparePixel(arrayToConfirm[i], arrayToConfirm[i + 1], sortCriteria);
    
    if (res == 1) {
      positives++;
    } else if (res == -1) {
      negatives++;
    } else {
      positives++;
      negatives++;
    }
  }
  
  if (positives == (arrayToConfirm.length - 1) || negatives == (arrayToConfirm.length - 1)) {
    println("sort success!");
  } else {
    if (positives > negatives) println("sort failed with estimated " + ((arrayToConfirm.length - 1) - positives) + " wrong pixels!");
    if (negatives >= positives) println("sort failed with estimated " + ((arrayToConfirm.length - 1) - negatives) + " wrong pixels!");
  }
}

void draw() {
  
  if (isAnimationEnabled) {
    if (imageCounter >= processImgsSize - 1) {
      imageCounter = processImgsSize - 1;
      frameRate(1);
      save("output.png");
    }
    
    PImage img2 = createImage(img.width, img.height, RGB);
    img2.pixels = processImgsPixels.get(imageCounter);
    imageCounter ++;
  
    image(img, 0, 0);
    image(img2, img.width, 0);
  }
  else {
    image(img, 0, 0);
    image(sortedImg, img.width, 0);
    save("output.png");
  }
}
