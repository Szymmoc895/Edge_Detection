using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Edge_Detection
{
    internal static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [DllImport(@"C:\Users\szymk\source\repos\Edge_Detection\x64\Debug\Asm.dll")]
        static extern int MyProc1(int a, int b);
        [STAThread]
        static void Main()
        {
            int x = 5, y = 3;
            int retVal = MyProc1(x, y);
            Console.Write("Moja pierwsza wartość obliczona w asm to:");
            Console.WriteLine(retVal);
            Console.ReadLine();
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new Form1());
        }
    }
}
