import pg
import vweb
import net.urllib
import os { getenv }
import rand { uuid_v4 }

struct App {
	vweb.Context
mut:
	db pg.DB
}

fn main() {
	vweb.run<App>(3000)
}

pub fn (mut app App) init_once() {
	url := urllib.parse(getenv('DB_URL')) or { panic(err) }

	app.db = pg.connect(pg.Config{
		host: url.hostname()
		port: url.port().int()
		user: url.user.username
		password: url.user.password
		dbname: url.path[1..]
	}) or { panic(err) }

	app.db.exec('create table if not exists items (id varchar primary key, text varchar)') or {
		panic(err)
	}
}

fn (mut app App) index() vweb.Result {
	rows := app.db.exec('select text from items') or { panic(err) }
	items := rows.map(fn (row pg.Row) string {
		return row.vals[0]
	})

	len := items.len

	return $vweb.html()
}

[post]
fn (mut app App) create() vweb.Result {
	id := uuid_v4()

	app.db.exec_param_many('insert into items (id, text) values ($1, $2)', [id, app.form['text']]) or {
		panic(err)
	}

	println(app.form['text'])
	println(app.form)

	return app.redirect('/')
}
