//
//  ChatQuery.swift
//  
//
//  Created by Sergii Kryvoblotskyi on 02/04/2023.
//

import Foundation

/// Creates a model response for the given chat conversation
/// https://platform.openai.com/docs/guides/text-generation
public struct ChatQuery: Equatable, Codable, Streamable {

    /// A list of messages comprising the conversation so far
    public let messages: [Self.ChatCompletionMessageParam]
    /// ID of the model to use. See the model endpoint compatibility table for details on which models work with the Chat API.
    /// https://platform.openai.com/docs/models/model-endpoint-compatibility
    public let model: Model
    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim.
    /// Defaults to 0
    /// https://platform.openai.com/docs/guides/text-generation/parameter-details
    public let frequencyPenalty: Double?
    /// Modify the likelihood of specified tokens appearing in the completion.
    /// Accepts a JSON object that maps tokens (specified by their token ID in the tokenizer) to an associated bias value from -100 to 100. Mathematically, the bias is added to the logits generated by the model prior to sampling. The exact effect will vary per model, but values between -1 and 1 should decrease or increase likelihood of selection; values like -100 or 100 should result in a ban or exclusive selection of the relevant token.
    /// Defaults to null
    public let logitBias: [String:Int]?
    /// Whether to return log probabilities of the output tokens or not. If true, returns the log probabilities of each output token returned in the content of message. This option is currently not available on the gpt-4-vision-preview model.
    /// Defaults to false
    public let logprobs: Bool?
    /// The maximum number of tokens to generate in the completion.
    /// The total length of input tokens and generated tokens is limited by the model's context length.
    /// https://platform.openai.com/tokenizer
    public let maxTokens: Int?
    /// How many chat completion choices to generate for each input message. Note that you will be charged based on the number of generated tokens across all of the choices. Keep n as 1 to minimize costs.
    /// Defaults to 1
    public let n: Int?
    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics.
    /// https://platform.openai.com/docs/guides/text-generation/parameter-details
    public let presencePenalty: Double?
    /// An object specifying the format that the model must output. Compatible with gpt-4-1106-preview and gpt-3.5-turbo-1106.
    /// Setting to { "type": "json_object" } enables JSON mode, which guarantees the message the model generates is valid JSON.
    /// Important: when using JSON mode, you must also instruct the model to produce JSON yourself via a system or user message. Without this, the model may generate an unending stream of whitespace until the generation reaches the token limit, resulting in a long-running and seemingly "stuck" request. Also note that the message content may be partially cut off if finish_reason="length", which indicates the generation exceeded max_tokens or the conversation exceeded the max context length.
    public let responseFormat: Self.ResponseFormat?
    /// This feature is in Beta. If specified, our system will make a best effort to sample deterministically, such that repeated requests with the same seed and parameters should return the same result. Determinism is not guaranteed, and you should refer to the system_fingerprint response parameter to monitor changes in the backend.
    public let seed: Int? // BETA
    /// Up to 4 sequences where the API will stop generating further tokens. The returned text will not contain the stop sequence.
    /// Defaults to null
    public let stop: Stop?
    /// What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
    /// We generally recommend altering this or top_p but not both.
    /// Defaults to 1
    public let temperature: Double?
    /// Controls which (if any) function is called by the model. none means the model will not call a function and instead generates a message. auto means the model can pick between generating a message or calling a function. Specifying a particular function via {"type": "function", "function": {"name": "my_function"}} forces the model to call that function.
    /// none is the default when no functions are present. auto is the default if functions are present
    public let toolChoice: Self.ChatCompletionFunctionCallOptionParam?
    /// A list of tools the model may call. Currently, only functions are supported as a tool. Use this to provide a list of functions the model may generate JSON inputs for.
    public let tools: [Self.ChatCompletionToolParam]?
    /// An integer between 0 and 5 specifying the number of most likely tokens to return at each token position, each with an associated log probability. logprobs must be set to true if this parameter is used.
    public let topLogprobs: Int?
    /// An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.
    /// We generally recommend altering this or temperature but not both.
    /// Defaults to 1
    public let topP: Double?
    /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
    /// https://platform.openai.com/docs/guides/safety-best-practices/end-user-ids
    public let user: String?
    /// If set, partial message deltas will be sent, like in ChatGPT. Tokens will be sent as data-only server-sent events as they become available, with the stream terminated by a data: [DONE] message.
    /// https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events#Event_stream_format
    public var stream: Bool

