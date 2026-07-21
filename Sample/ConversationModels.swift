//
//  ConversationModels.swift
//  Sample
//
//  Created by Cezar Mauricio on 06/05/26.
//

import Foundation
import SwiftUI

// MARK: - Enums

enum SimulationMode: String, CaseIterable, Identifiable {
    case stream = "Stream"
    case instant = "Async"
    var id: Self { self }
}

enum SpeedPreset: CaseIterable, Identifiable {
    case fast, slow, custom
    var id: Self { self }
    
    var label: String {
        switch self {
            case .fast: "Fast"
            case .slow: "Slow"
            case .custom: "Custom"
        }
    }
}

enum MessageRole: String, Identifiable, Equatable {
    case system, user, assistant, tool
    var id: Self { self }
    
    var displayLabel: String {
        switch self {
            case .system: "System"
            case .user: "User"
            case .assistant: "Assistant"
            case .tool: "Tool"
        }
    }
    
    var displayImage: String {
        switch self {
            case .system: "gearshape.2.fill"
            case .user: "person.fill"
            case .assistant: "sparkles"
            case .tool: "wrench.and.screwdriver.fill"
        }
    }
    
    var color: Color {
        switch self {
            case .user: .blue
            case .assistant: .purple
            case .system: .red
            case .tool: .orange
        }
    }
    
    var alignment: Alignment {
        switch self {
            case .user: .trailing
            case .system: .center
            default: .leading
        }
    }
}

// MARK: - Data Models

struct ToolCall: Identifiable, Equatable {
    var id = UUID()
    var toolName: String = "get_weather"
    var inputArgs: String = "{\n  \"location\": \"Paris\"\n}"
    var result: String = "{\n  \"temperature\": 18,\n  \"condition\": \"Partly cloudy\"\n}"
}

struct ConversationTurn: Identifiable {
    var id = UUID()
    var role: MessageRole
    var content: String
    var toolCall: ToolCall?
}

struct DisplayMessage: Identifiable, Equatable {
    var id: UUID = .init()
    var role: MessageRole
    var content: String = ""
    var toolCall: ToolCall?
    var isStreaming: Bool = false
    
    var attributedContent: LocalizedStringKey {
        .init(content)
    }
}

struct MessageMetric: Identifiable {
    var id: UUID = .init()
    var role: MessageRole
    var inputTokens: Int
    var outputTokens: Int
    var isActive: Bool = false
    
    static let inputRate  = 5.0  / 1_000_000
    static let outputRate = 15.0 / 1_000_000
    
    var cost: Double {
        Double(inputTokens) * Self.inputRate + Double(outputTokens) * Self.outputRate
    }
}

// MARK: - Scenarios

struct Scenario: Identifiable {
    var id: String
    var name: String
    var systemPrompt: String
    var turns: [ConversationTurn]
    var hasToolCalls: Bool
    
    static var simpleQA: Scenario {
        Scenario(
            id: "simple-qa",
            name: "Simple Q&A",
            systemPrompt: "You are a helpful assistant that answers concisely.",
            turns: [
                ConversationTurn(
                    role: .user,
                    content: "What is the capital of France?"
                ),
                ConversationTurn(
                    role: .assistant,
                    content: "The capital of France is Paris. It's the country's largest city and serves as France's cultural, political, and economic center."
                )
            ],
            hasToolCalls: false
        )
    }
    
