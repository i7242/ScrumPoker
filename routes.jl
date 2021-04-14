using Genie.Router, Genie.Requests, Genie.Responses, Genie.Renderer, Genie.Renderer.Html, Genie.Sessions

using Genie.Assets

Genie.config.websockets_server = true

login_users = Dict{String, String}()

Sessions.init()

function validate_and_redirect(sid::String)
    if haskey(login_users, sid)
        redirect(:scrum_url)
    else
        redirect(:login_url)
    end
end

route("/") do
    sid = Sessions.id(request())
    validate_and_redirect(sid)
end

route("/login", named=:login_url) do
    html(:login, :login, layout=:scrumpoker)
end

route("/login/update", named=:update_user_info_url) do 
    alias = get(@params, :alias, "")
    if length(strip(alias)) > 0
        sid = Sessions.id()
        sess, resp = Sessions.start(sid, request(), getresponse())
        login_users[sid] = alias
        redirect(:scrum_url)
    else
        redirect(:login_url)
    end
end

route("/scrum", named=:scrum_url) do
    # test to start a channel
    Assets.channels_support()

    Genie.WebChannels.broadcast("__", string(Genie.WebChannels.connected_clients()))
end
