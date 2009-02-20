From: Neil Brown <neilb@suse.de>
Subject: Re: Thoughts about cache consistency and directories in particular.
Date: Sat, 21 Feb 2009 06:47:58 +1100
Message-ID: <18847.2286.101191.989726@notabene.brown>
References: <18846.4842.625445.980681@notabene.brown>
	<20090220182350.GB1104@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:45305 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750939AbZBTTsI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Feb 2009 14:48:08 -0500
In-Reply-To: message from J. Bruce Fields on Friday February 20
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Friday February 20, bfields@fieldses.org wrote:
> On Fri, Feb 20, 2009 at 01:18:18PM +1100, Neil Brown wrote:
> >  I also came up with a simple way to demonstrate a related caching
> >  anomaly:
> > 
> >   - Create a localhost mount
> >   - create a directory
> >   - "ls -l" the directory via NFS
> >   - create a file directly
> 
> (And do this within a second (or a jiffy, depending on filesystem) of
> the directory creation?)

Sorry, I meant to include that detail -  Yes.


> 
> >   - look again via NFS.
> 
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
> This has come up before, but I can't remember what the argument was
> against it....

Trond seems happy with it now.  And the NFSv4 server effectively
imposes it.  So maybe there are no remaining arguments against it ??

> 
> >  2/ The server could lie about the mtime.
> >     In particular, if the mtime for a file was the same as the current
> >     time - to the granularity of the filesystem storing the file -
> >     then reduce the mtime that is reported by the smallest difference that
> >     can be reported by the protocol.
> >     That would be one microsecond for v2, and one nanosecond for v3
> >     and v4.
> 
> Assume for simplicity's sake the time granularity is a second, and
> measure time in seconds in the following examples:
> 
> Your proposal offers an improvement in this example (currently,
> subsequent getattrs will not reflect the final modification):
> 
> 	t=0.1 modify
> 	t=0.2 getattr
> 	t=0.3 modify
> 
> Your proposal causes a regression in the following example:
> 
> 	t=0.1 modify
> 	t=0.2 getattr
> 	t=1.1 modify 
> 	t=1.2 modify
> 

I cannot see how there is a regression here.  Subsequent getattrs will
show all modifications (if you wait at least one second).
The first gettattr returns '-0.000000001', which is different from any
previously returned mtime.
Any subsequent getattr will return 0.999999999 or 1, depending on when
it arrives.

The only possible regression is that sometimes we will flush the cache
when previously we didn't.  In each case where that changes, the
client can not possible know whether it needs to or not, so flushing
rather than not flushing is the safest option.

> 
> By the way, I have one sadly neglected todo here: ext4 has a real nfsv4
> changeattribute, which needs to be hooked up to the nfsd code.

Does it?
I just had a quick look, found that it stores a 64 bit number on disk
which is stored in inode->i_version.
And this is incremented for directory operations.  But it doesn't seem
to be changed for file operations.

But maybe I missed something.


Thanks,
NeilBrown
