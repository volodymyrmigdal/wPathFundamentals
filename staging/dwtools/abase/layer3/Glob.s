( function _Glob_s_() {

'use strict';

/**
 * @file Glob.s.
 */

if( typeof module !== 'undefined' )
{

  if( typeof _global_ === 'undefined' || !_global_.wBase )
  {
    let toolsPath = '../../../dwtools/Base.s';
    let toolsExternal = 0;
    try
    {
      toolsPath = require.resolve( toolsPath );
    }
    catch( err )
    {
      toolsExternal = 1;
      require( 'wTools' );
    }
    if( !toolsExternal )
    require( toolsPath );
  }

  let _ = _global_.wTools;

}

//

let _global = _global_;
let _ = _global_.wTools;
let Self = _.path = _.path || Object.create( null );

// --
// glob
// --

/*
(\*\*)| -- **
([?*])| -- ?*
(\[[!^]?.*\])| -- [!^]
([+!?*@]\(.*\))| -- @+!?*()
(\{.*\}) -- {}
(\(.*\)) -- ()
*/

// let transformation1 =
// [
//   [ /\[(.+?)\]/g, handleSquareBrackets ], /* square brackets */
//   [ /\{(.*)\}/g, handleCurlyBrackets ], /* curly brackets */
// ]
//
// let transformation2 =
// [
//   [ /\.\./g, '\\.\\.' ], /* double dot */
//   [ /\./g, '\\.' ], /* dot */
//   [ /([!?*@+]*)\((.*?(?:\|(.*?))*)\)/g, hanleParentheses ], /* parentheses */
//   [ /\/\*\*/g, '(?:\/.*)?', ], /* slash + double asterix */
//   [ /\*\*/g, '.*', ], /* double asterix */
//   [ /(\*)/g, '[^\/]*' ], /* single asterix */
//   [ /(\?)/g, '.', ], /* question mark */
// ]

// let _pathIsGlobRegexp = /(\*\*)|([?*])|(\[[!^]?.*\])|([+!?*@]?)|\{.*\}|(\(.*\))/;

let _pathIsGlobRegexpStr = '';
_pathIsGlobRegexpStr += '(?:[?*]+)'; /* asterix, question mark */
_pathIsGlobRegexpStr += '|(?:([!?*@+]*)\\((.*?(?:\\|(.*?))*)\\))'; /* parentheses */
_pathIsGlobRegexpStr += '|(?:\\[(.+?)\\])'; /* square brackets */
_pathIsGlobRegexpStr += '|(?:\\{(.*)\\})'; /* curly brackets */

let _pathIsGlobRegexp = new RegExp( _pathIsGlobRegexpStr );
function isGlob( src )
{
  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.strIs( src ) );

  /* let regexp = /(\*\*)|([!?*])|(\[.*\])|(\(.*\))|\{.*\}+(?![^[]*\])/g; */

  return _pathIsGlobRegexp.test( src );
}

//

function fromGlob( glob )
{
  let result;

  _.assert( _.strIs( glob ) );
  _.assert( arguments.length === 1, 'expects single argument' );

  let i = glob.search( /[^\\\/]*?(\*\*|\?|\*|\[.*\]|\{.*\}+(?![^[]*\]))[^\\\/]*/ );
  if( i === -1 )
  result = glob;
  else
  result = glob.substr( 0,i );

  /* replace urlNormalize by detrail */
  result = _.uri.normalize( result );

  // if( !result && _.path.realMainDir )
  // debugger;
  // if( !result && _.path.realMainDir )
  // result = _.path.realMainDir();

  return result;
}

//

/**
 * Turn a *-wildcard style _glob into a regular expression
 * @example
 * let _glob = '* /www/*.js';
 * wTools.globRegexpsForTerminalSimple( _glob );
 * // /^.\/[^\/]*\/www\/[^\/]*\.js$/m
 * @param {String} _glob *-wildcard style _glob
 * @returns {RegExp} RegExp that represent passed _glob
 * @throw {Error} If missed argument, or got more than one argumet
 * @throw {Error} If _glob is not string
 * @function globRegexpsForTerminalSimple
 * @memberof wTools
 */

function globRegexpsForTerminalSimple( _glob )
{

  function strForGlob( _glob )
  {

    let result = '';
    _.assert( arguments.length === 1, 'expects single argument' );
    _.assert( _.strIs( _glob ) );

    let w = 0;
    _glob.replace( /(\*\*[\/\\]?)|\?|\*/g, function( matched,a,offset,str )
    {

      result += _.regexpEscape( _glob.substr( w,offset-w ) );
      w = offset + matched.length;

      if( matched === '?' )
      result += '.';
      else if( matched === '*' )
      result += '[^\\\/]*';
      else if( matched.substr( 0,2 ) === '**' )
      result += '.*';
      else _.assert( 0,'unexpected' );

    });

    result += _.regexpEscape( _glob.substr( w,_glob.length-w ) );
    if( result[ 0 ] !== '^' )
    {
      result = _.strPrependOnce( result,'./' );
      result = _.strPrependOnce( result,'^' );
    }
    result = _.strAppendOnce( result,'$' );

    return result;
  }

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.strIs( _glob ) || _.strsAre( _glob ) );

  if( _.strIs( _glob ) )
  _glob = [ _glob ];

  let result = _.entityMap( _glob,( _glob ) => strForGlob( _glob ) );
  result = RegExp( '(' + result.join( ')|(' ) + ')','m' );

  return result;
}

