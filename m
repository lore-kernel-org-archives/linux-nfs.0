From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC] Reinstate NFS exportability for JFFS2.
Date: Sat, 2 Aug 2008 14:26:44 -0400
Message-ID: <20080802182644.GE30454@fieldses.org>
References: <18578.21997.529551.676627@notabene.brown> <1217551230.3719.15.camel@shinybook.infradead.org> <76bd70e30807311753m2785c6d3kd82edd1fe8b5f8b7@mail.gmail.com> <1217552437.3719.30.camel@shinybook.infradead.org> <76bd70e30807311831p771d0f1eia3e303bd84919422@mail.gmail.com> <1217597759.3454.356.camel@pmac.infradead.org> <1217598976.3454.359.camel@pmac.infradead.org> <76bd70e30808010905j3010a6bfy534c068a662d348d@mail.gmail.com> <1217607571.3454.417.camel@pmac.infradead.org> <76bd70e30808011047u3cd0a56cg3b2d62e01afed014@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Woodhouse <dwmw2@infradead.org>, viro@zeniv.linux.org.uk,
	Neil Brown <neilb@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: chucklever@gmail.com
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <76bd70e30808011047u3cd0a56cg3b2d62e01afed014@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 01, 2008 at 01:47:58PM -0400, Chuck Lever wrote:
> AFAIK WORD0_CHANGE is a required value for NFSv4 clients to detect
> data changes on the server.  That's one I think needs to remain
> enabled in the server capabilities bitmask.  In fact most local file
> systems on Linux don't handle that one correctly yet anyway, but
> "saner" clients do depend on that one to manage their page caches.
> 
> I don't think there's a way to indicate to a client that a server
> supports WORD0_CHANGE for a normal NFSv4 GETATTR, but not during a
> NFSv4 READDIR.
> 
> > But still, if masking them out would be a problem, we could use the
> > existing trick of doing readdir into a buffer and then going back and
> > doing the actual lookup later. But _only_ for that relatively rare case,
> > rather than for _all_ users of readdirplus, as we do at the moment.
> 
> Personally I don't have an immediate problem with the double-buffering
> here.  The extra data copy wouldn't add significant overhead to an
> already expensive and not terribly frequent operation.  There may be a
> caching opportunity to saving the buffered result, but I would bet
> either the contents of a directory or the attributes of objects
> residing in it would change too often for there to be much benefit.
> 
> I think we have an opportunity for a little better concurrency here,
> though.  Doing all the lookups and the directory read asynchronously
> and concurrently, if that's possible, might be a performance
> enhancement in most normal cases.  This would allow the requests to be
> passed all at once to the local file system, which could then organize
> any necessary disk accesses in a more optimal way.
> 
> That would be a reason to continue to do a double-buffered readdir in
> every case.

I don't see how xfs's double-buffered readdir allows you to do the
"lookups and directory reads asynchronously and concurrently"?  The
filesystem doesn't know the lookups are going to be coming at the time
that it gets the readdir, so it doesn't know to start them yet.

Could you add a readdirplus vfs operation which took a flag indicating
how much extra information you're going to need?

The three cases where readdir can be called are:

	- ordinary readdir, for which the existing filldir_t provides
	  all the information needed.
	- nfsv3 readdirplus, where the only additional information
	  needed is whether there's a mountpoint.
	- nfsv4 readdir, where we may need all the stat info, acls,
	  etc., etc.

So you could define a readdirplus file operation like

	readdirplus(file, void, plusfiller, flag)

with plusfiller defined just as filldir_t but with an extra struct
dentry * argument.  The only nonzero flag value would be DENTRY_NEEDED,
and without DENTRY_NEEDED set, the filesystem would have the option of
passing NULL in the plusfiller callback's dentry argument.  So nfsv3
would use flag == 0, and get a dentry passed back to it only when it was
already cached (all it needs to detect mountpoints).  But nfsv4 would
pass in DENTRY_NEEDED, and get a dentry on every callback.

Um.  That assumes it's only the lookup that has the locking problems,
and that the calls back into the filesystem for acls and so on will be
safe.  Etc.

Or you could define a more complicated set of flags indicating exactly
what would be needed, and have the callback pass back a big structure,
most of whose fields could be left unset depending on what was
requested.

Though really I can't see any great objection to just moving xfs's hack
up into nfsd.  It may not do everything, but it seems like an
incremental improvement.

--b.
