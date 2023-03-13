// Quantum Software Development
// Lab 6: Simon's Algorithm
// Copyright 2023 The MITRE Corporation. All Rights Reserved.
//
// Due 3/13 at 6:00PM ET:
//  - Completed exercises and evidence of unit tests passing uploaded to GitHub.
//
// Notes:
//  - For this assignment, there unit tests in both Q# and C#. The C# unit
//    tests are run in the same way with "dotnet test".
//  - This assignment contains extra credit problems.
//  - There are multiple unit tests for exercise 2 and each of the challenge
//    problems. There are 14 unit tests in total.

namespace Lab6 {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Diagnostics;


    /// # Summary
    /// This operation just entangles the input with the output so that
    /// whatever state the input is measured in, the output will be measured
    /// as the same state. Essentially, it "copies" the input into the
    /// output.
    ///
    /// # Input
    /// ## input
    /// The register to "copy". It can be any length, and in any state.
    ///
    /// ## output
    /// The register to "copy" the input into. It must be the same length as
    /// the input register, and it must be in the |0...0> state. After this
    /// operation, it will be in the same state as the input.
    operation Copy (input : Qubit[], output : Qubit[]) : Unit
    {
        // This just runs CNOT on every pair of qubits between the two
        // registers, using the input qubit as the control and the output
        // qubit as the target.
        for i in 0 .. Length(input) - 1 {
            CNOT(input[i], output[i]);
        }
    }


    /// # Summary
    /// This operation left-shifts the input register by 1 bit, putting the
    /// shifted version of it into the output register. For example, if you
    /// provide it with |1110> as the input, this will put the output into the
    /// state |1100>.
    ///
    /// # Input
    /// ## input
    /// The register to shift. It can be any length, and in any state.
    ///
    /// ## output
    /// The register to shift the input into. It must be the same length as
    /// the input register, and it must be in the |0...0> state. After this
    /// operation, it will be in the state of the input, left-shifted by 1 bit.
    operation LeftShiftBy1 (input : Qubit[], output : Qubit[]) : Unit {
        // Start at input[1]
        for inputIndex in 1 .. Length(input) - 1 {
            // Copy input[i] to output[i-1]
            let outputIndex = inputIndex - 1;
            CNOT(input[inputIndex], output[outputIndex]);
        }
    }


    /// # Summary
    /// In this exercise, you are given a quantum operation that takes in an
    /// input and output register of the same size, and a classical bit string
    /// representing the desired input. Your goal is to run the operation in
    /// "classical mode", which means running it on a single input (rather
    /// than a superposition), and measuring the output (rather than the
    /// input).
    ///
    /// More specifically, you must do this:
    /// 1. Create a qubit register and put it in the same state as the input
    ///    bit string.
    /// 2. Run the operation with this input.
    /// 3. Measure the output register.
    /// 4. Return the output measurements as a classical bit string.
    ///
    /// This will be used by Simon's algorithm to check if the secret string
    /// and the |0...0> state have the same output value - if they don't, then
    /// the operation is 1-to-1 instead of 2-to-1 so it doesn't have a secret
    /// string.
    ///
    /// # Input
    /// ## op
    /// The quantum operation to run in classical mode.
    ///
    /// ## input
    /// A classical bit string representing the input to the operation.
    ///
    /// # Output
    /// A classical bit string containing the results of the operation.
    operation Exercise1 (
        op : ((Qubit[], Qubit[]) => Unit),
        input : Bool[]
    ) : Bool[] {

        let qubitLen = Length(input);
        mutable returnArr = [];
        
        use (qinput, qtarget) = (Qubit[qubitLen],Qubit[qubitLen]){
            for i in 0..qubitLen -1{
                if input[i] == true{
                    X(qinput[i]);
                }
            }
            //DumpRegister((),qinput);
            // Message($"Input is {input}");
            


            op(qinput,qtarget);

            for i in 0..qubitLen-1{
                if M(qtarget[i]) == One{
                    set returnArr += [true];
                }
                else {set returnArr += [false];}
                //reset input qubits too
                let _ = M(qinput[i]);
            }

            

        }

        return returnArr;
    }


