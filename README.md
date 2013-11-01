An "easy" interface on top of the Xmlm [1] library.  This version provides more
convenient (but far less flexible) input and output functions that go to and
from [string] values.  This avoids the need to write signal code, which is
useful for quick scripts that manipulate XML.
   
More advanced users should go straight to the Xmlm library and use it
directly, rather than be saddled with the Ezxmlm interface.

[1] https://github.com/dbuenzli/xmlm
