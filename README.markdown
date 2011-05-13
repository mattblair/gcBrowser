# GeoCouch Browser for iOS

Last updated: 2011-05-12

## Project Goals

* to make it easy to browse GeoCouch databases while wandering around in the real world
* to build a re-usable geodata collection tool
* to demonstrate how to interact with remote (and eventually on-device) GeoCouch databases from an iOS device 

## Who's it for?

* Developers and organizations already using CouchDB and GeoCouch
* Anyone who wants to browse (and eventually contribute to) GeoCouch? datasets set up by other people
* Anyone curious about open data 

You need a basic knowledge of GeoCouch to get this working with a new database. My goal is to make it polished enough that discovering and browsing geo-datasets is easy for people who are new to CouchDB and GeoCouch, and that the app could be configured by slightly technical folks for people who don't even know what a document database is, but want to view and contribute to open geo-datasets.

It's not there yet.

## Running the app

If you have Xcode, you can run it in the simulator.

If you want to run it on a device, you need a developer account with Apple -- at least for now.

If these aren't an option, and you really want a peek now, I can make a few ad-hoc distributions. If there is high demand, I'll try to polish it and get it in the App Store ASAP.

## Project Status

* Rebuilt as a Universal app. 
* Most of the basics work on both iPhone and iPad
* Some parts of the code are more temporary/placeholder-ish than others. See roadmap for hints of what will likely change.
* The detail view unpacks geometry and properties objects, but doesn't handle attachments or any other nested/non-text keys
* Can read any GeoCouch dataset with a geoquery that emits title and subtitle (see below for an example)
* Needs a lot of UI polishing
* I've done basic functional testing, but I haven't put it through extensive field testing or debugging yet. Some things may not work. 

## Known Bugs

* Popover display on iPad is well-less than beautiful: It leaps in, doesn't quite point to the pin, overlaps the toolbar, etc. And the fetch button animation is awful.
* Database name is not displayed anywhere on the map view, without going back to the database list. 

## Roadmap

Near Term:

* Switch from plist to JSON for database list. I used a plist out of habit, but JSON makes more sense, so users can...
* Load database lists from an URL specified in Settings. This would allow editing the list with Futon and/or text editor, until I build an in-app list editor.
* Create a custom cell for the detail view. None of the defaults work very well for this context.
* include_docs mode: Browse GeoCouch databases that don't have a title/subtitle geoquery design document, and choose which keys to show in title/subtitle. (Could require a lot more bandwidth, and impact on device memory could be problematic for large datasets, which is why it's not the default option.)
* UI polish and extensive testing.
* Submit it to the App Store for broader availability.

Make it read-write:

* Add document editor with text editing for values, for adding/editing documents in writable databases
* Adjust location on map before submit
* Add an in-app database list editor 

A little further off:

* Attach photos and sound recordings
* Integration of CouchBase for iOS + GeoCouch, with UI controls for syncing data between local and remote Couch databases
* Show polylines and polygons 

## Database list format

The app includes a starter list of databases, to make it usable without any extra configuration. I plan to add a list editor into the app, but for now you'll need to edit the CouchSources.plist file. And even that is going to change to JSON very soon.

In the future, you'll be able to enter an URL in settings to load a list. If you are curating a bunch of geo-databases, you could have a database list document somewhere on your server with all the details. The app downloads that document once, then saves and loads it locally until you tell it to refresh or you point it elsewhere. This gives users menu-like access to all your databases. And of course you can mix and match the databases in the list, including data from your own and other people's GeoCouch databases.

The database list uses the keys listed below. The app tries to substitute sensible defaults if something isn't specified, but if you don't specify something critical like a databaseURL, it won't go well. I'm not writing validation for database definitions until I switch over to parsing it from JSON rather than the plist.

* name (just a human-friendly display name)
* collection (to be used to group similar databases)
* databaseURL (the url for the server and database, without a slash at the end. Example:  http://myserver.com/mygeocouch)
* pathForMapSearch (the path for the location of your title/subtitle geoquery design doc. Example: "/_design/gcbrowser/_spatial/points?bbox=" 

* initialRegion (A dictionary with four keys that is translated into an MKCoordinateRegion for the first view of a dataset. At a minimum, specify the latitude and longitude keys, with decimal degrees that indicate the center of your map view. Otherwise, you may be querying NYC data while looking at Portland and not finding anything until you do 3000 miles worth of map swiping.) 

* keysToDisplay (An array of keys you would like to appear in the detail view, in the order you'd like to display them. If you omit a key, it won't be shown. If you don't specify this array, all available keys will be displayed in an arbitrary order.) 

For includeDocs mode, which fetches all data in geoquery (not implemented yet):

* includeDocs (BOOL, requires more bandwidth if enabled, but loads detail view faster.)
* keyForTitle (default="title")
* keyForSubtitle (default="subtitle") 

Additional details for writable databases (not implemented yet):

* writable (BOOL, default=NO)
* requiredKeys (array, values will be text-only to start)
* desiredKeys (array, values will be text-only to start)
* allow attachments (BOOL, default=YES)
* allowArbitraryKeys (BOOL, default=YES) 

I'll keep the notes in GeoCouchDatabaseDefinition.h updated with the latest details.

## Design Document for Titles and Subtitles 

Until the includeDocs mode is implemented, you need a design doc loaded into your GeoCouch database before it will work with this app. That's as simple as adding a document in Futon, editing one of the options below to match what you want to use for title and subtitle, pasting it into the Ssource tab, and then saving it. You'll have to be an admin to create a design doc. Or you could use CouchApp to push this document.

Example for a public read-only database that emits address as the title and station as the subtitle:

```javascript
{
   "_id": "_design/gcbrowser",
   "spatial": {
       "points": "function(doc) { emit(doc.geometry || {type: 'Point',coordinates: [0,0]}, {'title': (typeof(doc.address) == 'undefined') ? 'Unnamed' : doc.address, 'subtitle': (typeof(doc.station) == 'undefined') ? 'Unknown' : doc.station})}"
   },
   "validate_doc_update": "function (newDoc, oldDoc, userCtx) { isAdmin = ((userCtx.roles.indexOf(\"_admin\") != -1) || (userCtx.roles.indexOf(\"db_admin\") != -1)); if (!isAdmin) { throw({unauthorized: \"You must be logged in as an administrator to update this database.\"});}}"
}
```

For a public-writable database:

```javascript
{
   "_id": "_design/gcbrowser",
   "spatial": {
       "points": "function(doc) { emit(doc.geometry || {type: 'Point',coordinates: [0,0]}, {'title': (typeof(doc.address) == 'undefined') ? 'Unnamed' : doc.address, 'subtitle': (typeof(doc.station) == 'undefined') ? 'Unknown' : doc.station})}"
   }
}
```
## Dependencies

This project uses [json-framework](http://code.google.com/p/json-framework/) and [ASIHTTPRequest](http://allseeing-i.com/ASIHTTPRequest/), both of which are included in the project for convenience.

## Hat-Tips

Thanks to: 

* Volker Mische for creating GeoCouch.
* Max Ogden for importing most of the databases in the current list into GeoCouch.
* J. Chris Anderson and Jason Smith for Couch tips and help.

## Contact 

Questions? Ideas? Add an issue or email me.

## License and Copyright

**Modified BSD:**
http://opensource.org/licenses/bsd-license

Copyright (c) 2011, Elsewise LLC
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
* Neither the name of Elsewise LLC nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.