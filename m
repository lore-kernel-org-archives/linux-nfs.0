Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cliff.cs.toronto.edu ([128.100.3.120]:32958 "EHLO
        cliff.cs.toronto.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751421AbdBWQqv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Feb 2017 11:46:51 -0500
From: Chris Siebenmann <cks.nfs01@cs.toronto.edu>
To: NeilBrown <neilb@suse.com>
cc: Chris Siebenmann <cks.nfs01@cs.toronto.edu>, linux-nfs@vger.kernel.org
Subject: Re: Manual page bug: two inaccuracies in nfsd(7)
In-reply-to: neilb's message of Mon, 13 Feb 2017 15:46:10 +1100.
             <87tw7y4s19.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Thu, 23 Feb 2017 11:46:44 -0500
Message-Id: <20170223164644.E40565A0066@apps1.cs.toronto.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> >  I was recently reading this manual page as part of exploring running
> > an NFS server on Ubuntu 16.04 (with Ubuntu's kernel '4.4.0') and found
> > two inaccuracies with the current state of the kernel (or at least how
> > it looks to me based on both experimentation and code).
> >
> >  First, there is no /proc/net/rpc/auth.domain directory and cache any
> > more. This was removed from the kernel in 2006 (in commit efc36aa5608f),
> > so I think it should be safe to remove from current versions of the
> > manpage.
> 
> I agree.
> 
> >
> >  Second, the manpage says about the 'flush' files to be found in eg
> > /proc/net/rpc/auth.unix.ip:
> >
> > 	When a number of seconds since epoch (1 Jan 1970) is written to
> > 	this file, all entries in the cache that were last updated before
> > 	that file become invalidated and will be flushed out. Writing
> > 	1 will flush everything. [...]
> >
> > The bit about 'writing 1 will flush everything' does not appear to be
> > accurate.
> 
> I was never accurate.  I vaguely remember writing it.  I must have been
> confused.
> 
> Would you be able to create a patch which fixes these issues, and post
> it, with a signed-off-by ?

 Here is a patch that deletes the mention of auth.domain and changes the
wording around 'flush' files. I'm not attached to the revised wording;
it's just the best I could manage in something that felt that it was
within the same style and space as the current wording.

Signed-off-by: Chris Siebenmann <cks.nfs01@cs.toronto.edu>

diff --git a/utils/exportfs/nfsd.man b/utils/exportfs/nfsd.man
index 0c516fa..9efa29f 100644
--- a/utils/exportfs/nfsd.man
+++ b/utils/exportfs/nfsd.man
@@ -105,11 +105,6 @@ clients have for different filesystems.
 The caches are:
 
 .TP
-.B auth.domain
-This cache maps the name of a client (or domain) to an internal data
-structure.  The only access that is possible is to flush the cache.
-
-.TP
 .B auth.unix.ip
 This cache contains a mapping from IP address to the name of the
 authentication domain that the ipaddress should be treated as part of.
@@ -133,7 +128,8 @@ are:
 .B flush
 When a number of seconds since epoch (1 Jan 1970) is written to this
 file, all entries in the cache that were last updated before that file
-become invalidated and will be flushed out.  Writing 1 will flush
+become invalidated and will be flushed out.  Writing a time in the
+future (in seconds since epoch) will flush
 everything.  This is the only file that will always be present.
 
 .TP


	- cks
