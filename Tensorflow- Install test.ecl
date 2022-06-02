/* 
    Learning Outcome: 
        Try EMBED function in ECL
        Try Python3 call 
        Use TensorFlow library via Python3 EMBED
        Print an output from TensorFlow 

 import tensorflow as tf;
    tfVersion = tf.__version__;*/
IMPORT Python3 as Python;

INTEGER tfInstallTest := EMBED(Python)
   
    XDATA = 121;
    return XDATA;
ENDEMBED;

// Invoke EMBED
tfInstallTest;