# render_htmldoc_pdf

## Summary

Generate PDFs from your Rails views using [HTMLDoc](http://www.htmldoc.org).

## Usage

Let's say we've got this setup:

    # controller
    class FooController < ApplicationController
      def bar
        # ...
      end
    end
    
    # view - bar.html.erb
    <p>Blah blah blah</p>
    
Now let's say we want to give the user a PDF file when they go to /foo/bar, and we want the content to be generated from the view. There are only two things we have to do. First, we have to give the view an `.rpdf` extension. This extension is special and tells Rails to use a custom renderer class in rendering the view (which will run through HTMLDoc). Second, we use `render_pdf` in the controller action, instead of `render`. This is also special, but it allows us to pass some options, such as whether or not a download box should appear, and so on. So after we've done those two things we'll have this:

  # controller
  class FooController < ApplicationController
    def bar
      # ...
      render_pdf :action => 'bar.rpdf'
    end
  end
  
  # view - bar.rpdf
  <p>Blah blah blah</p>
  
If you want to know what all of the options to `render_pdf` are, then check out `lib/mcmire/render_htmldoc_pdf/controller.rb`.

## Prerequisites

* HTMLDoc 1.9.x
* htmldoc gem

## Installation

First, you'll need to download, compile, and install the htmldoc executable. If you're on a *nix system, this is really easy. Just head on over to [the HTMLDoc website](http://www.htmldoc.org/software.php). You'll see a link to download 1.8, but don't even bother with that, since 1.8.27 was released way back in 2006 and doesn't support CSS or tables very well. These days new improvements are being done (however occasionally) on the 1.9.x branch, so you'll want to download the latest developer snapshot instead (it worked fine for us). Once you've done that, you should be able to just

    ./configure
    make
    sudo make install

If you happen to be on Windows, well, you aren't so lucky. If you're fine with using 1.8, you can find a pre-compiled copy either from the HTMLDoc website or from Cygwin. If you really want a version of 1.9, you'll have to look around -- possibly someone has been generous enough to put one out there.

Once you've got the htmldoc executable installed, you'll need the htmldoc Ruby gem, which provides a thin wrapper around the executable. Just

    gem install htmldoc

Finally, you can install this gem:

    gem install htmldoc-rails

## Support

If you find a bug or have a feature request, I want to know about it! Feel free to file a [Github issue](http://github.com/mcmire/render_htmldoc_pdf/issues), or do one better and fork the [project on Github](http://github.com/mcmire/render_htmldoc_pdf) and send me a pull request or patch. Be sure to add tests if you do so, though.

You can also [email me](mailto:elliot.winkler@gmail.com), or [find me on Twitter](http://twitter.com/mcmire).

## Credits

The view renderer originated from PDF::HTMLDoc::View by Marcello Barnaba (<http://gist.github.com/53906>). Thank you!

## Author/License

(c) 2008-2010 Elliot Winkler. See LICENSE for details.