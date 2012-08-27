web-list-watcher
================

Watch for new items in lists on web pages. Send an email when new items are found.

Usage
-----

ruby lib/watch.rb <config file> <data directory>

<config file> is a json file
<data directory> is where the items that have already been seen are stored

Requirements
------------

You should set the script up as a cron job. It will store what it has seen in the data directory so you will get an
email containing only the new items since the last run. Once an item has been seen it will not be emailed, even if it
disappears and reappears.

You will also need an email account to send the notifications from. Currently Gmail and Yahoo mail are supported.
Don't use an account you care about as the password will need to be stored in the configuration.

Config
------
<code>
{
"from_email" : "<email to send notifications from (must be gmail.com or yahoo.com>",
"password" : "<password for that account>",
"to_email" : "<email to send notification to>",
"user_agent" : "<user agent to use when loading web pages>",
"web_pages" : [
	{
		"id" : "<an id for this set of pages>",
		"uri" : "<uri to start looking from>",
		"xpaths" : {
			"item" : "<an xpath that extracts the hrefs of the items you are interested in>",
			"next_page" : "<an xpath that extracts the hrefs of the next page of items>"
		}
	},
	...
]
}
</code>