fn say_hello(someone: &str) -> String {
    format!("Hello, {}!", someone)
}

fn main() {
    println!("{}", say_hello("world"));
}

#[cfg(test)]
mod tests {
    use crate::say_hello;

    #[test]
    fn it_says_hello() {
        assert_eq!(say_hello("world"), "Hello, world!");
    }
}