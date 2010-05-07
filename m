Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:33948 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751614Ab0EGWe0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 May 2010 18:34:26 -0400
Date: Sat, 8 May 2010 08:34:15 +1000
From: Neil Brown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: linux-nfs@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH] Should we expect close-to-open consistency on
 directories?
Message-ID: <20100508083415.54231ffe@notabene.brown>
In-Reply-To: <1273154311.7699.33.camel@localhost.localdomain>
References: <20100420172238.520eaa89@notabene.brown>
	<1271768521.25129.94.camel@localhost.localdomain>
	<20100421170321.41592c77@notabene.brown>
	<20100506141347.06451f56@notabene.brown>
	<1273154311.7699.33.camel@localhost.localdomain>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 06 May 2010 09:58:31 -0400 Trond Myklebust<trond.myklebust@fys.uio.no> wrote:
> > 
> > 
> > diff --git a/fs/namei.c b/fs/namei.c
> > index a7dce91..256ae13 100644
> > --- a/fs/namei.c
> > +++ b/fs/namei.c
> > @@ -719,7 +719,11 @@ static int do_lookup(struct nameidata *nd, struct qstr *name,
> >  done:
> >  	path->mnt = mnt;
> >  	path->dentry = dentry;
> > -	__follow_mount(path);
> > +	if (__follow_mount(path) &&
> > +	    (path->mnt->mnt_sb->s_type->fs_flags & FS_REVAL_DOT)) {
> > +		if (!path->dentry->d_op->d_revalidate(path->dentry, nd))
> > +			return -ESTALE;
> 
> Won't this prevent you from ever being able to unmount the stale
> filesystem?
> 

Good point - I think you are right.

It seems to me that ->d_revalidate is being used for two distinct, though
related, tasks.
One is to revalidate the dentry - make sure the name still refers to the same
inode.  The other is to revalidate the inode - make sure the cached
attributes are still valid.  In NFS (v3 and v4 at least) these are both
performed by one call so it makes some sense to combine them.  But from the
VFS perspective I would have thought they were quite separate.
nfs_lookup_revalidate sometimes does a GETATTR, and sometimes does a LOOKUP,
depending to some extent on the 'intent' in the nameidata.  I find this makes
it a bit hard to follow what is really happening, or how d_revalidate should
really be used.

Maybe we should just ignore the return value above.  Or maybe d_revalidate
should never do a GETATTR - that should be done by ->open ??

Confused :-(

NeilBrown
