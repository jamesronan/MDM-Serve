MDM-Serve
=========

A lghtweight standalone MDM server for local networks, to save having to have a full Domain Controller.

**This isn't complete - It's a Work In Progress**

This will be updated when the code reaches a minimum viable product.

SSL
===

In order for this to work, you need to proxy it behind server running with SSL certificates. 
These can be snakeoil, but you'll need to add them to your client machine's chain of trust.

Also, enterpriseenrollment.$yourdomain must exist in your network's DNS, as that's where the
service auto-discovery starts.

