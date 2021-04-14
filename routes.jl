using Genie.Router, Genie.Requests, Genie.Responses, Genie.Renderer, Genie.Renderer.Html, Genie.Sessions

using Genie.Assets

Genie.config.websockets_server = true

route("/login", named=:login_url) do
    html(:login, :login, layout=:scrumpoker)
end

route("/scrum", named=:scrum_url) do
    Assets.channels_support() *
    """
    <h1 id=alias></h1>
    <script>
    const queryString = window.location.search;
    const urlParams = new URLSearchParams(queryString);
    const alias = urlParams.get('alias');
    document.getElementById('alias').innerHTML = alias;
    sessionStorage.setItem("scrum_alias", alias);
    </script>
    """
end

channel("/__/echo") do
    "$(getpayload(:alias, "none"))"
end
