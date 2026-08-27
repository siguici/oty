# Oty 🐘

**Oty** is a strongly typed, object-oriented superset of PHP designed to evolve the PHP programming language while preserving its programming model, semantics, and ecosystem.

Oty extends PHP with an expressive static type system and a concise object-oriented syntax while keeping PHP syntax, data structures, functions, conventions, and object model at its core.

* 📄 **Pure Source Files:** Oty source files use the `.oty` extension and contain pure Oty code.
* ⚡ **Native Compiler:** `oty` is a standalone compiler written in [V](https://vlang.io/).
* 🐘 **PHP Target:** Oty transpiles to standard PHP and runs on the PHP runtime.
* 🧩 **Object-Oriented by Design:** PHP values can be accessed through an object-oriented syntax while relying on existing PHP operations and functions.
* ✨ **Concise Syntax:** Semicolons and commas may be omitted when line breaks unambiguously separate statements or elements.

---

## ✨ Type System

Oty provides a powerful static type system designed around the PHP programming model.

### Core Types

* Type aliases
* Generic parameters
* Generic applications
* Union types
* Intersection types
* Type constraints
* Inferred types
* Indexed access types
* Conditional types
* Mapped types
* Utility types
* Template literal types
* `infer`
* Opaque types
* Structs

### Array Shapes

Oty supports statically typed PHP arrays using PHP-like array syntax:

```oty
type User = [
    'id' => int,
    'name' => string,
    'email' => string|null,
]
```

PHP arrays remain PHP arrays at runtime.

---

## 🧩 Object-Oriented Syntax

Oty provides an object-oriented way to work with PHP values while preserving their underlying PHP semantics.

```oty
$a = [1, 2, 3]

echo $a->count()
```

Oty uses existing PHP operations and functions when lowering these expressions rather than introducing a separate runtime or collection system.

---

## 🚀 Quick Start

Create an Oty source file:

```oty
namespace App\Domain

type UserId = int

type User = [
    'id' => UserId
    'name' => string
]

class UserRepository
{
    public function find(UserId $id): User
    {
        return [
            'id' => $id
            'name' => 'John Doe'
        ]
    }
}
```

Transpile the file:

```bash
oty path/to/UserRepository.oty
```

You can also transpile an entire directory:

```bash
oty path/to/project/
```

Oty produces standard PHP source files that can be executed by a PHP 8.2+ runtime.

---

## ⚙️ Installation

### Requirements

* PHP 8.2+
* [V](https://vlang.io/) when building `oty` from source

### Build from Source

```bash
git clone https://github.com/siguici/oty.git
cd oty

v -prod . -o oty
```

Then transpile an Oty file or directory:

```bash
./oty path/to/file.oty
```

---

## 🐘 PHP Compatibility

Oty is designed to work naturally within the existing PHP ecosystem.

Transpiled code targets standard PHP and can be used with existing PHP applications, libraries, Composer packages, and development tools.

The initial target is **PHP 8.2+**. Specific PHP target versions may be introduced as Oty evolves.

---

## 💡 Philosophy

> **Oty is PHP, evolved.**

Oty takes inspiration from modern language and type-system design without adopting another language's programming model.

PHP remains the foundation:

* arrays remain arrays;
* classes remain classes;
* objects remain objects;
* PHP functions remain available;
* PHP conventions remain conventions;
* the PHP runtime remains the target.

Oty improves the way PHP code is written without requiring a new runtime or a separate ecosystem.

---

## 🤝 Contributing

Contributions, bug reports, and language proposals are welcome.

```bash
git clone https://github.com/siguici/oty.git
cd oty

v test .
```

For significant language changes, please open an issue before submitting a pull request.

---

## 📜 License

MIT © [Sigui Kessé Emmanuel](https://github.com/siguici)