    /// # Summary
    /// In this exercise, you must implement the quantum portion of Simon's
    /// algorithm. You are given a black-box quantum operation that is either
    /// 2-to-1 or 1-to-1, and a size that it expects for its input and output
    /// registers. Your goal is to run the operation as defined by Simon's
    /// algorithm, measure the input register, and return the result as a
    /// classical bit string.
    /// 
    /// # Input
    /// ## op
    /// The black-box quantum operation being evaluated. It takes two qubit
    /// registers (an input and an output, both of which are the same size).
    /// 
    /// ## inputSize
    /// The length of the input and output registers that the black-box
    /// operation expects.
    /// 
    /// # Output
    /// A classical bit string representing the measurements of the input
    /// register.
    operation Exercise2 (
        op : ((Qubit[], Qubit[]) => Unit),
        inputSize : Int
    ) : Bool[] {

    mutable res = [];  
    use (input, output) = (Qubit[inputSize],Qubit[inputSize]){
        ApplyToEach(H,input);

        op(input, output);

        ApplyToEach(H,input);
        for i in 0..inputSize - 1{
            if M(input[i]) == One{
                set res += [true];
            }
            else{ set res +=[false];}
            //measure to clear qubits
            let _ = M(output[i]);
        }
    }
    return res;
}

    //////////////////////////////////
    /// === CHALLENGE PROBLEMS === ///
    //////////////////////////////////

    // The problems below are extra quantum operations you can implement to try
    // Simon's algorithm on. 5% extra credit is awarded for each problem
    // attempted, and 10% for each implemented correctly.


    /// # Summary
    /// In this exercise, you must right-shift the input register by 1 bit,
    /// putting the shifted version of it into the output register. For
    /// example, if you are given the input |1110> you must put the output
    /// into the state
    /// |0111>.
    ///
    /// # Input
    /// ## input
    /// The register to shift. It can be any length, and in any state.
    ///
    /// ## output
    /// The register to shift the input into. It must be the same length as
    /// the input register, and it must be in the |0...0> state. After this
    /// operation, it will be in the state of the input, right-shifted by 1
    /// bit.
    ///
    /// # Remarks
    /// This function should have the secret string |10...0>. For example, for
    /// a three-qubit register, it would be |100>. If the unit tests provide
    /// that result, then you've implemented it properly.
    operation Challenge1 (input : Qubit[], output : Qubit[]) : Unit {
        // Start at input[1]
        for inputIndex in 0 .. Length(input) - 2 {
            // Copy input[i] to output[i+1]
            CNOT(input[inputIndex], output[inputIndex+1]);
        }
    }


    /// # Summary
    /// In this exercise, you must implement the black-box operation shown in
    /// the lecture on Simon's algorithm. As a reminder, this operation takes
    /// in a  3-qubit input and a 3-qubit output. It has this input/output
    /// table:
    ///
    ///  Input | Output
    /// ---------------
    ///   000  |  101
    ///   001  |  010
    ///   010  |  000
    ///   011  |  110
    ///   100  |  000
    ///   101  |  110
    ///   110  |  101
    ///   111  |  010
    ///
    /// # Input
    /// ## input
    /// The input register. It will be of size 3, but can be in any state.
    ///
    /// ## output
    /// The output register. It will be of size 3, and in the state |000>.
    ///
    /// # Remarks
    /// To implement this operation, you'll need to find patterns in the
    /// input/output pairs to determine a set of gates that produces this
    /// table. Hint: you can do it by only using the X gate, and controlled
    /// variants of the X gate (CNOT and CCNOT).
    operation Challenge2 (input : Qubit[], output : Qubit[]) : Unit {
        // scratchpad no solution found
        CNOT(input[0],output[0]);
        X(input[1]);
        CNOT(input[1],output[1]);
        X(input[1]);

    }
}
