Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13427 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757682Ab0ENRig (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 May 2010 13:38:36 -0400
Date: Fri, 14 May 2010 13:38:19 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Mi Jinlong <mijinlong@cn.fujitsu.com>,
        NFSv3 list <linux-nfs@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
        ebiederm@xmission.com, adobriyan@gmail.com, viro@ZenIV.linux.org.uk,
        jamie@shareable.org
Subject: Re: [PATCH] VFS: Unlink should revoke all outstanding leases on
 file
Message-ID: <20100514133819.5e383485@tlielax.poochiereds.net>
In-Reply-To: <1273857471.4732.7.camel@localhost.localdomain>
References: <4BED195F.3070504@cn.fujitsu.com>
	<20100514055844.109d2fdc@tlielax.poochiereds.net>
	<1273857471.4732.7.camel@localhost.localdomain>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 14 May 2010 13:17:51 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Fri, 2010-05-14 at 05:58 -0400, Jeff Layton wrote: 
> > On Fri, 14 May 2010 17:35:27 +0800
> > Mi Jinlong <mijinlong@cn.fujitsu.com> wrote:
> > 
> > > After client get one file's READ delegation through NFSv4,
> > > server delete this file but don't reclaim the delegation.
> > > 
> > > This patch add break_lease at may_delete, which can reclaim delegations.
> > > 
> > > ---
> > >  fs/namei.c |    2 +-
> > >  1 files changed, 1 insertions(+), 1 deletions(-)
> > > 
> > > diff --git a/fs/namei.c b/fs/namei.c
> > > index 16df727..17bafc1 100644
> > > --- a/fs/namei.c
> > > +++ b/fs/namei.c
> > > @@ -1338,7 +1338,7 @@ static int may_delete(struct inode *dir,struct dentry *victim,int isdir)
> > >  		return -ENOENT;
> > >  	if (victim->d_flags & DCACHE_NFSFS_RENAMED)
> > >  		return -EBUSY;
> > > -	return 0;
> > > +	return break_lease(victim->d_inode, FMODE_WRITE);
> > >  }
> > >  
> > >  /*	Check whether we can create an object with dentry child in directory
> > 
> > This doesn't look right to me.
> > 
> > The fcntl(2) manpage basically says that leases should be broken if the
> > file is opened for read or write, or is truncated. unlinks don't seem
> > to fall into either category...
> > 
> 
> Breaking the lease in this case is certainly a requirement for NFSv4
> delegations. I've no idea what the CIFS oplock requirements are...
> 

Heh, probably "undefined". Windows generally doesn't allow you to
delete open files at all. I don't think samba will really care too
much either way. I suppose it could hurt performance in situations
where you had a file that was hardlinked and deleted a hardlink that
was "unrelated" to the dentry being held open...but that's pretty
clearly a corner case at best.

At the risk of being lazy and not checking for myself...what in the
NFSv4 spec mandates this?

-- 
Jeff Layton <jlayton@redhat.com>
