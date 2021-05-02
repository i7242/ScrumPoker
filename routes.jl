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

const ascii_begin = """
░░  ░░ 
   ▒▒  
  ▒▒   
 ▓▓    
██  ██ 
       
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
    votes::R{Dict{String, String}} = Dict{String, String}()
    # votes_show is a single string, bind with pre() for auto update
    votes_show::R{String} = ascii_begin
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

# this is a process to split the ascii string, then recombine them into one row for display
function update_votes_show()
    tmp = Array{Union{Missing, String}}(missing, 6, length(scrum_model.votes[])+1)
    ct = 1
    # the "ascii_begin" has 7 row, the last is empty and throw it
    tmp[:, ct] = split(ascii_begin, r"\n")[1:6, 1]
    for (alias, poker) in scrum_model.votes[]
        ct += 1
        if scrum_model.status[]
            tmp[:, ct] = split(poker, r"\n")
        else
            tmp[:, ct] = split(ascii_unknown, r"\n")
        end
        tmp[6, ct] = alias
    end

    tmp_str = ""
    for i in 1:size(tmp, 1)
        for j in 1:size(tmp, 2)
            tmp_str *= (" "^4)*tmp[i, j]
        end
        tmp_str *= "\n"
    end
    scrum_model.votes_show[] = tmp_str
end

function update_votes(pk::String)
    ip = Genie.Requests.getheaders()["Origin"]
    scrum_model.votes[][scrum_model.users[][ip]] = pk
    update_votes_show()
end

on(scrum_model.poker_1) do _
    if scrum_model.poker_1[] == true
        update_votes(ascii_1)
        scrum_model.poker_1[] = false
    end
end

on(scrum_model.poker_2) do _
    if scrum_model.poker_2[] == true
        update_votes(ascii_2)
        scrum_model.poker_2[] = false
    end
end

on(scrum_model.poker_3) do _
    if scrum_model.poker_3[] == true
        update_votes(ascii_3)
        scrum_model.poker_3[] = false
    end
end

on(scrum_model.poker_4) do _
    if scrum_model.poker_4[] == true
        update_votes(ascii_4)
        scrum_model.poker_4[] = false
    end
end

on(scrum_model.poker_5) do _
    if scrum_model.poker_5[] == true
        update_votes(ascii_5)
        scrum_model.poker_5[] = false
    end
end

on(scrum_model.poker_6) do _
    if scrum_model.poker_6[] == true
        update_votes(ascii_6)
        scrum_model.poker_6[] = false
    end
end

on(scrum_model.poker_7) do _
    if scrum_model.poker_7[] == true
        update_votes(ascii_7)
        scrum_model.poker_7[] = false
    end
end

on(scrum_model.poker_8) do _
    if scrum_model.poker_8[] == true
        update_votes(ascii_8)
        scrum_model.poker_8[] = false
    end
end

on(scrum_model.poker_unknown) do _
    if scrum_model.poker_unknown[] == true
        update_votes(ascii_unknown)
        scrum_model.poker_unknown[] = false
    end
end

on(scrum_model.poker_cafe) do _
    if scrum_model.poker_cafe[] == true
        update_votes(ascii_cafe)
        scrum_model.poker_cafe[] = false
    end
end

on(scrum_model.flip) do _
    if scrum_model.flip[]
	    if scrum_model.status[]
	        scrum_model.votes[] = Dict{String, String}()
	        scrum_model.status[] = false
        else
	        scrum_model.status[] = true
        end
        update_votes_show()
	    scrum_model.flip[] = false
    end
end

function scrum_ui()
    page(vm(scrum_model), class="container", [
        pre(ascii_title)
        hr()
        p(pre("", @text(:votes_show)))
        hr()
        p([
	        button(pre(ascii_1), @click("poker_1 = true"))
            button(pre(ascii_2), @click("poker_2 = true"))
            button(pre(ascii_3), @click("poker_3 = true"))
            button(pre(ascii_4), @click("poker_4 = true"))
            button(pre(ascii_5), @click("poker_5 = true"))
            button(pre(ascii_6), @click("poker_6 = true"))
            button(pre(ascii_7), @click("poker_7 = true"))
            button(pre(ascii_8), @click("poker_8 = true"))
            button(pre(ascii_unknown), @click("poker_unknown = true"))
            button(pre(ascii_cafe), @click("poker_cafe = true"))
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

