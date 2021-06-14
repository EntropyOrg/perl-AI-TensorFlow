package AI::Libtensorflow;
# ABSTRACT: Bindings for Libtensorflow deep learning library

use strict;
use warnings;

use Capture::Tiny;
use Path::Tiny;

use FFI::Platypus;

my $ffi = FFI::Platypus->new( api => 1 );
$ffi->lib( $class->dl_file );
$ffi->mangler(sub {
  my($name) = @_;
  "TF_$name";
});

$ffi->type('object(AI::Libtensorflow::Status)'      => 'TF_Status');
$ffi->type('object(AI::Libtensorflow::Tensor)'      => 'TF_Tensor');

# ::Libtensorflow {{{
sub dl_file {
	return 'libtensorflow-cpu-linux-x86_64-2.5.0/lib/libtensorflow.so';
}

sub new {
	my ($class) = @_;
	bless {}, $class;
}

$ffi->attach( [ Version => 'version' ] => [], 'string' );#}}}
# ::Status {{{
package AI::Libtensorflow::Status {
}
#}}}
# ::DType {{{
$ffi->load_custom_type('::DType', 'TF_DataType',
	{ rev => 'int', package => 'AI::Libtensorflow::DType' },
	# from tensorflow/c/tf_datatype.h
  FLOAT      => 1,
  DOUBLE     => 2,
  INT32      => 3, #// Int32 tensors are always in 'host' memory.
  UINT8      => 4,
  INT16      => 5,
  INT8       => 6,
  STRING     => 7,
  COMPLEX64  => 8, #// Single-precision complex
  COMPLEX    => 8, #  // Old identifier kept for API backwards compatibility
  INT64      => 9,
  BOOL       => 10,
  QINT8      => 11,#    // Quantized int8
  QUINT8     => 12,#   // Quantized uint8
  QINT32     => 13,#   // Quantized int32
  BFLOAT16   => 14,# // Float32 truncated to 16 bits.  Only for cast ops.
  QINT16     => 15,#   // Quantized int16
  QUINT16    => 16,#  // Quantized uint16
  UINT16     => 17,
  COMPLEX128 => 18,# // Double-precision complex
  HALF       => 19,
  RESOURCE   => 20,
  VARIANT    => 21,
  UINT32     => 22,
  UINT64     => 23,
);

package AI::Libtensorflow::DType {

}#}}}
# ::Tensor {{{
package AI::Libtensorflow::Tensor {
  $ffi->attach( [ AllocateTensor => 'Allocate' ] => [], 'string' );
 AllocateTensor(TF_DataType,

                                                   const int64_t* dims,
                                                   int num_dims, size_t len);
  $ffi->attach();
}
#}}}

1;
# vim:fdm=marker
