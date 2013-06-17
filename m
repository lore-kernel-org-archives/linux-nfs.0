Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:21503 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751763Ab3FQPuO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Jun 2013 11:50:14 -0400
Date: Mon, 17 Jun 2013 11:49:38 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: viro@zeniv.linux.org.uk, matthew@wil.cx, bfields@fieldses.org,
        dhowells@redhat.com, sage@inktank.com, smfrench@gmail.com,
        swhiteho@redhat.com, Trond.Myklebust@netapp.com,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, piastryyy@gmail.com
Subject: Re: [PATCH v3 06/13] locks: protect most of the file_lock handling
 with i_lock
Message-ID: <20130617114938.447a8d81@tlielax.poochiereds.net>
In-Reply-To: <20130617114609.708a336b@tlielax.poochiereds.net>
References: <1371482036-15958-1-git-send-email-jlayton@redhat.com>
	<1371482036-15958-7-git-send-email-jlayton@redhat.com>
	<20130617114609.708a336b@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 17 Jun 2013 11:46:09 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> On Mon, 17 Jun 2013 11:13:49 -0400
> Jeff Layton <jlayton@redhat.com> wrote:
> 
> > Having a global lock that protects all of this code is a clear
> > scalability problem. Instead of doing that, move most of the code to be
> > protected by the i_lock instead. The exceptions are the global lists
> > that the ->fl_link sits on, and the ->fl_block list.
> > 
> > ->fl_link is what connects these structures to the
> > global lists, so we must ensure that we hold those locks when iterating
> > over or updating these lists.
> > 
> > Furthermore, sound deadlock detection requires that we hold the
> > blocked_list state steady while checking for loops. We also must ensure
> > that the search and update to the list are atomic.
> > 
> > For the checking and insertion side of the blocked_list, push the
> > acquisition of the global lock into __posix_lock_file and ensure that
> > checking and update of the  blocked_list is done without dropping the
> > lock in between.
> > 
> > On the removal side, when waking up blocked lock waiters, take the
> > global lock before walking the blocked list and dequeue the waiters from
> > the global list prior to removal from the fl_block list.
> > 
> > With this, deadlock detection should be race free while we minimize
> > excessive file_lock_lock thrashing.
> > 
> > Finally, in order to avoid a lock inversion problem when handling
> > /proc/locks output we must ensure that manipulations of the fl_block
> > list are also protected by the file_lock_lock.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  Documentation/filesystems/Locking |   21 ++++--
> >  fs/afs/flock.c                    |    5 +-
> >  fs/ceph/locks.c                   |    2 +-
> >  fs/ceph/mds_client.c              |    8 +-
> >  fs/cifs/cifsfs.c                  |    2 +-
> >  fs/cifs/file.c                    |   13 ++--
> >  fs/gfs2/file.c                    |    2 +-
> >  fs/lockd/svcsubs.c                |   12 ++--
> >  fs/locks.c                        |  151 ++++++++++++++++++++++---------------
> >  fs/nfs/delegation.c               |   10 +-
> >  fs/nfs/nfs4state.c                |    8 +-
> >  fs/nfsd/nfs4state.c               |    8 +-
> >  include/linux/fs.h                |   11 ---
> >  13 files changed, 140 insertions(+), 113 deletions(-)
> > 
> 
> [...]
> 
> > @@ -1231,7 +1254,7 @@ int __break_lease(struct inode *inode, unsigned int mode)
> >  	if (IS_ERR(new_fl))
> >  		return PTR_ERR(new_fl);
> >  
> > -	lock_flocks();
> > +	spin_lock(&inode->i_lock);
> >  
> >  	time_out_leases(inode);
> >  
> > @@ -1281,11 +1304,11 @@ restart:
> >  			break_time++;
> >  	}
> >  	locks_insert_block(flock, new_fl);
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  	error = wait_event_interruptible_timeout(new_fl->fl_wait,
> >  						!new_fl->fl_next, break_time);
> > -	lock_flocks();
> > -	__locks_delete_block(new_fl);
> > +	spin_lock(&inode->i_lock);
> > +	locks_delete_block(new_fl);
> 
> Doh -- bug here. This should not have been changed to
> locks_delete_block(). My apologies.
> 
> >  	if (error >= 0) {
> >  		if (error == 0)
> >  			time_out_leases(inode);
> 
> [...]
> 
> >  posix_unblock_lock(struct file *filp, struct file_lock *waiter)
> >  {
> > +	struct inode *inode = file_inode(filp);
> >  	int status = 0;
> >  
> > -	lock_flocks();
> > +	spin_lock(&inode->i_lock);
> >  	if (waiter->fl_next)
> > -		__locks_delete_block(waiter);
> > +		locks_delete_block(waiter);
> 
> 
> Ditto here...
> 
> >  	else
> >  		status = -ENOENT;
> > -	unlock_flocks();
> > +	spin_unlock(&inode->i_lock);
> >  	return status;
> >  }
> >  
> 

Bah, scratch that -- this patch is actually fine. We hold the i_lock
here and locks_delete_block takes the file_lock_lock, which is correct.
There is a potential race in patch 7 though. I'll reply to that patch
to point it out in a minute.

-- 
Jeff Layton <jlayton@redhat.com>
