using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Edge_Detection
{
    public partial class Form1 : Form
    {

        Image pic; //the first image, which the user loads
        Image pic2; //the second image, which displays the edges
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
    }
}