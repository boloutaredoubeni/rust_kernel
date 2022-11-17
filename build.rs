use std::process::Command;
use std::env;

fn main() {
    let out_dir = env::var("OUT_DIR").unwrap();

    // convert image to vmdk for use in other hypervisors
    let bin_file = format!("{}/bootimage-rust_kernel.bin", out_dir);
    let vmdk_file = format!("{}/bootimage-rust_kernel.vmdk", out_dir);
    Command::new("qemu-img").args(&["convert", "-f", "raw", "-O", "vmdk", &bin_file, &vmdk_file]).status().unwrap();
    println!("cargo:rerun-if-changed=build.rs");
}
