module ScrumPoker

using Genie, Logging, LoggingExtras

function main()
  Base.eval(Main, :(const UserApp = ScrumPoker))

  Genie.genie(; context = @__MODULE__)

  Base.eval(Main, :(const Genie = ScrumPoker.Genie))
  Base.eval(Main, :(using Genie))
end

end
