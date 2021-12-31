use ckb_testtool::ckb_error::Error;
use ckb_testtool::ckb_types::bytes::Bytes;
use std::env;
use std::fs;
use std::path::PathBuf;

#[cfg(test)]
mod tests;

pub struct Loader(PathBuf);

impl Default for Loader {
    fn default() -> Self {
        let dir = env::current_dir().unwrap();
        let mut path = PathBuf::new();
        path.push(dir);
        path.push("..");
        path.push("zig-out");
        path.push("bin");
        Loader(path)
    }
}

impl Loader {
    pub fn load_binary(&self, name: &str) -> Bytes {
        let mut path = self.0.clone();
        path.push(name);
        fs::read(path).expect("binary").into()
    }
}

pub fn assert_script_error(err: Error, err_code: i8) {
    let error_string = err.to_string();
    assert!(
        error_string.contains(format!("error code {}", err_code).as_str()),
        "error_string: {}, expected_error_code: {}",
        error_string,
        err_code
    );
}
