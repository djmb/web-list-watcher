web-list-watcher
================

A script that watches for new items in lists on web pages and sends an email when they are found.

Usage
-----

ruby lib/watch.rb &lt;config file&gt; &lt;data directory&gt;

&lt;config file&gt; is a json file

&lt;data directory&gt; is a directory where the items that have been seen will be stored

Requirements
------------

You should set the script up as a cron job. It will store what it has seen in the data directory so you will get an
email containing only the new items since the last run. Once an item has been seen it will not be emailed, even if it
disappears and reappears.

You will also need an email account to send the notifications from. Currently Gmail and Yahoo mail are supported.
Don't use an account you care about as the password will need to be stored in the configuration.

Config
------
<pre>
{
"from_email" : "&lt;email to send notifications from (must be gmail.com or yahoo.com&gt;",
"password" : "&lt;password for that account&gt;",
"to_email" : "&lt;email to send notification to&gt;",
"user_agent" : "&lt;user agent to use when loading web pages&gt;",
"web_pages" : [
	{
		"id" : "&lt;an id for this set of pages&gt;",
		"uri" : "&lt;uri to start looking from&gt;",
		"clean_uri_regexp" : "&lt;regexp to clean item uris&gt;
		"xpaths" : {
			"item" : "&lt;an xpath that extracts the hrefs of the items you are interested in&gt;",
			"next_page" : "&lt;an xpath that extracts the hrefs of the next page of items&gt;"
		}
	},
	...
]
}
</pre>

The clean_uri_regexp should match the entire item string and will replace the uri with the groups that it matches.

This is useful if the uri has some sort of tracking parameters that vary every time you load the page.

So for http://www.example.com/item1?search_id=12345, you could supply a clean_uri_regexp of <code>(.*)\?.*<code> to remove the query string.