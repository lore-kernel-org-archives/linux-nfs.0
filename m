Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail2.shareable.org ([80.68.89.115]:55130 "EHLO
	mail2.shareable.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756753Ab0ENRrB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 May 2010 13:47:01 -0400
Date: Fri, 14 May 2010 18:46:53 +0100
From: Jamie Lokier <jamie@shareable.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Mi Jinlong <mijinlong@cn.fujitsu.com>,
        NFSv3 list <linux-nfs@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
        ebiederm@xmission.com, adobriyan@gmail.com, viro@ZenIV.linux.org.uk
Subject: Re: [PATCH] VFS: Unlink should revoke all outstanding leases on file
Message-ID: <20100514174653.GC10133@shareable.org>
References: <4BED195F.3070504@cn.fujitsu.com> <20100514055844.109d2fdc@tlielax.poochiereds.net> <1273857471.4732.7.camel@localhost.localdomain> <20100514133819.5e383485@tlielax.poochiereds.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100514133819.5e383485@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Jeff Layton wrote:
> On Fri, 14 May 2010 13:17:51 -0400
> Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> 
> > On Fri, 2010-05-14 at 05:58 -0400, Jeff Layton wrote: 
> > > On Fri, 14 May 2010 17:35:27 +0800
> > > Mi Jinlong <mijinlong@cn.fujitsu.com> wrote:
> > > 
> > > > After client get one file's READ delegation through NFSv4,
> > > > server delete this file but don't reclaim the delegation.
> > > > 
> > > > This patch add break_lease at may_delete, which can reclaim delegations.
> > > > 
> > > > ---
> > > >  fs/namei.c |    2 +-
> > > >  1 files changed, 1 insertions(+), 1 deletions(-)
> > > > 
> > > > diff --git a/fs/namei.c b/fs/namei.c
> > > > index 16df727..17bafc1 100644
> > > > --- a/fs/namei.c
> > > > +++ b/fs/namei.c
> > > > @@ -1338,7 +1338,7 @@ static int may_delete(struct inode *dir,struct dentry *victim,int isdir)
> > > >  		return -ENOENT;
> > > >  	if (victim->d_flags & DCACHE_NFSFS_RENAMED)
> > > >  		return -EBUSY;
> > > > -	return 0;
> > > > +	return break_lease(victim->d_inode, FMODE_WRITE);
> > > >  }
> > > >  
> > > >  /*	Check whether we can create an object with dentry child in directory
> > > 
> > > This doesn't look right to me.
> > > 
> > > The fcntl(2) manpage basically says that leases should be broken if the
> > > file is opened for read or write, or is truncated. unlinks don't seem
> > > to fall into either category...
> > > 
> > 
> > Breaking the lease in this case is certainly a requirement for NFSv4
> > delegations. I've no idea what the CIFS oplock requirements are...
> > 
> 
> Heh, probably "undefined". Windows generally doesn't allow you to
> delete open files at all.

I think you can delete open files on Windows nowadays, if they are
opened with a particular flag.

> I don't think samba will really care too much either way. I suppose
> it could hurt performance in situations where you had a file that
> was hardlinked and deleted a hardlink that was "unrelated" to the
> dentry being held open...but that's pretty clearly a corner case at
> best.

Leases are handy for some userspace caching tricks too.  (inotify is
too late for some coherent things: the file is modified first, then
you find out.)

I wouldn't like deleting a hard-link to have that effect if it can be
avoided.  Or renaming (see below).

> At the risk of being lazy and not checking for myself...what in the
> NFSv4 spec mandates this?

On the same note, if deleting any link of a hard-link file requires
this, surely renaming a file requires it too, because that's roughly
equivalent to making a new link and deleting the old one.

-- Jamie
