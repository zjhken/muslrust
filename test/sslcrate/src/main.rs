extern crate openssl_sys;
use std::env;

fn main() {
    let pr = openssl_sys::probe::ProbeResult {
        cert_file: None,
        cert_dir: Some(env::current_dir().unwrap()),
    };
    println!("Hello {}", pr.cert_dir.unwrap().display());
}
