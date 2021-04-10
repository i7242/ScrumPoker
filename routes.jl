using Genie.Router, Genie.Requests, Genie.Responses, Genie.Renderer, Genie.Sessions, Genie.Renderer.Html

mutable struct User
    alias::String
    poker::String
end
scrum_data = Dict{String, User}()

Sessions.init()

route("/") do
    # get session id corresponding to current request
    # avoid users login multiple times
    sid = Sessions.id(request())
    if haskey(scrum_data, sid)
        redirect(:scrum_url)
    else
        redirect(:login_url)
    end
end

route("/login", named=:login_url) do
    html(:login, :login, layout=:scrumpoker)
end

route("/login/update", named=:update_user_info_url) do 
    alias = get(@params, :alias, "")
    if length(strip(alias)) > 0
        sid = Sessions.id()
        sess, resp = Sessions.start(sid, request(), getresponse())
        scrum_data[sid] = User(alias, "")
        redirect(:scrum_url)
    else
        redirect(:login_url)
    end
end

route("/scrum", named=:scrum_url) do
    sid = Sessions.id(request())
    alias = scrum_data[sid].alias
    html(:scrum, :scrum, alias=alias, layout=:scrumpoker)
end
