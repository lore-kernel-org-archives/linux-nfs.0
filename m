From: Neil Brown <neilb@suse.de>
Subject: Re: Thoughts about cache consistency and directories in particular.
Date: Sat, 21 Feb 2009 06:52:50 +1100
Message-ID: <18847.2578.480148.216735@notabene.brown>
References: <18846.4842.625445.980681@notabene.brown>
	<1235156207.31066.21.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:39171 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750784AbZBTTxS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Feb 2009 14:53:18 -0500
In-Reply-To: message from Trond Myklebust on Friday February 20
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Friday February 20, trond.myklebust@fys.uio.no wrote:
> On Fri, 2009-02-20 at 13:18 +1100, Neil Brown wrote:
> > Hi,
> >  I've been thinking about cache consistency, particularly of
> >  directories, in response to a customer who's NFS was getting confused
> >  by their usage of "rsync -a" without the "--omit-dir-times" flag:
> >  A client would see an old copy of a directory and never get a more
> >  up-to-date copy because the mtime appeared not to change.
> > 
> >  This results in a situation where a directory has wrong data cache
> >  and there is no way to force that cache to be flushed.
> > 
> >  This contrasts with files where you can always flush the file
> >  contents by taking a read lock on the file.
> > 
> >  I also came up with a simple way to demonstrate a related caching
> >  anomaly:
> > 
> >   - Create a localhost mount
> >   - create a directory
> >   - "ls -l" the directory via NFS
> >   - create a file directly
> >   - look again via NFS.
> > 
> >   The directory will appear empty via NFS but it is not.  And this
> >   cache anomily does not time out (though memory pressure could
> >   eventually remove it).
> > 
> >   There is a script below which reproduces both anomalies (providing
> >   /export is exported and /mnt is available).
> >  
> > 
> >  Can anything be done about this?
> > 
> > 
> >  1/ The client could flush the cache for a directory when ctime
> >     changes as well as when mtime or size change.
> >     This would help solve the "rsync -a without --omit-dir-times"
> >     problem (and also another weird problem I had reported that
> >     involved strange behaviour from an NetApp filer).
> >     It might increase the number of READDIR requests in some cases.
> >     Would that be enough of an increase to be a real problem?
> >     It would be no worse than NFSv4 which - as the Linux NFS server
> >     uses ctime to produce the changeattr - refreshes both directories
> >     and files when the ctime changes.
> 
> It should work fine. The ctime tracks the mtime in all cases except when
> you setacl, setfattr, chown, chgrp, chmod, or touch the directory. Those
> should be very rare operations for pretty much any workload...
> 

Does that mean you'll take the patch ??

> >  2/ The server could lie about the mtime.
> >     In particular, if the mtime for a file was the same as the current
> >     time - to the granularity of the filesystem storing the file -
> >     then reduce the mtime that is reported by the smallest difference that
> >     can be reported by the protocol.
> >     That would be one microsecond for v2, and one nanosecond for v3
> >     and v4.
> > 
> >     This is something I've thought about (and probably muttered about)
> >     in various forms at various times over the years, but this time I
> >     think I am actually happy with the formulation of the solution and
> >     want to push forward with it.
> > 
> > 
> > 
> >  Option 1, by itself, would mostly resolve the rsync issue and have
> >  no effect on my little test case.
> >  Option 2 by itself would have no effect on the rsync issue but would
> >  nicely resolve my little test cache.
> >  Together they should significantly reduce the number of caching
> >  anomalies.
> 
> I'm assuming that option 2 applies to the ctime as well as the mtime,
> otherwise applying option 1 will void the effects of option 2?

Yes, of course.   My code didn't do that, but it will.
Thanks.

> 
> Note also that the client now has the 'lookupcache' mount option that
> can be set to ensure stricter revalidation of lookups.

I wasn't aware of that ... goes and looks ... that affects lookup but
not readdir.  So: useful, but not directly relevant to the current
situation. 

Thanks,
NeilBrown
