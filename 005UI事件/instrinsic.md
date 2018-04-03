



1. UIView and NSView
No intrinsic content size.
2. Sliders
Defines only the width (iOS).
 Defines the width, the height, or both—depending on the slider’s type (OS X).
3. Labels, buttons, switches, and text fields
Defines both the height and the width.

4. Text views and image views
Intrinsic content size can vary.



> The intrinsic content size is based on the view’s current content. A label or button’s intrinsic content size is based on the amount of text shown and the font used. For other views, the intrinsic content size is even more complex. For example, an empty image view does not have an intrinsic content size. As soon as you add an image, though, its intrinsic content size is set to the image’s size
> 取决于文本内容


> A text view’s intrinsic content size varies depending on the content, on whether or not it has scrolling enabled, and on the other constraints applied to the view. For example, with scrolling enabled, the view does not have an intrinsic content size. With scrolling disabled, by default the view’s intrinsic content size is calculated based on the size of the text without any line wrapping. For example, if there are no returns in the text, it calculates the height and width needed to layout the content as a single line of text. If you add constraints to specify the view’s width, the intrinsic content size defines the height required to display the text given its width.
textView根据文本内容动态改变


1. Compression-Resistance ： 抗挤压 ，等级越高越不容易拉伸
2.  Content-Hugging：抗拉伸

> Whenever possible, use the view’s intrinsic content size in your layout. It lets your layout dynamically adapt as the view’s content changes. It also reduces the number of constraints you need to create a nonambiguous, nonconflicting layout, but you will need to manage the view’s content-hugging and compression-resistance (CHCR) priorities. Here are some guidelines for handling intrinsic content sizes:
尽量使用 intrinsic size，但这时候你需要管理好view 的拉伸 和压缩




[intrinsic contensize](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/AnatomyofaConstraint.html#//apple_ref/doc/uid/TP40010853-CH9-SW21)