    public init(
        messages: [Self.ChatCompletionMessageParam],
        model: Model,
        frequencyPenalty: Double? = nil,
        logitBias: [String : Int]? = nil,
        logprobs: Bool? = nil,
        maxTokens: Int? = nil,
        n: Int? = nil,
        presencePenalty: Double? = nil,
        responseFormat: Self.ResponseFormat? = nil,
        seed: Int? = nil,
        stop: Self.Stop? = nil,
        temperature: Double? = nil,
        toolChoice: Self.ChatCompletionFunctionCallOptionParam? = nil,
        tools: [Self.ChatCompletionToolParam]? = nil,
        topLogprobs: Int? = nil,
        topP: Double? = nil,
        user: String? = nil,
        stream: Bool = false
    ) {
        self.messages = messages
        self.model = model
        self.frequencyPenalty = frequencyPenalty
        self.logitBias = logitBias
        self.logprobs = logprobs
        self.maxTokens = maxTokens
        self.n = n
        self.presencePenalty = presencePenalty
        self.responseFormat = responseFormat
        self.seed = seed
        self.stop = stop
        self.temperature = temperature
        self.toolChoice = toolChoice
        self.tools = tools
        self.topLogprobs = topLogprobs
        self.topP = topP
        self.user = user
        self.stream = stream
    }

    public enum ChatCompletionMessageParam: Codable, Equatable {

        case system(Self.ChatCompletionSystemMessageParam)
        case user(Self.ChatCompletionUserMessageParam)
        case assistant(Self.ChatCompletionAssistantMessageParam)
        case tool(Self.ChatCompletionToolMessageParam)

        public var content: Self.ChatCompletionUserMessageParam.Content? { get {
            switch self {
            case .system(let systemMessage):
                return Self.ChatCompletionUserMessageParam.Content.string(systemMessage.content)
            case .user(let userMessage):
                return userMessage.content
            case .assistant(let assistantMessage):
                if let content = assistantMessage.content {
                    return Self.ChatCompletionUserMessageParam.Content.string(content)
                }
                return nil
            case .tool(let toolMessage):
                return Self.ChatCompletionUserMessageParam.Content.string(toolMessage.content)
            }
        }}

        public var role: Role { get {
            switch self {
            case .system(let systemMessage):
                return systemMessage.role
            case .user(let userMessage):
                return userMessage.role
            case .assistant(let assistantMessage):
                return assistantMessage.role
            case .tool(let toolMessage):
                return toolMessage.role
            }
        }}

        public var name: String? { get {
            switch self {
            case .system(let systemMessage):
                return systemMessage.name
            case .user(let userMessage):
                return userMessage.name
            case .assistant(let assistantMessage):
                return assistantMessage.name
            default:
                return nil
            }
        }}

        public var toolCallId: String? { get {
            switch self {
            case .tool(let toolMessage):
                return toolMessage.toolCallId
            default:
                return nil
            }
        }}

        public var toolCalls: [Self.ChatCompletionAssistantMessageParam.ChatCompletionMessageToolCallParam]? { get {
            switch self {
            case .assistant(let assistantMessage):
                return assistantMessage.toolCalls
            default:
                return nil
            }
        }}

        public init?(
            role: Role,
            content: String? = nil,
            name: String? = nil,
            toolCalls: [Self.ChatCompletionAssistantMessageParam.ChatCompletionMessageToolCallParam]? = nil,
            toolCallId: String? = nil
        ) {
            switch role {
            case .system:
                if let content {
                    self = .system(.init(content: content, name: name))
                } else {
                    return nil
                }
            case .user:
                if let content {
                    self = .user(.init(content: .init(string: content), name: name))
                } else {
                    return nil
                }
            case .assistant:
                self = .assistant(.init(content: content, name: name, toolCalls: toolCalls))
            case .tool:
                if let content, let toolCallId {
                    self = .tool(.init(content: content, toolCallId: toolCallId))
                } else {
                    return nil
                }
            }
        }

        public init?(
            role: Role,
            content: [ChatCompletionUserMessageParam.Content.VisionContent],
            name: String? = nil
        ) {
            switch role {
            case .user:
                self = .user(.init(content: .vision(content), name: name))
            default:
                return nil
            }

        }

