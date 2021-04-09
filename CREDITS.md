# Preface

Preface is a free (an open-source) library written in (and for)
[OCaml](https://ocaml.org) and released under the [MIT
license](LICENSE) The library is mainly maintained by:

- [Didier Plaindoux](https://github.com/d-plaindoux)
- [Pierre Ruyter](https://github.com/gr-im)
- [Xavier Van de Woestyne](https://github.com/xvw/)

### Warm thanks and help

- [Gabriel Scherer](https://github.com/gasche) for many design choice
  and technical help about specific subject
- [Andrey Mokhov](https://github.com/snowleopard) for his help in
  understanding Selectives (and Free Selective) and constant reviews
  related to Selectives
- [Florian Angeletti](https://github.com/Octachron) for advices and
  help
- [Oleg Kiselyov](http://okmij.org/ftp) for advices about Freer monad
- [XHTMLBoy](https://github.com/xhtmlboi) for providing an
  implementation of Freer capable of discarding the continuation
- [Pierre-Evariste
  Dagand](https://pages.lip6.fr/Pierre-Evariste.Dagand/) for a lot of
  help with Arrows

## Used libraries

Preface use several libraries (especially for unit tests). For more
information, feel free to refer to the OPAM files located at the root
of the project.  Here is a list of our dependancies:

- [Alcotest](https://github.com/mirage/alcotest) - for the definition
  of unit tests
- [QCheck](https://github.com/c-cube/qcheck) - for the definition of
  properties based testing (coupled with Alcotest)
- [Either](https://github.com/mirage/either) - for having an
  `Either.t` before OCaml `4.12`


## Used tools

In addition to [OCaml](https://ocaml.org), we use tools from the OCaml
ecosystem:

- [Dune](https://github.com/ocaml/dune) - as a build system (and task
  runner)
- [OCamlformat](https://github.com/ocaml-ppx/ocamlformat) - as a code
  formatter in order to keep our code formatted according to fixed
  standards.
- [Odoc](https://github.com/ocaml/odoc) - as a documentation
  generator.
- [mdx](https://github.com/realworldocaml/mdx) - for guide as tests

In addition, we use [Merlin](https://github.com/ocaml/merlin) and
[Tuareg](https://github.com/ocaml/tuareg) or [OCaml
mode](https://github.com/ocaml/caml-mode) as IDE. For the more
adventurous with more RAM
[IntelliJ](https://plugins.jetbrains.com/plugin/4986-ocaml-support).
