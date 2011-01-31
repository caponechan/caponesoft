package HokkaidoBank;
use Mouse;
use WWW::Mechanize;
use utf8;
use strict;
use URI;
use Web::Scraper;
use YAML;
use DateTime;
my $uri = URI->new("https://www2.paweb.anser.or.jp/BS?CCT0080=0116");


has user => ( is => 'rw',
	isa => 'Str', 
	required => 1);
has pass => ( is => 'rw', 
	isa => 'Str', 
	required => 1);
has date =>  ( is => 'rw',
	isa => 'DateTime', 
	 );
has balance =>  ( is => 'rw',
	default => '0' ,
	isa => 'Num', 
	);
has uri =>  ( is => 'ro',
	isa => 'URI', 
	default => sub { URI->new("https://www2.paweb2a.anser.or.jp/BS?CCT0080=0116");},
	 );


sub BUILD {
my $self = shift;
my $mech = WWW::Mechanize->new;
$mech->get($self->uri);

my $res = $mech->submit_form(
    fields => {
        'BTX0010' => $self->user,
        'BPW0020' => $self->pass,
    },
);

$mech->success or die "postに失敗しました：";
my $sc =  scraper {#一行目の項目を飛ばす
  process '//td[6]', 'kingaku' => 'TEXT';
  process '//td[7]', 'hiniti' => 'TEXT';
};

my $dump = $sc->scrape($res);

$res = $mech->submit_form();
 $dump->{"kingaku"} =~ s/\D//g;
 $self->balance($dump->{"kingaku"});
 my $dt = DateTime->now(time_zone => 'Asia/Tokyo');
 $dump->{"hiniti"} =~ /(\d+)月(\d+)日/;
 my $dt2 = DateTime->now(time_zone => 'Asia/Tokyo');
  $dt2->set( month  => $1,
             day    => $2,
           );
my $d = $dt - $dt2 ;
if ( $d->is_negative ) { 
$dt2->add(years => -1);
}
$self->date($dt2);

}
1;