        private init?(
            content: String,
            role: Role,
            name: String? = nil
        ) {
            if role == .system {
                self = .system(.init(content: content, name: name))
            } else {
                return nil
            }
        }

        private init?(
            content: Self.ChatCompletionUserMessageParam.Content,
            role: Role,
            name: String? = nil
        ) {
            if role == .user {
                self = .user(.init(content: content, name: name))
            } else {
                return nil
            }
        }

        private init?(
            role: Role,
            content: String? = nil,
            name: String? = nil,
            toolCalls: [Self.ChatCompletionAssistantMessageParam.ChatCompletionMessageToolCallParam]? = nil
        ) {
            if role == .assistant {
                self = .assistant(.init(content: content, name: name, toolCalls: toolCalls))
            } else {
                return nil
            }
        }

        private init?(
            content: String,
            role: Role,
            toolCallId: String
        ) {
            if role == .tool {
                self = .tool(.init(content: content, toolCallId: toolCallId))
            } else {
                return nil
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .system(let a0):
                try container.encode(a0)
            case .user(let a0):
                try container.encode(a0)
            case .assistant(let a0):
                try container.encode(a0)
            case .tool(let a0):
                try container.encode(a0)
            }
        }

        enum CodingKeys: CodingKey {
            case system
            case user
            case assistant
            case tool
        }

        public struct ChatCompletionSystemMessageParam: Codable, Equatable {
            public typealias Role = ChatQuery.ChatCompletionMessageParam.Role

            /// The contents of the system message.
            public let content: String
            /// The role of the messages author, in this case system.
            public let role: Self.Role = .system
            /// An optional name for the participant. Provides the model information to differentiate between participants of the same role.
            public let name: String?

            public init(
                content: String,
                name: String? = nil
            ) {
                self.content = content
                self.name = name
            }

            enum CodingKeys: CodingKey {
                case content
                case role
                case name
            }
        }

        public struct ChatCompletionUserMessageParam: Codable, Equatable {
            public typealias Role = ChatQuery.ChatCompletionMessageParam.Role

            /// The contents of the user message.
            public let content: Content
            /// The role of the messages author, in this case user.
            public let role: Self.Role = .user
            /// An optional name for the participant. Provides the model information to differentiate between participants of the same role.
            public let name: String?

            public init(
                content: Content,
                name: String? = nil
            ) {
                self.content = content
                self.name = name
            }

            enum CodingKeys: CodingKey {
                case content
                case role
                case name
            }

            public enum Content: Codable, Equatable {
                case string(String)
                case vision([VisionContent])

                public var string: String? { get {
                    switch self {
                    case .string(let string):
                        return string
                    default:
                        return nil
                    }
                }}

                public init(string: String) {
                    self = .string(string)
                }

                public init(vision: [VisionContent]) {
                    self = .vision(vision)
                }

                public enum CodingKeys: CodingKey {
                    case string
                    case vision
                }

                public func encode(to encoder: Encoder) throws {
                    var container = encoder.singleValueContainer()
                    switch self {
                    case .string(let a0):
                        try container.encode(a0)
                    case .vision(let a0):
                        try container.encode(a0)
                    }
                }

            public enum VisionContent: Codable, Equatable {
                case chatCompletionContentPartTextParam(ChatCompletionContentPartTextParam)
                case chatCompletionContentPartImageParam(ChatCompletionContentPartImageParam)

                public var text: String? { get {
                    switch self {
                    case .chatCompletionContentPartTextParam(let text):
                        return text.text
                    default:
                        return nil
                    }
                }}

                public var imageUrl: Self.ChatCompletionContentPartImageParam.ImageURL? { get {
                    switch self {
                    case .chatCompletionContentPartImageParam(let image):
                        return image.imageUrl
                    default:
                        return nil
                    }
                }}

                public init(chatCompletionContentPartTextParam: ChatCompletionContentPartTextParam) {
                    self = .chatCompletionContentPartTextParam(chatCompletionContentPartTextParam)
                }

                public init(chatCompletionContentPartImageParam: ChatCompletionContentPartImageParam) {
                    self = .chatCompletionContentPartImageParam(chatCompletionContentPartImageParam)
                }
                
