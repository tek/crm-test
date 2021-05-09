import Neovim (neovim, defaultConfig, plugins, Neovim, NeovimPlugin, Plugin(..), wrapPlugin, def)
import Neovim.Context.Internal (asks', customConfig)
import Ribosome.Control.Monad.Ribo (Ribo)
import Ribosome.Control.Ribosome (Ribosome, newRibosome)
import Ribosome.Error.Report (reportError)
import Ribosome.Plugin (RpcDef, cmd, riboPlugin, rpcHandler)
import Ribosome.Internal.IO (retypeNeovim)
import Ribosome.Data.Mapping (MappingError)
import Ribosome.Prelude (deepPrisms)
import Ribosome (RpcError)

data Error =
  Mapping MappingError
  |
  Rpc RpcError

deepPrisms ''Error

type Crm a = Ribo () Error a

initialize :: Neovim e (Ribosome ())
initialize = do
  ribo <- newRibosome "crm-test" ()
  retypeNeovim (const ribo) (asks' customConfig)

crmTest ::
  Monad m =>
  m Int
crmTest =
  pure 5

$(pure [])

rpcHandlers :: [[RpcDef (Ribo () Error)]]
rpcHandlers =
  [$(rpcHandler (cmd []) 'crmTest)]

plugin' :: Ribosome () -> Plugin (Ribosome ())
plugin' env =
  riboPlugin "crm-test" env rpcHandlers def (const (pure ())) def

plugin :: Neovim e NeovimPlugin
plugin =
  wrapPlugin . plugin' =<< initialize

main :: IO ()
main = neovim defaultConfig {plugins = [plugin]}
