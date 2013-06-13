Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60729 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755391Ab3FMPBD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Jun 2013 11:01:03 -0400
Date: Thu, 13 Jun 2013 11:00:33 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: viro@zeniv.linux.org.uk, matthew@wil.cx, dhowells@redhat.com,
        sage@inktank.com, smfrench@gmail.com, swhiteho@redhat.com,
        Trond.Myklebust@netapp.com, akpm@linux-foundation.org,
        linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, cluster-devel@redhat.com,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        piastryyy@gmail.com
Subject: Re: [PATCH v2 11/14] locks: add a new "lm_owner_key" lock operation
Message-ID: <20130613150033.GA20666@fieldses.org>
References: <1370948948-31784-1-git-send-email-jlayton@redhat.com>
 <1370948948-31784-12-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1370948948-31784-12-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 11, 2013 at 07:09:05AM -0400, Jeff Layton wrote:
> Currently, the hashing that the locking code uses to add these values
> to the blocked_hash is simply calculated using fl_owner field. That's
> valid in most cases except for server-side lockd, which validates the
> owner of a lock based on fl_owner and fl_pid.
> 
> In the case where you have a small number of NFS clients doing a lot
> of locking between different processes, you could end up with all
> the blocked requests sitting in a very small number of hash buckets.
> 
> Add a new lm_owner_key operation to the lock_manager_operations that
> will generate an unsigned long to use as the key in the hashtable.
> That function is only implemented for server-side lockd, and simply
> XORs the fl_owner and fl_pid.

Like I've said I think we should look into defining a lock_owner struct
that lockd can allocate as necessary so that the lock code can just do a
pointer comparison on struct lock_owner *'s.  But maybe that doesn't
work out and in any case it can be future work, so looks fine, ACK.

--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  Documentation/filesystems/Locking |   18 +++++++++++-------
>  fs/lockd/svclock.c                |   12 ++++++++++++
>  fs/locks.c                        |   12 ++++++++++--
>  include/linux/fs.h                |    1 +
>  4 files changed, 34 insertions(+), 9 deletions(-)
> 
> diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
> index 13f91ab..ee351ac 100644
> --- a/Documentation/filesystems/Locking
> +++ b/Documentation/filesystems/Locking
> @@ -351,6 +351,7 @@ fl_release_private:	maybe		no
>  ----------------------- lock_manager_operations ---------------------------
>  prototypes:
>  	int (*lm_compare_owner)(struct file_lock *, struct file_lock *);
> +	unsigned long (*lm_owner_key)(struct file_lock *);
>  	void (*lm_notify)(struct file_lock *);  /* unblock callback */
>  	int (*lm_grant)(struct file_lock *, struct file_lock *, int);
>  	void (*lm_break)(struct file_lock *); /* break_lease callback */
> @@ -360,18 +361,21 @@ locking rules:
>  
>  			inode->i_lock	file_lock_lock	may block
>  lm_compare_owner:	yes		maybe		no
> +lm_owner_key		yes		yes		no
>  lm_notify:		yes		no		no
>  lm_grant:		no		no		no
>  lm_break:		yes		no		no
>  lm_change		yes		no		no
>  
> -	->lm_compare_owner is generally called with *an* inode->i_lock
> -held. It may not be the i_lock of the inode for either file_lock being
> -compared! This is the case with deadlock detection, since the code has
> -to chase down the owners of locks that may be entirely unrelated to the
> -one on which the lock is being acquired. For deadlock detection however,
> -the file_lock_lock is also held. The locks primarily ensure that neither
> -file_lock disappear out from under you while doing the comparison.
> +	->lm_compare_owner and ->lm_owner_key are generally called with
> +*an* inode->i_lock held. It may not be the i_lock of the inode
> +associated with either file_lock argument! This is the case with deadlock
> +detection, since the code has to chase down the owners of locks that may
> +be entirely unrelated to the one on which the lock is being acquired.
> +For deadlock detection however, the file_lock_lock is also held. The
> +fact that these locks are held ensures that the file_locks do not
> +disappear out from under you while doing the comparison or generating an
> +owner key.
>  
>  --------------------------- buffer_head -----------------------------------
>  prototypes:
> diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
> index e703318..ce2cdab 100644
> --- a/fs/lockd/svclock.c
> +++ b/fs/lockd/svclock.c
> @@ -744,8 +744,20 @@ static int nlmsvc_same_owner(struct file_lock *fl1, struct file_lock *fl2)
>  	return fl1->fl_owner == fl2->fl_owner && fl1->fl_pid == fl2->fl_pid;
>  }
>  
> +/*
> + * Since NLM uses two "keys" for tracking locks, we need to hash them down
> + * to one for the blocked_hash. Here, we're just xor'ing the host address
> + * with the pid in order to create a key value for picking a hash bucket.
> + */
> +static unsigned long
> +nlmsvc_owner_key(struct file_lock *fl)
> +{
> +	return (unsigned long)fl->fl_owner ^ (unsigned long)fl->fl_pid;
> +}
> +
>  const struct lock_manager_operations nlmsvc_lock_operations = {
>  	.lm_compare_owner = nlmsvc_same_owner,
> +	.lm_owner_key = nlmsvc_owner_key,
>  	.lm_notify = nlmsvc_notify_blocked,
>  	.lm_grant = nlmsvc_grant_deferred,
>  };
> diff --git a/fs/locks.c b/fs/locks.c
> index 76fb7af..11e7784 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -481,11 +481,19 @@ static int posix_same_owner(struct file_lock *fl1, struct file_lock *fl2)
>  	return fl1->fl_owner == fl2->fl_owner;
>  }
>  
> +static unsigned long
> +posix_owner_key(struct file_lock *fl)
> +{
> +	if (fl->fl_lmops && fl->fl_lmops->lm_owner_key)
> +		return fl->fl_lmops->lm_owner_key(fl);
> +	return (unsigned long)fl->fl_owner;
> +}
> +
>  /* Remove a blocker or lock from one of the global lists */
>  static inline void
>  locks_insert_global_blocked(struct file_lock *waiter)
>  {
> -	hash_add(blocked_hash, &waiter->fl_link, (unsigned long)waiter->fl_owner);
> +	hash_add(blocked_hash, &waiter->fl_link, posix_owner_key(waiter));
>  }
>  
>  static inline void
> @@ -739,7 +747,7 @@ static struct file_lock *what_owner_is_waiting_for(struct file_lock *block_fl)
>  {
>  	struct file_lock *fl;
>  
> -	hash_for_each_possible(blocked_hash, fl, fl_link, (unsigned long)block_fl->fl_owner) {
> +	hash_for_each_possible(blocked_hash, fl, fl_link, posix_owner_key(block_fl)) {
>  		if (posix_same_owner(fl, block_fl))
>  			return fl->fl_next;
>  	}
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 3b340f7..232a345 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -908,6 +908,7 @@ struct file_lock_operations {
>  
>  struct lock_manager_operations {
>  	int (*lm_compare_owner)(struct file_lock *, struct file_lock *);
> +	unsigned long (*lm_owner_key)(struct file_lock *);
>  	void (*lm_notify)(struct file_lock *);	/* unblock callback */
>  	int (*lm_grant)(struct file_lock *, struct file_lock *, int);
>  	void (*lm_break)(struct file_lock *);
> -- 
> 1.7.1
> 
