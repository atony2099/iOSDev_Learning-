
### UITextView that expands to text using auto layout

Just got into this issue, I don't know if I'm off topic, but if you set your UITextView to "not" scrollable:

```
[textView setScrollEnabled:NO]
```
it will be able to calculate an intrinsic size, thus allowing auto layout to move the other elements by itself, then it's up to you to setup the constraints right.

[UITextView that expands to text using auto layout](https://stackoverflow.com/questions/16868117/uitextview-that-expands-to-text-using-auto-layout)
