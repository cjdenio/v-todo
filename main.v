import pg
import vweb

struct App {
	vweb.Context
mut:
	db pg.DB
}

fn main() {
	vweb.run<App>(3000)
}

pub fn (mut app App) init_once() {
	app.db = pg.connect(pg.Config {
		host: "localhost",
		port: 5432,
		user: "postgres",
		password: "postgres",
		dbname: "postgres"
	}) or { panic(err) }

	app.db.exec("create table if not exists items (id integer primary key, text varchar)") or { panic(err) }
}

fn (mut app App) index() vweb.Result {
	rows := app.db.exec("select text from items") or { panic(err) }
	items := rows.map(fn (row pg.Row) string {
		return row.vals[0]
	})

	len := items.len

	return $vweb.html()
}