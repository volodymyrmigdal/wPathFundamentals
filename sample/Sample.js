
if( typeof module !== 'undefined' )
require( 'wPathFundamentals' );
var _ = wTools;

var pathFile = '/a/b/c.x'
var name = _.path.pathName( pathFile );
console.log( 'name of ' + pathFile + ' is ' + name );
