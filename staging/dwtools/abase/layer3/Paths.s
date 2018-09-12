( function _Paths_s_() {

'use strict';

/**
 * @file Paths.s.
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

  require( './Path.s' );

}

//

let _global = _global_;
let _ = _global_.wTools;
let Parent = _.path;
let Self = _.paths = _.paths || Object.create( Parent );

//

function _filterNoInnerArray( arr )
{
  return arr.every( ( e ) => !_.arrayIs( e ) );
}

//

function _filterOnlyPath( e,k,c )
{
  if( _.strIs( k ) )
  {
    if( _.strEnds( k,'Path' ) )
    return true;
    else
    return false
  }
  return this.is( e );
}

// --
// normalizer
// --

let refine = _.routineVectorize_functor
({
  routine : _.routineJoin( _.path,_.path.refine ),
  vectorizingArray : 1,
  vectorizingMap : 1,
});

let onlyRefine = _.routineVectorize_functor
({
  routine : _.routineJoin( _.path,_.path.refine ),
  fieldFilter : _filterOnlyPath,
  vectorizingArray : 1,
  vectorizingMap : 1,
});

//

let normalize = _.routineVectorize_functor
({
  routine : _.routineJoin( _.path,_.path.normalize ),
  vectorizingArray : 1,
  vectorizingMap : 1,
});

let onlyNormalize = _.routineVectorize_functor
({
  routine : _.routineJoin( _.path,_.path.normalize ),
  fieldFilter : _filterOnlyPath,
  vectorizingArray : 1,
  vectorizingMap : 1,
});

//

let dot = _.routineVectorize_functor
({
  routine : _.routineJoin( _.path,_.path.dot ),
  vectorizingArray : 1,
  vectorizingMap : 1,
})

let onlyDot = _.routineVectorize_functor
({
  routine : _.routineJoin( _.path,_.path.dot ),
  fieldFilter : _filterOnlyPath,
  vectorizingArray : 1,
  vectorizingMap : 1,
})

//

let undot = _.routineVectorize_functor
({
  routine : _.routineJoin( _.path,_.path.undot ),
  vectorizingArray : 1,
  vectorizingMap : 1,
})

let onlyUndot = _.routineVectorize_functor
({
  routine : _.routineJoin( _.path,_.path.undot ),
  fieldFilter : _filterOnlyPath,
  vectorizingArray : 1,
  vectorizingMap : 1,
})

// --
// path join
// --

let join = _.routineVectorize_functor
({
  routine : _.routineJoin( _.path,_.path.join ),
  vectorizingArray : 1,
  vectorizingMap : 1,
  select : Infinity
})

//

let reroot = _.routineVectorize_functor
({
  routine : _.routineJoin( _.path,_.path.reroot ),
  vectorizingArray : 1,
  vectorizingMap : 1,
  select : Infinity
})

//

let onlyReroot = _.routineVectorize_functor
({
  routine : _.routineJoin( _.path,_.path.reroot ),
  fieldFilter : _filterOnlyPath,
  vectorizingArray : 1,
  vectorizingMap : 1,
  select : Infinity
})

//

let resolve = _.routineVectorize_functor
({
  routine : _.routineJoin( _.path,_.path.resolve ),
  vectorizingArray : 1,
  vectorizingMap : 1,
  select : Infinity
})

//

let onlyResolve = _.routineVectorize_functor
({
  routine : _.routineJoin( _.path,_.path.resolve ),
  fieldFilter : _filterOnlyPath,
  vectorizingArray : 1,
  vectorizingMap : 1,
  select : Infinity
})


// --
// path cut off
// --

let dir = _.routineVectorize_functor
({
  routine : _.routineJoin( _.path, _.path.dir ),
  vectorizingArray : 1,
  vectorizingMap : 1,
  select : Infinity
})

//

let onlyDir = _.routineVectorize_functor
({
  routine : _.routineJoin( _.path, _.path.dir ),
  fieldFilter : _filterOnlyPath,
  vectorizingArray : 1,
  vectorizingMap : 1,
  select : Infinity
})

//

let prefixesGet = _.routineVectorize_functor
({
  routine : _.routineJoin( _.path,_.path.prefixGet ),
  vectorizingArray : 1,
  vectorizingMap : 1,
  select : Infinity
})

//

let onlyPrefixesGet = _.routineVectorize_functor
({
  routine : _.routineJoin( _.path,_.path.prefixGet ),
  fieldFilter : _filterOnlyPath,
  vectorizingArray : 1,
  vectorizingMap : 1,
  select : Infinity
})

//

let name = _.routineVectorize_functor
({
  routine : _.routineJoin( _.path,_.path.name ),
  vectorizingArray : 1,
  vectorizingMap : 1,
  select : Infinity
})

let onlyName = _.routineVectorize_functor
({
  routine : _.routineJoin( _.path,_.path.name ),
  vectorizingArray : 1,
  vectorizingMap : 1,
  select : Infinity,
  fieldFilter : function( e )
  {
    let path = _.objectIs( e ) ? e.path : e;
    return this.is( path );
  }
})

//

let withoutExt = _.routineVectorize_functor
({
  routine : _.routineJoin( _.path,_.path.withoutExt ),
  vectorizingArray : 1,
  vectorizingMap : 1,
  select : Infinity
})

//

let onlyWithoutExt = _.routineVectorize_functor
({
  routine : _.routineJoin( _.path,_.path.withoutExt ),
  fieldFilter : _filterOnlyPath,
  vectorizingArray : 1,
  vectorizingMap : 1,
  select : Infinity
})

//

function _changeExt( src )
{
  _.assert( _.longIs( src ) );
  _.assert( src.length === 2 );

  return _.path.changeExt.apply( this, src );
}

//

let changeExt = _.routineVectorize_functor
({
  routine : _changeExt,
  vectorizingArray : 1,
  vectorizingMap : 1,
  select : Infinity
})

//

let onlyChangeExt = _.routineVectorize_functor
({
  routine : _changeExt,
  vectorizingArray : 1,
  vectorizingMap : 1,
  select : Infinity,
  fieldFilter : function( e )
  {
    return this.is( e[ 0 ] )
  }
})

//

let ext = _.routineVectorize_functor
({
  routine : _.routineJoin( _.path,_.path.ext ),
  vectorizingArray : 1,
  vectorizingMap : 1,
  select : Infinity
})

//

let onlyExt = _.routineVectorize_functor
({
  routine :_.routineJoin( _.path,_.path.ext ),
  fieldFilter : _filterOnlyPath,
  vectorizingArray : 1,
  vectorizingMap : 1,
  select : Infinity
})

//

let exts = _.routineVectorize_functor
({
  routine : _.routineJoin( _.path,_.path.exts ),
  vectorizingArray : 1,
  vectorizingMap : 1,
  select : Infinity
})

// --
// path transformer
// --

let from = _.routineVectorize_functor
({
  routine : _.routineJoin( _.path,_.path.from ),
  vectorizingArray : 1,
  vectorizingMap : 1,
  select : Infinity
});

//

function _relative( o )
{
  _.assert( _.objectIs( o ) || _.longIs( o ) );
  let args = _.arrayAs( o );

  return _.path.relative.apply( this, args );
}

//

let relative = _.routineVectorize_functor
({
  routine : _.routineJoin( _.path,_.path.relative ),
  vectorizingArray : 1,
  vectorizingMap : 1,
  select : 2
})

//

function _filterForPathRelative( e )
{
  let paths = [];

  if( _.arrayIs( e ) )
  _.arrayAppendArrays( paths, e );

  if( _.objectIs( e ) )
  _.arrayAppendArrays( paths, [ e.relative, e.path ] );

  if( !paths.length )
  return false;

  return paths.every( ( path ) => this.is( path ) );
}

let onlyRelative = _.routineVectorize_functor
({
  routine : _.routineJoin( _.path,_.path.relative ),
  fieldFilter : _filterForPathRelative,
  vectorizingArray : 1,
  vectorizingMap : 1,
  select : Infinity
})

//

function _common()
{
  let parent = Object.getPrototypeOf( this );
  let args = arguments;

  if( args.length > 1 )
  args = [ _.longSlice( args ) ];

  return parent.common.apply( parent, args );
}

//

let common = _.routineVectorize_functor
({
  routine : _common,
  vectorizingArray : 1,
  vectorizingMap : 1,
  select : Infinity
})

//

let onlyCommon = _.routineVectorize_functor
({
  routine : _common,
  fieldFilter : _filterOnlyPath,
  vectorizingArray : 1,
  vectorizingMap : 1,
  select : Infinity
})

// --
// fields
// --

let Fields =
{
}

// --
// routines
// --

let Routines =
{
  _filterNoInnerArray : _filterNoInnerArray,
  _filterOnlyPath : _filterOnlyPath,

  // normalizer

  refine : refine,
  onlyRefine : onlyRefine,

  normalize : normalize,
  onlyNormalize : onlyNormalize,

  dot : dot,
  onlyDot : onlyDot,

  undot : undot,
  onlyUndot : onlyUndot,

  // path join

  join : join,

  reroot : reroot,
  onlyReroot : onlyReroot,

  resolve : resolve,
  onlyResolve : onlyResolve,

  // path cut off

  dir : dir,
  onlyDir : onlyDir,

  prefixesGet : prefixesGet,
  onlyPrefixesGet : onlyPrefixesGet,

  name : name,
  onlyName : onlyName,

  withoutExt : withoutExt,
  onlyWithoutExt : onlyWithoutExt,

  changeExt : changeExt,
  onlyChangeExt : onlyChangeExt,

  ext : ext,
  onlyExt : onlyExt,

  exts : exts,

  // path transformer

  from : from,

  relative : relative,
  onlyRelative : onlyRelative,

  common : common,
  onlyCommon : onlyCommon
}

_.mapExtend( Self, Fields );
_.mapExtend( Self, Routines );

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();