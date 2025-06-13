alias b := build
alias bd := build_deploy

build:
	gleam run -m lustre/dev build app --minify
	mkdir -p dist
	cp index.html dist/index.html
	cp -r priv dist/priv
	sed -i 's|priv/static/app.mjs|priv/static/app.min.mjs|' dist/index.html

clean:
	rm -rf dist build

deploy:
	wrangler pages deploy dist --project-name pep-frontend

build_deploy: build deploy clean
