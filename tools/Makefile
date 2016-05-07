
haxe= haxe

all: ../rxpattern/GeneralCategory.hx

UnicodeData.txt:
	curl -o $@ http://www.unicode.org/Public/UCD/latest/ucd/UnicodeData.txt

UnicodeData-8.0.0.txt:
	curl -o $@ http://www.unicode.org/Public/8.0.0/ucd/UnicodeData.txt

UnicodeData-7.0.0.txt:
	curl -o $@ http://www.unicode.org/Public/7.0.0/ucd/UnicodeData.txt

UnicodeData-6.3.0.txt:
	curl -o $@ http://www.unicode.org/Public/6.3.0/ucd/UnicodeData.txt

UnicodeData-6.2.0.txt:
	curl -o $@ http://www.unicode.org/Public/6.2.0/ucd/UnicodeData.txt

UnicodeData-6.1.0.txt:
	curl -o $@ http://www.unicode.org/Public/6.1.0/ucd/UnicodeData.txt

../rxpattern/GeneralCategory.hx: GenGeneralCategory.hs UnicodeData.txt
	runghc GenGeneralCategory.hs > $@

.PHONY: all


# $(call test-targets,<name>,<Main Class>)
define test-targets
$1-neko:
	$(haxe) -main $2 -cp .. -x $1

$1-js:
	$(haxe) -main $2 -cp .. -js $1.js -cmd "node $1.js"

$1-php:
	$(haxe) -main $2 -cp .. -php $1-php -cmd "php $1-php/index.php"

$1-python:
	$(haxe) -main $2 -cp .. -python $1.py -cmd "python3 $1.py"

$1-lua:
	$(haxe) -main $2 -cp .. -lua $1.lua -cmd "lua $1.lua"

$1-cpp:
	$(haxe) -main $2 -cp .. -cpp $1-cpp -cmd "$1-cpp/$2"

$1-java:
	$(haxe) -main $2 -cp .. -java $1-java -cmd "java -jar $1-java/$2.jar"

$1-cs:
	$(haxe) -main $2 -cp .. -cs $1-cs

$1-swf:
	$(haxe) -main $2 -cp .. -swf $1.swf

$1-all: $1-neko $1-js $1-php $1-python $1-lua $1-cpp $1-java

clean-$1:
	-rm $1.n $1.js $1.py $1.lua $1.swf
	-rm -r $1-php $1-cpp $1-java $1-cs

clean: clean-$1

.PHONY: clean-$1 $1-neko $1-js $1-php $1-python $1-lua $1-cpp $1-java $1-cs $1-swf
endef

$(eval $(call test-targets,PlatformReport,PlatformReport))

.PHONY: clean
