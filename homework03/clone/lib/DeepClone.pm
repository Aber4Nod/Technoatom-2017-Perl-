package DeepClone;
# vim: noet:

use strict;
use warnings;

=encoding UTF8

=head1 SYNOPSIS

Клонирование сложных структур данных

=head1 clone($orig)

Функция принимает на вход ссылку на какую либо структуру данных и отдаюет, в качестве результата, ее точную независимую копию.
Это значит, что ни один элемент результирующей структуры, не может ссылаться на элементы исходной, но при этом она должна в точности повторять ее схему.

Входные данные:
* undef
* строка
* число
* ссылка на массив
* ссылка на хеш
Элементами ссылок на массив и хеш, могут быть любые из указанных выше конструкций.
Любые отличные от указанных типы данных -- недопустимы. В этом случае результатом клонирования должен быть undef.

Выходные данные:
* undef
* строка
* число
* ссылка на массив
* ссылка на хеш
Элементами ссылок на массив или хеш, не могут быть ссылки на массивы и хеши исходной структуры данных.

=cut

my %mem; my $key = 0;

sub clone {

  return undef if @_!=1;

  my $orig = shift;
  my $cloned;

  return $mem{$orig} if (defined $mem{$orig});
  return undef if not defined($orig);

  my $refT = ref $orig or return $orig;

  if ($refT eq 'ARRAY') {
    $mem{$orig} = $cloned = [];
    @$cloned = map { ! ref($_) ? $_ : clone($_) } @$orig;
  } elsif ($refT eq 'HASH') {
    $mem{$orig} = $cloned = {};
    %$cloned = map { ! ref($_) ? $_ : clone($_) } %$orig;
  } else {
    $key = 1;
    return undef;
  }
  return $key ? undef : $cloned;
}

1;
