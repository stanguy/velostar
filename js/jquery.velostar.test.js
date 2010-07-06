var original_ajax = jQuery.ajax;
var TEST_KEY = 'this is a key';

module( "fetching data with ajax", {
    setup : function() {
        jQuery.ajax = function( opts ) {
            console.log( opts );
            ok( TEST_KEY == opts.data.key, "ajax call with a key" );
            opts.success( {
                opendata : {
                    request : "test"
                }
            } );
        };
    },
    teardown : function() {

    }
} );

test( "fetch without key", function() {
    equals( null, $.veloStar.getStations(),
            "returns null if no key is provided" );
} );

test( "fetch with key", function() {
    expect( 2 );
    ok( null != $.veloStar.getStations( TEST_KEY ), "result from getstation" );
} );

var TEST_DATA_GETSTATION_FAILED = {
    opendata : {
        request : 'test-data-url',
        answer : {
            status : {
                '@attributes' : {
                    code : 4,
                    message : 'Failed for some reason'
                }
            }
        }
    }
};

var TEST_DATA_GETSTATION_OK_SOURCE = {
    opendata : {
        request : 'test-data-url',
        answer : {
            status : {
                '@attributes' : {
                    code : 0,
                    message : 'OK'
                }
            },
            data : {
                station : [ {
                    id : 12,
                    number : 12,
                    name : "Station 12",
                    latitude : '48.1321',
                    longitude : '-1.63528',
                    district : 'DISTRICT 1'
                } ]
            }
        }
    }
};

var TEST_DATA_GETSTATION_OK = {
    opendata : {
        request : 'test-data-url',
        answer : {
            status : {
                '@attributes' : {
                    code : 0,
                    message : 'OK'
                }
            },
            data : {
                station : [ {
                    id : 12,
                    number : 12,
                    name : "Station 12",
                    latitude : 48.1321,
                    longitude : -1.63528,
                    district : 'DISTRICT 1'
                }, {
                    id : 13,
                    number : 13,
                    name : "Station 13",
                    latitude : 48.1322,
                    longitude : -1.63568,
                    district : 'DISTRICT 2'
                }, {
                    id : 14,
                    number : 14,
                    name : "Station 14",
                    latitude : 48.1323,
                    longitude : -1.63528,
                    district : 'DISTRICT 1'
                }, {
                    id : 15,
                    number : 15,
                    name : "Station 15",
                    latitude : 48.1324,
                    longitude : -1.63528,
                    district : 'DISTRICT 2'
                } ]
            }
        }
    }
};

module( "type conversion", {
    setup : function() {
        jQuery.ajax = function( opts ) {
            opts.success( TEST_DATA_GETSTATION_OK_SOURCE );
        };
    },
    teardown : function() {

    }
} );

test( "type conversion", function() {
    var data = $.veloStar.getStations( TEST_KEY );
    ok( "number" == ( typeof data.opendata.answer.data.station[ 0 ].latitude ),
            "is the lat/lon a number?" );
} );

module( "Districts" );

test( "list districts without data", function() {
    var districts = $.veloStar.listDistricts();
    ok( null == districts, "listDistricts returned an incorrect value" );
} );

test( "list districts with invalid data", function() {
    var districts = $.veloStar.listDistricts( TEST_DATA_GETSTATION_FAILED );
    ok( null == districts, "listDistricts returned an incorrect value" );
} );

test( "list districts", function() {
    var districts = $.veloStar.listDistricts( TEST_DATA_GETSTATION_OK );
    ok( null != districts && ( "object" == ( typeof districts ) ),
            "listDistricts returned an incorrect value" );
    var count = 0;
    $.each( districts, function( k, v ) {
        count++;
    } );
    equals( count, 2, "number of districts" );
} );

module( "misc" );

var STATIONS_POUR_BOUNDING_BOX = [ {
    latitude : 48.2,
    longitude : -1
}, {
    latitude : 47.2,
    longitude : -1.2
}, {
    latitude : 48.3,
    longitude : -0.9
}, {
    latitude : 48.1,
    longitude : -1.3
}, {
    latitude : 48.2,
    longitude : -1
} ];

var BOUNDING_BOX_RESULT = [ {
    latitude : 47.2,
    longitude : -1.3
}, {
    latitude : 48.3,
    longitude : -0.9
} ];

test( "bounding box for empty list", function() {
    var bbox = $.veloStar.getBoundingBox( [] );
    equals( bbox, null, "bounding box is null" );
} );

test( "bounding box for list", function() {
    var bbox = $.veloStar.getBoundingBox( STATIONS_POUR_BOUNDING_BOX );
    same( bbox, BOUNDING_BOX_RESULT, "bounding box is correct" );
} );

test( "distance between points", function() {
    var p1 = {
        latitude : 48.111269,
        longitude : -1.667338
    };
    var p2 = {
        latitude : 48.110836,
        longitude : -1.667760
    };
    var dist = 57.494;
    var computed_distance = jQuery.veloStar.distVincenty( p1.latitude,
            p1.longitude, p2.latitude, p2.longitude );
    equals( computed_distance, dist );
} );
