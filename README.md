# aqua

aqua is a small interpreted programming language implemented in Ruby.

# Requirements

- Ruby 3.4 or later

# Usage

For example, save the following code as factorial.aq.

```
def f(n) {
  if (n == 0) {
    1
  } else {
    n * f(n -1)
  }
}

f(1)
f(2)
f(3)
f(4)
f(5)
f(6)
f(7)
f(8)
f(9)
f(10)
```

Then run it like this:

```bash
./aqua -v factorial.aq
```

Output:

```
❯ ./aqua -v factorial.aq
1
2
6
24
120
720
5040
40320
362880
3628800
```

# Development

Clone the repository and run it locally.

```bash
git clone https://github.com/hashimoto-kei/aqua.git
cd aqua
```
