[Tropo](http://tropo.com) + [Sinatra](http://sinatrarb.com) + [Heroku](http://heroku.com/) = Easy Ruby Communication Apps
=======================================================
Steps to recreate
-----------------

1. You will need to have [Ruby](http://www.ruby-lang.org/en/downloads/), [Rubygems](http://docs.rubygems.org/read/chapter/3), [Heroku](http://docs.heroku.com/heroku-command) and [Git](http://book.git-scm.com/2_installing_git.html) installed first.  

2. Drop into your command line and run the following commands:  
    * `git clone http://github.com/tropo/tropo-volunteer.git --depth 1`  
    * `cd tropo-volunteer`  
    * `heroku create`  
    * `git push heroku master`  

3. Log in or sign up for [Tropo](http://www.tropo.com/) and create a new WebAPI application.  
    For the App URL, enter in your Heroku app's URL and append `/index.json` to the end of it.  

4. That's it! Call in, use, and tinker with your app!  