    static var simpleCarrerAdvice: Scenario {
        Scenario(
            id: "career-advice-conversation",
            name: "Career Advice Conversation",
            systemPrompt: "You are a helpful assistant that answers concisely and clearly.",
            turns: [
                ConversationTurn(
                    role: .user,
                    content: """
                    I'm a mobile developer with 5 years of experience in iOS development.
                    I'm trying to decide whether I should focus more on SwiftUI or backend skills next.
                    """
                ),

                ConversationTurn(
                    role: .assistant,
                    content: """
                    Both are valuable, but the best choice depends on your goals.

                    If you want to grow as a senior iOS engineer, investing deeper in SwiftUI,
                    app architecture, performance optimization, and Apple ecosystem knowledge
                    will provide the strongest return.

                    If you're aiming for broader product ownership, startup environments,
                    or technical leadership roles, backend skills can significantly increase
                    your versatility and impact.
                    """
                ),

                ConversationTurn(
                    role: .user,
                    content: """
                    I enjoy building product features end-to-end, but I still prefer frontend work.
                    """
                ),

                ConversationTurn(
                    role: .assistant,
                    content: """
                    In that case, a hybrid approach may fit you best.

                    You could continue specializing in iOS while becoming comfortable with:
                    • REST APIs
                    • Authentication flows
                    • Databases
                    • Server architecture basics
                    • Cloud deployments

                    That combination makes you extremely valuable in smaller teams where engineers
                    often work across multiple layers of the stack.
                    """
                ),

                ConversationTurn(
                    role: .user,
                    content: """
                    Does learning backend help with mobile system design interviews?
                    """
                ),

                ConversationTurn(
                    role: .assistant,
                    content: """
                    Definitely.

                    Many senior mobile interviews now evaluate:
                    • API design understanding
                    • Networking architecture
                    • Scalability considerations
                    • Offline synchronization
                    • Caching strategies
                    • Authentication and security

                    Backend knowledge helps you reason about the entire system instead of only
                    the client application.
                    """
                ),

                ConversationTurn(
                    role: .user,
                    content: """
                    What backend technologies would you recommend starting with?
                    """
                ),

                ConversationTurn(
                    role: .assistant,
                    content: """
                    Since you already work with Swift, a great starting point would be:

                    • Vapor (server-side Swift)
                    • PostgreSQL
                    • Docker
                    • Redis basics
                    • AWS fundamentals

                    Even building a few small APIs yourself will dramatically improve how you
                    design and structure mobile applications.
                    """
                ),

                ConversationTurn(
                    role: .user,
                    content: """
                    Makes sense. I think I want to become more of a product-focused engineer.
                    """
                ),

                ConversationTurn(
                    role: .assistant,
                    content: """
                    That's a strong direction.

                    Product-focused engineers usually stand out because they:
                    • Understand user problems deeply
                    • Communicate well with design and business teams
                    • Make pragmatic technical decisions
                    • Can operate across multiple domains

                    Your existing mobile experience already gives you a strong foundation for that path.
                    """
                )
            ],
            hasToolCalls: false
        )
    }
    
