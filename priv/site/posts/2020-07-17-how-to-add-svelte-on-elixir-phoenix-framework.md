---
layout: posts/_post.slime
tag:
  - post
tags: 
  - elixir
  - phoenix
  - svelte
title: "How to add svelte on Elixir Phoenix Framework"
description: "A reminder on how to add svelte on Elixir Phoenix Framework with the minimum of enfort"
permalink: "post/how-to-add-svelte-on-elixir-phoenix-framework/index.html"
date: "2020-07-17"
---

## Adding the Svelte and Svelte-Loader

To do that, run this on the root dir of your phoenix project:
```bash
cd assets && npm install svelte svelte-loader --save
```

## Configuring the webpack

Based on: https://github.com/sveltejs/template-webpack

First add this on asserts/webpack.config.js:

```js
resolve: {
	alias: {
		svelte: path.resolve('node_modules', 'svelte')
	},
	extensions: ['.mjs', '.js', '.svelte'],
	mainFields: ['svelte', 'browser', 'module', 'main']
}
```

Then add:

```javascript
{
	test: /\.svelte$/,
	use: {
		loader: 'svelte-loader',
		options: {
			emitCss: true,
			hotReload: true
		}
	}
}
```

For the config explanations see: https://github.com/sveltejs/svelte-loader

## Adding the function on Phoenix

On your APP_web.ex in the function `view_helpers` add the function:

```elixir
@doc """
Will add a component from the asserts/js/svelte, the component must have the same `file_name`
"""
@spec svelte(bitstring(), map()) :: Phoenix.HTML.safe()
def svelte(file_name, props \\ %{}) do
  {:ok, props} = Jason.encode(props)

  tag =
    Phoenix.HTML.Tag.tag(:div,
      data: [props: props],
      class: "__svelte__-#{file_name}"
    )
    |> Phoenix.HTML.safe_to_string()

  Phoenix.HTML.raw(tag <> "</div>")
end
```

`Note: You can define this function in another file and import if you want a more clean solution`

## Mounting the svelte component

Finally we need to get the svelte file and mount on the element defined by the function above, for this we create a file `svelte.js` on assets/js/

```javascript
// This code will look in the assets/js/svelte/ and in the sub-directorys for
// .svelte files, the result of this files will be mounted on the element
// "svelte-file_name" who have props from the phoenix render(name, props)

// directory, useSubdirectories, regex
const context = require.context("./svelte", true, /\.svelte$/);

window.onload = function () {
  context.keys().forEach(file_path => {
    // name that will be requeride by render(name, props)
    const file_name = file_path.replace(/\.\/|\.svelte$/g, "");

    // COMPONENT
    const component_name = `svelte-${file_name}`;
    const component_container = document.getElementById(component_name);
    if (!component_container) {
      return;
    }

    // PROPS
    const { props } = component_container.dataset;
    let my_props = {};
    if (props) {
      my_props = JSON.parse(props);
    }

    // MOUNT ON
    const App = require(`./svelte/${file_name}`);

    new App.default({
      target: component_container,
      props: my_props
    });
  });
};
```

## Testing

Just create a component and add a
```elixir
<\%= svelte "YOUR_COMPONENT_FILE_NAME", %{some_var: "some value"} %>
```
on a template :)

Note 1: Yes, the YOUR\_COMPONENT\_FILE_NAME is the name of your file, please change it ;)

Note 2: The props will be used on your `export` variables on the svelte component
