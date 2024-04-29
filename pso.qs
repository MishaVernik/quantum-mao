namespace QuantumPSO {
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Math;

    @EntryPoint()
    operation Main() : Double {
        let nParticles = 100;
        let dimensions = 2;
        let iterations = 100;

        mutable gBestValue = 9999999999999.0;
        mutable gBestPosition = [0.0, size=dimensions];
        mutable positions = [0.0, size=nParticles*dimensions];
        mutable velocities = [0.0, size=nParticles*dimensions];
        
        for particle in 0..nParticles - 1 {
            for dimension in 0..dimensions - 1 {
                let index = particle * dimensions + dimension;
                set positions w/= index <- QuantumRandomDouble(-1.0, 1.0, 10);
                set velocities w/= index <- QuantumRandomDouble(-0.1, 0.1, 10);
            }
        }

        for iteration in 1..iterations {
            for particle in 0..nParticles - 1 {
                mutable fitness = 0.0;

                // Calcualte fitness of the function.
                // e.g. x1^2 + x2^2 + ... + xN^2
                let x = positions[particle * dimensions];
                let y = positions[particle * dimensions + 1];
                let term1 = (x * x + y - 11.0) * (x * x + y - 11.0);
                let term2 = (x + y * y - 7.0) * (x + y * y - 7.0);
                set fitness = term1 + term2;
            //     mutable result = 0.0;
            //    for i in 0..dimensions - 2 {
            //         let xi = positions[particle * dimensions +i];
            //         let xi1 = positions[particle * dimensions +i + 1];
            //         let term1 = 100.0 * (xi1 - xi * xi) * (xi1 - xi * xi); // (x[i+1] - x[i]^2)^2
            //         let term2 = (1.0 - xi) * (1.0 - xi); // (1 - x[i])^2
            //         set result += (term1 + term2);
            //     }

            //     set fitness = result;
                // for index in 0..dimensions-1{
                //     set fitness += Square(positions[particle*dimensions + index])
                // }

                if (fitness < gBestValue) {
                    set gBestValue = fitness;
                    for index in 0..dimensions-1 {
                        set gBestPosition w/= index <- positions[particle * dimensions + index];
                    }
                    
                }

                // Update velocity and position
                for dimension in 0..dimensions - 1 {
                    let r1 = QuantumRandomDouble(0.0, 1.0, 5);
                    let r2 = QuantumRandomDouble(0.0, 1.0, 5);
                    let cognitiveComponent = 1.49 * r1 * (gBestPosition[dimension] - positions[particle*dimensions + dimension]);
                    let socialComponent = 1.49 * r2 * (gBestPosition[dimension] - positions[particle*dimensions + dimension]);
                    let inertiaComponent = 0.5 * velocities[particle*dimensions + dimension];

                    let index = particle * dimensions + dimension;
                    set velocities w/= index <- inertiaComponent + cognitiveComponent + socialComponent;
                    set positions w/= index <- positions[particle * dimensions + dimension] + velocities[particle*dimensions + dimension];
                }
            }
        }
        Message($"Best global value in the swarm: {gBestValue}");
        return gBestValue;
    }

     // Function to evaluate the Ackley function given a position vector.
   

    function RosenbrockFunction(position : Double[]) : Double {
        mutable result = 0.0;

        // Compute the Rosenbrock function for (n-1) dimensions
        for i in 0..Length(position) - 2 {
            let xi = position[i];
            let xi1 = position[i + 1];
            let term1 = 100.0 * (xi1 - xi * xi) * (xi1 - xi * xi); // (x[i+1] - x[i]^2)^2
            let term2 = (1.0 - xi) * (1.0 - xi); // (1 - x[i])^2
            set result += (term1 + term2);
        }

        return result;
    }

    function BoothFunction(x : Double, y : Double) : Double {
        
        // Calculate the Booth function
        let term1 = (x + 2.0 * y - 7.0) * (x + 2.0 * y - 7.0);
        let term2 = (2.0 * x + y - 5.0) * (2.0 * x + y - 5.0);

        return term1 + term2;
    }
 // This function calculates the Alpine N. 2 function value for a given position vector.
    function CalculateFitness2(position : Double[]) : Double {

        return Fold(AddD, 0.0, Mapped(Alpine2, position));
    }
    function Alpine2(x : Double) : Double {
        return x * Sin(x) + 0.1 * x;
    }
    // Helper function to sum doubles, used in Fold operation.
    function AddD(a : Double, b : Double) : Double {
        return a + b;
    }

    /// Fitness function for evaluation (Sphere Function as example)
    function CalculateFitness(position : Double[]) : Double {
        let sumSquares = Fold(Add, 0.0, Mapped(Square, position));
        return sumSquares;
    }

    function Square(x : Double) : Double {
        return x * x;
    }

    function Add(a : Double, b : Double) : Double {
        return a + b;
    }

    /// Helper to convert result array to integer
    function ResultArrayAsInt(results : Result[]) : Int {
        mutable intValue = 0;
        for index in 0..Length(results) - 1 {
            if (results[index] == One) {
                set intValue = intValue + (1 <<< index);
            }
        }
        return intValue;
    }

    /// Generates random double values using quantum randomness, scaled to a specific range.
    operation QuantumRandomDouble(min : Double, max : Double, nBits : Int) : Double {
        use qubits = Qubit[nBits];
        ApplyToEach(H, qubits);
        let results = MResetEachZ(qubits);
        let power = IntAsDouble(1 <<< nBits);
        let decimal = IntAsDouble(ResultArrayAsInt(results)) / power;
        return min + (max - min) * decimal;
    }
}
