using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Numerics;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Forms;
using System.Windows.Media.Imaging;
using System.Xml.Linq;
using PixelFormat = System.Windows.Media.PixelFormat;
namespace Edge_Detection
{
    public partial class Form1 : Form
    {

        Image pic; //the first image, which the user loads
        Image pic2; //the second image, which displays the edges
        Stopwatch clock;
        Bitmap bmp;


        int[,] xkernell = xSobel;
        int[,] ykernell = ySobel;

        public Action<byte[], byte[], int, int, Vector2> FuncToCall { get; set; }

       
        public List<Task> threads = new List<Task>();
        public Form1()
        {
            int threadsNumber = Environment.ProcessorCount;
            InitializeComponent();
            trackBar1.Value = threadsNumber;
            label1.Text = "Threads used: " + trackBar1.Value.ToString();
            radioButton1.Checked = true;
        }

        private void trackBar1_Scroll(object sender, EventArgs e)
        {
            label1.Text = "Threads used: " + trackBar1.Value.ToString();
        }

        private void button1_Click(object sender, EventArgs e)
        {

            OpenFileDialog openFileDialog1 = new OpenFileDialog();
            openFileDialog1.Filter = "Image Files (*.jpeg;*.jpg;*.png;*.gif)|(*.jpeg;*.jpg;*.png;*.gif|JPEG Files (*.jpeg)|*.jpeg|PNG Files (*.png)|*.png|JPG Files (*.jpg)|*.jpg|GIF Files (*.gif)|*.gif";
            if (openFileDialog1.ShowDialog() == DialogResult.OK)
            {
                pic = new Bitmap(openFileDialog1.FileName);
                pic2 = new Bitmap(pic.Width, pic.Height);
                pictureBox2.SizeMode = PictureBoxSizeMode.Zoom;
                pictureBox1.SizeMode = PictureBoxSizeMode.Zoom;
                pictureBox2.Image = pic2;
                pictureBox1.Image = pic;
            }
        }

        private void button3_Click(object sender, EventArgs e)
        {
            clock = Stopwatch.StartNew();
            bmp = new Bitmap(pictureBox1.Image);
            int threads = trackBar1.Value;
            Bitmap bmp2 = new Bitmap(ConvolutionFilter(bmp, threads, radioButton1, radioButton2, xSobel, ySobel));
            pictureBox2.Image = bmp2;
            clock.Stop();
            float time = clock.ElapsedMilliseconds;
            label3.Text = "Analyze: " + time / 1000 + " sec";
            bmp.Dispose();
            //bmp2.Dispose();
        }

        public static BitmapSource BitmapToBitmapSource(System.Drawing.Bitmap source)
        {
            using (MemoryStream memory = new MemoryStream())
            {
                source.Save(memory, ImageFormat.Png);
                memory.Position = 0;
                BitmapImage bitmapImage = new BitmapImage();
                bitmapImage.BeginInit();
                bitmapImage.StreamSource = memory;
                bitmapImage.CacheOption = BitmapCacheOption.OnLoad;
                bitmapImage.EndInit();
                return bitmapImage;
            }
        }

        private static byte[] greyScaleGood(byte[] pixelBuffer)
        {
            float rgb = 0;
            for (int i = 0; i < pixelBuffer.Length; i += 4)
            {
                rgb = pixelBuffer[i] * .21f;
                rgb += pixelBuffer[i + 1] * .71f;
                rgb += pixelBuffer[i + 2] * .071f;
                pixelBuffer[i] = (byte)rgb;
                pixelBuffer[i + 1] = pixelBuffer[i];
                pixelBuffer[i + 2] = pixelBuffer[i];
                pixelBuffer[i + 3] = 255;
            }
            return pixelBuffer;
        }

