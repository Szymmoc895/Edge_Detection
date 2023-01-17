using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Imaging;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Edge_Detection
{
    public partial class Form1 : Form
    {

        Image pic; //the first image, which the user loads
        Image pic2; //the second image, which displays the edges
        Stopwatch clock;
        public Form1()
        {
            InitializeComponent();
        }

        private void trackBar1_Scroll(object sender, EventArgs e)
        {

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
            Bitmap bmp = new Bitmap(pictureBox1.Image);
            pic2 = SobelEdgeDetect(bmp);
            pictureBox2.Image = pic2;
            clock.Stop();
            float time = clock.ElapsedMilliseconds;
            label3.Text = "Analyze: " + time / 1000 + " sec";
        }

        private Bitmap SobelEdgeDetect(Bitmap original)
        {
            Bitmap b = original;
            Bitmap bb = original;
            int width = b.Width;
            int height = b.Height;
            int[,] gx = new int[,] { { -1, 0, 1 }, { -2, 0, 2 }, { -1, 0, 1 } };
            int[,] gy = new int[,] { { 1, 2, 1 }, { 0, 0, 0 }, { -1, -2, -1 } };

            int[,] allPixR = new int[width, height];
            int[,] allPixG = new int[width, height];
            int[,] allPixB = new int[width, height];

            int limit = 64 * 64;

            for (int i = 0; i < width; i++)
            {
                for (int j = 0; j < height; j++)
                {
                    allPixR[i, j] = b.GetPixel(i, j).R;
                    allPixG[i, j] = b.GetPixel(i, j).G;
                    allPixB[i, j] = b.GetPixel(i, j).B;
                }
            }

            int new_rx = 0, new_ry = 0;
            int new_gx = 0, new_gy = 0;
            int new_bx = 0, new_by = 0;
            int rc, gc, bc;
            for (int i = 1; i < b.Width - 1; i++)
            {
                for (int j = 1; j < b.Height - 1; j++)
                {

                    new_rx = 0;
                    new_ry = 0;
                    new_gx = 0;
                    new_gy = 0;
                    new_bx = 0;
                    new_by = 0;
                    rc = 0;
                    gc = 0;
                    bc = 0;

                    for (int wi = -1; wi < 2; wi++)
                    {
                        for (int hw = -1; hw < 2; hw++)
                        {
                            rc = allPixR[i + hw, j + wi];
                            new_rx += gx[wi + 1, hw + 1] * rc;
                            new_ry += gy[wi + 1, hw + 1] * rc;

                            gc = allPixG[i + hw, j + wi];
                            new_gx += gx[wi + 1, hw + 1] * gc;
                            new_gy += gy[wi + 1, hw + 1] * gc;

                            bc = allPixB[i + hw, j + wi];
                            new_bx += gx[wi + 1, hw + 1] * bc;
                            new_by += gy[wi + 1, hw + 1] * bc;
                        }
                    }
                    if (new_rx * new_rx + new_ry * new_ry > limit || new_gx * new_gx + new_gy * new_gy > limit || new_bx * new_bx + new_by * new_by > limit)
                        bb.SetPixel(i, j, Color.Black);


                    else
                        bb.SetPixel(i, j, Color.Transparent);
                }
            }
            return bb;
        }

    }
}