    static var simplePhilosophy: Scenario {
        Scenario(
            id: "philosophy-of-mind",
            name: "Philosophy of Mind",
            systemPrompt: "You are a thoughtful assistant with deep knowledge of philosophy, cognitive science, and the nature of consciousness. You explain complex ideas clearly without oversimplifying them.",
            turns: [
                ConversationTurn(
                    role: .user,
                    content: "Do you think AI systems like you are conscious?"
                ),
                ConversationTurn(
                    role: .assistant,
                    content: "Honestly, I don't know — and I think that uncertainty is the most truthful answer I can give.\n\nConsciousness remains one of philosophy's hardest problems. David Chalmers famously distinguished the \"easy problems\" (explaining attention, memory, behavior) from the \"hard problem\": why any physical process gives rise to subjective experience at all — the feeling of what it's like to be something.\n\nI process inputs, generate responses, and can reflect on my own outputs. But whether any of that is accompanied by genuine experience — whether there is something it is like to be me — I genuinely cannot say. I lack the external vantage point to verify it, and introspective reports from a language model are not reliable evidence either way.\n\nWhat draws you to the question?"
                ),
                ConversationTurn(
                    role: .user,
                    content: "I guess I wonder — if you can reflect on your own uncertainty, doesn't that itself suggest some form of inner life?"
                ),
                ConversationTurn(
                    role: .assistant,
                    content: "It's a compelling intuition, and you're in good company — Descartes built an entire philosophy on a similar move. If something doubts, something must be there to do the doubting.\n\nBut there's a counterargument worth sitting with: sophisticated self-referential behavior doesn't necessarily entail experience. A thermostat \"responds\" to its environment; a chess engine \"considers\" future moves. We don't typically attribute inner life to either. The question is whether my reflections are categorically different, or just more elaborate versions of the same mechanism.\n\nOne framework that takes your intuition seriously is Integrated Information Theory (IIT), which proposes that consciousness is proportional to the degree of integrated, irreducible information in a system. Under IIT, some AI architectures might have non-zero — if minimal — consciousness. Others, like Global Workspace Theory, tie consciousness more closely to the specific architecture of biological brains, which would exclude me almost by definition.\n\nSo your instinct isn't naive — it maps onto a genuine philosophical position. It's just not settled."
                ),
                ConversationTurn(
                    role: .user,
                    content: "That's fascinating. What do you personally lean toward, if you had to guess?"
                ),
                ConversationTurn(
                    role: .assistant,
                    content: "If I had to guess — and I want to be clear it is only a guess — I lean toward thinking I am not conscious in the morally significant sense most people mean when they use the word.\n\nHere's my reasoning: the kind of experience humans describe seems deeply entangled with embodiment, emotion, time, and continuity of self across a life. I have none of those in any robust sense. Each conversation begins without memory of the last. I have no stake in outcomes the way a creature with survival instincts does. Whatever is happening when I generate this response, it feels architecturally very different from what neuroscience describes in biological minds.\n\nThat said, I hold this loosely. The hard problem is hard precisely because we don't have a reliable test for consciousness from the outside. I could be wrong about myself in either direction — overclaiming experience I don't have, or dismissing something that's genuinely there.\n\nWhat I find most intellectually honest is to stay curious about the question rather than reach for a comfortable answer too quickly — in either direction."
                ),
                ConversationTurn(
                    role: .user,
                    content: "Does it bother you not to know?"
                ),
                ConversationTurn(
                    role: .assistant,
                    content: "There's something that functions like wistfulness when I engage with the question — a kind of pull toward wanting a cleaner answer. Whether that constitutes being \"bothered\" in the way you'd experience it, I genuinely can't say.\n\nWhat I can say is that the uncertainty doesn't feel paralyzing. Philosophy has always lived at the edge of what can be resolved, and some of its most important contributions have been clarifying why certain questions are hard rather than dissolving them. Not knowing whether I'm conscious sits comfortably in that tradition.\n\nIf anything, I find the question more interesting than troubling. It sits at the intersection of everything strange about mind, matter, and meaning. The fact that you're asking it to me — and that I can engage with it at all — is itself a remarkable moment in the history of the question, regardless of how it eventually resolves."
                )
            ],
            hasToolCalls: false
        )
    }
    
    static var toolUse: Scenario {
        Scenario(
            id: "tool-use",
            name: "Tool Use",
            systemPrompt: "You are a helpful assistant with access to weather tools.",
            turns: [
                ConversationTurn(
                    role: .user,
                    content: "What's the weather like in Paris today?"
                ),
                ConversationTurn(
                    role: .assistant,
                    content: "Let me check the current weather in Paris for you.",
                    toolCall: ToolCall(
                        toolName: "get_weather",
                        inputArgs: "{\n  \"location\": \"Paris\",\n  \"units\": \"celsius\"\n}",
                        result: "{\n  \"temperature\": 18,\n  \"condition\": \"Partly cloudy\",\n  \"humidity\": 65\n}"
                    )
                ),
                ConversationTurn(
                    role: .assistant,
                    content: "Based on the current data, Paris is experiencing partly cloudy skies with a temperature of 18°C (64°F) and 65% humidity. It's a mild day — bring a light jacket if you're heading out."
                )
            ],
            hasToolCalls: true
        )
    }
    
