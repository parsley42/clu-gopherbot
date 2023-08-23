require "openai"
require 'json'
require 'base64'
require 'digest/sha1'

class ConversationStatus
  attr_accessor :valid, :error, :tokens, :in_progress
  def initialize(valid, error, tokens, in_progress)
    @valid = valid
    @error = error
    @tokens = tokens
    @in_progress = in_progress
  end
end

class OpenAI_API
  attr_reader :status, :cfg

  ShortTermMemoryPrefix = "ai-conversation"
  ShortTermMemoryDebugPrefix = "ai-debug"
  DefaultProfile = "default"
  PartialLineLength = 42
  ThinkingStrings = [ "pondering", "working", "thinking", "cogitating", "processing", "analyzing" ]

  def initialize(bot,
      direct:,
      botalias:,
      botname:
    )
    # For now, static profile
    @profile = DefaultProfile
    @direct = direct
    @alias = botalias
    @name = botname
    @bot = direct ? bot : bot.Threaded
    in_progress = false
    if direct
      @memory = ShortTermMemoryPrefix
      exclusive = "#{ShortTermMemoryPrefix}:#{ENV["GOPHER_USER_ID"]}"
    else
      @memory = "#{ShortTermMemoryPrefix}:#{bot.thread_id}"
      exclusive = "#{ShortTermMemoryPrefix}:#{bot.channel}:#{bot.thread_id}"
    end
    @exchanges = []
    @tokens = 0
    @valid = true
    debug_memory = @bot.Recall(ShortTermMemoryDebugPrefix + ":" + bot.thread_id, true)
    @debug = (debug_memory.length > 0)

    error = nil
    unless bot.Exclusive(exclusive, false)
      verb = bot.RandomString(ThinkingStrings)
      error = "(message not processed, AI still #{verb}; you can resend or edit after reply)"
      @status = ConversationStatus.new(false, error, 0, false)
      return
    end
    encoded_state = bot.Recall(@memory, true)
    if encoded_state.length > 0
      state = decode_state(encoded_state)
      in_progress = true
      @profile, @tokens, @owner, @exchanges = state.values_at("profile", "tokens", "owner", "exchanges")
    else
      @owner = ENV["GOPHER_USER"]
    end
    @cfg = bot.GetTaskConfig()
    @settings = @cfg["Profiles"][@profile]
    unless @settings
      @profile = "default"
      @settings = @cfg["Profiles"][@profile]
      @bot.Log(:warn, "no settings found for profile #{@profile}, falling back to 'default'")
    end
    @system = @settings["system"]
    @max_context = @settings["max_context"]

    @org = ENV["OPENAI_ORGANIZATION_ID"]
    token = ENV['OPENAI_KEY']
    unless token and token.length > 0
      @valid = false
      botalias = @bot.GetBotAttribute("alias")
      error = "Sorry, no OPENAI_KEY set"
    end
    if @valid
      OpenAI.configure do |config|
        config.access_token = token
        if @org
          config.organization_id = @org
        end
      end
      @client = OpenAI::Client.new
    end
    @status = ConversationStatus.new(@valid, error, @tokens, in_progress)
  end

  def draw(prompt)
    response = @client.images.generate(parameters: { prompt: prompt, size: "512x512" })
    return response.dig("data", 0, "url")
  end

  def reset()
    # Wipe the memory
    @bot.Remember(@memory, "", true)
    if !@direct
      @bot.Unsubscribe()
    end
  end

  def say_chunk(chunk, final = false)
    if ENV["GOPHER_PROTOCOL"] == "slack"
      chunk = chunk.gsub(/```\w+\n/) { |language| "#{language[3..-2]}:\n```\n" }
    end
    chunk.chomp!
    chunk.strip!
    return if chunk == ""
    unless final
      chunk += " (...)"
    end
    @bot.Say(chunk)
  end

  def query(input)
    input = "#{@bot.user} says: #{input}"
    while true
      messages, partial = build_messages(input)
      parameters = @settings["params"]
      parameters["user"] = Digest::SHA1.hexdigest(ENV["GOPHER_USER_ID"])
      if @debug
        @bot.Say("Query parameters: #{parameters.to_json}", :fixed)
        @bot.Say("Chat (lines truncated):\n#{partial}", :fixed)
      end
      parameters[:messages] = messages
      reply = ""
      accumulated_chunks = ""
      replied = false
  
      parameters[:stream] = proc do |chunk, _bytesize|
        # @bot.Log(:debug, "Chunk: #{chunk}")
        if chunk["choices"]
          content = chunk["choices"][0]["delta"]["content"] ? chunk["choices"][0]["delta"]["content"] : ""
          finished = chunk["choices"][0]["finish_reason"]
          unless finished
            replied = true
            reply += content
            accumulated_chunks += content
            paragraph, remaining = accumulated_chunks.split("\n", 2)
            if accumulated_chunks.include?("\n")
              paragraph, remaining = accumulated_chunks.split("\n", 2)
              say_chunk(paragraph)
              accumulated_chunks = remaining || ""
            end
          end
        end
      end
  
      @client.chat(parameters: parameters)
      
      ## NOTE: This is an ugly hack because the library doesn't
      ## return errors in streaming mode. :-(
      unless replied
        parameters.delete(:stream)
        response = @client.chat(parameters: parameters)
        if response["error"]
          message = response["error"]["message"]
          if message.match?(/tokens/i)
            @exchanges.shift
            @bot.Log(:warn, "token error, dropping an exchange and re-trying")
            next
          end
          @bot.SayThread("Sorry, there was an error - '#{message}'")
          @bot.Log(:error, "connecting to openai: #{message}")
        else
          @bot.Log(:error, "Response after no streaming data: #{response}")
        end
        exit(0)
      end
  
      say_chunk(accumulated_chunks, true) if accumulated_chunks.length > 0
      reply.strip!
      if input.length > 0
        @exchanges << {
          "human" => input,
          "ai" => reply
        }
      end
      @bot.Remember(@memory, encode_state, true)
      break # Exit the loop when no token error occurred
    end
  end

  def build_messages(input)
    messages = [
      {
        role: "system", content: @system
      }
    ]
    partial = String.new
    final = nil
    if input.length > 0
      final = {
        role: "user", content: input
      }
    end
    @exchanges.each do |exchange|
      contents, partial_string = exchange_data(exchange)
      messages += contents
      partial += partial_string
    end
    if final
      messages.append(final)
      partial += "user: #{input}"
    end
    return messages, partial
  end

  def encode_state
    state = {
      "profile": @profile,
      "tokens": @tokens,
      "owner": @owner,
      "exchanges": @exchanges
    }
    json = state.to_json
    Base64.strict_encode64(json)
  end

  def decode_state(encoded_state)
    json = Base64.strict_decode64(encoded_state)
    JSON.parse(json)
  end

  ## Courtesy of OpenAI / Astro Boy
  def truncate_line(str)
    truncated_str = str.split("\n").first
    if truncated_str.length > PartialLineLength
      truncated_str = truncated_str[0..PartialLineLength-1] + " ..."
    end
    return truncated_str
  end

  def exchange_data(exchange)
    contents = [
      {
        role: "user", content: exchange["human"]
      },
      {
        role: "assistant", content: exchange["ai"]
      }
    ]
    human_line = "user: #{exchange["human"]}"
    ai_line = "assistant: #{exchange["ai"]}"
    partial = "#{truncate_line(human_line)}\n#{truncate_line(ai_line)}\n"
    return contents, partial
  end
end
