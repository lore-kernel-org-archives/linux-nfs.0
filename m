Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52677 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756395Ab3FMOui (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Jun 2013 10:50:38 -0400
Date: Thu, 13 Jun 2013 10:50:09 -0400
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
Subject: Re: [PATCH v2 10/14] locks: turn the blocked_list into a hashtable
Message-ID: <20130613145009.GB20235@fieldses.org>
References: <1370948948-31784-1-git-send-email-jlayton@redhat.com>
 <1370948948-31784-11-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1370948948-31784-11-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 11, 2013 at 07:09:04AM -0400, Jeff Layton wrote:
> Break up the blocked_list into a hashtable, using the fl_owner as a key.
> This speeds up searching the hash chains, which is especially significant
> for deadlock detection.
> 
> Note that the initial implementation assumes that hashing on fl_owner is
> sufficient. In most cases it should be, with the notable exception being
> server-side lockd, which compares ownership using a tuple of the
> nlm_host and the pid sent in the lock request. So, this may degrade to a
> single hash bucket when you only have a single NFS client. That will be
> addressed in a later patch.
> 
> The careful observer may note that this patch leaves the file_lock_list
> alone. There's much less of a case for turning the file_lock_list into a
> hashtable. The only user of that list is the code that generates
> /proc/locks, and it always walks the entire list.

Makes sense to me, ACK to this and the previous patch.--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/locks.c |   25 ++++++++++++++++++-------
>  1 files changed, 18 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/locks.c b/fs/locks.c
> index 28959bc..76fb7af 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -126,6 +126,7 @@
>  #include <linux/time.h>
>  #include <linux/rcupdate.h>
>  #include <linux/pid_namespace.h>
> +#include <linux/hashtable.h>
>  
>  #include <asm/uaccess.h>
>  
> @@ -153,10 +154,19 @@ int lease_break_time = 45;
>  #define for_each_lock(inode, lockp) \
>  	for (lockp = &inode->i_flock; *lockp != NULL; lockp = &(*lockp)->fl_next)
>  
> +/*
> + * By breaking up the blocked locks list into a hashtable, we speed up the
> + * deadlock detection.
> + *
> + * FIXME: make this value scale via some heuristic?
> + */
> +#define BLOCKED_HASH_BITS	7
> +
> +static DEFINE_HASHTABLE(blocked_hash, BLOCKED_HASH_BITS);
> +
>  static HLIST_HEAD(file_lock_list);
> -static HLIST_HEAD(blocked_list);
>  
> -/* Protects the two list heads above */
> +/* Protects the file_lock_list and the blocked_hash */
>  static DEFINE_SPINLOCK(file_lock_lock);
>  
>  static struct kmem_cache *filelock_cache __read_mostly;
> @@ -475,13 +485,13 @@ static int posix_same_owner(struct file_lock *fl1, struct file_lock *fl2)
>  static inline void
>  locks_insert_global_blocked(struct file_lock *waiter)
>  {
> -	hlist_add_head(&waiter->fl_link, &blocked_list);
> +	hash_add(blocked_hash, &waiter->fl_link, (unsigned long)waiter->fl_owner);
>  }
>  
>  static inline void
>  __locks_delete_global_blocked(struct file_lock *waiter)
>  {
> -	hlist_del_init(&waiter->fl_link);
> +	hash_del(&waiter->fl_link);
>  }
>  
>  static inline void
> @@ -729,7 +739,7 @@ static struct file_lock *what_owner_is_waiting_for(struct file_lock *block_fl)
>  {
>  	struct file_lock *fl;
>  
> -	hlist_for_each_entry(fl, &blocked_list, fl_link) {
> +	hash_for_each_possible(blocked_hash, fl, fl_link, (unsigned long)block_fl->fl_owner) {
>  		if (posix_same_owner(fl, block_fl))
>  			return fl->fl_next;
>  	}
> @@ -865,7 +875,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
>  	/*
>  	 * New lock request. Walk all POSIX locks and look for conflicts. If
>  	 * there are any, either return error or put the request on the
> -	 * blocker's list of waiters and the global blocked_list.
> +	 * blocker's list of waiters and the global blocked_hash.
>  	 */
>  	if (request->fl_type != F_UNLCK) {
>  		for_each_lock(inode, before) {
> @@ -2284,13 +2294,14 @@ static void lock_get_status(struct seq_file *f, struct file_lock *fl,
>  
>  static int locks_show(struct seq_file *f, void *v)
>  {
> +	int bkt;
>  	struct file_lock *fl, *bfl;
>  
>  	fl = hlist_entry(v, struct file_lock, fl_link);
>  
>  	lock_get_status(f, fl, *((loff_t *)f->private), "");
>  
> -	hlist_for_each_entry(bfl, &blocked_list, fl_link) {
> +	hash_for_each(blocked_hash, bkt, bfl, fl_link) {
>  		if (bfl->fl_next == fl)
>  			lock_get_status(f, bfl, *((loff_t *)f->private), " ->");
>  	}
> -- 
> 1.7.1
> 
