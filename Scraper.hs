-- Simple scraper for getting the markdown, using the perl script

import X
import qualified Data.Map as M
import System.FilePath.Posix
import Data.Char
import Data.List
import qualified System.Process as P
import System.Directory
--import Web.Encodings

main = do
        -- Here are the files we are trying to generates
        -- For now, just POPL
        let nodes = [ (a,t) | x@(a,b,_,_,t,_,_,_,_,_,_,_,_,_,_) <- dr_node ] -- , a == "124" ]
--        print nodes

        -- next, look up the name of
        let aliases = M.fromList [ (a,b) | (_,a,b,_) <- dr_url_alias ]

        -- next, look up the name of
        let revisions = M.fromList [ (a,(t,txt)) | (a,b,_,t,txt,_,_,_,_) <- dr_node_revisions ]

--        print aliases

        let generate nm t = do
                case M.lookup ("node/" ++ nm) aliases of
                  Nothing -> print ("Can not find", nm)
                  Just alias0 -> do
                          let alias1 = if takeFileName alias0 == "Main"
                                       then takeDirectory alias0
                                       else alias0
                          let fileName = "content/" ++ alias1 ++ ".md"
                          createDirectoryIfMissing True (takeDirectory fileName)
--                          print (fileName,takeDirectory fileName,t)
                          case M.lookup nm revisions of
                             Nothing -> print ("Can not find in dr_node_revisions", nm)
                             Just (t',txt) | t /= t' -> print ("title mismatch",t,t',nm)
                             Just (t',txt) -> do
                               txt' <- markdown nm txt
                               writeFile fileName $ unlines
                                ["---"
                                ,"layout: default"
                                ,"title: " ++ "\"" ++ escape t ++ "\""
                                ,"---"
                                ] ++ escape (filter (/= '\r') txt')
                                  ++ (if last txt' == '\n' then "" else "\n")

        sequence_ [ generate nm t
                  | (nm,t) <- nodes
                  ]

escape :: String -> String
escape xs = concatMap f xs
  where
{-
     f '"' = "&quot;"
     f '\'' = "&apos;"
     f '&' = "&amb;"
     f '<' = "&lt;"
     f '>' = "&gt;"
-}
     f x | ord x > 126 = "&#" ++ show (ord x) ++ ";"
         | otherwise          = [x]

-- convert to markdown
markdown :: String -> String -> IO String
markdown nm txt
        | "</" `isInfixOf` txt = do
                -- Suspect HTML
                print $ "FIXING " ++ show nm
                writeFile "tmp.html" txt
                P.callCommand "pandoc tmp.html -o tmp.md"
                txt <- readFile "tmp.md"
                return txt
        | otherwise = return txt


-- check that all the inputs are expected. Empty list is good

sanity = [ (a,b) | (a,b,_,_,_,_,_,_,_,_,_,_,_,_,_) <- dr_node, a /= b ]
      ++ [ (a,b) | (a,b,_,_,_,_,_,_,_) <- dr_node_revisions, a /= b ]