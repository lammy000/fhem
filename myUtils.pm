##############################################
# $Id: 99_myUtils.pm 11984 2016-08-19 12:47:50Z rudolfkoenig $
package main;

use strict;
use warnings;
use POSIX;

sub
myUtils_Initialize($$)
{
  my ($hash) = @_;
}

######## VoIP Call mit sipcmd starten ############
######## Beispiel:
######## ({voipcall("Guten Tag hier ist Hans Wurst",'08003301000')})
sub
voipcall($$)
{
  my $text = shift;
  my $callnumber = shift;
  my $return_sipcmd = "";
  my $return_espeak = "";
  my $return_sox = "";
  my $ret = "";
  my $name = "FhemVoIP";
  my $konto = "user";
  my $passwrd = "pass";
  my $provider = "sip.de";
  my $protocol = "sip";
  my $audiofilefolder = "/opt/fhem/voip/messages/";
  my $audiofile = int(rand(9999-1));
  my $dateityp = ".wav";
  my $audiofileextentin = "_mono";
  my $clearcallident = "PlaybackAudioFile";
  Log 1, "-------- voipcall start --------";
  Log 1, "voipcall callnumber: $callnumber";
  Log 1, "voipcall Text: $text";
  Log 1, "voipcall Filename: $audiofile$dateityp";
  Log 1, "voipcall Debug Filename/Folder/Extention: $audiofilefolder$audiofile$dateityp";

  ####### espeak auführen #######
  $return_espeak .= qx(espeak '-vde+m4'  '$text' '-b 1' '-w $audiofilefolder$audiofile$dateityp');
  Log 1, "voipcall espeak returned: $return_espeak";
  ####### sox auführen #######
  $return_sox .= qx(sox '$audiofilefolder$audiofile$dateityp' '-b 16' '-c 1' '-r 8000' '$audiofilefolder$audiofile$audiofileextentin$dateityp');
  Log 1, "voipcall sox returned: $return_sox";

  ####### sipcmd auführen #######
  #system "echo sipcmd -P $protocol -u $konto -c '$passwrd' -w $provider -x 'c$callnumber;ws10000;$audiofilefolder$audiofile$audiofileextentin$dateityp;h'";
  $return_sipcmd .= qx(sipcmd -P $protocol -u $konto -c '$passwrd' -w $provider -x 'c$callnumber;ws1000;v$audiofilefolder$audiofile$audiofileextentin$dateityp;h' &);
  #system "sipcmd -P $protocol -u $konto -c '$passwrd' -w $provider -x 'c$callnumber;ws1000;v$audiofilefolder$audiofile$audiofileextentin$dateityp;h' &";
  $return_sipcmd =~ s,[\r\n]*,,g;    # remove CR from return-string
  ###### Prüfung ob die Konsolenausgabe von sipcmd die in die Variable $return_sipcmd geleitet wurde ein bestimmtes Wort enthält
  if(index($return_sipcmd,$clearcallident) > 0){
    Log 1, "voipcall sipcmd returned: call finished correctly";
  }
  else{
    Log 1, "voipcall sipcmd returned: call failed";
  }

  ####### Bereingung von nicht benötigten Dateien #######
  system "rm '$audiofilefolder$audiofile$dateityp' &";
  system "rm '$audiofilefolder$audiofile$audiofileextentin$dateityp' &";
  Log 1, "voipcall cleaning: nicht benoetigte Dateien wurden geloescht";
  Log 1, "-------- voipcall end --------";
}

1;
