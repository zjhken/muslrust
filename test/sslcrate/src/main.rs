extern crate openssl;
use std::str;
use openssl::crypto::hash;

fn main() {
    let data: &[u8] = b"Hello, world";
    let digest = hash::hash(hash::Type::SHA256, &data);

    println!("{}", str::from_utf8(data).ok().unwrap());
    println!("hash: {:?}", digest);
}