//

function globRegexpsForTerminalOld( src )
{

  _.assert( _.strIs( src ) || _.strsAre( src ) );
  _.assert( arguments.length === 1, 'expects single argument' );

/*
  (\*\*\\\/|\*\*)|
  (\*)|
  (\?)|
  (\[.*\])
*/

  let map =
  {
    0 : '.*', /* doubleAsterix */
    1 : '[^\/]*', /* singleAsterix */
    2 : '.', /* questionMark */
    3 : handleSquareBrackets, /* handleSquareBrackets */
    '{' : '(',
    '}' : ')',
  }

  /* */

  let result = '';

  if( _.strIs( src ) )
  {
    result = adjustGlobStr( src );
  }
  else
  {
    if( src.length > 1 )
    for( let i = 0; i < src.length; i++ )
    {
      let r = adjustGlobStr( src[ i ] );
      result += `(${r})`;
      if( i + 1 < src.length )
      result += '|'
    }
    else
    {
      result = adjustGlobStr( src[ 0 ] );
    }
  }

  result = _.strPrependOnce( result,'\\/' );
  result = _.strPrependOnce( result,'\\.' );

  result = _.strPrependOnce( result,'^' );
  result = _.strAppendOnce( result,'$' );

  return RegExp( result );

  /* */

  function handleSquareBrackets( src )
  {
    debugger;
    src = _.strInsideOf( src, '[', ']' );
    // src = _.strIsolateInsideOrNone( src, '[', ']' );
    /* escape inner [] */
    src = src.replace( /[\[\]]/g, ( m ) => '\\' + m );
    /* replace ! -> ^ at the beginning */
    src = src.replace( /^\\!/g, '^' );
    return '[' + src + ']';
  }

  function curlyBrackets( src )
  {
    debugger;
    src = src.replace( /[\}\{]/g, ( m ) => map[ m ] );
    /* replace , with | to separate regexps */
    src = src.replace( /,+(?![^[|(]*]|\))/g, '|' );
    return src;
  }

  function globToRegexp()
  {
    let args = _.longSlice( arguments );
    let i = args.indexOf( args[ 0 ], 1 ) - 1;

    /* i - index of captured group from regexp is equivalent to key from map  */

    if( _.strIs( map[ i ] ) )
    return map[ i ];
    else if( _.routineIs( map[ i ] ) )
    return map[ i ]( args[ 0 ] );
    else _.assert( 0 );
  }

  function adjustGlobStr( src )
  {
    _.assert( !_.path.isAbsolute( src ) );

    /* espace simple text */
    src = src.replace( /[^\*\[\]\{\}\?]+/g, ( m ) => _.regexpEscape( m ) );
    /* replace globs with regexps from map */
    src = src.replace( /(\*\*\\\/|\*\*)|(\*)|(\?)|(\[.*\])/g, globToRegexp );
    /* replace {} -> () and , -> | to make proper regexp */
    src = src.replace( /\{.*\}/g, curlyBrackets );
    // src = src.replace( /\{.*\}+(?![^[]*\])/g, curlyBrackets );

    return src;
  }

}

