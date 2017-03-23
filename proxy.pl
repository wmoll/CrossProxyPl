use strict;
use warnings;

use LWP::UserAgent;
use HTML::Entities;
use JSON;

my $ua = new LWP::UserAgent;

my $waketime;
my $json;
{
  local $/;
  open my $fh, "<", "config.txt";
  $json = <$fh>;
  close $fh;
}
my $config = decode_json($json);

my $sleep_duration = $config->{'period'};

while (1) {
	$waketime = time + $sleep_duration;
    
	my $response = $ua->get($config->{'from'});
	unless ($response->is_success) {
		die $response->status_line;
	}
	my $content = $response->decoded_content();
	if (utf8::is_utf8($content)) {
		binmode STDOUT,':utf8';
	} else {
		binmode STDOUT,':raw';
	}
	
	my $contentPath = encode_entities($content);

	my $uri = $config->{'to'};
	my $json = '{"username":"'.$config->{'username'}.'","accesskey":"'.$config->{'accesskey'}.'","label":"'.$config->{'label'}.'","content":"'.$contentPath.'"}';
	my $req = HTTP::Request->new( 'POST', $uri );
	$req->header( 'Content-Type' => 'application/json' );
	$req->content( $json );

	my $lwp = LWP::UserAgent->new;
	my $response2 = $lwp->request( $req );
	
	print $response2->as_string();
    
    sleep($waketime-time);
}

	



	
        

