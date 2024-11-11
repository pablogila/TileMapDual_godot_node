# How to contribute

So you have a cool idea for a new feature or a bug fix? Great! Just please consider the following guidelines before contributing:

## Submitting an issue

If you find a bug or have a feature request, please open an issue. This way, we can discuss the best way to implement it and avoid duplicated work.  

Please provide a clear description of your problem, including the steps to reproduce it, and an example if possible.  

## Submitting a pull request

You can go for the `master` branch for minor changes. For significant modifications, please submit your pull request in a custom branch created for the occasion.  

Also, don't forget:  

### Testing

Please make sure that the example scenes inside the `/tests/` folder work as intended. If not, please include a clear custom scene showcasing the dual-grid system in action. This scene should:  

- Update in-editor
- Update in-game
- Include a clear description of how to get it working
- Work for square and isometric tilemaps

If the [docuentation in the README file](README.md) needs updating, please at least indicate it somewhere to avoid confusion.  

### Code style

To make sure the code is consistent and easy to work with, please try to follow the [GDQuest GDScript guidelines](https://gdquest.gitbook.io/gdquests-guidelines/godot-gdscript-guidelines) as much as possible.  

Also, please try to avoid nesting up to infinity whenever possible. For example, instead of  

```gdscript
def test():
    if condition:
        do_something()
        ...
```

it is cleaner in the long run to use  

```gdscript
def test():
    if not condition:
        return
    do_something()
    ...
```

## Finally but most importantly

Be kind and nice to each other. We are all here to learn and improve, and we will surely make mistakes along the way. Dont' worry, we will fix them together.  

