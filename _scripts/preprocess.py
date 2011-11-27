
import sys
import re

from pygments import highlight
from pygments.formatters import HtmlFormatter
from pygments.lexers import OocLexer

pattern = re.compile(
    r'(~{3,})(.+?)\1',
    re.S
)

formatter = HtmlFormatter( style='trac' )
lexer     = OocLexer()

sourceFile = open( sys.argv[ 1 ], 'r+' )
source = sourceFile.read()

matches = pattern.finditer( source )

for match in matches:
    source = source.replace( match.group(), highlight( match.group( 2 ), lexer, formatter ) )

sourceFile.seek( 0 )
sourceFile.write( source )
sourceFile.close()

css = formatter.get_style_defs( '.highlight' )
cssFile = open( sys.argv[ 2 ] + '/highlight.css', 'w' )
cssFile.write( '\n/* Pygments CSS for style "trac" */\n\n' )
cssFile.write( css )
cssFile.close()