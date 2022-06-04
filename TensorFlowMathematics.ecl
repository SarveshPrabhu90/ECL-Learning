/* 
    Learning Outcome: 
        Try EMBED function in ECL
        Try Python3 call 
        Use TensorFlow library via Python3 EMBED
        Print an output from TensorFlow 

 */

 IMPORT Python3 as Python;

STRING tftest := EMBED(Python)
    import tensorflow as tf
    import numpy as np
    
    a = tf.constant(5,name="a")
    b = tf.constant(15,name="b")
    c = tf.add(a,b,name="c")
    return "Value of c before running tensor: " + str(c)

ENDEMBED;

// And here is the ECL code that evaluates the embed:

tftest;