                public init(
                    text: String? = nil,
                    imageURL: String? = nil,
                    detail: ChatCompletionContentPartImageParam.ImageURL.Detail = .high
                ) {
                    if let text {
                        self = .chatCompletionContentPartTextParam(
                            ChatCompletionContentPartTextParam(text: text)
                        )
                    } else if let imageURL {
                        self = .chatCompletionContentPartImageParam(
                            ChatCompletionContentPartImageParam(
                                imageUrl: ChatCompletionContentPartImageParam.ImageURL(
                                    url: imageURL,
                                    detail: detail
                                )
                            )
                        )
                    } else {
                        self = .chatCompletionContentPartTextParam(
                            ChatCompletionContentPartTextParam(text: "")
                        )
                    }
                }

                public func encode(to encoder: Encoder) throws {
                    var container = encoder.singleValueContainer()
                    switch self {
                    case .chatCompletionContentPartTextParam(let a0):
                        try container.encode(a0)
                    case .chatCompletionContentPartImageParam(let a0):
                        try container.encode(a0)
                    }
                }

                enum CodingKeys: CodingKey {
                    case chatCompletionContentPartTextParam
                    case chatCompletionContentPartImageParam
                }

                public struct ChatCompletionContentPartTextParam: Codable, Equatable {
                    /// The text content.
                    public let text: String
                    /// The type of the content part.
                    public let type: String

                    public init(text: String) {
                        self.text = text
                        self.type = "text"
                    }
                }

                public struct ChatCompletionContentPartImageParam: Codable, Equatable {
                    public let imageUrl: ImageURL
                    /// The type of the content part.
                    public let type: String

                    public init(imageUrl: ImageURL) {
                        self.imageUrl = imageUrl
                        self.type = "image_url"
                    }

                    public struct ImageURL: Codable, Equatable {
                        /// Either a URL of the image or the base64 encoded image data.
                        public let url: String
                        /// Specifies the detail level of the image. Learn more in the
                        /// Vision guide https://platform.openai.com/docs/guides/vision/low-or-high-fidelity-image-understanding
                        public let detail: Detail

                        public init(url: String, detail: Detail) {
                            self.url = url
                            self.detail = detail
                        }

                        public init(url: Data, detail: Detail) {
                            self.init(
                                url: "data:image/jpeg;base64,\(url.base64EncodedString())",
                                detail: detail)
                        }

                        public enum Detail: String, Codable, Equatable, CaseIterable {
                            case auto
                            case low
                            case high
                        }
                    }

                    public enum CodingKeys: String, CodingKey {
                        case imageUrl = "image_url"
                        case type
                    }
                }
            }
        }
        }

        internal struct ChatCompletionMessageParam: Codable, Equatable {
            typealias Role = ChatQuery.ChatCompletionMessageParam.Role

            let role: Self.Role

            enum CodingKeys: CodingKey {
                case role
            }
        }

        public struct ChatCompletionAssistantMessageParam: Codable, Equatable {
            public typealias Role = ChatQuery.ChatCompletionMessageParam.Role

            //// The role of the messages author, in this case assistant.
            public let role: Self.Role = .assistant
            /// The contents of the assistant message. Required unless tool_calls is specified.
            public let content: String?
            /// The name of the author of this message. `name` is required if role is `function`, and it should be the name of the function whose response is in the `content`. May contain a-z, A-Z, 0-9, and underscores, with a maximum length of 64 characters.
            public let name: String?
            /// The tool calls generated by the model, such as function calls.
            public let toolCalls: [Self.ChatCompletionMessageToolCallParam]?

            public init(
                content: String? = nil,
                name: String? = nil,
                toolCalls: [Self.ChatCompletionMessageToolCallParam]? = nil
            ) {
                self.content = content
                self.name = name
                self.toolCalls = toolCalls
            }

            public enum CodingKeys: String, CodingKey {
                case name
                case role
                case content
                case toolCalls = "tool_calls"
            }

            public struct ChatCompletionMessageToolCallParam: Codable, Equatable {
                public typealias ToolsType = ChatQuery.ChatCompletionToolParam.ToolsType

                /// The ID of the tool call.
                public let id: String
                /// The function that the model called.
                public let function: Self.FunctionCall
                /// The type of the tool. Currently, only `function` is supported.
                public let type: Self.ToolsType

