
---

One day later and another urxvt extension - [man2pdf].

I've been converting man pages by hand for a long time, and since I gained more knowledge in writing extensions for urxvt I ported my shell code to make it easy for anyone wanting to convert man page while reading it.

With the shell alternative I had to quit reading the man page or open another instance/tab to convert the man page by hand, but with this extension the conversion is super easy.

```perl
#! /usr/bin/env perl
# Author:   Aaron Caffrey
# Website:  https://github.com/wifiextender/urxvt-man2pdf
# License:  GPLv3

# Usage: put the following lines in your .Xdefaults/.Xresources:
# URxvt.perl-ext-common           : man
# URxvt.keysym.Control-Shift-X    : perl:man:topdf
use strict;
use warnings;

sub on_user_command {
  my ($self, $cmd) = @_;

  if ($cmd eq "man:topdf") {
    my $cur_row = $self->nrow - 1;
    my $top = $self->top_row;

    while ($cur_row >= $top) {
      my $line_obj = $self->line ($cur_row);
      my $it_found_smth = $self->try_conversion ($line_obj->t);

      last if ($it_found_smth);
      $cur_row = $line_obj->beg - 1;
    }
  }
  ()
}

sub try_conversion {
  my ($self) = shift;
  my ($text) = @_;

  if ($text =~ /\([^)]*\)/) {
    $text =~ s/\([^)]*\)//g;             # strip (1) from printf(1)
    $text =~ s/(?!\-|\.)[[:punct:]]//g;  # strip [\$#@~!&*()\[\];,:?^`\\\/]+;
    my @arr = split(/\s+/, $text);
    my $page = $arr[$#arr] ? lc $arr[$#arr] : "";

    # the LESS pager line makes it easy for us
    if ($page =~ /\d+$/) {
      my @new_arr = split(" ", join(" ", @arr)); # strip left-right space
      if (lc $new_arr[0] eq "manual" and lc $new_arr[3] eq "line") {
        $page = lc $new_arr[2];
      }
    }

    if ($page ne "") {
      my $has_ext = `man -Iw $page`;  # to check for file extension

      if ($? == 0) {
        if (-w $ENV{"HOME"}) {
          my $pdf_dir = $ENV{"HOME"} . "/man2pdf";
          mkdir($pdf_dir, 0700) unless(-d $pdf_dir);

          if ($has_ext =~ /\.\w+$/) {
            $self->exec_async ("man -Tpdf $page > $pdf_dir/$page.pdf");
            $self->exec_async ("notify-send \"Trying to convert $pdf_dir/$page.pdf\"");
            return 1;
          }
        }
      }
    }
  }
  return 0;
}
```

The shell function that I've been using up until now:

```bash
manf() {
  man --troff "$1" | \
  gs -dBATCH -dNOPAUSE -dQUIET \
     -dSAFER -sDEVICE=pdfwrite \
     -sOutputFile="/tmp/$1_man.pdf" -
  exo-open "/tmp/$1_man.pdf"
}
```

[man2pdf]: https://github.com/wifiextender/urxvt-man2pdf
