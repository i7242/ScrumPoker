using Genie.Router, Genie.Requests, Genie.Responses
using Genie.Assets, Genie.Sessions
using Genie.Renderer, Genie.Renderer.Html, Stipple
using Base:@kwdef

@kwdef mutable struct Model <: ReactiveModel
    # for Stipple, a default value is required
    alias::R{String} = ""
    poker_1::R{Bool} = false
    poker_2::R{Bool} = false
    poker_3::R{Bool} = false
    poker_4::R{Bool} = false
    poker_5::R{Bool} = false
    poker_6::R{Bool} = false
    poker_7::R{Bool} = false
    poker_8::R{Bool} = false
    poker_unknown::R{Bool} = false
    poker_cafe::R{Bool} = false
    votes::R{Dict{String, String}} = Dict{String, String}()
end

model = Model() |> Stipple.init

on(model.poker_1) do _
    alias = get(@params, :alias, "ξ")
    model.votes[][alias] = ascii_1
    model.poker_1 = false
end

function login_ui()
    page(vm(model), class="container", [
        pre(ascii_title)
        hr()
        form([input("",name="alias", placeholder="Enter your alias", @bind(:alias))
            button("GO", typt="submit")], action="/scrum")
    ]) |> html
end

function scrum_ui()
    alias = get(@params, :alias, "ξ")
    votes = [button(pre(poker)) for (alias, poker) in model.votes[]]
    page(vm(model), class="container", [
        pre(ascii_title)
        hr()
        p([button(pre(poker)) for (alias, poker) in model.votes[]])
        hr()
        p([
           button(pre(ascii_1), @click("poker_1 = true"))
           button(pre(ascii_2))
           button(pre(ascii_3))
           button(pre(ascii_4))
           button(pre(ascii_5))
           button(pre(ascii_6))
           button(pre(ascii_7))
           button(pre(ascii_8))
           button(pre(ascii_unknown))
           button(pre(ascii_cafe))
        ])
    ]) |> html
end

route("/login", login_ui, named=:login_ui)
route("/scrum", scrum_ui, named=:scrum_ui)

const ascii_title = """
                                     ▄▄                                                                                                          
  ▄▄█▀▀▀█▄█                          ██      ▄█▀▀▀█▄█                                              ▀███▀▀▀██▄         ▀███                       
▄██▀     ▀█                                 ▄██    ▀█                                                ██   ▀██▄          ██                       
██▀       ▀ ▄██▀██▄▀███▄███ ▄█▀████████     ▀███▄    ▄██▀██▀███▄███▀███  ▀███ ▀████████▄█████▄       ██   ▄██  ▄██▀██▄  ██  ▄██▀  ▄▄█▀██▀███▄███ 
██         ██▀   ▀██ ██▀ ▀▀▄██  ██   ██       ▀█████▄█▀  ██  ██▀ ▀▀  ██    ██   ██    ██    ██       ███████  ██▀   ▀██ ██ ▄█    ▄█▀   ██ ██▀ ▀▀ 
██▄        ██     ██ ██    ▀█████▀   ██     ▄     ▀███       ██      ██    ██   ██    ██    ██       ██       ██     ██ ██▄██    ██▀▀▀▀▀▀ ██     
▀██▄     ▄▀██▄   ▄██ ██    ██        ██     ██     ███▄    ▄ ██      ██    ██   ██    ██    ██       ██       ██▄   ▄██ ██ ▀██▄  ██▄    ▄ ██     
  ▀▀█████▀  ▀█████▀▄████▄   ███████▄████▄   █▀█████▀ █████▀▄████▄    ▀████▀███▄████  ████  ████▄   ▄████▄      ▀█████▀▄████▄ ██▄▄ ▀█████▀████▄   
                           █▀     ██                                                                                                             
                           ██████▀                                                                                                               
"""

const ascii_1 = """
   ░░   
  ▒▒▒   
   ▒▒   
   ▓▓   
   ██   
"""

const ascii_2 = """
░░░░░░  
     ▒▒ 
 ▒▒▒▒▒  
▓▓      
███████ 
"""

const ascii_3 = """
░░░░░░  
     ▒▒ 
 ▒▒▒▒▒  
     ▓▓ 
██████  
"""

const ascii_4 = """
░░   ░░ 
▒▒   ▒▒ 
▒▒▒▒▒▒▒ 
     ▓▓ 
     ██ 
"""

const ascii_5 = """
░░░░░░░ 
▒▒      
▒▒▒▒▒▒▒ 
     ▓▓ 
███████ 
"""

const ascii_6 = """
 ░░░░░░  
▒▒       
▒▒▒▒▒▒▒  
▓▓    ▓▓ 
 ██████  
"""

const ascii_7 = """
░░░░░░░ 
     ▒▒ 
   ▒▒   
  ▓▓    
  ██    
"""

const ascii_8 = """
 ░░░░░  
▒▒   ▒▒ 
 ▒▒▒▒▒  
▓▓   ▓▓ 
 █████  
"""

const ascii_unknown = """
░░░░░░░
▒▒   ▒▒
   ▒▒▒
   ▀▀
   ██
"""

const ascii_cafe = """
  ░ ░    
 ░ ░   
 ████▄ 
 ████ █
 ████▀ 
"""

