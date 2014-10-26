package UAV::Pilot::Video::H264Decoder;
use v5.14;
use Moose;
use namespace::autoclean;

require DynaLoader;
our @ISA = qw(DynaLoader);
bootstrap UAV::Pilot::Video::H264Decoder;


with 'UAV::Pilot::Video::H264Handler';

has 'displays' => (
    is  => 'ro',
    isa => 'ArrayRef[Item]',
);


# Helper sub to simplifiy throwing exceptions in the xs code
sub _throw_error
{
    my ($class, $error_str) = @_;
    UAV::Pilot::VideoException->throw(
        error => $error_str,
    );
    return 1;
}

# Helper sub to iterate over all displays after processing a frame
sub _iterate_displays
{
    my ($self, $width, $height) = @_;
    foreach my $display (@{ $self->displays }) {
        $display->process_raw_frame( $width, $height, $self );
    }
    return 1;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__


=head1 NAME

    UAV::Pilot::Video::H264Decoder

=head1 SYNOPSIS

    # $display is some object that does the role UAV::Pilot::Video::RawHandler, like 
    # UAV::Pilot::SDL::Video
    my $display = ...;

    my $decoder = UAV::Pilot::Video::H264Decoder->new({
        displays => [ $display ],
    });

=head1 DESCRIPTION

Decodes a stream of h.264 frames using ffmpeg.  Does the
C<UAV::Pilot::Video::H264Handler> role.

=head1 FETCHING LAST PROCESSED FRAME

After a frame is decoded, there are two ways to fetch it: a fast way for things 
implemented in C, and a slow way for things implemented in Perl.

=head2 get_last_frame_c_obj

Returns a scalar which contains a pointer to the decoded AVFrame object.  In C, 
you can derefernce the pointer to get the AVFrame and handle it from there.

=head2 get_last_frame_pixel_arrayref

Converts data of the three YUV channels  into one array each, and then pushes 
those onto an array and returns the an arrayref.  This is really, really slow, 
and not at all suitable for real-time processing.  It has the advantage that you 
can do everything in Perl.

=cut
