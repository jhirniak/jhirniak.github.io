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

1. jQuery:

For this tutorial we will need jQuery, which you can get from [jQuery CDN](https://code.jquery.com/). We will use the latest and minified jQuery from [https://code.jquery.com/jquery-2.1.4.min.js](https://code.jquery.com/jquery-2.1.4.min.js):

```html
<script type="text/javascript" src="https://code.jquery.com/jquery-2.1.4.min.js"></script>
```

2. This trick will only work on browsers with enabled JavaScript and it is estimated that [about 1% of Internet users will have not](https://gds.blog.gov.uk/2013/10/21/how-many-people-are-missing-out-on-javascript-enhancement/). So, this trick may not work for everyone. For me it is fine because of my target audience.

## The nuts and bolts

We will create a dummy `a` object such as

```javascript
<a id="mm" href="mailto:nospam@thanks.com">click to reveal (JS required)</a>
```

for which click we will intercept, decode email address from base64 representation, update `href` attribute and text of `a` object, prevent default click action (it would open default mail client to the correct mail address, but we want more logical flow), and finally unbind jQuery event trigger to leave default HTML behaviour.

### Base 64

Base64 is just binary-to-text encoding scheme for representing binary 
data in ASCII string format. For most implementations base64 uses `A-Z`, `a-z`, and `0-9` for the first 62 characters, and most differences depend on the last 2.

Base64 encoding and decoding is available in vanilla JS using `btoa` (for encoding "binary" string to encoded ASCII) and `btoa` for (for decoding encoded ASCII to our original "binary" string).

Here we will use string encoded before to obfruscate email address from the website source code. To generate binary ASCII binary representation of our email address just run this command, e.g. in developers console:

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

```javascript
$("a#mm").click(function (e) {
  // ...
  $(this).off("click");
  e.preventDefault();
  // ...
}
```

### jQuery

We can add our event trigger only when document is ready, which we can do by placing our little script at the end of `body` and surrounding it with
```javasript
$(document).ready(function () {
	// our implementation
})
```

or for compactness with
```javascript
$(function {
  // our implementation
})
```

which is equivalent to `$(document).ready(...)` method.

## Final code

Finally our code placed at the end of `body` looks like this (I encoded here my email address).

```html
<script type='text/javascript'>
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
</script>
```

## Demo

I took this demo from my [about page]({{< relref "about.md" >}}).

The best way to contact me is via email <a id="mm" href="mailto:nospam@thanks.com">click to reveal (JS required)</a>.

<script type='text/javascript'>
$(function () {
  var decodedTextField = $("#decoded");
  var encodedTextField = $("#encoded");

  decodedTextField.on('input', function () {
  	alert('typed');
  	encodedTextField.val(btoa(decodedTextField.val()));
  });

  encodedTextField.on('input', function () {
  	decodedTextField.val(atob(encodedTextField.val()));
  });


  $("a#mm").click(function (e) {
    console.log('Fired');
    var secret = function () { return atob('akBoaXJuaWFrLmluZm8=') };
    $(this).attr("href", 'mailto:' + secret());
    $(this).text(secret());
    $(this).off("click");
    e.preventDefault();
  });
});
</script>