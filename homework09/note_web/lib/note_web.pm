package note_web;
use Dancer2;
use Dancer2::Plugin::CSRF;
use HTML::Entities;

use Digest::MD5 qw(md5_hex);
use Digest::CRC qw(crc32);
use Encode qw(encode);
our $VERSION = '1.00';

use FindBin;
use lib "$FindBin::Bin/../lib";
use DBApi;
use ConfApi;

use DDP;

my $confReader = ConfApi->new();
my $conf = $confReader->Get_conf(); 
my $dbFile = $conf->{DataBase};
my $db = DBApi->new(DataBase => $dbFile);

hook before => sub {
    if (request->is_post()) {
        my $csrf_token = body_parameters->get('csrf_token');
        if (!$csrf_token or !validate_csrf_token($csrf_token)) {
                redirect '/?err=2';
        }
    }
};

get '/' => sub {
    my $err;
    if (params('query')) {
        my $errNum = params('query')->{'err'};
        $err = $errNum == 1 ? "Invalid user or pswd" : "CSRF prevented";
    }

    template 'index' => { 
        csrf_token => get_csrf_token(),
        err => $err,
    };
};

post '/' => sub {
    my $user = body_parameters->get('user');
    $user =~ s/\n//;
    my $pswd = md5_hex(encode('utf8',body_parameters->get('pswd')));
    my $validator =  qr/[a-zA-Z0-9]{6,15}/;
    if ($user !~ $validator) {
        template 'index', {
            'err' => 'username should consists of letters, numbers and also its length must be > 6',
            csrf_token => get_csrf_token(),
        };
    } elsif (length($pswd) < 8) {
        template 'index', {
            'err' => 'length of the password should be > 8',
            csrf_token => get_csrf_token(),
        };
    } elsif ($db->CHECK_user_pswd($user, $pswd)) {
        session 'user' => $user;
        session 'user_id' => $db->GET_id($user);
        session 'logged_in' => true;
        redirect '/home';
    }
    else {
        redirect '/?err=1';
    };
};

get '/registration' => sub {
    template 'register' => { 
        'csrf_token' => get_csrf_token(),
         };
};

post '/registration' => sub {
    my $user = body_parameters->get('user');
    my $pswd = md5_hex(body_parameters->get('pswd'));
    my $validator =  qr/[A-Za-z0-9]{6,15}/;
    if ($user !~ $validator or length($pswd) < 8) {
        template 'register', {
            'err' => 'Invalid name or pswd',
            'csrf_token' => get_csrf_token(),
        };
    } elsif ($db->ADD_user($user, $pswd)) {
        redirect '/';
    } else {
        template 'register', {
            'err' => 'The user already exists',
            'csrf_token' => get_csrf_token(),
        };
    }
};

get '/home' => sub {
    if (!session('logged_in')) {
        redirect '/';
    }
    
    my $user_id = session('user_id');
    my $user = session('user');
    my $notes = $db->GET_notes($user_id);

    template 'home' => {
        'csrf_token' => get_csrf_token(),
        'user' => $user,
        'notes' => $notes,
    };
};

post '/home' => sub {
    my $logout = body_parameters->get('logout');
    if ($logout) {
        app->destroy_session;
        redirect '/';
    }
    my $user = session('user');
    my $user_id = session('user_id');
    my $title = body_parameters->get('title') || 'None';
    my $text = body_parameters->get('text');
    my $sharing = body_parameters->get('share');

    if (!session('logged_in')) {
        redirect '/';
    } elsif (!$text) {
        my $notes = $db->GET_notes($user_id);
        return template 'home' => { 
           'csrf_token' => get_csrf_token(),
           'err' => 'fill the TEXT field',
           'notes' => $notes,
           'user' => $user,
        };
    } else {
        foreach my $input ($title, $text) {
            encode_entities($input);
        }

    my $time = time;
    my $note_id = crc32($user_id.$title.$time);
    my @sharingUsers = (split '\r\n', $sharing);
    $db->ADD_note($note_id, $user_id, $time, $title, $text, \@sharingUsers);

    redirect '/home';
    }
};

get qr{^/note/([a-f0-9]{8})$} => sub {
    my ($note_id) = splat;
    my $id = unpack 'L', pack 'H*', $note_id;

    my $note = $db->GET_note($id);

    p $note;
    template 'ntredirect' => {
        'note' => $note,
    };
};

1;
