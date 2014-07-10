module Part2 where

import Data.Array
import Data.Foldable

import qualified Data.String as S

type Edit = 
  { start :: Number
  , deleteCount :: Number
  , inserted :: String
  }

edit :: Edit -> String -> String
edit o s = S.take o.start s ++ 
	   o.inserted ++ 
	   S.drop (o.deleteCount + S.length o.inserted) s

type Script = [Edit]

edits :: Script -> String -> String
edits script s = foldl (\s e -> edit e s) s script

truncate :: Number -> Script -> Script
truncate len script = 
  let 
    init = take (length script - len + 1) script
    rest = drop (length script - len + 1) script
    
    truncated = { start: 0, deleteCount: 0, inserted: edits init "" } : rest
  in truncated
