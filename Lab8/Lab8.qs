// Intro to Quantum Software Development
// Lab 8: Quantum Fourier Transform
// Copyright 2023 The MITRE Corporation. All Rights Reserved.
//
// Due 4/3 at 6:00PM ET:
//  - Completed exercises and evidence of unit tests passing uploaded to GitHub.

namespace Lab8 {

    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Measurement;


    /// # Summary
    /// In this exercise, you must implement the quantum Fourier transform
    /// circuit. The operation should be performed in-place, meaning the
    /// time-domain output should be in the same order as the frequency-domain
    /// input, not reversed.
    ///
    /// # Input
    /// ## register
    /// A qubit register with unknown length in an unknown state. It is of type
    /// Microsoft.Quantum.Arithmetic.BigEndian, which can be used with some
    /// arithmetic library operations. Use the unwrap operator (!) to access
    /// the underlying array. For example, to address the first qubit in the
    /// register, use `register![0]`. For more info, see:
    /// https://learn.microsoft.com/en-us/azure/quantum/user-guide/language/expressions/itemaccessexpressions#item-access-for-user-defined-types
    operation Exercise1 (register : BigEndian) : Unit is Adj + Ctl {
        // Hint: There are two operations you may want to use here:
        //  1. Your implementation of register reversal in Lab 2, Exercise 2.
        //  2. The Microsoft.Quantum.Intrinsic.R1Frac() gate.
        let registerLength = Length(register!);

        //for each qubit in the register; controlled rotate based on the remaining qubits in the register
        for idx in 0 .. registerLength -1{
            //hadamard the qubit
            H(register![idx]);
            //controlled rotate based on qubit's position in the register
            for rotateIter in idx +1 ..registerLength -1 {
                //so we are controlling off of the second iterator, and the amount to rotate is 
                //the rotate iterator - the index (so at qubit two, while controlling off of qubit 4 would have exponent
                //2 in the denominator)
               Controlled R1Frac([register![rotateIter]],(1,rotateIter - idx,register![idx]));
            }
        }
        //Q sharp reference shows method to reverse register 
        //https://learn.microsoft.com/en-us/qsharp/api/qsharp/microsoft.quantum.canon.swapreverseregister
        SwapReverseRegister(register!);
        
    }


    /// # Summary
    /// In this exercise, you are given a quantum register with a single sine
    /// wave encoded into the amplitudes of each term in the superposition.
    ///
    /// For example: the first sample of the wave will be the amplitude of the
    /// |0> term, the second sample of the wave will be the amplitude of the
    /// |1> term, the third will be the amplitude of the |2> term, and so on.
    ///
    /// Your goal is to find the frequency of these samples, and return that
    /// frequency.
    ///
    /// # Input
    /// ## register
    /// The register which contains the samples of the sine wave in the
    /// amplitudes of its terms.
    ///
    /// ## sampleRate
    /// The number of samples per second that were used to collect the
    /// original samples. You will need this to retrieve the correct
    /// frequency.
    ///
    /// # Output
    /// The frequency of the sine wave.
    ///
    /// # Remarks
    /// When using the DFT to analyze the frequency components of a purely real
    /// signal, typically the second half of the output is thrown away, since
    /// these represent frequencies too fast to show up in the time domain.
    /// Here, we can't just "throw away" a part of the output, so if we measure
    /// a value above N/2, it will need to be mirrored about N/2 to recover the
    /// actual frequency of the input sine wave. For more info, see:
    /// https://en.wikipedia.org/wiki/Nyquist_frequency
    operation Exercise2 (
        register : BigEndian,
        sampleRate : Double
    ) : Double {
        //start with a qubit register apply the QFT to obtain the frequenc of the sginal

        Exercise1(register);
        //need to keep track of all possible samples for converting to frequency
        let numSamples = IntAsDouble(2 ^ Length(register!));

        //mesaure output of QFT and get result based on location of 1 in result
        let retValInt = MeasureInteger(BigEndianAsLittleEndian(register));
        //make double for future math
        mutable retValDouble = IntAsDouble(retValInt);
        //handle aliasing -- basically if teh value is larger than nyquist frequency then we just
        //grab sample on mirrored side of frequency distribution
        if(retValDouble > (numSamples) / 2.0)
        {
            set retValDouble = numSamples - retValDouble;
        }
        let totalTime = numSamples / sampleRate;
        set retValDouble = retValDouble / totalTime;
        
        return retValDouble;
    }
}
