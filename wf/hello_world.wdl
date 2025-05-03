version 1.0

workflow HelloWorld {
    input {
        String name = "Dr. Smith"
        String greeting = "Hello"
    }

    call Print as printHelloWorld {
        input:
            name = name,
            greeting = greeting
    }

    output {
        String greetingMessage = printHelloWorld.message
    }

    parameter_meta {
        # inputs
        name: {description: "The name to use in greeting a person.", category: "required"}
        greeting: {description: "The greeting text that should be used when generating a greeting.", category: "required"}
#                dockerImage: {description: "The docker image used for this task. Changing this may result in errors which the developers may choose not to address.", category: "advanced"}

        # outputs
        greetingMessage: {description: "The text of the composed greeting."}
    }

}

task Print {
    input {
        String name = "Dr. Smythe"
        String greeting = "Hello There"
        String salutation = "Dear"
    }
    command <<<
        echo ~{salutation} ~{greeting} and ~{name}
    >>>

    output {
        String message = read_string(stdout())
    }
}