        public static Bitmap ConvolutionFilter(Bitmap sourceImage, int numberOfThreads, RadioButton r1, RadioButton r2,
  int[,] xkernel,
  int[,] ykernel, double factor = 1, int bias = 0, bool grayscale = true)
        {

            //Image dimensions stored in variables for convenience
            int width = sourceImage.Width;
            int height = sourceImage.Height;

            BitmapSource btm = BitmapToBitmapSource(sourceImage);

            //Lock source image bits into system memory
            BitmapData srcData = sourceImage.LockBits(new Rectangle(0, 0, width, height), ImageLockMode.ReadOnly, sourceImage.PixelFormat);

            //Get the total number of bytes in your image - 32 bytes per pixel x image width x image height -> for 32bpp images
            int bytes = srcData.Stride * srcData.Height;

            //Create byte arrays to hold pixel information of your image
            byte[] pixelBuffer = new byte[bytes];
            byte[] resultBuffer = new byte[bytes];

            //Get the address of the first pixel data
            IntPtr srcScan0 = srcData.Scan0;

            //Copy image data to one of the byte arrays
            Marshal.Copy(srcScan0, pixelBuffer, 0, bytes);

            //Unlock bits from system memory -> we have all our needed info in the array
            sourceImage.UnlockBits(srcData);
            //Convert your image to grayscale if necessary
            if (grayscale == true)
            {
                pixelBuffer = greyScaleGood(pixelBuffer);
            }

            //Create variable for pixel data for each kernel
            double xr = 0.0;
            double xg = 0.0;
            double xb = 0.0;
            double yr = 0.0;
            double yg = 0.0;
            double yb = 0.0;
            double rt = 0.0;
            double gt = 0.0;
            double bt = 0.0;

            //This is how much your center pixel is offset from the border of your kernel
            //Sobel is 3x3, so center is 1 pixel from the kernel border
            int filterOffset = 1;
            int calcOffset = 0;
            int byteOffset = 0;

            //Calculate Start and End positions using numberOfThreads

            int pieceLength = height / numberOfThreads;
            while (pieceLength % (btm.Format.BitsPerPixel / 8) != 0)
                pieceLength++;
            int startPos = 0;
            int endPos = 0;

            List<Task> watki = new List<Task>();

            var calcBar = height / numberOfThreads;
            var remainder = height % numberOfThreads;

            int jeden = 1;
            int stopp = height - 1;
            float row_size = width;

            float startPos1 = 1;
            float endPos1 = height - 1;

            var calcBarPerTask = Enumerable.Repeat(calcBar, numberOfThreads).ToList();

            for (int i = remainder; i > 0; i--)
                calcBarPerTask[i]++;

                for (int threadNumber = 0; threadNumber < numberOfThreads; threadNumber++)
                {
                    var tidx = threadNumber;
                    var startHeight = calcBarPerTask.Take(tidx).Sum();
                    var endHeight = startHeight + calcBarPerTask[tidx];

                    watki.Add(Task.Run(() => SobelAlg(pixelBuffer, resultBuffer, srcData, width,
                        tidx == 0 ? startHeight + 1 : startHeight, tidx == threadNumber - 1 ? endHeight - 1 : endHeight, r1, r2)));

                }

            Task.WaitAll(watki.ToArray());


            //Create new bitmap which will hold the processed data
            Bitmap resultImage = new Bitmap(width, height);

            //Lock bits into system memory
            BitmapData resultData = resultImage.LockBits(new Rectangle(0, 0, width, height), ImageLockMode.WriteOnly, sourceImage.PixelFormat);

            //Copy from byte array that holds processed data to bitmap
            Marshal.Copy(resultBuffer, 0, resultData.Scan0, resultBuffer.Length);

            //Unlock bits from system memory
            resultImage.UnlockBits(resultData);

            //Return processed image
            return resultImage;

            srcData= null;
        }

        static float[] xKernel = new float[] { -1, 0, 1, -2, 0, 2, -1, 0, 1 };

        static float[] yKernel = new float[] { 1, 2, 1, 0, 0, 0, -1, -2, -1 };


        [DllImport(@"C:\Users\szymk\source\repos\Edge_Detection\x64\Debug\Asm.dll")]
        static extern void fnSobelFilter(byte[] pixelBuffer, int[] outValues, float[] xKernel, float[] yKernel, Vector2 v);

