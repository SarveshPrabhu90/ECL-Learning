/* 
    Learning Outcome: 
        Try EMBED function in ECL
        Try Python3 call 
        Use TensorFlow library via Python3 EMBED
        Print an output from TensorFlow 

 */
IMPORT Python3 as Python;

INTEGER tfInstallTest := EMBED(Python)
   
   import tensorflow as tf;
   x = 2;
   y = 1;
   addeddata = tf.add(x, y);
   tfVersion = 'TF version: ' + tf.__version__ ;
   return addeddata;

ENDEMBED;

// Invoke EMBED
tfInstallTest;