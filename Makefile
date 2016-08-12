build:
	mdbook build
	cd book && find . -iname '*.sw?' -delete

import:
	ghp-import book

publish:
	git push -f my gh-pages
