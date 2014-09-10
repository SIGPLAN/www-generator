boot::
	perl mysql-to-haskell.pl > X.hs
	ghc -O0 X.hs
	ghci Main.hs

