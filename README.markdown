# MGWordCounter

by **Matt Gemmell**

- Visit my blog at [http://mattgemmell.com/](http://mattgemmell.com/)
- Follow [@mattgemmell on Twitter](http://twitter.com/mattgemmell)
- Follow [mattgemmell on App.Net](http://alpha.app.net/mattgemmell)


## What is MGWordCounter?

**MGWordCounter provides live word-counting for NSTextViews on OS X and UITextViews on iOS.**

- Counting is asynchronous (in the background)
- It tries not to count any more text than is necessary
- It counts both the full text and any _selection_ in the textview

MGWordCounter uses NSString's own (excellent) understanding of what constitutes a "word", and thus will improve as NSString and the text system are enhanced in future.


## Why did you create this?

I do a lot of writing, and I find it extremely useful to have a live word-count (and character-count) for the piece I'm working on. I also like to try out new writing apps and text-editors, and I'd be disappointed if they didn't have that feature.

I thought that the best way to make sure all my favourite writing apps of the future have live word-counting was to implement the feature in a straightforward, drop-in way, then I can just point those developers towards this code. Then they'll have _absolutely no excuse_ for not implementing it.


## Getting the code

MGWordCounter can be cloned from its git repository on github. You can find the repository here: [http://github.com/mattgemmell/MGWordCounter](http://github.com/mattgemmell/MGWordCounter)


## Requirements and supported OS versions

- **OS X 10.7 Lion** or later (**with ARC**) for Mac
- **iOS 5.0** or later (**with ARC**) for iPhone, iPad and iPod touch


## License

MGWordCounter is distributed under an **attribution license**. You're free to use it, with attribution, in any kind of project you like (including commercial and/or closed-source apps).

You can read the full license here: [http://mattgemmell.com/license/](http://mattgemmell.com/license/)

See the license page for information on using it _without_ attribution too.


## Saying Thank You

As with all the other OS X and iOS code I've released over the years, I'm making MGWordCounter available for the benefit of the developer community.

If you find it useful, a Paypal donation (or something from my Amazon.co.uk Wishlist) would be very much appreciated. Appropriate links (and my other code) can be found here: [http://mattgemmell.com/source](http://mattgemmell.com/source)


## Sample code

The MGWordCounter project includes simple OS X and iPhone demonstration apps, showing a live word-count display above a text-view. Both apps are separate targets in the same Xcode project.


## How to use MGWordCounter

Briefly, you create an MGWordCounter object by initialising it with a suitable NSTextView or UITextView, then you tell the MGWordCounter to start counting.

    wordCounter = [MGWordCounter wordCounterForTextView:textview];
    wordCounter.delegate = self;
    textview.delegate = wordCounter;
    [wordCounter startCounting];

MGWordCounter will then post **notifications** (and call a **delegate method**, if you've given it a delegate) whenever the word-count changes. You can also specify a **block** to be executed.


## Does it need to be my Text View's delegate?

**No**. Normally, the MGWordCounter object _will_ be your text-view's delegate (i.e. its NSTextViewDelegate on OS X, or its UITextViewDelegate on iOS). However, this isn't absolutely required.

If you already have a text-view delegate object, you can simply forward three delegate methods to the MGWordCounter from your actual text-view delegate, and everything will still work. See the comments in MGWordCounter's header file for more information.


## Can it work with something other than a Text View?

Potentially. If you can fulfil the (NS/UI)TextViewDelegate contract, and the "text-view" object you pass to the MGWordCounter responds to `-string` on OS X and `-text` on iOS, then yes, you can presumably make it work for other controls or even more exotic objects. This hasn't been tested, however.


## Bugs and feature requests

There is absolutely **no support** offered with this component. You're on your own! If you want to submit a feature request, please do so via [the issue tracker on github](http://github.com/mattgemmell/MGWordCounter/issues) (and _not_ via Twitter, email, carrier pigeon, smoke signals or anything else).

MGWordCounter is open source code for developers. If you find a bug, please _investigate it_. There are many `NSLog` statements (commented-out) throughout the code, allowing you to selectively inspect its workings. The algorithm used isn't complex. Find out what's going wrong, and fix it!

I'll be glad to receive pull-requests for bug-fixes and enhancements on [MGWordCounter's github repository](http://github.com/mattgemmell/MGWordCounter). Please try not to report bugs without a diagnosis and fix. Similarly, please try not to submit fixes without an accompanying explanation of what you're fixing, and how. :)


## Final notes

To keep up to date with future code releases, amongst many other things, you'd be well advised to:

- Visit my blog at [http://mattgemmell.com/](http://mattgemmell.com/)
- Follow [@mattgemmell on Twitter](http://twitter.com/mattgemmell)
- Follow [mattgemmell on App.Net](http://alpha.app.net/mattgemmell)