//

function _globRegexpForTerminal( glob, filePath, basePath )
{
  let self = this;
  _.assert( arguments.length === 3 );
  if( basePath === null )
  basePath = filePath;
  if( filePath === null )
  filePath = basePath;
  if( basePath === null )
  basePath = filePath = this.fromGlob( glob );
  return self._globRegexpFor2.apply( self, [ glob, filePath, basePath ] ).terminal;
}

//

// let _globRegexpsForTerminal = _.routineVectorize_functor( _globRegexpForTerminal );
let _globRegexpsForTerminal = _.routineVectorize_functor
({
  routine : _globRegexpForTerminal,
  select : 3,
});

function globRegexpsForTerminal()
{
  let result = _globRegexpsForTerminal.apply( this, arguments );
  return _.regexpsAny( result );
}

//

function _globRegexpForDirectory( glob, filePath, basePath )
{
  let self = this;
  _.assert( arguments.length === 3 );
  if( basePath === null )
  basePath = filePath;
  if( filePath === null )
  filePath = basePath;
  if( basePath === null )
  basePath = filePath = this.fromGlob( glob );
  return self._globRegexpFor2.apply( self, [ glob, filePath, basePath ] ).directory;
}

//

// let _globRegexpsForDirectory = _.routineVectorize_functor( _globRegexpForDirectory );

let _globRegexpsForDirectory = _.routineVectorize_functor
({
  routine : _globRegexpForDirectory,
  select : 3,
});

function globRegexpsForDirectory()
{
  let result = _globRegexpsForDirectory.apply( this, arguments );
  return _.regexpsAny( result );
}

//

function _globRegexpFor2( glob, filePath, basePath )
{
  let self = this;

  _.assert( _.strIs( glob ) );
  _.assert( _.strIs( filePath ) );
  _.assert( _.strIs( basePath ) );
  _.assert( arguments.length === 3, 'expects single argument' );

  glob = this.join( filePath, glob );

  // let isRelative = this.isRelative( glob );
  let related = this.relateForGlob( glob, filePath, basePath );
  let maybeHere = '';
  // let maybeHere = '\\.?';

  // if( !isRelative || glob === '.' )
  // maybeHere = '';

  // if( isRelative )
  // glob = this.undot( glob );

  let hereEscapedStr = self._globSplitToRegexpSource( self._hereStr );
  let downEscapedStr = self._globSplitToRegexpSource( self._downStr );
  // let prefix = self.split( related[ 0 ] );

  let result = Object.create( null );
  result.directory = [];
  result.terminal = [];

  // debugger;
  for( let r = 0 ; r < related.length ; r++ )
  {
    related[ r ] = this.split( related[ r ] ).map( ( e, i ) => self._globSplitToRegexpSource( e ) );

    result.directory.push( self._globRegexpSourceSplitsJoinForDirectory( related[ r ] ) );
    result.terminal.push( self._globRegexpSourceSplitsJoinForTerminal( related[ r ] ) );

    // let groups = self._globSplitsToRegexpSourceGroups( related[ r ] );
    // result.directory.push( write( groups, 0, 1 ) );
    // result.terminal.push( write( groups, 0, 0 ) );

  }
  // debugger;

  result.directory = '(?:(?:' + result.directory.join( ')|(?:' ) + '))';
  result.directory = _.regexpsJoin([ '^', result.directory, '$' ]);
  result.terminal = '(?:(?:' + result.terminal.join( ')|(?:' ) + '))';
  result.terminal = _.regexpsJoin([ '^', result.terminal, '$' ]);

  // result.directory = [ _.regexpsAtLeastFirstOnly( prefix ).source, write( groups, 0, 1 ) ];
  // result.terminal = write( groups, 0, 0 );
  //
  // result.directory = '(?:(?:' + result.directory.join( ')|(' ) + '))';
  // // if( maybeHere )
  // // result.directory = '(?:' + result.directory + ')?';
  // result.directory = _.regexpsJoin([ '^', maybeHere, result.directory, '$' ]);
  //
  // result.terminal = _.regexpsJoin([ '^', maybeHere, result.terminal, '$' ]);

  return result;

  /* - */

  function write( groups, written, forDirectory )
  {

    if( _.strIs( groups ) )
    {
      if( groups === '.*' )
      return '(?:/' + groups + ')?';
      else if( written === 0 && ( groups === downEscapedStr || groups === hereEscapedStr ) )
      return groups;
      else if( groups === hereEscapedStr )
      return '(?:/' + groups + ')?';
      else
      return '/' + groups;
    }

    let joined = [];
    for( var g = 0 ; g < groups.length ; g++ )
    {
      let group = groups[ g ];
      let text = write( group, written, forDirectory );
      if( _.arrayIs( group ) )
      if( group[ 0 ] !== downEscapedStr )
      text = '(?:' + text + ')?';
      if( _.arrayIs( group ) && groups[ g ] === downEscapedStr )
      text = '(?:' + text + ')?';
      joined[ g ] = text;
      written += 1;
    }

    let result;

    if( forDirectory )
    // result = _.regexpsAtLeastFirst( joined ).source;
    result = _.regexpsAtLeastFirstOnly( joined ).source;
    else
    result = joined.join( '' );

    return result;
  }

}

