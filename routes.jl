using Genie.Router, Genie.Requests, Genie.Responses
using Genie.Assets, Genie.Sessions
using Genie.Renderer, Genie.Renderer.Html, Stipple
using Base:@kwdef

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

const ascii_flip ="""
░░░░░░░ ░░      ░░ ░░░░░░  
▒▒      ▒▒      ▒▒ ▒▒   ▒▒ 
▒▒▒▒▒   ▒▒      ▒▒ ▒▒▒▒▒▒  
▓▓      ▓▓      ▓▓ ▓▓      
██      ███████ ██ ██      
"""


@kwdef mutable struct ScrumModel <: ReactiveModel
    # for Stipple, a default value is required
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
    # used for record, values are true vote values, votes are for flip positioning
    values::R{Dict{String, String}} = Dict{String, String}()
    votes::R{Dict{String, String}} = Dict{String, String}()
    users::R{Dict{String, String}} = Dict{String, String}()
    # control flip status, false hide value, true show value
    status::R{Bool} = false
    flip::R{Bool} = false
end

@kwdef mutable struct UserModel <: ReactiveModel
    alias::R{String} = ""
end



function login_ui()
    user_model = Stipple.init(UserModel(), channel="login")

    on(user_model.alias) do _
        ip = Genie.Requests.getheaders()["Origin"]
	scrum_model.users[][ip] = user_model.alias[]
    end

    page(vm(user_model), class="container", [
        pre(ascii_title)
        hr()
	form(input("", placeholder="Your Alias", name="alias", @bind(:alias)), action="/scrum")
    ], channel="login") |> html
end



scrum_model = Stipple.init(ScrumModel(), channel="scrum")

on(scrum_model.poker_1) do _
    ip = Genie.Requests.getheaders()["Origin"]
    if scrum_model.poker_1[] == true
        scrum_model.values[][scrum_model.users[][ip]] = ascii_1
        scrum_model.votes[][scrum_model.users[][ip]] = ascii_unknown
        scrum_model.poker_1[] = false
    end
end
on(scrum_model.poker_2) do _
    ip = Genie.Requests.getheaders()["Origin"]
    if scrum_model.poker_2[] == true
	scrum_model.values[][scrum_model.users[][ip]] = ascii_2
	scrum_model.votes[][scrum_model.users[][ip]] = ascii_unknown
        scrum_model.poker_2[] = false
    end
end

on(scrum_model.flip) do _
    if scrum_model.flip[]
	if scrum_model.status[]
	    scrum_model.status[] = false
	    scrum_model.votes[] = Dict{String, String}()
	    scrum_model.values[] = Dict{String, String}()
        else
	    scrum_model.status[] = true
	    scrum_model.votes[] = scrum_model.values[]
        end
	scrum_model.flip[] = false
    end
end

function scrum_ui()
    page(vm(scrum_model), class="container", [
        pre(ascii_title)
        hr()
	p([pre(poker*alias) for (alias, poker) in scrum_model.votes[]])
        hr()
        p([
	    button(pre(ascii_1), @click("poker_1 = true"))
            button(pre(ascii_2), @click("poker_2 = true"))
            button(pre(ascii_3))
            button(pre(ascii_4))
            button(pre(ascii_5))
            button(pre(ascii_6))
            button(pre(ascii_7))
            button(pre(ascii_8))
            button(pre(ascii_unknown))
            button(pre(ascii_cafe))
        ])
	p(button(pre(ascii_flip)), @click("flip = true"))
   ], channel="scrum") |> html
end



route("/login") do
    login_ui()
end
route("/scrum") do
    scrum_ui()
end

up()
