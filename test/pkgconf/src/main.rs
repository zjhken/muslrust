extern crate pkg_config;

use std::env;
use std::process;

fn main() {
    if let Ok(info) = pkg_config::find_library("openssl") {
        let paths = env::join_paths(info.include_paths).unwrap();
        println!("cargo:include={}", paths.to_str().unwrap());
        process::exit(0);
    }
    process::exit(1);
}
