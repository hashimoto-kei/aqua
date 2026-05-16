# Aqua

Aqua is a small interpreted programming language implemented in Ruby.

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

x = 0
while (x <= 10) {
  y = f(x)
  x = x + 1
  p(y)
}
```

Then run it like this:

```bash
./aqua factorial.aq
```

Output:

```
❯ ./aqua factorial.aq
1
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
