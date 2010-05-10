Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:34929 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754808Ab0EJDBh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 May 2010 23:01:37 -0400
Date: Mon, 10 May 2010 13:01:27 +1000
From: Neil Brown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, linux-nfs@vger.kernel.org,
        Alexander Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH] Should we expect close-to-open consistency on
 directories?
Message-ID: <20100510130127.7edf6e9c@notabene.brown>
In-Reply-To: <4BE76F87.4000809@oracle.com>
References: <20100420172238.520eaa89@notabene.brown>
	<1271768521.25129.94.camel@localhost.localdomain>
	<20100421170321.41592c77@notabene.brown>
	<20100506141347.06451f56@notabene.brown>
	<1273154311.7699.33.camel@localhost.localdomain>
	<20100508083415.54231ffe@notabene.brown>
	<4BE56180.2020307@oracle.com>
	<20100509080810.338f6e8f@notabene.brown>
	<4BE76F87.4000809@oracle.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, 09 May 2010 22:29:27 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> On 05/ 8/10 06:08 PM, Neil Brown wrote:
> > On Sat, 08 May 2010 09:05:04 -0400
> > Chuck Lever<chuck.lever@oracle.com>  wrote:
> >
> >> On 05/07/2010 06:34 PM, Neil Brown wrote:
> >>> On Thu, 06 May 2010 09:58:31 -0400 Trond Myklebust<trond.myklebust@fys.uio.no>   wrote:
> >>>>>
> >>>>>
> >>>>> diff --git a/fs/namei.c b/fs/namei.c
> >>>>> index a7dce91..256ae13 100644
> >>>>> --- a/fs/namei.c
> >>>>> +++ b/fs/namei.c
> >>>>> @@ -719,7 +719,11 @@ static int do_lookup(struct nameidata *nd, struct qstr *name,
> >>>>>    done:
> >>>>>    	path->mnt = mnt;
> >>>>>    	path->dentry = dentry;
> >>>>> -	__follow_mount(path);
> >>>>> +	if (__follow_mount(path)&&
> >>>>> +	    (path->mnt->mnt_sb->s_type->fs_flags&   FS_REVAL_DOT)) {
> >>>>> +		if (!path->dentry->d_op->d_revalidate(path->dentry, nd))
> >>>>> +			return -ESTALE;
> >>>>
> >>>> Won't this prevent you from ever being able to unmount the stale
> >>>> filesystem?
> >>>>
> >>>
> >>> Good point - I think you are right.
> >>>
> >>> It seems to me that ->d_revalidate is being used for two distinct, though
> >>> related, tasks.
> >>> One is to revalidate the dentry - make sure the name still refers to the same
> >>> inode.  The other is to revalidate the inode - make sure the cached
> >>> attributes are still valid.  In NFS (v3 and v4 at least) these are both
> >>> performed by one call so it makes some sense to combine them.  But from the
> >>> VFS perspective I would have thought they were quite separate.
> >>> nfs_lookup_revalidate sometimes does a GETATTR, and sometimes does a LOOKUP,
> >>> depending to some extent on the 'intent' in the nameidata.  I find this makes
> >>> it a bit hard to follow what is really happening, or how d_revalidate should
> >>> really be used.
> >>>
> >>> Maybe we should just ignore the return value above.  Or maybe d_revalidate
> >>> should never do a GETATTR - that should be done by ->open ??
> >>>
> >>> Confused :-(
> >>
> >> The reason for this arrangement is that by the time ->open is called,
> >> it's too late to return ESTALE.  During the path walk, there is still an
> >> opportunity to renew the mapping between dentry and inode, should the
> >> cached value of that mapping be stale.
> >>
> >
> > Is it?
> > ->open seems to be able to return an error code, and that error code seems to
> > be propagated up.  What am I missing?
> 
> "too late to return ESTALE" ... to the VFS layer.  When d_revalidate 
> returns ESTALE while a pathname is being resolved, our VFS layer 
> re-walks the pathname from the root, passing in a flag that says "please 
> don't use our cache, but do each LOOKUP again."

I see. path_walk does that, the flag being "LOOKUP_REVAL".
But this is just saying that 'open' is too late to validate a name, and I
agree with that.  I want 'open' to revalidate the cached attributes -
particularly in the case where there is no name to revalidated.
i.e. a mount point or '.'.  In those cases we would want to return ESTALE,
not try to redo the lookup (because there is no lookup to do).

> 
> That way, we can rely on the dentry cache most of the time, and have 
> some way to recover when file system objects are renamed on the server.
> 
> > I appreciate that a previous lookup might have already done the equivalent of
> > 'open' (e.g. for O_EXCL) but it seems wrong to assume that the last lookup
> > will always do the GETATTR required for open (because there isn't always a
> > 'last lookup').
> 
> open(".") has always been funky.
> 
> I had an argument years ago with someone who pointed out that the POSIX 
> standards are written in such a way that it is entirely optional to 
> revalidate ".", and so we don't.  I don't recall the specifics.

The rationale I fall back on is that to preserve "close-to-open-coherency"
you need to get the change attribute (aka mtime) when you open something - a
directory in this case.
This isn't so much "revalidating" as "refreshing".
So prima-facie 'open' should always issue a GETATTR and check if the file has
changed.  In practice that isn't necessary in most cases as a d_revalidate
has issued a LOOKUP or a GETATTR and the cached attributes are current.
But in the cases where there is no dentry to revalidate (mountpoint and "."),
something more is needed.

NeilBrown


> 
> > I would rather see the lookup (or d_revalidate) remember how much of an open
> > it has done, and then ->open does the rest.  i.e. it does a GETATTR if that
> > hasn't already been done.
> > I don't think there is currently an easy way for 'open' to know how much work
> > 'd_revalidate' or 'lookup' has done, though I suspect that could be fixed.
> > Maybe pass (as pointer to) the whole intent structure into open rather than
> > just the intent.open.file ??
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

