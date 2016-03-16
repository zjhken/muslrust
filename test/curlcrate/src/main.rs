extern crate curl;

use std::process;
use curl::http;

fn main() {
    let url = "https://raw.githubusercontent.com/clux/muslrust/master/test/curlcrate/src/main.rs";

    let resp = http::handle().get(url).exec().unwrap();
    let body = String::from_utf8_lossy(resp.get_body());
    println!("{}", body);
    process::exit(if resp.get_code() == 200 { 0 } else { 1 });
    // NB: This is a quine
}
