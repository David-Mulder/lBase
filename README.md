Installation
============
*I do plan to automate this at some point*

1. Set up a jetty or tomcat webapp.
2. Install OpenBD into it (make sure to add tools.jar)
3. Add a system folder
4. Place all this code (from this git repository) into the system folder
5. Move the files from system/_installation/root to the root of the webapp
6. Install [UrlRewriteFilter](http://www.tuckey.org/urlrewrite/) in your webapp and move _installation/urlrewrite.xml to WEB-INF
7. Delete the _installation folder
8. Download the admin and manual module from the lbase_modules repository

Do not forget
=============
- To trigger the admin/assets/regenerate before you start using modules.