//

let _globRegexpsFor2 = _.routineVectorize_functor
({
  routine : _globRegexpFor2,
  select : 3,
});

function globRegexpsFor2()
{
  let r = _globRegexpsFor2.apply( this, arguments );
  if( _.arrayIs( r ) )
  {
    let result = Object.create( null );
    result.terminal = r.map( ( e ) => e.terminal );
    result.directory = r.map( ( e ) => e.directory );
    // result.terminal = _.regexpsAny( r.map( ( e ) => e.terminal ) );
    // result.directory = _.regexpsAny( r.map( ( e ) => e.directory ) );
    return result;
  }
  return r;
}

//
//
// function _globRegexpFor( srcGlob )
// {
//   let self = this;
//
//   _.assert( _.strIs( srcGlob ) );
//   _.assert( arguments.length === 1, 'expects single argument' );
//
//   let isRelative = this.isRelative( srcGlob );
//   let maybeHere = '\\.?';
//
//   if( !isRelative || srcGlob === '.' )
//   maybeHere = '';
//
//   if( isRelative )
//   srcGlob = this.undot( srcGlob );
//
//   let hereEscapedStr = self._globSplitToRegexpSource( self._hereStr );
//   let downEscapedStr = self._globSplitToRegexpSource( self._downStr );
//   let groups = self._globSplitsToRegexpSourceGroups( srcGlob );
//   let result = Object.create( null )
//
//   result.directory = write( groups, 0, 1 );
//   result.terminal = write( groups, 0, 0 );
//
//   if( maybeHere )
//   result.directory = '(?:' + result.directory + ')?';
//   result.directory = _.regexpsJoin([ '^', maybeHere, result.directory, '$' ]);
//
//   result.terminal = _.regexpsJoin([ '^', maybeHere, result.terminal, '$' ]);
//
//   return result;
//
//   /* - */
//
//   function write( groups, written, forDirectory )
//   {
//
//     if( _.strIs( groups ) )
//     {
//       if( groups === '.*' )
//       return '(?:/' + groups + ')?';
//       else if( written === 0 && ( groups === downEscapedStr || groups === hereEscapedStr ) )
//       return groups;
//       else if( groups === hereEscapedStr )
//       return '(?:/' + groups + ')?';
//       else
//       return '/' + groups;
//     }
//
//     let joined = [];
//     for( var g = 0 ; g < groups.length ; g++ )
//     {
//       let group = groups[ g ];
//       let text = write( group, written, forDirectory );
//       if( _.arrayIs( group ) )
//       text = '(?:' + text + ')?';
//       if( _.arrayIs( group ) && groups[ g ] === downEscapedStr )
//       text = '(?:' + text + ')?';
//       joined[ g ] = text;
//       written += 1;
//     }
//
//     let result;
//
//     if( forDirectory )
//     result = _.regexpsAtLeastFirstOnly( joined ).source;
//     else
//     result = joined.join( '' );
//
//     return result;
//   }
//
// }
//
// //
//
// let _globRegexpsFor = _.routineVectorize_functor( _globRegexpFor );
// function globRegexpsFor()
// {
//   let r = _globRegexpsFor.apply( this, arguments );
//   if( _.arrayIs( r ) )
//   {
//     let result = Object.create( null );
//     result.terminal = _.regexpsAny( r.map( ( e ) => e.terminal ) );
//     result.directory = _.regexpsAny( r.map( ( e ) => e.directory ) );
//     return result;
//   }
//   return r;
// }
//
//