        private static void SobelAlg(byte[] pixelBuffer, byte[] resultBuffer, BitmapData srcData,
            int width, int startPos, int endPos, RadioButton r1, RadioButton r2)
        {
            int xr = 0;
            int xg = 0;
            int xb = 0;
            int yr = 0;
            int yg = 0;
            int yb = 0;
            double rt = 0;
            double gt = 0;
            double bt = 0;
            int filterOffset = 1;
            //width = 4 * width;
            int[,] xkernelll = xSobel;
            int[,] ykernelll = ySobel;

            for (int OffsetY = startPos; OffsetY < endPos; OffsetY++)
            {
                for (int OffsetX = filterOffset; OffsetX < width - filterOffset; OffsetX++)
                {
                    //reset rgb values to 0
                    xr = xg = xb = yr = yg = yb = 0;
                    rt = gt = bt = 0.0;

                    //position of the kernel center pixel
                    int byteOffset = OffsetY * srcData.Stride + OffsetX * 4;
                    //5396 stride
                    //5400 byteOffset
                    int calcOffset = 0;

                    if (r1.Checked == false)
                    {
                        int[] outValues = new int[6];
                        fnSobelFilter(pixelBuffer, outValues, xKernel, yKernel, new Vector2((float)srcData.Stride, (float)byteOffset));
                        xb = outValues[0];
                        xg = outValues[1];
                        xr = outValues[2];

                        yb = outValues[3];
                        yg = outValues[4];
                        yr = outValues[5];
                    }
                    else
                    {
                        //kernel calculations

                        for (int filterY = -filterOffset; filterY <= filterOffset; filterY++)
                        {
                            for (int filterX = -filterOffset; filterX <= filterOffset; filterX++)
                            {
                                calcOffset = byteOffset + filterX * 4 + filterY * srcData.Stride; //0
                                xb += (pixelBuffer[calcOffset]) * xkernelll[filterY + filterOffset, filterX + filterOffset];
                                xg += (pixelBuffer[calcOffset + 1]) * xkernelll[filterY + filterOffset, filterX + filterOffset];
                                xr += (pixelBuffer[calcOffset + 2]) * xkernelll[filterY + filterOffset, filterX + filterOffset];
                                yb += (pixelBuffer[calcOffset]) * ykernelll[filterY + filterOffset, filterX + filterOffset];
                                yg += (pixelBuffer[calcOffset + 1]) * ykernelll[filterY + filterOffset, filterX + filterOffset];
                                yr += (pixelBuffer[calcOffset + 2]) * ykernelll[filterY + filterOffset, filterX + filterOffset];
                            }
                        }
                    }

                    //total rgb values for this pixel
                    bt = Math.Sqrt((xb * xb) + (yb * yb));
                    gt = Math.Sqrt((xg * xg) + (yg * yg));
                    rt = Math.Sqrt((xr * xr) + (yr * yr));

                    //set limits, bytes can hold values from 0 up to 255;
                    if (bt > 255) bt = 255;
                    else if (bt < 0) bt = 0;
                    if (gt > 255) gt = 255;
                    else if (gt < 0) gt = 0;
                    if (rt > 255) rt = 255;
                    else if (rt < 0) rt = 0;

                    //set new data in the other byte array for your image data
                    resultBuffer[byteOffset] = (byte)(bt);
                    resultBuffer[byteOffset + 1] = (byte)(gt);
                    resultBuffer[byteOffset + 2] = (byte)(rt);
                    resultBuffer[byteOffset + 3] = 255;
                }
            }
        }

        //Sobel operator kernel for horizontal pixel changes
        private static int[,] xSobel
        {
            get
            {
                return new int[,]
                {
            { -1, 0, 1 },
            { -2, 0, 2 },
            { -1, 0, 1 }
                };
            }
        }

        //Sobel operator kernel for vertical pixel changes
        private static int[,] ySobel
        {
            get
            {
                return new int[,]
                {
            {  1,  2,  1 },
            {  0,  0,  0 },
            { -1, -2, -1 }
                };
            }
        }
    }
}