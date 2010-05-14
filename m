Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:35269 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754271Ab0ENRSE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 May 2010 13:18:04 -0400
Subject: Re: [PATCH] VFS: Unlink should revoke all outstanding leases on
 file
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Jeff Layton <jlayton@redhat.com>
Cc: Mi Jinlong <mijinlong@cn.fujitsu.com>,
        NFSv3 list <linux-nfs@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
        ebiederm@xmission.com, adobriyan@gmail.com, viro@ZenIV.linux.org.uk,
        jamie@shareable.org
In-Reply-To: <20100514055844.109d2fdc@tlielax.poochiereds.net>
References: <4BED195F.3070504@cn.fujitsu.com>
	 <20100514055844.109d2fdc@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 14 May 2010 13:17:51 -0400
Message-ID: <1273857471.4732.7.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-05-14 at 05:58 -0400, Jeff Layton wrote: 
> On Fri, 14 May 2010 17:35:27 +0800
> Mi Jinlong <mijinlong@cn.fujitsu.com> wrote:
> 
> > After client get one file's READ delegation through NFSv4,
> > server delete this file but don't reclaim the delegation.
> > 
> > This patch add break_lease at may_delete, which can reclaim delegations.
> > 
> > ---
> >  fs/namei.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/fs/namei.c b/fs/namei.c
> > index 16df727..17bafc1 100644
> > --- a/fs/namei.c
> > +++ b/fs/namei.c
> > @@ -1338,7 +1338,7 @@ static int may_delete(struct inode *dir,struct dentry *victim,int isdir)
> >  		return -ENOENT;
> >  	if (victim->d_flags & DCACHE_NFSFS_RENAMED)
> >  		return -EBUSY;
> > -	return 0;
> > +	return break_lease(victim->d_inode, FMODE_WRITE);
> >  }
> >  
> >  /*	Check whether we can create an object with dentry child in directory
> 
> This doesn't look right to me.
> 
> The fcntl(2) manpage basically says that leases should be broken if the
> file is opened for read or write, or is truncated. unlinks don't seem
> to fall into either category...
> 

Breaking the lease in this case is certainly a requirement for NFSv4
delegations. I've no idea what the CIFS oplock requirements are...

Cheers
  Trond

