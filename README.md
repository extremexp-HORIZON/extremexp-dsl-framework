# ExtremeXP DSL Framework

A Domain-Specific Language (DSL) for modeling and orchestrating machine learning experiments and workflows. The ExtremeXP DSL provides a declarative way to define complex experimental workflows with tasks, data flows, and conditional execution paths.

---

## Table of Contents
- [Installation](#installation)
- [Writing in the DSL](#writing-in-the-dsl)
- [Running with Docker](#running-with-docker)

---

## Installation

### Prerequisites
- Java Development Kit (JDK) 21 or higher
- Apache Maven 3.9.11 or higher

### Building from Source

1. **Build the parent project**

   Navigate to the parent directory and run:
   ```bash
   cd eu.extremexp.dsl.parent
   mvn clean install
   ```

   This will build all DSL modules including the core language, IDE support, and UI components.

2. **Install the Language Server**

   To enable IDE support and language server capabilities, navigate to the IDE module and build with the language server profile:
   ```bash
   cd eu.extremexp.dsl.ide
   mvn clean install -Plang-server
   ```

   This generates the language server JAR file (`eu.extremexp.dsl.ide-1.0.0-SNAPSHOT-ls.jar`) that can be used by editors supporting the Language Server Protocol (LSP).

---

## Writing in the DSL

The ExtremeXP DSL allows you to define **workflows**, **tasks**, **experiments**, and **data flows** for machine learning pipelines. Files use the `.xxp` extension.

### Core Concepts

#### 1. Workflows

Workflows define sequences of tasks and their connections. There are three types:

- **CompositeWorkflow**: Define tasks, data, and control flow from scratch
- **AssembledWorkflow**: Extend an existing workflow with configuration
- **TaskSpecification**: Define reusable task specifications

**Example - Simple Workflow:**
```xxp
workflow SimpleWorkflow {
    task Task1 {
        implementation "path/to/Task1";
    }
    
    task Task2 {
        implementation "path/to/Task2";
    }
    
    // Control flow
    START -> Task1 -> Task2 -> END;
    
    // Input data
    define input data InputFile;
    configure data InputFile {
        path "datasets/input.csv";
    }
    
    // Data connections
    InputFile --> Task1.InputFile;
    Task1.OutputData --> Task2.InputData;
    
    // Output data
    define output data ResultFile;
    Task2.Result --> ResultFile;
    configure data ResultFile {
        path "output/results/**";
    }
}
```

#### 2. Tasks

Tasks are the computational units in your workflow. Tasks can have:
- **Implementation**: Path to the actual code
- **Subworkflow**: Reference to another workflow
- **Parameters**: Configurable values
- **Input/Output data**: Data dependencies

**Example - Task with Parameters:**
```xxp
task TrainModel {
    implementation "ML/TrainModel";
    
    param epochs {
        type Integer;
        default 100;
        range(50, 200);
    }
    
    param learning_rate {
        type String;
        default "0.001";
        enum("0.001", "0.01", "0.1");
    }
    
    define input data TrainingData;
    define output data ModelFile;
}
```

#### 3. Data Flow

Connect data between tasks using data links:

```xxp
// Input data to task
InputFile --> Task1.InputParameter;

// Task to task
Task1.OutputData --> Task2.InputData;

// Task to output
Task2.Result --> OutputFile;
```

#### 4. Control Flow

Define execution order with operators:

**Sequential:**
```xxp
START -> Task1 -> Task2 -> Task3 -> END;
```

**Parallel Execution:**
```xxp
START -> PARALLEL-1 -> Task1 -> END;
PARALLEL-1 -> Task2 -> END;
```

**Conditional Branching:**
```xxp
Task1 ?-> Task2 {
    condition "check_accuracy > 0.8";
}

Task1 ?-> Task3 {
    condition "check_accuracy <= 0.8";
}
```

**Exception Handling:**
```xxp
Task1 !-> ErrorHandler {
    event "processing_error";
}
```

#### 5. Experiments

Experiments define parameter spaces and execution strategies for automated experimentation:

**Example - Complete Experiment:**
```xxp
experiment ModelOptimization {
    intent FindBestHyperparameters;
    
    // Define control flow between spaces
    control {
        START -> S1 -> S2 -> END;
    }
    
    // Define parameter space
    space S1 of TrainModelWorkflow {
        strategy gridsearch;  // or: randomsearch
        runs = 10;
        
        // Define parameter variations
        param epochs_values = range(50, 200, 25);
        param batch_size_values = enum(16, 32, 64);
        param learning_rate_values = enum("0.001", "0.01", "0.1");
        
        // Assign to task parameters
        task TrainModel {
            param epochs = epochs_values;
            param batch_size = batch_size_values;
            param learning_rate = learning_rate_values;
        }
    }
    
    space S2 of EvaluationWorkflow {
        strategy gridsearch;
        runs = 1;
    }
}
```

#### 6. Assembled Workflows

Extend existing workflows with specific configurations:

```xxp
workflow BaseWorkflow {
    task ProcessData;
    task TrainModel;
    
    START -> ProcessData -> TrainModel -> END;
}

workflow OptimizedWorkflow from BaseWorkflow {
    task ProcessData {
        implementation "optimized/DataProcessor";
    }
    
    task TrainModel {
        implementation "optimized/ModelTrainer";
    }
}
```

#### 7. Advanced Features

**Parallel Nodes in Experiments:**
```xxp
control {
    START -> (Space1 || Space2) -> Space3 -> END;
}
```

**Conditional Experiment Flow:**
```xxp
control {
    START -> S1 -> Evaluator;
    Evaluator ?-> S2 { condition "check_results > 0.75" };
    Evaluator ?-> S3 { condition "check_results <= 0.75" };
    S2 -> END;
    S3 -> END;
}
```

**Subworkflows:**
```xxp
task PreprocessData {
    subworkflow "data_preprocessing_workflow";
}
```

### Parameter Types

The DSL supports various parameter types:

```xxp
// Primitive types
'Integer' | 'Boolean' | 'String' | 'Blob'

// Value specifications
range(start, end)           // e.g., range(1, 100)
range(start, end, step)     // e.g., range(0, 1, 0.1)
enum(val1, val2, ...)       // e.g., enum("relu", "tanh", "sigmoid")
[val1, val2, ...]           // List values

// Custom structures
struct Config {
    learning_rate as String;
    epochs as Integer;
}

// Arrays
params[10] as Integer
```

### Complete Example

Here's a complete example combining multiple concepts:

```xxp
workflow MLPipeline {
    // Tasks
    task LoadData {
        implementation "data/Loader";
    }
    
    task PreprocessData {
        implementation "data/Preprocessor";
    }
    
    task TrainModel;
    
    task EvaluateModel {
        implementation "evaluation/Evaluator";
    }
    
    // Control flow
    START -> LoadData -> PreprocessData -> TrainModel -> EvaluateModel -> END;
    
    // Data definitions
    define input data RawData;
    define output data TrainedModel;
    
    configure data RawData {
        path "datasets/raw/**";
    }
    
    configure data TrainedModel {
        path "output/models/**";
        type "generated-ML-model";
    }
    
    // Data flow
    RawData --> LoadData.Input;
    LoadData.Output --> PreprocessData.Input;
    PreprocessData.Output --> TrainModel.Input;
    TrainModel.Model --> EvaluateModel.Model;
    TrainModel.Model --> TrainedModel;
}

workflow NeuralNetPipeline from MLPipeline {
    task TrainModel {
        implementation "models/NeuralNetwork";
    }
}

experiment OptimizeNN {
    intent FindOptimalArchitecture;
    
    control {
        START -> S1 -> END;
    }
    
    space S1 of NeuralNetPipeline {
        strategy gridsearch;
        runs = 5;
        
        param hidden_layers = range(1, 5);
        param neurons = enum(64, 128, 256);
        param activation = enum("relu", "tanh");
        
        task TrainModel {
            param hidden_layers = hidden_layers;
            param neurons = neurons;
            param activation = activation;
        }
    }
}
```

---

## Running with Docker

A pre-built Docker image is available that includes the complete DSL environment with the language server.

### Building the Docker Image

```bash
docker build -t extremexp-dsl .
```

### Running the Container

Run the language server in a container:

```bash
docker run -d -p 5007:5007 --name extremexp-dsl extremexp-dsl
```

This will:
- Start the language server on port 5007
- Make it accessible for IDE integration via LSP
- Store logs in `/opt/logs/` inside the container

### Accessing Logs

```bash
docker exec extremexp-dsl cat /opt/logs/access.log
docker exec extremexp-dsl cat /opt/logs/errors.log
```

### Using with Your IDE

Configure your LSP-compatible editor to connect to `localhost:5007` to get language features like syntax highlighting, auto-completion, and validation for `.xxp` files.

### Working with Workspace Files

Mount your workspace directory to work with local files:

```bash
docker run -d -p 5007:5007 \
  -v /path/to/your/workspace:/home/user/workspace \
  --name extremexp-dsl \
  extremexp-dsl
```

---

## Project Structure

```
extremexp-dsl-framework/
├── eu.extremexp.dsl.parent/          # Parent Maven project
│   ├── eu.extremexp.dsl/             # Core DSL implementation
│   ├── eu.extremexp.dsl.ide/         # IDE/Language Server support
│   ├── eu.extremexp.dsl.ui/          # Eclipse UI integration
│   └── eu.extremexp.dsl.target/      # Target platform definition
├── workspace/                         # Example workflows and experiments
│   └── experiments/                   # Sample .xxp files
├── Dockerfile                         # Docker image definition
└── launch.sh                          # Language server startup script
```

---
