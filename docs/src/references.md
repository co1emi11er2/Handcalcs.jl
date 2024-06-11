# References

## Disclaimer

Note that there are 3 macros exported. It is recommended to use `@handcalcs` mainly. The singular `@handcalc` macro is used by the `@handcalcs` macro. You may find `@handcalc` useful on certain occasions where you don't define a variable. For example:

```@example
using Handcalcs
a = 2
b = 3
@handcalc a + b
```

Besides this use case, `@handcalcs` macro can be used. The `@handfunc` macro should not be used anymore.

## References

```@index
```

```@autodocs
Modules = [Handcalcs]
```