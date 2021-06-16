#!/usr/bin/env perl

use Test::More tests => 1;

use strict;
use warnings;

use AI::TensorFlow;
use List::Util qw(reduce);
use PDL;
use PDL::Core ':Internal';

use FFI::Platypus::Memory;
use FFI::Platypus::Buffer qw(scalar_to_pointer);

subtest "Allocate a tensor" => sub {
	my $ffi = FFI::Platypus->new( api => 1 );

	my @dims = ( 1, 5, 12 );
	my $ndims = scalar @dims;
	my $data_size_bytes = howbig(float) * reduce { $a * $b } (1, @dims);
	my $tensor = AI::TensorFlow::Tensor->_Allocate(
		AI::TensorFlow::DType::FLOAT,
		\@dims, $ndims,
		$data_size_bytes,
	);

	ok $tensor && $tensor->Data, 'Allocated tensor';

	my $pdl = sequence(float, @dims );
	my $pdl_ptr = scalar_to_pointer ${ $pdl->get_dataref };

	memcpy $tensor->Data, $pdl_ptr, List::Util::min( $data_size_bytes, $tensor->ByteSize );

	is $tensor->Type, AI::TensorFlow::DType::FLOAT, 'Check Type is FLOAT';
	is $tensor->NumDims, $ndims, 'Check NumDims';
};

done_testing;
