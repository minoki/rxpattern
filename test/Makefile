
haxe= haxe

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

$(eval $(call test-targets,Test,Test))
$(eval $(call test-targets,RxPatternTest,RxPatternTest))
$(eval $(call test-targets,UnicodeTest,UnicodeTest))
$(eval $(call test-targets,IntSetTest,IntSetTest))
$(eval $(call test-targets,Example,Example))

.PHONY: clean
