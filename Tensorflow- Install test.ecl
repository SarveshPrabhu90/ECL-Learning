/* 
    Learning Outcome: 
        Try EMBED function in ECL
        Try Python3 call 
        Use TensorFlow library via Python3 EMBED
        Print an output from TensorFlow 

 */
IMPORT Python3 as Python;

STRING tfInstallTest := EMBED(Python)
   
   import tensorflow as tf;
   tfVersion = tf.__version__;
   return tfVersion;
ENDEMBED;

// Invoke EMBED
tfInstallTest;