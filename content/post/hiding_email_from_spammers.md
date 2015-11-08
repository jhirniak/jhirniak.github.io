+++
date = "2015-11-08T17:02:41Z"
draft = true
title = "Hiding your email address from spammers using jQuery"
Description = "Short tutorial how to hide an email address on your website from spammer web crawlers using jQuery and base64 coding."

tags = [ "JavaScript", "jQuery", "hiding email"]
categories = [ "JavaScript Tricks" ]
series = [ "js" ]
slug = "hiding_email_with_jquery"

+++

## Requirements

* jQuery:

For this tutorial we will need jQuery, which you can get from [jQuery CDN](https://code.jquery.com/). We will use the latest and minified jQuery from [https://code.jquery.com/jquery-2.1.4.min.js](https://code.jquery.com/jquery-2.1.4.min.js):

```html
<script type="text/javascript" src="https://code.jquery.com/jquery-2.1.4.min.js"></script>
```

* This trick will only work on browsers with enabled JavaScript and it is estimated that [about 1% of Internet users have JavaScript disabled](https://gds.blog.gov.uk/2013/10/21/how-many-people-are-missing-out-on-javascript-enhancement/). So, this trick may not work for everyone. For me it is fine because of my target audience.

## The nuts and bolts

We will create a dummy `a` tag such as

```javascript
<a id="mm" href="mailto:nospam@thanks.com">click to reveal (JS required)</a>
```

for which click we will
1. we will intercept click with jQuery, 
2. decode email address from base64 representation,
3. update `href` attribute and text of our `a` tag,
4. prevent default click action (i.e. openning default mail client to give it more logical flow),
5. and finally unbind jQuery event trigger to leave default HTML behaviour, from here on.

### Base 64

Base64 is binary-to-text encoding scheme for representing binary 
data in string format in ASCII string encoding. For most implementations base64 uses `A-Z`, `a-z`, and `0-9` for the first 62 characters of target code, and most differences depend on the last 2. You can think of same as of hexadecimal representation (base 16), octal (base 8), binary (base 2), here our radix (base) is just `64`, with other requirement being that characters are printable.

Base64 encoding and decoding is available in vanilla JS using `btoa` (for encoding "binary" string to encoded ASCII) and `btoa` for (for decoding encoded ASCII to our original "binary" string). You can read more about it on [MDN](https://developer.mozilla.org/en-US/docs/Web/API/WindowBase64/btoa).

Here we will use string encoded before to obfruscate email address from the website source code, e.g. to prevent malicient web crawlers grabbing our email address and using it for spam. We generate base64 encoded string using `btoa`, e.g. in the developer console (CTRL+SHIFT+J in Chrome) or the snippet below:

```javascript
/** Converts binary to ASCII representation */
btoa('your@email.address')
```

You can test how `btoa` and `atob` works below:
<div>
<label for="decoded">Decoded: </label><input type='text' id='decoded' /><br>
<label for="encoded">Encoded: </label><input type='text' id='encoded' />
</div>

### Updating `a` `href` attribute and text

We simply update attribute `href` value with `attr` function and `a` tag content with `text`.

### Unbinding and preventing default

We want to disable the jQuery event trigger after first firing. To do this we apply `off("click")` to disable all click triggers for given selector.

Also we want to prevent browser from doing the default action of opening mail client for the update `mailto` value to give our implementation more natural look and feel (first reveal then email). We do this using `preventDefault()` function on event `e` passed to our function on the event trigger.

Note that because of the scope, i.e. inside `$("a#mm")` we can use `$(this)` to refer to `$("a#mm")`, what we do for clarity.

```javascript
$("a#mm").click(function (e) {
  // ...
  $(this).off("click");
  e.preventDefault();
  // ...
}
```

### jQuery

We can add our event trigger only when document is ready (i.e. browser generated all the fields in body), which we can do by placing our little script at the end of `body` or separate script and surrounding it with
```javasript
$(document).ready(function () {
	// our implementation
})
```

or for compactness just with

```javascript
$(function {
  // our implementation
})
```

where both are equivalent.

## Final code

Finally our code, that we can now include on our website, looks like this (email address is taken from the encoded field above).

```javascript
$(function () {
  $("a#mm").click(function (e) {
    console.log('Fired');
    var secret = function () { return atob('akBoaXJuaWFrLmluZm8=') };
    $(this).attr("href", 'mailto:' + secret());
    $(this).text(secret());
    $(this).off("click");
    e.preventDefault();
  });
});
```

## Demo

I used this method on my [about page]({{< relref "about.md" >}}) page. But, the below example uses email hidden in the `encoded` field above.

The best way to contact me is via email <a id="mm" href="mailto:nospam@thanks.com">click to reveal (JS required)</a>.

<script type='text/javascript'>
$(function () {
  var decodedTextField = $("#decoded");
  var encodedTextField = $("#encoded");

  decodedTextField.val('hello@world.com');
  encodedTextField.val(btoa('hello@world.com'));

  decodedTextField.on('input', function () {
  	encodedTextField.val(btoa(decodedTextField.val()));
  });

  encodedTextField.on('input', function () {
  	decodedTextField.val(atob(encodedTextField.val()));
  });


  $("a#mm").click(function (e) {
    console.log('Fired');
    var secret = function () { $("#encoded").val() };
    $(this).attr("href", 'mailto:' + secret());
    $(this).text(secret());
    $(this).off("click");
    e.preventDefault();
  });
});
</script>