function globToRegexp( glob )
{

  _.assert( _.strIs( glob ) || _.regexpIs( glob ) );
  _.assert( arguments.length === 1 );

  if( _.regexpIs( glob ) )
  return glob;

  let str = this._globSplitToRegexpSource( glob );

  let result = new RegExp( str );

  return result;
}

// //
//
// function globSplit( glob )
// {
//   _.assert( arguments.length === 1, 'expects single argument' );
//
//   debugger;
//
//   return _.path.split( glob );
// }

//

function _globSplitsToRegexpSourceGroups( globSplits )
{
  let self = this;

  _.assert( _.arrayIs( globSplits ) );
  // _.assert( _.strIs( srcGlob ) );
  // _.assert( _.path.isRelative( srcGlob ) );
  _.assert( arguments.length === 1, 'expects single argument' );

  // let isRelative = this.isRelative( srcGlob );
  // let maybeHere = '(?:\\.|\\./)?';
  // if( !isRelative || srcGlob === '.' )
  // maybeHere = '';
  //
  // if( isRelative )
  // srcGlob = this.undot( srcGlob );

  // let splits = this.split( srcGlob );

  // splits = splits.map( ( e, i ) => self._globSplitToRegexpSource( e ) );

  _.assert( globSplits.length >= 1 );

  let s = 0;
  let depth = 0;
  let hereEscapedStr = self._globSplitToRegexpSource( self._hereStr );
  let downEscapedStr = self._globSplitToRegexpSource( self._downStr );
  let levels = levelsEval( globSplits );

  for( let s = 0 ; s < globSplits.length ; s++ )
  {
    let split = globSplits[ s ];
    if( _.strHas( split, '.*' ) )
    {
      let level = levels[ s ];
      if( level < 0 )
      {
        for( let i = s ; i < globSplits.length ; i++ )
        levels[ i ] += 1;
        levels.splice( s, 0, level );
        globSplits.splice( s, 0, '[^\/]*' );
      }
      else
      {
        while( levels.indexOf( level, s+1 ) !== -1 )
        {
          _.assert( 0, 'not tested' ); xxx
          levels.splice( s+1, 0, level );
          globSplits.splice( s+1, 0, '[^\/]*' );
          for( let i = s+1 ; i < globSplits.length ; i++ )
          levels[ i ] += 1;
        }
      }
    }
  }

  let groups = groupWithLevels( globSplits.slice(), levels, 0 );

  return groups;

  /* - */

  function levelsEval()
  {
    let result = [];
    let level = 0;
    for( let s = 0 ; s < globSplits.length ; s++ )
    {
      split = globSplits[ s ];
      if( split === downEscapedStr )
      level -= 1;
      result[ s ] = level;
      if( split !== downEscapedStr )
      level += 1;
    }
    return result;
  }

  /* - */

  function groupWithLevels( globSplits, levels, first )
  {
    let result = [];

    for( let b = first ; b < globSplits.length-1 ; b++ )
    {
      let level = levels[ b ];
      let e = levels.indexOf( level, b+1 );

      if( e === -1 /*|| ( b === 0 && e === globSplits.length-1 )*/ )
      {
        continue;
      }
      else
      {
        let inside = globSplits.splice( b, e-b+1, null );
        globSplits[ b ] = inside;
        inside = levels.splice( b, e-b+1, null );
        levels[ b ] = inside;
        groupWithLevels( globSplits[ b ], levels[ b ], 1 );
      }

    }

    return globSplits;
  }

}

