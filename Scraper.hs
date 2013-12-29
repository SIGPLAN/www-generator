-- Simple scraper for getting the markdown, using the perl script

import X
import qualified Data.Map as M

main = do
        -- Here are the files we are trying to generates
        let aliases = M.fromList [ (a,b) | (_,a,b) <- ar_url_alias ]


        print aliases


