#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 1;

use AI::TensorFlow;
use Path::Tiny;

use lib 't/lib';

subtest "Load graph" => sub {
	my $model_file = path("t/models/graph.pb");
	my $ffi = FFI::Platypus->new( api => 1 );

	my $data = $model_file->slurp_raw;
	my $buf = AI::TensorFlow::Buffer->NewFromData($data);
	ok $buf;

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