//

function _globSplitToRegexpSource( src )
{

  _.assert( _.strIs( src ) );
  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( !_.strHas( src, this._downStr ) || src === this._downStr, 'glob should not has splits with ".." combined with something' );

  let transformation1 =
  [
    [ /\[(.+?)\]/g, handleSquareBrackets ], /* square brackets */
    [ /\{(.*)\}/g, handleCurlyBrackets ], /* curly brackets */
  ]

  let transformation2 =
  [
    [ /\.\./g, '\\.\\.' ], /* double dot */
    [ /\./g, '\\.' ], /* dot */
    [ /([!?*@+]*)\((.*?(?:\|(.*?))*)\)/g, hanleParentheses ], /* parentheses */
    [ /\/\*\*/g, '(?:\/.*)?', ], /* slash + double asterix */
    [ /\*\*/g, '.*', ], /* double asterix */
    [ /(\*)/g, '[^\/]*' ], /* single asterix */
    [ /(\?)/g, '.', ], /* question mark */
  ]

  let result = adjustGlobStr( src );

  return result;

  /* */

  function handleCurlyBrackets( src, it )
  {
    throw _.err( 'Globs with curly brackets are not supported' );
  }

  /* */

  function handleSquareBrackets( src, it )
  {
    let inside = it.groups[ 1 ];
    /* escape inner [] */
    inside = inside.replace( /[\[\]]/g, ( m ) => '\\' + m );
    /* replace ! -> ^ at the beginning */
    inside = inside.replace( /^!/g, '^' );
    if( inside[ 0 ] === '^' )
    inside = inside + '\/';
    return '[' + inside + ']';
  }

  /* */

  function hanleParentheses( src, it )
  {

    let inside = it.groups[ 2 ].split( '|' );
    let multiplicator = it.groups[ 1 ];
    multiplicator = _.strReverse( multiplicator );
    if( multiplicator === '*' )
    multiplicator += '?';

    _.assert( _.strCount( multiplicator, '!' ) === 0 || multiplicator === '!' );
    _.assert( _.strCount( multiplicator, '@' ) === 0 || multiplicator === '@' );

    let result = '(?:' + inside.join( '|' ) + ')';
    if( multiplicator === '@' )
    result = result;
    else if( multiplicator === '!' )
    result = '(?:(?!(?:' + result + '|\/' + ')).)*?';
    else
    result += multiplicator;

    /* (?:(?!(?:abc)).)+ */

    return result;
  }

  // /* */
  //
  // function curlyBrackets( src )
  // {
  //   debugger;
  //   src = src.replace( /[\}\{]/g, ( m ) => map[ m ] );
  //   /* replace , with | to separate regexps */
  //   src = src.replace( /,+(?![^[|(]*]|\))/g, '|' );
  //   return src;
  // }

  /* */

  function adjustGlobStr( src )
  {
    let result = src;

    // _.assert( !_.path.isAbsolute( result ) );

    result = _.strReplaceAll( result, transformation1 );
    result = _.strReplaceAll( result, transformation2 );

    // /* espace ordinary text */
    // result = result.replace( /[^\*\+\[\]\{\}\?\@\!\^\(\)]+/g, ( m ) => _.regexpEscape( m ) );

    // /* replace globs with regexps from map */
    // result = result.replace( /(\*\*\\\/|\*\*)|(\*)|(\?)|(\[.*\])/g, globToRegexp );

    // /* replace {} -> () and , -> | to make proper regexp */
    // result = result.replace( /\{.*\}/g, curlyBrackets );
    // result = result.replace( /\{.*\}+(?![^[]*\])/g, curlyBrackets );

    return result;
  }

}

