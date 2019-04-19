// The order of these extern crate lines matter for ssl!
extern crate openssl;
#[macro_use] extern crate diesel;
// openssl must be included before diesel atm.

use std::env;

fn main() {
    env_logger::init();

    let _db = {
        let url = std::env::var("DATABASE_URL")
            .unwrap_or("postgres://localhost?connect_timeout=1&sslmode=require".into());
        let size = env::var("DATABASE_POOL_SIZE")
            .map(|val| {
                val.parse::<u32>()
                    .expect("Error converting DATABASE_POOL_SIZE variable into u32")
            })
            .unwrap_or_else(|_| 5);

        crate::db::create_database_pool(&url, size)
    };

    {
        let mut input = String::new();
        std::io::stdin().read_line(&mut input).unwrap();
    }
}

pub(crate) mod db;
