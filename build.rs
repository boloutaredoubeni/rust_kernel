use std::process::Command;
use std::env;

fn main() {
    let out_dir = env::var("OUT_DIR").unwrap();

    // convert image to vmdk for use in other hypervisors
    Command::new("qemu-img").args(&["convert", "-f", "raw", "-O", "vmdk", "target/kernel/debug/bootimage-rust_kernel.bin", "target/kernel/debug/bootimage-rust_kernel.vmdk"]).status().unwrap();
    println!("cargo:rerun-if-changed=build.rs");
}
