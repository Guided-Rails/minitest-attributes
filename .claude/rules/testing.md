---
description: Rules for writing tests
globs: test/**/*.rb
---

- Do not use `setup` methods. Create the necessary objects inline within each test method.
- Use plain `Struct`s or small classes as records; the gem must not depend on ActiveRecord or ActiveSupport to be tested.
- Every branch of `assert_attributes` (plain, nil, Time, rich text) needs both a passing case and a failing case that checks the failure message.
