#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 1;

use AI::TensorFlow;
use Path::Tiny;

use lib 't/lib';

use FFI::Platypus::Buffer;
use FFI::Platypus::Memory;

subtest "Load graph" => sub {
	my $model_file = path("t/models/graph.pb");
	my $ffi = FFI::Platypus->new( api => 1 );
	my $buf = AI::TensorFlow::Buffer->_New;

	my $data = $model_file->slurp_raw;
	my ($pointer, $size) = scalar_to_buffer $data;
	$buf->data( $pointer );
	$buf->length( $size );
	my $closure = $ffi->closure(sub {
		my ($pointer, $size) = @_;
		free $pointer;
	});
	$buf->data_deallocator( $closure );
	note $buf;

	my $graph = AI::TensorFlow::Graph->_New;
	my $status = AI::TensorFlow::Status->_New;
	my $opts = AI::TensorFlow::ImportGraphDefOptions->_New;

	$graph->ImportGraphDef( $buf, $opts, $status );

	#$opts->_Delete;
	#$buf->_Delete;

	if( $status->GetCode eq 'OK' ) {
		print "Load graph success\n";
		pass;
	} else {
		fail;
	}

	#$status->_Delete;
	#$graph->_Delete;
	pass;
};

done_testing;
