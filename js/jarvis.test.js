
module( "min_element" );

test( "simple data set", function() {
    var data = [
        { x: 1, y: 1 },
        { x: 3, y: 3 },
        { x: 3, y: 4 }
    ];
    var r = jarvis.min_element( data );
    ok( r == 0 );
});

test( "simple data set with random order", function() {
    var data = [
        { x: 3, y: 3 },
        { x: 1, y: 1 },
        { x: 3, y: 4 }
    ];
    var r = jarvis.min_element( data );
    ok( r == 1 );
});

test( "data set with points with the same Y value must return the leftmost", function() {
    var data = [
        { x: 3, y: 1 },
        { x: 1, y: 1 },
        { x: 3, y: 4 }
    ];
    var r = jarvis.min_element( data );
    ok( r == 1 );
});

module( "bearing" );

test( "simple1", function() {
    var b = jarvis.bearing( { x: 0, y: 0 }, { x: 1, y: 0 } );
    equals( b, 90 );
});
test( "simple2", function() {
    b = jarvis.bearing( { x: 0, y: 0 }, { x: 0, y: 1 } );
    equals( b, 0 );
});
test( "simple 45 deg", function() {
    b = jarvis.bearing( { x: 0, y: 0 }, { x: 1, y: 1 } );
    equals( Math.ceil( b ), 45 );
});
test( "real to the right", function() {
    b = jarvis.bearing( { x:  -1.620755, y:  48.114116 }, { x: -1.617381, y: 48.114116 });
    equals( Math.round( b ), 90 );
});
test( "real to the left", function() {
    b = jarvis.bearing( { x: -1.617381, y: 48.114116 }, { x:  -1.620755, y:  48.114116 } );
    equals( Math.round( b ), -90 );
});
test( "real top right", function() {
    // right, top
    b = jarvis.bearing( { x:  -1.620755, y:  48.114116 }, { x: -1.618786, y: 48.115401} );
    equals( Math.floor( b ), 45 );
});
test( "real top left", function() {
    // left up
    b = jarvis.bearing( { x:  -1.620755, y:  48.114116 }, { x: -1.622724, y: 48.115401} );
    equals( Math.ceil( b ), -45 );
});
test( "real right bottom", function() {
    // right, bottom
    b = jarvis.bearing( { x:  -1.620755, y:  48.114116 }, { x: -1.618786, y: 48.112800} );
    equals( Math.floor( b ), 90+45 );
});
test( "real bottom left", function() {
    // left bottom
    b = jarvis.bearing( { x:  -1.620755, y:  48.114116 }, { x: -1.622724, y: 48.112800} );
    equals( Math.ceil( b ), -(45+90) );
});

module( "walk" );

test( "triangle only", function() {
    var points = [{ x: 1, y: 1 }, { x: 2, y: 1}, { x: 2, y: 2 }];
    var r = jarvis.walk( points );
    same( r, [ 0, 1, 2 ]);
});

test( "triangle only with inner point", function() {
    var points = [{ x: 1, y: 1 }, { x: 4, y: 2}, { x: 5, y: 1 }, { x: 5, y: 6 }];
    var r = jarvis.walk( points );
    same( r, [ 0, 2, 3 ]);
});

test( "square", function() {
    var points = [{ x: 1, y: 1}, { x: 3, y: 1 }, { x: 3, y: 3 }, { x: 1, y: 3 } ];
    var r = jarvis.walk( points );
    same( r, [ 0, 1, 2, 3 ] );
});

test( "unordered square", function() {
    var points = [{ x: 1, y: 3}, { x: 1, y: 1 }, { x: 3, y: 1 }, { x: 3, y: 3 } ];
    var r = jarvis.walk( points );
    same( r, [ 1, 2, 3, 0 ] );
});

test( "unordered square with inside point", function() {
    var points = [{ x: 1, y: 3}, { x: 1, y: 1 }, { x: 3, y: 1 }, { x: 3, y: 3 }, { x: 2, y: 2 } ];
    var r = jarvis.walk( points );
    same( r, [ 1, 2, 3, 0 ] );
});

test( "inner point has better (higher than horizon) angle than next outer point", function(){
    ok( false, "not written" );
} );