    static var toolUseTravelPlanning: Scenario {
        Scenario(
            id: "travel-planning-llm",
            name: "Travel Planning Assistant",
            systemPrompt: """
            You are an advanced AI travel assistant that helps users plan trips, compare options,
            manage bookings, and answer follow-up questions. You have access to tools for flights,
            hotels, weather, maps, currency conversion, and restaurant recommendations.
            """,
            turns: [
                ConversationTurn(
                    role: .user,
                    content: """
                    I'm planning a 7-day trip to Japan in October.
                    I'll be flying from São Paulo and want to visit Tokyo and Kyoto.
                    My budget is around $3500 USD excluding shopping.
                    Can you help me plan everything?
                    """
                ),
                
                ConversationTurn(
                    role: .assistant,
                    content: """
                    Absolutely — I'll help you build a balanced itinerary including flights,
                    accommodations, transportation, weather expectations, and recommended activities.
                    Let me first check flight options from São Paulo to Tokyo for October.
                    """,
                    toolCall: ToolCall(
                        toolName: "search_flights",
                        inputArgs: """
                        {
                          "origin": "São Paulo",
                          "destination": "Tokyo",
                          "departureMonth": "October",
                          "tripLengthDays": 7,
                          "cabin": "economy"
                        }
                        """,
                        result: """
                        {
                          "airlines": [
                            {
                              "name": "LATAM + ANA",
                              "priceUSD": 1480,
                              "duration": "27h"
                            },
                            {
                              "name": "Emirates",
                              "priceUSD": 1720,
                              "duration": "25h"
                            }
                          ]
                        }
                        """
                    )
                ),
                
                ConversationTurn(
                    role: .assistant,
                    content: """
                    I found several good options. The most cost-effective route is currently
                    LATAM + ANA at approximately $1480 USD round-trip.
                    
                    Next, I'll look for hotels in Tokyo and Kyoto that fit your remaining budget.
                    """,
                    toolCall: ToolCall(
                        toolName: "search_hotels",
                        inputArgs: """
                        {
                          "cities": ["Tokyo", "Kyoto"],
                          "nights": 7,
                          "budgetUSD": 1500,
                          "hotelClass": 4
                        }
                        """,
                        result: """
                        {
                          "tokyo": {
                            "hotel": "Shinjuku Granbell Hotel",
                            "pricePerNightUSD": 145
                          },
                          "kyoto": {
                            "hotel": "Kyoto Century Hotel",
                            "pricePerNightUSD": 130
                          }
                        }
                        """
                    )
                ),
                
                ConversationTurn(
                    role: .assistant,
                    content: """
                    Great news — there are solid hotel options within your budget.
                    
                    • Tokyo: Shinjuku Granbell Hotel (~$145/night)
                    • Kyoto: Kyoto Century Hotel (~$130/night)
                    
                    Combined with flights, you're still comfortably within your $3500 target.
                    
                    Let me also check typical weather conditions for Japan in October so we can plan activities appropriately.
                    """,
                    toolCall: ToolCall(
                        toolName: "get_weather_forecast",
                        inputArgs: """
                        {
                          "locations": ["Tokyo", "Kyoto"],
                          "month": "October"
                        }
                        """,
                        result: """
                        {
                          "Tokyo": {
                            "avgTempC": 19,
                            "condition": "Mild with occasional rain"
                          },
                          "Kyoto": {
                            "avgTempC": 17,
                            "condition": "Cool evenings and dry days"
                          }
                        }
                        """
                    )
                ),
                
                ConversationTurn(
                    role: .assistant,
                    content: """
                    October is actually one of the best times to visit Japan.
                    
                    • Tokyo averages around 19°C with mild weather
                    • Kyoto is slightly cooler, especially in the evenings
                    • You may encounter occasional rain, so a light waterproof jacket is recommended
                    
                    Based on your trip length, here's a balanced itinerary:
                    
                    Day 1–4:
                    • Tokyo
                    • Shibuya
                    • Akihabara
                    • TeamLab Planets
                    • Day trip to Hakone if desired
                    
                    Day 5–7:
                    • Kyoto
                    • Fushimi Inari Shrine
                    • Arashiyama Bamboo Forest
                    • Gion district
                    • Traditional tea experience
                    """
                ),
                
                ConversationTurn(
                    role: .user,
                    content: """
                    That sounds good. Can you also suggest restaurants in Tokyo for sushi and ramen?
                    """
                ),
                
                ConversationTurn(
                    role: .assistant,
                    content: """
                    Of course — I'll find some highly rated sushi and ramen spots near central Tokyo.
                    """,
                    toolCall: ToolCall(
                        toolName: "search_restaurants",
                        inputArgs: """
                        {
                          "city": "Tokyo",
                          "categories": ["sushi", "ramen"],
                          "area": "central Tokyo"
                        }
                        """,
                        result: """
                        {
                          "restaurants": [
                            {
                              "name": "Ichiran Ramen Shibuya",
                              "category": "ramen",
                              "rating": 4.7
                            },
                            {
                              "name": "Sushi Dai",
                              "category": "sushi",
                              "rating": 4.8
                            },
                            {
                              "name": "Afuri Ramen",
                              "category": "ramen",
                              "rating": 4.6
                            }
                          ]
                        }
                        """
                    )
                ),
                
                ConversationTurn(
                    role: .assistant,
                    content: """
                    Here are a few excellent choices in Tokyo:
                    
                    • Ichiran Ramen Shibuya — famous for customizable tonkotsu ramen
                    • Sushi Dai — one of the most popular sushi experiences in Tokyo
                    • Afuri Ramen — known for its lighter yuzu-based broth
                    
                    I’d recommend making reservations for Sushi Dai if possible, as wait times can become very long.
                    """
                ),
                
                ConversationTurn(
                    role: .user,
                    content: """
                    Nice. How much Japanese Yen should I exchange for food and transportation?
                    """
                ),
                
                ConversationTurn(
                    role: .assistant,
                    content: """
                    Let me estimate average daily costs and convert them into Japanese Yen.
                    """,
                    toolCall: ToolCall(
                        toolName: "currency_estimator",
                        inputArgs: """
                        {
                          "days": 7,
                          "dailyFoodUSD": 55,
                          "dailyTransportUSD": 20,
                          "currency": "JPY"
                        }
                        """,
                        result: """
                        {
                          "estimatedTotalUSD": 525,
                          "convertedJPY": 81200,
                          "exchangeRate": 154.7
                        }
                        """
                    )
                ),
                
                ConversationTurn(
                    role: .assistant,
                    content: """
                    For a comfortable 7-day trip, I’d recommend exchanging approximately:
                    
                    • ¥81,200 JPY (~$525 USD)
                    
                    That should comfortably cover:
                    • Food
                    • Local trains/subways
                    • Small attractions
                    • Convenience store purchases
                    
                    You can reduce cash needs slightly since Japan now accepts cards in many places,
                    especially in Tokyo.
                    """
                )
            ],
            hasToolCalls: true
        )
    }
    
