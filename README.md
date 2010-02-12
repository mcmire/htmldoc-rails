# htmldoc-rails

## Summary

Generate PDFs from your Rails views using [HTMLDoc](http://www.htmldoc.org).

## Usage

Let's say we've got this setup:

    # controller
    class FooController < ApplicationController
      def bar
        # render bar.html.erb
      end
    end
    
    # view - bar.html.erb
    <p>Some content goes here</p>
    
Now let's say we want to give the user a regular HTML view when they go to `/foo/bar`, but a PDF file when they go to `/foo/bar.pdf`. We can use `respond_to` to differentiate between the two course of actions, but as for generating the PDF file itself, `htmldoc-rails` provides a special method called `render_pdf`. This method is responsible for piping a view through HTMLDoc and telling the action to return a PDF file. It also accepts options such as which view you want the PDF to be generated from, whether or not a download box should appear, and so on (you can find the possible options in the [documentation](http://mcmire.github.com/htmldoc-rails/HtmldocRails/Controller.html#render_pdf-instance_method)). Since we want to use the HTML view to generate the PDF, all we have to say is this:

    # controller
    class FooController < ApplicationController
      def bar
        respond_to do |wants|
          wants.html
          wants.pdf { render_pdf }
        end
      end
    end

## Prerequisites

* HTMLDoc 1.9.x
* htmldoc gem

## Installation

First, you'll need to download, compile, and install the htmldoc executable. If you're on Mac or Linux, this is really easy. Just head on over to [the HTMLDoc website](http://www.htmldoc.org/software.php). You'll see a link to download 1.8, but don't even bother with that, since 1.8.27 was released way back in 2006 and doesn't support CSS or tables very well. These days new improvements are being done (however occasionally) on the 1.9.x branch, so you'll want to download the latest developer snapshot instead (it worked fine for us). Once you've done that, you should be able to just

    ./configure
    make
    sudo make install

If you happen to be on Windows, well, you aren't so lucky. If you're fine with using 1.8, you can find a pre-compiled copy either from the HTMLDoc website or from Cygwin. If you really want a version of 1.9, you'll have to look around -- possibly someone has been generous enough to put one out there.

Once you've got the htmldoc executable installed, you'll need the htmldoc Ruby gem, which provides a thin wrapper around the executable. Just

    gem install htmldoc

Finally, you can install this gem:

* `gem install htmldoc-rails` (probably as root)
* Add `config.gem 'htmldoc-rails'` to your environment.rb file

## Compatibility

This gem has been tested successfully on Rails 2.1.2, 2.2.3, and 2.3.5 under Ruby 1.8.6, 1.8.7, and 1.9.1.

## I found a bug!

Great! File a [Github issue](http://github.com/mcmire/htmldoc-rails/issues) so that I am aware of the problem and I will try to fix it as soon as I can. If you're able to figure out a solution on your own, feel free to write a patch and send it to me, or fork the [project on Github](http://github.com/mcmire/htmldoc-rails) and send me a pull request. Bonus points if you write tests -- that helps me out a lot.

If you need to get in contact with me, you can [find me on Twitter](http://twitter.com/mcmire) or [send me an email](mailto:elliot.winkler@gmail.com).

## Author

(c) 2008-2010 Elliot Winkler. See LICENSE for details.