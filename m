Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:5613 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751999Ab3FMPTU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Jun 2013 11:19:20 -0400
Date: Thu, 13 Jun 2013 11:18:44 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: viro@zeniv.linux.org.uk, matthew@wil.cx, dhowells@redhat.com,
        sage@inktank.com, smfrench@gmail.com, swhiteho@redhat.com,
        Trond.Myklebust@netapp.com, akpm@linux-foundation.org,
        linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, cluster-devel@redhat.com,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        piastryyy@gmail.com
Subject: Re: [PATCH v2 12/14] locks: give the blocked_hash its own spinlock
Message-ID: <20130613111844.59421622@corrin.poochiereds.net>
In-Reply-To: <20130613150247.GB20666@fieldses.org>
References: <1370948948-31784-1-git-send-email-jlayton@redhat.com>
	<1370948948-31784-13-git-send-email-jlayton@redhat.com>
	<20130613150247.GB20666@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 13 Jun 2013 11:02:47 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Jun 11, 2013 at 07:09:06AM -0400, Jeff Layton wrote:
> > There's no reason we have to protect the blocked_hash and file_lock_list
> > with the same spinlock. With the tests I have, breaking it in two gives
> > a barely measurable performance benefit, but it seems reasonable to make
> > this locking as granular as possible.
> 
> Out of curiosity...  In the typical case when adding/removing a lock,
> aren't both lists being modified in rapid succession?
> 
> I wonder if it would be better to instead stick with one lock and take
> care to acquire it only once to cover both manipulations.
> 
> --b.
> 

That's not really the case...

Typically, when doing a call into __posix_lock_file with FL_SLEEP set,
we either end up blocking on the lock or acquiring it. In either case,
we'll only end up taking one of the global spinlocks. The reason for
this is that blocker is what dequeues a waiter from the blocked_hash
before waking it up (in locks_wake_up_posix_blocks).

Also, while this patch description doesn't spell it out, we require a
truly global lock for deadlock detection. In a later patch though, I
convert the file_lock_lock to a per-cpu spinlock. So we really do need
to separate the locks here in order to make the per-cpu file_lock_list
worthwhile.

> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  Documentation/filesystems/Locking |   16 ++++++++--------
> >  fs/locks.c                        |   25 +++++++++++++------------
> >  2 files changed, 21 insertions(+), 20 deletions(-)
> > 
> > diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
> > index ee351ac..8d8d040 100644
> > --- a/Documentation/filesystems/Locking
> > +++ b/Documentation/filesystems/Locking
> > @@ -359,20 +359,20 @@ prototypes:
> >  
> >  locking rules:
> >  
> > -			inode->i_lock	file_lock_lock	may block
> > -lm_compare_owner:	yes		maybe		no
> > -lm_owner_key		yes		yes		no
> > -lm_notify:		yes		no		no
> > -lm_grant:		no		no		no
> > -lm_break:		yes		no		no
> > -lm_change		yes		no		no
> > +			inode->i_lock	blocked_hash_lock	may block
> > +lm_compare_owner:	yes		maybe			no
> > +lm_owner_key		yes		yes			no
> > +lm_notify:		yes		no			no
> > +lm_grant:		no		no			no
> > +lm_break:		yes		no			no
> > +lm_change		yes		no			no
> >  
> >  	->lm_compare_owner and ->lm_owner_key are generally called with
> >  *an* inode->i_lock held. It may not be the i_lock of the inode
> >  associated with either file_lock argument! This is the case with deadlock
> >  detection, since the code has to chase down the owners of locks that may
> >  be entirely unrelated to the one on which the lock is being acquired.
> > -For deadlock detection however, the file_lock_lock is also held. The
> > +For deadlock detection however, the blocked_hash_lock is also held. The
> >  fact that these locks are held ensures that the file_locks do not
> >  disappear out from under you while doing the comparison or generating an
> >  owner key.
> > diff --git a/fs/locks.c b/fs/locks.c
> > index 11e7784..8124fc1 100644
> > --- a/fs/locks.c
> > +++ b/fs/locks.c
> > @@ -162,12 +162,11 @@ int lease_break_time = 45;
> >   */
> >  #define BLOCKED_HASH_BITS	7
> >  
> > +static DEFINE_SPINLOCK(blocked_hash_lock);
> >  static DEFINE_HASHTABLE(blocked_hash, BLOCKED_HASH_BITS);
> >  
> > -static HLIST_HEAD(file_lock_list);
> > -
> > -/* Protects the file_lock_list and the blocked_hash */
> >  static DEFINE_SPINLOCK(file_lock_lock);
> > +static HLIST_HEAD(file_lock_list);
> >  
> >  static struct kmem_cache *filelock_cache __read_mostly;
> >  
> > @@ -505,9 +504,9 @@ __locks_delete_global_blocked(struct file_lock *waiter)
> >  static inline void
> >  locks_delete_global_blocked(struct file_lock *waiter)
> >  {
> > -	spin_lock(&file_lock_lock);
> > +	spin_lock(&blocked_hash_lock);
> >  	__locks_delete_global_blocked(waiter);
> > -	spin_unlock(&file_lock_lock);
> > +	spin_unlock(&blocked_hash_lock);
> >  }
> >  
> >  static inline void
> > @@ -581,14 +580,14 @@ static void locks_wake_up_blocks(struct file_lock *blocker)
> >  
> >  /*
> >   * Wake up processes blocked waiting for blocker. In the FL_POSIX case, we must
> > - * also take the global file_lock_lock and dequeue it from the global blocked
> > - * list as we wake the processes.
> > + * also take the global blocked_hash_lock and dequeue it from the global
> > + * blocked list as we wake the processes.
> >   *
> >   * Must be called with the inode->i_lock of the blocker held!
> >   */
> >  static void locks_wake_up_posix_blocks(struct file_lock *blocker)
> >  {
> > -	spin_lock(&file_lock_lock);
> > +	spin_lock(&blocked_hash_lock);
> >  	while (!list_empty(&blocker->fl_block)) {
> >  		struct file_lock *waiter;
> >  
> > @@ -601,7 +600,7 @@ static void locks_wake_up_posix_blocks(struct file_lock *blocker)
> >  		else
> >  			wake_up(&waiter->fl_wait);
> >  	}
> > -	spin_unlock(&file_lock_lock);
> > +	spin_unlock(&blocked_hash_lock);
> >  }
> >  /* Insert file lock fl into an inode's lock list at the position indicated
> >   * by pos. At the same time add the lock to the global file lock list.
> > @@ -754,7 +753,7 @@ static struct file_lock *what_owner_is_waiting_for(struct file_lock *block_fl)
> >  	return NULL;
> >  }
> >  
> > -/* Must be called with the file_lock_lock held! */
> > +/* Must be called with the blocked_hash_lock held! */
> >  static int posix_locks_deadlock(struct file_lock *caller_fl,
> >  				struct file_lock *block_fl)
> >  {
> > @@ -898,13 +897,13 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
> >  			if (!(request->fl_flags & FL_SLEEP))
> >  				goto out;
> >  			error = -EDEADLK;
> > -			spin_lock(&file_lock_lock);
> > +			spin_lock(&blocked_hash_lock);
> >  			if (likely(!posix_locks_deadlock(request, fl))) {
> >  				error = FILE_LOCK_DEFERRED;
> >  				locks_insert_block(fl, request);
> >  				locks_insert_global_blocked(request);
> >  			}
> > -			spin_unlock(&file_lock_lock);
> > +			spin_unlock(&blocked_hash_lock);
> >  			goto out;
> >    		}
> >    	}
> > @@ -2309,10 +2308,12 @@ static int locks_show(struct seq_file *f, void *v)
> >  
> >  	lock_get_status(f, fl, *((loff_t *)f->private), "");
> >  
> > +	spin_lock(&blocked_hash_lock);
> >  	hash_for_each(blocked_hash, bkt, bfl, fl_link) {
> >  		if (bfl->fl_next == fl)
> >  			lock_get_status(f, bfl, *((loff_t *)f->private), " ->");
> >  	}
> > +	spin_unlock(&blocked_hash_lock);
> >  
> >  	return 0;
> >  }
> > -- 
> > 1.7.1
> > 


-- 
Jeff Layton <jlayton@redhat.com>
