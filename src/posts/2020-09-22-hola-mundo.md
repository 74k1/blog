---
title: "¡Hola Mundo!"
date: 2020-09-22
desc: "A brief description of my first blog post"
image: "./images/waiheke-stony-batter.jpg"
tags: ["¡Hola Mundo!", "Hardware", "DIY"]
lang: "es"
updated: "2020-09-23T12:00:00Z"
---

¡Hola Mundo! ¡Estoy aquí!

<img
  alt="Grapevines among rolling hills leading to the sea"
  src="./images/waiheke-stony-batter.jpg"
  height="200"
/>

Haskell, por ejemplo:

```haskell
toSlug :: T.Text -> T.Text
toSlug =
  T.intercalate (T.singleton '-') . T.words . T.toLower . clean
```
