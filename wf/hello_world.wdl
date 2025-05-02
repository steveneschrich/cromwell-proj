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
}

task Print {
    input {
        String name = "Dr. Smythe"
        String greeting = "Hello There"
    }
    command <<<
        echo ~{greeting} and ~{name}
    >>>

    output {
        String message = read_string(stdout())
    }
}