                public init(
                    id: String,
                    function:  Self.FunctionCall
                ) {
                    self.id = id
                    self.function = function
                    self.type = .function
                }

                public struct FunctionCall: Codable, Equatable {
                    /// The arguments to call the function with, as generated by the model in JSON format. Note that the model does not always generate valid JSON, and may hallucinate parameters not defined by your function schema. Validate the arguments in your code before calling your function.
                    public let arguments: String
                    /// The name of the function to call.
                    public let name: String
                }
            }
        }

        public struct ChatCompletionToolMessageParam: Codable, Equatable {
            public typealias Role = ChatQuery.ChatCompletionMessageParam.Role

            /// The contents of the tool message.
            public let content: String
            /// The role of the messages author, in this case tool.
            public let role: Self.Role = .tool
            /// Tool call that this message is responding to.
            public let toolCallId: String

            public init(
                content: String,
                toolCallId: String
            ) {
                self.content = content
                self.toolCallId = toolCallId
            }

            public enum CodingKeys: String, CodingKey {
                case content
                case role
                case toolCallId = "tool_call_id"
            }
        }

        public enum Role: String, Codable, Equatable, CaseIterable {
            case system
            case user
            case assistant
            case tool
        }
    }

    public enum Stop: Codable, Equatable {
        case string(String)
        case stringList([String])

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let a0):
                try container.encode(a0)
            case .stringList(let a0):
                try container.encode(a0)
            }
        }

        public init(string: String) {
            self = .string(string)
        }

        public init(stringList: [String]) {
            self = .stringList(stringList)
        }
    }

    // See more https://platform.openai.com/docs/guides/text-generation/json-mode
    public enum ResponseFormat: String, Codable, Equatable {
        case jsonObject = "json_object"
        case text

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(["type": self.rawValue])
        }
    }

    public enum ChatCompletionFunctionCallOptionParam: Codable, Equatable {
        case none
        case auto
        case function(String)

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .none:
                var container = encoder.singleValueContainer()
                try container.encode(CodingKeys.none.rawValue)
            case .auto:
                var container = encoder.singleValueContainer()
                try container.encode(CodingKeys.auto.rawValue)
            case .function(let name):
                var container = encoder.container(keyedBy: Self.ChatCompletionFunctionCallNameParam.CodingKeys.self)
                try container.encode("function", forKey: .type)
                try container.encode(["name": name], forKey: .function)
            }
        }

        public init(function: String) {
            self = .function(function)
        }

        enum CodingKeys: String, CodingKey {
            case none = "none"
            case auto = "auto"
            case function = "name"
        }

        private enum ChatCompletionFunctionCallNameParam: Codable, Equatable {
            case type
            case function

            enum CodingKeys: CodingKey {
                case type
                case function
            }
        }
    }

    public struct ChatCompletionToolParam: Codable, Equatable {

        public let function: Self.FunctionDefinition
        public let type: Self.ToolsType

        public init(
            function: Self.FunctionDefinition
        ) {
            self.function = function
            self.type = .function
        }

        public struct FunctionDefinition: Codable, Equatable {
            /// The name of the function to be called. Must be a-z, A-Z, 0-9, or contain underscores and dashes, with a maximum length of 64.
            public let name: String

            /// The description of what the function does.
            public let description: String?

            /// The parameters the functions accepts, described as a JSON Schema object.
            /// https://platform.openai.com/docs/guides/text-generation/function-calling
            /// https://json-schema.org/understanding-json-schema/
            /// **Python library defines only [String: Object] dictionary.
            public let parameters: Self.FunctionParameters?

            public init(
                name: String,
                description: String? = nil,
                parameters: Self.FunctionParameters? = nil
            ) {
                self.name = name
                self.description = description
                self.parameters = parameters
            }

            /// See the [guide](/docs/guides/gpt/function-calling) for examples, and the [JSON Schema reference](https://json-schema.org/understanding-json-schema/) for documentation about the format.
            public struct FunctionParameters: Codable, Equatable {

                public let type: Self.JSONType
                public let properties: [String: Property]?
                public let required: [String]?
                public let pattern: String?
                public let const: String?
                public let `enum`: [String]?
                public let multipleOf: Int?
                public let minimum: Int?
                public let maximum: Int?

                public init(
                    type: Self.JSONType,
                    properties: [String : Property]? = nil,
                    required: [String]? = nil,
                    pattern: String? = nil,
                    const: String? = nil,
                    enum: [String]? = nil,
                    multipleOf: Int? = nil,
                    minimum: Int? = nil,
                    maximum: Int? = nil
                ) {
                    self.type = type
                    self.properties = properties
                    self.required = required
                    self.pattern = pattern
                    self.const = const
                    self.`enum` = `enum`
                    self.multipleOf = multipleOf
                    self.minimum = minimum
                    self.maximum = maximum
                }

                public struct Property: Codable, Equatable {
                    public typealias JSONType = ChatQuery.ChatCompletionToolParam.FunctionDefinition.FunctionParameters.JSONType

                    public let type: Self.JSONType
                    public let description: String?
                    public let format: String?
                    public let items: Self.Items?
                    public let required: [String]?
                    public let pattern: String?
                    public let const: String?
                    public let `enum`: [String]?
                    public let multipleOf: Int?
                    public let minimum: Double?
                    public let maximum: Double?
                    public let minItems: Int?
                    public let maxItems: Int?
                    public let uniqueItems: Bool?

                    public init(
                        type: Self.JSONType,
                        description: String? = nil,
                        format: String? = nil,
                        items: Self.Items? = nil,
                        required: [String]? = nil,
                        pattern: String? = nil,
                        const: String? = nil,
                        enum: [String]? = nil,
                        multipleOf: Int? = nil,
                        minimum: Double? = nil,
                        maximum: Double? = nil,
                        minItems: Int? = nil,
                        maxItems: Int? = nil,
                        uniqueItems: Bool? = nil
                    ) {
                        self.type = type
                        self.description = description
                        self.format = format
                        self.items = items
                        self.required = required
                        self.pattern = pattern
                        self.const = const
                        self.`enum` = `enum`
                        self.multipleOf = multipleOf
                        self.minimum = minimum
                        self.maximum = maximum
                        self.minItems = minItems
                        self.maxItems = maxItems
                        self.uniqueItems = uniqueItems
                    }

                    public struct Items: Codable, Equatable {
                        public typealias JSONType = ChatQuery.ChatCompletionToolParam.FunctionDefinition.FunctionParameters.JSONType

                        public let type: Self.JSONType
                        public let properties: [String: Property]?
                        public let pattern: String?
                        public let const: String?
                        public let `enum`: [String]?
                        public let multipleOf: Int?
                        public let minimum: Double?
                        public let maximum: Double?
                        public let minItems: Int?
                        public let maxItems: Int?
                        public let uniqueItems: Bool?

                        public init(
                            type: Self.JSONType,
                            properties: [String : Property]? = nil,
                            pattern: String? = nil,
                            const: String? = nil,
                            `enum`: [String]? = nil,
                            multipleOf: Int? = nil,
                            minimum: Double? = nil,
                            maximum: Double? = nil,
                            minItems: Int? = nil,
                            maxItems: Int? = nil,
                            uniqueItems: Bool? = nil
                        ) {
                            self.type = type
                            self.properties = properties
                            self.pattern = pattern
                            self.const = const
                            self.`enum` = `enum`
                            self.multipleOf = multipleOf
                            self.minimum = minimum
                            self.maximum = maximum
                            self.minItems = minItems
                            self.maxItems = maxItems
                            self.uniqueItems = uniqueItems
                        }
                    }
                }


                public enum JSONType: String, Codable {
                    case integer
                    case string
                    case boolean
                    case array
                    case object
                    case number
                    case null
                }
            }
        }

        public enum ToolsType: String, Codable, Equatable {
            case function
        }
    }

    public enum CodingKeys: String, CodingKey {
        case messages
        case model
        case frequencyPenalty = "frequency_penalty"
        case logitBias = "logit_bias"
        case logprobs
        case maxTokens = "max_tokens"
        case n
        case presencePenalty = "presence_penalty"
        case responseFormat = "response_format"
        case seed
        case stop
        case temperature
        case toolChoice = "tool_choice"
        case tools
        case topLogprobs = "top_logprobs"
        case topP = "top_p"
        case user
        case stream
    }
}