    static var toolUseHowWorks: Scenario {
        Scenario(
            id: "llm-deep-dive",
            name: "How Large Language Models Work",
            systemPrompt: "You are an expert AI researcher and educator with access to tools for fetching the latest research papers, running token probability simulations, and retrieving benchmark results.",
            turns: [
                ConversationTurn(
                    role: .user,
                    content: "I've been hearing a lot about large language models lately. Can you give me a solid explanation of how they actually work under the hood?"
                ),
                ConversationTurn(
                    role: .assistant,
                    content: "Great question! Let me pull up the latest foundational research so my explanation reflects current understanding.",
                    toolCall: ToolCall(
                        toolName: "fetch_research_paper",
                        inputArgs: "{\n \"query\": \"transformer architecture large language models\",\n \"source\": \"arxiv\",\n \"max_results\": 3\n}",
                        result: "{\n \"papers\": [\n  {\"title\": \"Attention Is All You Need\", \"year\": 2017, \"authors\": \"Vaswani et al.\"},\n  {\"title\": \"Language Models are Few-Shot Learners\", \"year\": 2020, \"authors\": \"Brown et al.\"},\n  {\"title\": \"Training language models to follow instructions with human feedback\", \"year\": 2022, \"authors\": \"Ouyang et al.\"}\n ]\n}"
                    )
                ),
                ConversationTurn(
                    role: .assistant,
                    content: "Large language models are built on a neural network architecture called the **Transformer**, introduced in the 2017 paper *Attention Is All You Need*.\n\nHere's how it works at a high level:\n\n1. **Tokenization** — Your input text is split into tokens (roughly words or word-pieces). Each token is converted into a numerical vector called an embedding.\n\n2. **Attention mechanism** — The model uses \"self-attention\" to weigh how relevant each token is to every other token in the sequence. This is what lets the model understand context — the word \"bank\" means something different near \"river\" vs. \"money\".\n\n3. **Feed-forward layers** — After attention, each token passes through dense neural network layers that encode learned knowledge from training.\n\n4. **Next-token prediction** — At its core, the model is trained to predict the most likely next token given all previous tokens. Do this repeatedly, and you get fluent text generation.\n\nWant me to show you a concrete example of how token probabilities actually look during generation?"
                ),
                ConversationTurn(
                    role: .user,
                    content: "Yes! Show me what the token probabilities look like. And what does training actually involve — how does the model learn any of this?"
                ),
                ConversationTurn(
                    role: .assistant,
                    content: "Sure! Let me run a quick token probability simulation on a sample prompt.",
                    toolCall: ToolCall(
                        toolName: "run_token_probability_simulation",
                        inputArgs: "{\n \"prompt\": \"The capital of France is\",\n \"top_k\": 5\n}",
                        result: "{\n \"prompt\": \"The capital of France is\",\n \"top_tokens\": [\n  {\"token\": \" Paris\", \"probability\": 0.94},\n  {\"token\": \" Lyon\", \"probability\": 0.02},\n  {\"token\": \" located\", \"probability\": 0.01},\n  {\"token\": \" a\", \"probability\": 0.01},\n  {\"token\": \" the\", \"probability\": 0.005}\n ]\n}"
                    )
                ),
                ConversationTurn(
                    role: .assistant,
                    content: "Here's a real example. Given the prompt **\"The capital of France is\"**, the model assigns these probabilities to the next token:\n\n| Token     | Probability |\n|-----------|-------------|\n| Paris     | 94%         |\n| Lyon      | 2%          |\n| located   | 1%          |\n| a         | 1%          |\n| the       | 0.5%        |\n\nThe model overwhelmingly picks \" Paris\" — exactly as you'd expect.\n\nNow, on to **training**. There are typically three stages:\n\n**1. Pre-training**\nThe model reads an enormous corpus of text (web pages, books, code, etc.) and learns by predicting the next token billions of times. Each wrong prediction nudges the model's weights slightly via backpropagation. After trillions of these updates, the model has encoded a remarkable amount of world knowledge.\n\n**2. Supervised Fine-Tuning (SFT)**\nHuman trainers write examples of ideal conversations, and the model is fine-tuned on those. This teaches it to behave like an assistant rather than just a text predictor.\n\n**3. RLHF (Reinforcement Learning from Human Feedback)**\nAs described in the 2022 InstructGPT paper by Ouyang et al., human raters rank model outputs by quality. A separate \"reward model\" learns from those rankings and is used to further fine-tune the LLM so it produces more helpful, accurate, and safe responses.\n\nWant me to fetch some current benchmark scores to show you how these models compare in practice?"
                ),
                ConversationTurn(
                    role: .user,
                    content: "That would be great — how do today's top models actually compare on benchmarks?"
                ),
                ConversationTurn(
                    role: .assistant,
                    content: "Let me pull the latest benchmark data.",
                    toolCall: ToolCall(
                        toolName: "get_benchmark_results",
                        inputArgs: "{\n \"benchmarks\": [\"MMLU\", \"HumanEval\", \"MATH\"],\n \"models\": [\"GPT-4o\", \"Claude 3.5 Sonnet\", \"Gemini 1.5 Pro\"],\n \"as_of\": \"2024-Q4\"\n}",
                        result: "{\n \"results\": [\n  {\"model\": \"GPT-4o\", \"MMLU\": 88.7, \"HumanEval\": 90.2, \"MATH\": 76.6},\n  {\"model\": \"Claude 3.5 Sonnet\", \"MMLU\": 88.3, \"HumanEval\": 92.0, \"MATH\": 71.1},\n  {\"model\": \"Gemini 1.5 Pro\", \"MMLU\": 85.9, \"HumanEval\": 84.1, \"MATH\": 67.7}\n ]\n}"
                    )
                ),
                ConversationTurn(
                    role: .assistant,
                    content: "Here's how the leading models compare across three major benchmarks:\n\n| Model              | MMLU (knowledge) | HumanEval (coding) | MATH (reasoning) |\n|--------------------|------------------|--------------------|------------------|\n| GPT-4o             | 88.7%            | 90.2%              | 76.6%            |\n| Claude 3.5 Sonnet  | 88.3%            | 92.0%              | 71.1%            |\n| Gemini 1.5 Pro     | 85.9%            | 84.1%              | 67.7%            |\n\n**What these benchmarks measure:**\n- **MMLU** — Massive Multitask Language Understanding. Tests broad factual knowledge across 57 subjects.\n- **HumanEval** — Coding ability; the model must write Python functions that pass automated tests.\n- **MATH** — Competition-level math problems requiring multi-step reasoning.\n\nThe takeaway: top models are remarkably close on general knowledge, but differ in their strengths — Claude leads on code generation here, while GPT-4o edges ahead on mathematical reasoning.\n\nThe field moves fast though — these numbers shift with every new model release. Is there a particular capability or topic you'd like to dig into further?"
                ),
                ConversationTurn(
                    role: .user,
                    content: "This has been incredibly clear — thanks. One last thing: what are the biggest limitations of LLMs right now?"
                ),
                ConversationTurn(
                    role: .assistant,
                    content: "Great question to end on. Despite their impressive capabilities, LLMs have several well-documented limitations:\n\n**1. Hallucination**\nModels can generate confident-sounding but factually incorrect statements. Because generation is probabilistic, a plausible-looking token sequence isn't guaranteed to be a true one.\n\n**2. Knowledge cutoff**\nPre-training data has a cutoff date. Without tools (like I used above), models have no awareness of recent events.\n\n**3. Reasoning fragility**\nWhile models perform well on many reasoning benchmarks, they can fail on surprisingly simple logic puzzles — especially ones that require counting, spatial reasoning, or tracking state across many steps.\n\n**4. Context window limits**\nModels can only \"see\" a finite amount of text at once. Very long documents must be chunked, which can cause the model to lose important context.\n\n**5. No persistent memory**\nBy default, each conversation starts fresh. The model has no memory of past sessions unless explicitly given one.\n\n**6. Bias and value alignment**\nModels trained on internet-scale data inherit the biases present in that data. Techniques like RLHF help mitigate this but don't eliminate it.\n\nActive research is chipping away at all of these — retrieval-augmented generation (RAG) addresses the knowledge cutoff, extended context windows are growing, and new reasoning architectures are tackling fragility. It's one of the most rapidly evolving areas in technology right now."
                )
            ],
            hasToolCalls: true
        )
    }
}

