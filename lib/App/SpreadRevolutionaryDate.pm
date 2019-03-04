use strict;
use warnings;
use utf8;
use open qw(:std :utf8);
package App::SpreadRevolutionaryDate;

# ABSTRACT: Spread date and time from Revolutionary (Republican) Calendar on Twitter, Mastodon and Freenode.

use App::SpreadRevolutionaryDate::Config;
use App::SpreadRevolutionaryDate::Twitter;
use App::SpreadRevolutionaryDate::Mastodon;
use App::SpreadRevolutionaryDate::Freenode;
use DateTime::Calendar::FrenchRevolutionary;

=method new

Constructor class method. Takes one optional argument: C<$filename> which should be the file path of, or an opened file handle on your configuration file, defaults to C<~/.config/spread-revolutionary-date/spread-revolutionary-date.conf> or C<~/.spread-revolutionary-date.conf>. This is only used for testing, when cutsom configuration file is needed. You can safely leave this optional argument unset. Returns an C<App::SpreadRevolutionaryDate> object.

=cut

sub new {
  my $class = shift;
  my $filename = shift;
  my $config = App::SpreadRevolutionaryDate::Config->new;

  $config->parse_file($filename);
  $config->parse_command_line;
  
  my $self = {config => $config};

  if (!$self->{config}->twitter && !$self->{config}->mastodon && !$self->{config}->freenode) {
    $self->{config}->twitter(1);
    $self->{config}->mastodon(1);
    $self->{config}->freenode(1);
  }

  if ($self->{config}->twitter) {
    if ($self->{config}->check_twitter) {
      $self->{twitter} = App::SpreadRevolutionaryDate::Twitter->new($self->{config});
    }
  }

  if ($self->{config}->mastodon) {
    if ($self->{config}->check_mastodon) {
      $self->{mastodon} = App::SpreadRevolutionaryDate::Mastodon->new($self->{config});
    }
  }

  if ($self->{config}->freenode) {
    if ($self->{config}->check_freenode) {
      $self->{freenode} = App::SpreadRevolutionaryDate::Freenode->new($self->{config});
    }
  }

  bless $self, $class;
  return $self;
}

=method spread

Spreads calendar date to configured targets. Takes one optional boolean argument, if true (default) authentication and spreading to Freenode is performed, otherwise, you've got to run C<use POE; POE::Kernel->run();> to do so. This is only used for testing, when multiple bots are needed. You can safely leave this optional argument unset.

=cut

sub spread {
  my $self = shift;
  my $no_run = shift || 1;
  $no_run = !$no_run;

  my $now = DateTime->today->set(hour => 3, minute => 8, second => 56);
  my $msg = DateTime::Calendar::FrenchRevolutionary->from_object(object => $now)->strftime("Nous sommes le %A, %d %B de l'An %EY (%Y) de la Révolution, %Ej, il est %T!");

  $self->{twitter}->spread($msg) if $self->{twitter};
  $self->{mastodon}->spread($msg) if $self->{mastodon};
  $self->{freenode}->spread($msg, $no_run) if $self->{freenode};
}

1;
