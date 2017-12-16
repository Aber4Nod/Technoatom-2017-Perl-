#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";


# use this block if you don't need middleware, and only have a single target Dancer app to run here
use note_web;

note_web->to_app;

use Plack::Builder;

builder {
    enable 'Deflater';
    note_web->to_app;
}

=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use note_web;
use note_web_admin;

builder {
    mount '/'      => note_web->to_app;
    mount '/admin'      => note_web_admin->to_app;
}

=end comment

=cut

