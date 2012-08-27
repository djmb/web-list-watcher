web-list-watcher
================

Watch for new items in lists on web pages. Send an email when new items are found.

Usage
-----

ruby lib/watch.rb &lt;config file&gt; &lt;data directory&gt;

&lt;config file&gt; is a json file
&lt;data directory&gt; is where the items that have already been seen are stored

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
		"xpaths" : {
			"item" : "&lt;an xpath that extracts the hrefs of the items you are interested in&gt;",
			"next_page" : "&lt;an xpath that extracts the hrefs of the next page of items&gt;"
		}
	},
	...
]
}
</pre>