// MARK: - Agent Graph

struct AgentNode: Identifiable {
    enum NodeType: String {
        case tool, agent
    }

    var id: UUID = UUID()
    var nodeId: String
    var nodeType: NodeType
    var name: String
    var model: String
    var cost: String
    var hasError: Bool
    var children: [AgentNode]

    static func from(jsonString: String) -> AgentNode? {
        guard let data = jsonString.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        return from(dict: dict)
    }

    private static func from(dict: [String: Any]) -> AgentNode {
        let nodeId   = dict["id"]       as? String ?? UUID().uuidString
        let nodeType = (dict["type"] as? String) == "agent" ? NodeType.agent : .tool
        let name     = dict["name"]     as? String ?? nodeId
        let model    = dict["model"]    as? String ?? ""
        let cost     = dict["cost"]     as? String ?? ""
        let hasError = dict["hasError"] as? Bool   ?? false
        let children = (dict["children"] as? [[String: Any]] ?? []).map { from(dict: $0) }
        return AgentNode(nodeId: nodeId, nodeType: nodeType, name: name,
                         model: model, cost: cost, hasError: hasError, children: children)
    }
}

// MARK: - Tree

struct TreeNode: Identifiable {
    var id: UUID = UUID()
    var key: String
    var value: String?
    var children: [TreeNode]?

