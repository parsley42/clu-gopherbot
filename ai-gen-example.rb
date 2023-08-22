client.chat(
    parameters: {
        model: "gpt-3.5-turbo", # Required.
        messages: [{ role: "user", content: "Describe a character called Anna!"}], # Required.
        temperature: 0.7,
        stream: proc do |chunk, _bytesize|
            print chunk.dig("choices", 0, "delta", "content")
        end
    })

    def query(input)
        input = "#{@bot.user} says: #{input}"
        while true
          messages, partial = build_messages(input)
          parameters = @settings["params"]
          parameters["user"] = Digest::SHA1.hexdigest(ENV["GOPHER_USER_ID"])
          accumulated_chunks = ""
          error_occurred = false
      
          parameters[:stream] = proc do |chunk, _bytesize|
            if chunk["error"]
              message = chunk["error"]["message"]
              if message.match?(/tokens/i)
                @exchanges.shift
                @bot.Log(:warn, "token error, dropping an exchange and re-trying")
                error_occurred = true
                next
              end
              @bot.SayThread("Sorry, there was an error - '#{message}'")
              @bot.Log(:error, "connecting to openai: #{message}")
              exit(0)
            end
      
            content = chunk["choices"] ? chunk["choices"][0]["delta"]["content"] : ""
            accumulated_chunks += content
            paragraph, remaining = accumulated_chunks.split("\n", 2)
            if paragraph
              say_chunk(paragraph)
              accumulated_chunks = remaining || ""
            end
          end
      
          @client.chat(parameters: parameters)
          
          if error_occurred
            next
          end
      
          say_chunk(accumulated_chunks) if accumulated_chunks.length > 0
          @bot.Say('(</response>)')
          break # Exit the loop when no token error occurred
        end
      end
      
      def say_chunk(chunk)
        if ENV["GOPHER_PROTOCOL"] == "slack"
          chunk = chunk.gsub(/```\w+\n/) { |language| "#{language[3..-2]}:\n```\n" }
        end
        @bot.Say(chunk)
      end
      