//

function _globRegexpSourceSplitsJoinForTerminal( globRegexpSourceSplits )
{
  let result = '';
  // debugger;
  let splits = globRegexpSourceSplits.map( ( split, s ) =>
  {
    if( s > 0 )
    if( split == '.*' )
    split = '(?:(?:^|/)' + split + ')?';
    else
    split = '(?:^|/)' + split;
    return split;
  });

  // for( let g = 0 ; g < globRegexpSourceSplits.length ; g++ )
  // {
  //   let split = globRegexpSourceSplits[ g ];
  //   if( g > 0 && split !== '.*' && globRegexpSourceSplits[ g-1 ] !== '.*' )
  //   result += '/';
  //   result += split;
  // }

  result = splits.join( '' );
  // result = '^' + splits.join( '' ) + '$';
  return result;
}

//

function _globRegexpSourceSplitsJoinForDirectory( globRegexpSourceSplits )
{
  let result = '';
  let splits = globRegexpSourceSplits.map( ( split, s ) =>
  {
    if( s > 0 )
    if( split == '.*' )
    split = '(?:(?:^|/)' + split + ')?';
    else
    split = '(?:^|/)' + split;
    return split;
  });
  result = _.regexpsAtLeastFirst( splits ).source;
  return result;
}

//

function relateForGlob( glob, filePath, basePath )
{
  let self = this;
  let result = [];

  _.assert( arguments.length === 3, 'expects exactly three argument' );
  _.assert( _.strIs( glob ) );
  _.assert( _.strIs( filePath ) );
  _.assert( _.strIs( basePath ) );

  let glob1 = this.join( filePath, glob );
  // let downGlob = this.relative( basePath, glob1 );
  let r1 = this.relativeUndoted( basePath, filePath );
  let r2 = this.relativeUndoted( filePath, glob1 );
  let downGlob = this.dot( this.normalize( this.join( r1, r2 ) ) );

  result.push( downGlob );

  // if( _.strBegins( filePath, basePath ) )
  // return result;

  /* */

  if( !_.strBegins( basePath, filePath ) || basePath === filePath )
  return result;

  let common = this.common([ glob1, basePath ]);
  let glob2 = this.relative( common, glob1 );
  basePath = this.relative( common, basePath );

  if( basePath === '.' )
  {

    result.push( ( glob2 === '' || glob2 === '.' ) ? '.' : './' + glob2 );

  }
  else
  {

    let globSplits = this.split( glob2 );
    let globRegexpSourceSplits = globSplits.map( ( e, i ) => self._globSplitToRegexpSource( e ) );
    let s = 0;
    while( s < globSplits.length )
    {
      let globSliced = new RegExp( '^' + self._globRegexpSourceSplitsJoinForTerminal( globRegexpSourceSplits.slice( 0, s+1 ) ) + '$' );
      if( globSliced.test( basePath ) )
      {
        let splits = _.strHas( globSplits[ s ], '**' ) ? globSplits.slice( s ) : globSplits.slice( s+1 );
        let glob3 = splits.join( '/' );
        result.push( glob3 === '' ? '.' : './' + glob3  );
      }

      s += 1;
    }

  }

  /* */

  return result;

  // let common = this.common([ glob1, basePath ]);
  // let mandatory = this.dot( this.relative( basePath, glob1 ) );
  //
  // let optional;
  // if( common === basePath )
  // {
  //   let r1 = this.relative( common, '/' );
  //   let r2 = this.relative( '/', basePath );
  //   if( r1 === '.' )
  //   r1 = '';
  //   if( r2 === '.' )
  //   r2 = '';
  //   optional = this.join( r1, r2 );
  // }
  // else
  // {
  //   optional = this.relative( basePath, common );
  // }
  //
  // debugger;
  //
  // return [ optional, mandatory ];
}

/*
common : common glob base
common : /src2
glob : glob relative base
glob : **
optional : file relative common + common relative file
optional : ../src2
*/

