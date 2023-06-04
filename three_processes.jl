using Base.Threads

# Define enum for color
@enum Color red green blue N_A

# Define ProcessA, ProcessB, and ProcessC structs
struct ProcessA
    weight::Int
end

struct ProcessB
    color::Color
end

struct ProcessC
    alive::Bool
end

# Function for ProcessA to request interaction with other processes
function request_interaction(a::ProcessA, b_channel, c_channel)
    if a.weight > 50
        println("ProcessA requesting interaction with ProcessB and ProcessC")
        put!(b_channel, a)
        put!(c_channel, a)
    end
end

# Function for ProcessB to request interaction with other processes
function request_interaction(b::ProcessB, a_channel, c_channel)
    if is_colored(b.color)
        println("ProcessB requesting interaction with ProcessA and ProcessC")
        put!(a_channel, b)
        put!(c_channel, b)
    end
end

# Function for ProcessC to request interaction with other processes
function request_interaction(c::ProcessC, a_channel, b_channel)
    if c.alive
        println("ProcessC requesting interaction with ProcessA and ProcessB")
        put!(a_channel, c)
        put!(b_channel, c)
    end
end

# Function to check if the color is not N/A
function is_colored(color::Color)
    return color != N_A
end

# Main function
function main()
    # Initialize processes
    a = ProcessA(70)
    b = ProcessB(blue)
    c = ProcessC(true)

    # Create channels for communication
    a_channel = Channel{Union{ProcessB, ProcessC}}(2)
    b_channel = Channel{Union{ProcessA, ProcessC}}(2)
    c_channel = Channel{Union{ProcessA, ProcessB}}(2)

    # Spawn threads for each process
    threads = [
        @spawn request_interaction(a, b_channel, c_channel),
        @spawn request_interaction(b, a_channel, c_channel),
        @spawn request_interaction(c, a_channel, b_channel)
    ]

    # Process messages from channels
    while true
        a_msg1 = fetch(a_channel)
        a_msg2 = fetch(a_channel)
        if a_msg1 !== nothing && a_msg2 !== nothing
            println("ProcessA interacts with ProcessB and ProcessC")
        end

        b_msg1 = fetch(b_channel)
        b_msg2 = fetch(b_channel)
        if b_msg1 !== nothing && b_msg2 !== nothing
            println("ProcessB interacts with ProcessA and ProcessC")
        end

        c_msg1 = fetch(c_channel)
        c_msg2 = fetch(c_channel)
        if c_msg1 !== nothing && c_msg2 !== nothing
            println("ProcessC interacts with ProcessA and ProcessB")
        end

        if isready(a_channel) && isready(b_channel) && isready(c_channel)
            break
        end
    end

    # Wait for all threads to finish
    for thread in threads
        Base.wait(thread)
    end
end

# Call the main function
main()
