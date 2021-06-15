package AI::Libtensorflow;
# ABSTRACT: Bindings for Libtensorflow deep learning library

use strict;
use warnings;

use Capture::Tiny;
use Path::Tiny;

use FFI::Platypus;
use FFI::C;

my $ffi = FFI::Platypus->new( api => 1 );
$ffi->lib( __PACKAGE__->dl_file );
$ffi->mangler(sub {
	my($name) = @_;
	"TF_$name";
});

$ffi->type('(opaque,size_t)->void', 'data_deallocator_t');
$ffi->type('(opaque,size_t,opaque)->void', 'tensor_deallocator_t');

# ::Libtensorflow {{{
sub dl_file {
	return 'libtensorflow-cpu-linux-x86_64-2.5.0/lib/libtensorflow.so';
}

sub new {
	my ($class) = @_;
	bless {}, $class;
}

$ffi->attach( [ Version => 'version' ] => [], 'string' );#}}}

# enum TF_Code {{{
# From <include/tensorflow/c/tf_status.h>
$ffi->load_custom_type('::Enum', 'TF_Code',
	OK                  => 0,
	CANCELLED           => 1,
	UNKNOWN             => 2,
	INVALID_ARGUMENT    => 3,
	DEADLINE_EXCEEDED   => 4,
	NOT_FOUND           => 5,
	ALREADY_EXISTS      => 6,
	PERMISSION_DENIED   => 7,
	UNAUTHENTICATED     => 16,
	RESOURCE_EXHAUSTED  => 8,
	FAILED_PRECONDITION => 9,
	ABORTED             => 10,
	OUT_OF_RANGE        => 11,
	UNIMPLEMENTED       => 12,
	INTERNAL            => 13,
	UNAVAILABLE         => 14,
	DATA_LOSS           => 15,
);
#}}}
# enum TF_DataType {{{
$ffi->load_custom_type('::Enum', 'TF_DataType',
	{ rev => 'int', package => 'AI::Libtensorflow::DType' },
	# from tensorflow/c/tf_datatype.h
	[ FLOAT      => 1 ],
	[ DOUBLE     => 2 ],
	[ INT32      => 3 ], #// Int32 tensors are always in 'host' memory.
	[ UINT8      => 4 ],
	[ INT16      => 5 ],
	[ INT8       => 6 ],
	[ STRING     => 7 ],
	[ COMPLEX64  => 8 ],  # // Single-precision complex
	#[ COMPLEX    => 8 ], # // Old identifier kept for API backwards compatibility
	[ INT64      => 9 ],
	[ BOOL       => 10 ],
	[ QINT8      => 11 ],#    // Quantized int8
	[ QUINT8     => 12 ],#   // Quantized uint8
	[ QINT32     => 13 ],#   // Quantized int32
	[ BFLOAT16   => 14 ],# // Float32 truncated to 16 bits.  Only for cast ops.
	[ QINT16     => 15 ],#   // Quantized int16
	[ QUINT16    => 16 ],#  // Quantized uint16
	[ UINT16     => 17 ],
	[ COMPLEX128 => 18 ],# // Double-precision complex
	[ HALF       => 19 ],
	[ RESOURCE   => 20 ],
	[ VARIANT    => 21 ],
	[ UINT32     => 22 ],
	[ UINT64     => 23 ],
);

package AI::Libtensorflow::DType {

}#}}}


FFI::C->ffi($ffi);

package AI::Libtensorflow::Buffer {#{{{
	FFI::C->struct( 'TF_Buffer' => [
		data => 'opaque',
		length => 'size_t',
		_data_deallocator => 'opaque', # data_deallocator_t
	]);

	$ffi->attach( [ 'NewBuffer' => '_New' ] => [] => 'TF_Buffer' );

	sub data_deallocator {
		my ($self, $closure) = shift;
		my $opaque = $ffi->cast('data_deallocator_t', 'opaque', $closure);
		$self->_data_deallocator( $opaque );
	}

	$ffi->attach( [ 'DeleteBuffer' => '_Delete' ] => [ 'TF_Buffer' ], 'void' );
}#}}}
package AI::Libtensorflow::Graph {#{{{
	FFI::C->struct( 'TF_Graph' => [
	]);

	$ffi->attach( [ 'NewGraph' => '_New' ] => [] => 'TF_Graph' );

	$ffi->attach( [ 'DeleteGraph' => '_Delete' ] => [ 'TF_Graph' ], 'void' );
}#}}}
package AI::Libtensorflow::Status {#{{{
	FFI::C->struct( 'TF_Status' => [
	]);

	$ffi->attach( [ 'NewStatus' => '_New' ] => [] => 'TF_Status' );

  $ffi->attach( 'GetCode' => [ 'TF_Status' ], 'TF_Code' );
	
	$ffi->attach( [ 'DeleteStatus' => '_Delete' ] => [ 'TF_Status' ], 'void' );
}#}}}
package AI::Libtensorflow::ImportGraphDefOptions {#{{{
	FFI::C->struct( 'TF_ImportGraphDefOptions' => [
	]);

	$ffi->attach( [ 'NewImportGraphDefOptions' => '_New' ] => [] => 'TF_ImportGraphDefOptions' );

	$ffi->attach( [ 'DeleteImportGraphDefOptions' => '_Delete' ] => [] => 'TF_ImportGraphDefOptions' );
}#}}}
package AI::Libtensorflow::Tensor {#{{{
	FFI::C->struct( 'TF_Tensor' => [
	]);

	$ffi->attach( [ 'NewTensor' => '_New' ] =>
		[ 'TF_DataType', # dtype

			'int64_t[]',   # (dims)
			'int',         # (num_dims)

			'opaque',      # (data)
			'size_t',      # (len)

			'opaque',      # tensor_deallocator_t (deallocator)
			'opaque',      # (deallocator_arg)
		],
		=> 'TF_Tensor' => sub {
			my ($xs, $class,
				$dtype,
				$dims, $num_dims,
				$data, $len,
				$deallocator, $deallocator_arg,
			) = @_;
			my $deallocator_ptr = $ffi->cast( 'tensor_deallocator_t', 'opaque', $deallocator);
			$xs->(
				$dtype,
				$dims, $num_dims,
				$data, $len,
				$deallocator_ptr, $deallocator_arg,
			);

		});
}
#}}}

$ffi->attach( [ GraphImportGraphDef => 'AI::Libtensorflow::Graph::ImportGraphDef' ],
	[ 'TF_Graph', 'TF_Buffer', 'TF_ImportGraphDefOptions', 'TF_Status' ],
	=> 'void',
);


__END__

# ::Status {{{
package AI::Libtensorflow::Status {
}
#}}}

1;
# vim:fdm=marker
