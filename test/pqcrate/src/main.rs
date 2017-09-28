extern crate pq_sys;

fn main() {
    unsafe{ pq_sys::PQinitSSL(1); }
}
