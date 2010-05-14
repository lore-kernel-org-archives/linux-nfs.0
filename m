Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:45863 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756760Ab0ENR7j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 May 2010 13:59:39 -0400
Subject: Re: [PATCH] VFS: Unlink should revoke all outstanding leases on
 file
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Jeff Layton <jlayton@redhat.com>
Cc: Mi Jinlong <mijinlong@cn.fujitsu.com>,
        NFSv3 list <linux-nfs@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
        ebiederm@xmission.com, adobriyan@gmail.com, viro@ZenIV.linux.org.uk,
        jamie@shareable.org
In-Reply-To: <20100514133819.5e383485@tlielax.poochiereds.net>
References: <4BED195F.3070504@cn.fujitsu.com>
	 <20100514055844.109d2fdc@tlielax.poochiereds.net>
	 <1273857471.4732.7.camel@localhost.localdomain>
	 <20100514133819.5e383485@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 14 May 2010 13:59:28 -0400
Message-ID: <1273859968.4732.22.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-05-14 at 13:38 -0400, Jeff Layton wrote: 
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
> delete open files at all. I don't think samba will really care too
> much either way. I suppose it could hurt performance in situations
> where you had a file that was hardlinked and deleted a hardlink that
> was "unrelated" to the dentry being held open...but that's pretty
> clearly a corner case at best.
> 
> At the risk of being lazy and not checking for myself...what in the
> NFSv4 spec mandates this?
> 

Section 9.4.4: Recall of Open Delegation

   The following events necessitate recall of an open delegation:

   o  Potentially conflicting OPEN request (or READ/WRITE done with
      "special" stateid)

   o  SETATTR issued by another client

   o  REMOVE request for the file

   o  RENAME request for the file as either source or target of the
      RENAME

   Whether a RENAME of a directory in the path leading to the file
   results in recall of an open delegation depends on the semantics of
   the server filesystem.  If that filesystem denies such RENAMEs when a
   file is open, the recall must be performed to determine whether the
   file in question is, in fact, open.

Note that the server should also recall the delegation if someone
attempts to violate the guarantees that are listed in section 9.4: Open
Delegation

   When a client has a read open delegation, it may not make any changes
   to the contents or attributes of the file but it is assured that no
   other client may do so.  When a client has a write open delegation,
   it may modify the file data since no other client will be accessing
   the file's data.  The client holding a write delegation may only
   affect file attributes which are intimately connected with the file
   data:  size, time_modify, change.

IOW: even if you hold a write delegation you are not allowed to change
the file mode bits, owner, group or acls...

Cheers
  Trond

