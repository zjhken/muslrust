extern crate curl;

use std::process;
use curl::http;

fn main() {
    println!("Hello!");
    let url = "https://github.com/clux/muslrust/blob/master/README.md";
    let resp = http::handle().get(url).exec().unwrap();
    process::exit(if resp.get_code() == 200 { 0 } else { 1 });
}
