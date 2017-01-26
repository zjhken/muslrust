extern crate hyper;
extern crate hyper_openssl;

use std::process;
use std::io::Read;
use std::env;
use hyper::Client;

use hyper::net::HttpsConnector;
use hyper_openssl::OpensslClient;

// simple request body fetcher
fn hyper_req(url: &str) -> String {
    let ssl = OpensslClient::new().unwrap();
    let connector = HttpsConnector::new(ssl);
    let client = Client::with_connector(connector);

    let mut res = client.get(url).send().unwrap();
    if res.status != hyper::Ok {
        println!("Failed to fetch url {}", url);
        process::exit(1);
    }
    let mut body = String::new();
    res.read_to_string(&mut body).unwrap();
    body
}

fn main() {
    // set SSL_CERT location - see issue #5
    // normally you'd want to set this in your docker container
    // but for plain bin distribution and this test, we set it here
    env::set_var("SSL_CERT_FILE", "/etc/ssl/certs/ca-certificates.crt");

    let url = "https://raw.githubusercontent.com/clux/muslrust/master/test/curlcrate/src/main.rs";

    // this only works with correct cert evar
    let _ = hyper_req(url);
    println!("HTTPS request succeeeded");

    process::exit(0);
}
