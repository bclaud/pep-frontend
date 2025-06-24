alias b := build
alias bd := build_deploy

default:
	just --list

# build dist folder ready to be deployed on CDNs
build:
	gleam run -m lustre/dev build app --minify
	mkdir -p dist
	cp index.html dist/index.html
	cp -r priv dist/priv
	sed -i 's|priv/static/app.mjs|priv/static/app.min.mjs|' dist/index.html

# deletes dist folder
clean:
	rm -rf dist build

# Send to cloudflare pages
deploy:
	wrangler pages deploy dist --project-name pep-frontend

build_deploy: build deploy clean

# lustre dev server
dev:
	gleam run -m lustre/dev start
