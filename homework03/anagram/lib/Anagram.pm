package Anagram;
# vim: noet:
binmode(STDIN,':utf8');
binmode(STDOUT, ':utf8');
use utf8;

=head1 SYNOPSIS

Поиск анаграмм

=head1 anagram($arrayref)

Функция поиска всех множеств анаграмм по словарю.

Входные данные для функции: ссылка на массив - каждый элемент которого - слово на русском языке в кодировке utf8

Выходные данные: Ссылка на хеш множеств анаграмм.

Ключ - первое встретившееся в словаре слово из множества
Значение - ссылка на массив, каждый элемент которого слово из множества, в том порядке в котором оно встретилось в словаре в первый раз.

Множества из одного элемента не должны попасть в результат.

Все слова должны быть приведены к нижнему регистру.
В результирующем множестве каждое слово должно встречаться только один раз.
Например

anagram(['пятак', 'ЛиСток', 'пятка', 'стул', 'ПяТаК', 'слиток', 'тяпка', 'столик', 'слиток'])

должен вернуть ссылку на хеш


{
	'пятак'  => ['пятак', 'пятка', 'тяпка'],
	'листок' => ['листок', 'слиток', 'столик'],
}

=cut

sub anagram {
    my $words_list = shift;
    my %result; my %curCount; my $uniqueSort;

    $_ = lc for @$words_list;
    my @unique = do { my %exist; grep { !$exist{$_}++ } @$words_list };
    for my $curE (@unique) {
      $uniqueSort = join ("", sort (split //, $curE));
      if (!$curCount{$uniqueSort}) {
        $curCount{$uniqueSort} = $curE;
        $result{$curE} = [$curE];
      } else {
        push @{$result{$curCount{$uniqueSort}}}, $curE;
      }
    }

    for (keys %result) {
      if (@{$result{$_}} == 1) {
        delete $result{$_};
      }
    }

    return \%result;
}

1;