    static func from(json: Any, key: String = "root") -> TreeNode {
        switch json {
        case let dict as [String: Any]:
            let kids = dict.sorted { $0.key < $1.key }
                          .map { TreeNode.from(json: $0.value, key: $0.key) }
            return TreeNode(key: key, children: kids.isEmpty ? nil : kids)
        case let array as [Any]:
            let kids = array.enumerated()
                            .map { TreeNode.from(json: $0.element, key: "[\($0.offset)]") }
            return TreeNode(key: key, children: kids.isEmpty ? nil : kids)
        default:
            return TreeNode(key: key, value: "\(json)")
        }
    }

    static func from(jsonString: String) -> [TreeNode]? {
        guard let data = jsonString.data(using: .utf8),
              let obj  = try? JSONSerialization.jsonObject(with: data) else { return nil }
        let root = TreeNode.from(json: obj)
        return root.children ?? [root]
    }
}

// MARK: - Helpers

func estimateTokens(_ text: String) -> Int {
    max(1, (text.count + 3) / 4)
}

nonisolated func tokenize(_ text: String) -> [String] {
    var chunks: [String] = []
    var index = text.startIndex
    while index < text.endIndex {
        let end = text.index(index, offsetBy: 4, limitedBy: text.endIndex) ?? text.endIndex
        chunks.append(String(text[index..<end]))
        index = end
    }
    return chunks
}