//

function pathsRelateForGlob( filePath, oldPath, newPath )
{
  let length;

  let multiplied = _.multipleAll([ filePath, oldPath, newPath ]);

  filePath = multiplied[ 0 ];
  oldPath = multiplied[ 1 ];
  newPath = multiplied[ 2 ];

  _.assert( arguments.length === 3, 'expects exactly three argument' );

  if( _.arrayIs( filePath ) )
  {
    let result = [];
    for( let f = 0 ; f < filePath.length ; f++ )
    result[ f ] = this.relateForGlob( filePath[ f ], oldPath[ f ], newPath[ f ] );
    return result;
  }

  return this.relateForGlob( filePath, oldPath, newPath );
}

//

function globRecipeExtend( recipe, glob )
{
  let self = this;

  _.assert( arguments.length == 2 );
  _.assert( recipe === null || _.objectIs( recipe ) );

  if( recipe === null )
  recipe = Object.create( null );

  if( glob === null )
  return recipe;

  if( _.strIs( glob ) )
  glob = [ glob ];

  /* */

  if( _.mapIs( glob ) )
  {
    for( var g in glob )
    {
      if( !glob[ g ] || recipe[ g ] || recipe[ g ] === undefined )
      recipe[ g ] = glob[ g ];
    }
  }
  else if( _.arrayLike( glob ) )
  {
    for( var g = 0 ; g < glob.length ; g++ )
    {
      if( recipe[ glob[ g ] ] === undefined )
      recipe[ glob ] = true;
    }
  }
  else _.assert( 0, 'Expects glob' );

  return recipe;
}

// --
// fields
// --

let Fields =
{

  _rootStr : '/',
  _upStr : '/',
  _hereStr : '.',
  _downStr : '..',
  _hereUpStr : null,
  _downUpStr : null,

  _upEscapedStr : null,
  _butDownUpEscapedStr : null,
  _delDownEscapedStr : null,
  _delDownEscaped2Str : null,
  _delUpRegexp : null,
  _delHereRegexp : null,
  _delDownRegexp : null,
  _delDownFirstRegexp : null,
  _delUpDupRegexp : null,

  fileProvider : null,
  path : Self,

}

// --
// routines
// --

let Routines =
{

  // glob

  isGlob : isGlob,
  fromGlob : fromGlob,

  globRegexpsForTerminalSimple : globRegexpsForTerminalSimple,
  globRegexpsForTerminalOld : globRegexpsForTerminalOld,

  _globRegexpForTerminal : _globRegexpForTerminal,
  _globRegexpsForTerminal : _globRegexpsForTerminal,
  globRegexpsForTerminal : globRegexpsForTerminal,

  _globRegexpForDirectory : _globRegexpForDirectory,
  _globRegexpsForDirectory : _globRegexpsForDirectory,
  globRegexpsForDirectory : globRegexpsForDirectory,

  _globRegexpFor2 : _globRegexpFor2,
  _globRegexpsFor2 : _globRegexpsFor2,
  globRegexpsFor2 : globRegexpsFor2,

  // _globRegexpFor : _globRegexpFor,
  // _globRegexpsFor : _globRegexpsFor,
  // globRegexpsFor : globRegexpsFor,

  globToRegexp : globToRegexp,
  globsToRegexp : _.routineVectorize_functor( globToRegexp ),

  // globSplit : globSplit,
  _globSplitsToRegexpSourceGroups : _globSplitsToRegexpSourceGroups,
  _globSplitToRegexpSource : _globSplitToRegexpSource,
  _globRegexpSourceSplitsJoinForTerminal : _globRegexpSourceSplitsJoinForTerminal,
  _globRegexpSourceSplitsJoinForDirectory : _globRegexpSourceSplitsJoinForDirectory,

  relateForGlob : relateForGlob,
  pathsRelateForGlob : pathsRelateForGlob,
  globRecipeExtend : globRecipeExtend,

}

_.mapSupplement( Self, Fields );
_.mapSupplement( Self, Routines );

Self.Init();

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();