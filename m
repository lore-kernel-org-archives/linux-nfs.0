From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/11] nfsd: ADD new function infrastructure
Date: Tue, 21 Apr 2009 22:54:27 -0400
Message-ID: <20090422025427.GC29663@fieldses.org>
References: <20090325133607.16437.33288.sendpatchset@localhost.localdomain> <20090325133647.16437.59567.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jlayton@redhat.com, linux-nfs@vger.kernel.org,
	Krishna Kumar <krkumar2@in.ibm.com>
To: Krishna Kumar <krikku@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:45175 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752330AbZDVCya (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Apr 2009 22:54:30 -0400
In-Reply-To: <20090325133647.16437.59567.sendpatchset-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 25, 2009 at 07:06:47PM +0530, Krishna Kumar wrote:
> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> ADD infrastructure in terms of new functions.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
> 
>  fs/nfsd/vfs.c |  224 ++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 224 insertions(+)
> 
> diff -ruNp new1/fs/nfsd/vfs.c new2/fs/nfsd/vfs.c
> --- new1/fs/nfsd/vfs.c	2009-03-25 17:39:43.000000000 +0530
> +++ new2/fs/nfsd/vfs.c	2009-03-25 17:42:10.000000000 +0530
> @@ -55,11 +55,15 @@
>  #include <linux/security.h>
>  #endif /* CONFIG_NFSD_V4 */
>  #include <linux/jhash.h>
> +#include <linux/kthread.h>
>  
>  #include <asm/uaccess.h>
>  
>  #define NFSDDBG_FACILITY		NFSDDBG_FILEOP
>  
> +/* Number of jiffies to cache the file before releasing */
> +#define NFSD_CACHE_JIFFIES		(HZ/10)
> +
>  
>  /*
>   * This is a cache of readahead params that help us choose the proper
> @@ -111,6 +115,9 @@ struct fhcache {
>  	/* When this entry expires */
>  	unsigned long		p_expires;
>  
> +	/* List of entries linked to 'nfsd_daemon_free_list' */
> +	struct list_head	p_list;
> +
>  	unsigned int		p_hindex;
>  };
>  
> @@ -122,6 +129,7 @@ struct fhcache_hbucket {
>  #define FHPARM_HASH_BITS	8
>  #define FHPARM_HASH_SIZE	(1<<FHPARM_HASH_BITS)
>  #define FHPARM_HASH_MASK	(FHPARM_HASH_SIZE-1)
> +static struct fhcache_hbucket	fhcache_hash[FHPARM_HASH_SIZE];
>  
>  /* 
>   * Called from nfsd_lookup and encode_dirent. Check if we have crossed 
> @@ -866,6 +874,222 @@ found:
>  	return ra;
>  }
>  
> +/* Synchronization for daemon with enqueuer's */
> +static DEFINE_SPINLOCK(k_nfsd_lock);
> +
> +/* List of FH cache entries that has to be cleaned up when they expire */
> +static struct list_head		nfsd_daemon_free_list;
> +
> +/*
> + * Returns cached values of 'file' and svc_export; resets these entries
> + * to NULL.
> + */
> +static inline void fh_get_cached_entries(struct fhcache *fh,
> +					 struct file **filep,
> +					 struct svc_export **expp)
> +{
> +	*filep = fh->p_filp;
> +	*expp = fh->p_exp;
> +
> +	fh->p_filp = NULL;
> +	fh->p_exp = NULL;
> +}
> +
> +/*
> + * Hold a reference to dentry and svc_export (file already has an extra
> + * reference count as it is not closed normally.
> + */
> +static inline void fh_cache_get(struct file *file, struct svc_export *exp)
> +{
> +	dget(file->f_dentry);
> +	cache_get(&exp->h);
> +}
> +
> +/* Drop a reference to file, dentry and svc_export */
> +static inline void fh_cache_put(struct file *file, struct svc_export *exp)
> +{
> +	cache_put(&exp->h, &svc_export_cache);
> +	dput(file->f_dentry);
> +	fput(file);
> +}
> +
> +/*
> + * Holds a reference to dentry and svc_export, and caches both. Add fh entry
> + * to list for daemon to cleanup later. Once we add the entry to the list,
> + * we'd rather it expire prematurely rather than updating it on every read.
> + */
> +static inline void fh_cache_upd(struct fhcache *fh, struct file *file,
> +				struct svc_export *exp)
> +{
> +	if (fh) {
> +		if (!fh->p_filp && file) {
> +			struct fhcache_hbucket *fhb;
> +
> +			fh_cache_get(file, exp);
> +
> +			fhb = &fhcache_hash[fh->p_hindex];
> +
> +			spin_lock(&fhb->pb_lock);
> +			fh->p_filp = file;
> +			fh->p_exp = exp;
> +			fh->p_expires = jiffies + NFSD_CACHE_JIFFIES;
> +
> +			spin_lock(&k_nfsd_lock);
> +			list_add_tail(&fh->p_list, &nfsd_daemon_free_list);
> +			spin_unlock(&k_nfsd_lock);
> +
> +			spin_unlock(&fhb->pb_lock);
> +		}
> +
> +		/* Drop our reference */
> +		atomic_dec(&fh->p_count);
> +	} else if (file)
> +		nfsd_close(file);
> +}
> +
> +/* Daemon cache cleanup handler */
> +void daemon_free_entries(void)
> +{
> +	unsigned long now = jiffies;
> +
> +	spin_lock(&k_nfsd_lock);
> +	while (!list_empty(&nfsd_daemon_free_list)) {
> +		struct fhcache *fh = list_entry(nfsd_daemon_free_list.next,
> +                                                struct fhcache, p_list);
> +		struct fhcache_hbucket *fhb;
> +		struct file *file;
> +		struct svc_export *exp;
> +
> +		if (time_after(fh->p_expires, now) || now != jiffies) {
> +			/*
> +			 * This (and all subsequent entries) have not expired;
> +			 * or we have spent too long in this loop.
> +			 */
> +			break;
> +		}
> +
> +		fhb = &fhcache_hash[fh->p_hindex];
> +
> +		/*
> +		 * Make sure we do not deadlock with updaters - we can free
> +		 * entry next time in case of a race.
> +		 */
> +		if (!spin_trylock(&fhb->pb_lock)) {
> +			/*
> +			 * Entry is being used, no need to free this, try later
> +			 */
> +			break;
> +		}
> +
> +		if (atomic_read(&fh->p_count)) {
> +			spin_unlock(&fhb->pb_lock);
> +			break;
> +		}
> +
> +		list_del(&fh->p_list);
> +		fh_get_cached_entries(fh, &file, &exp);
> +		spin_unlock(&fhb->pb_lock);
> +		spin_unlock(&k_nfsd_lock);
> +
> +		fh_cache_put(file, exp);
> +		spin_lock(&k_nfsd_lock);
> +	}
> +	spin_unlock(&k_nfsd_lock);
> +}
> +
> +static int k_nfsd_thread(void *unused)
> +{
> +	while (!kthread_should_stop()) {
> +		schedule_timeout_interruptible(NFSD_CACHE_JIFFIES);
> +
> +		if (kthread_should_stop())
> +			break;
> +
> +		daemon_free_entries();
> +	}
> +	__set_current_state(TASK_RUNNING);

Is this necessary?  The comment before schedule_timeout() claims "The
current task state is guaranteed to be TASK_RUNNING when this routine
returns."

> +
> +	return 0;
> +}
> +
> +/*
> + * Obtain the cached file, export and d_inode values for the FH
> + * specified by fh->auth[3]
> + */
> +static inline struct fhcache *
> +nfsd_get_fhcache(__u32 auth)
> +{
> +	struct fhcache		*fh, **fhp, **ffhp = NULL;
> +	int			depth = 0;
> +	unsigned int		hash;
> +	struct fhcache_hbucket	*fhb;
> +
> +	if (!auth)
> +		return NULL;
> +
> +	hash = jhash_1word(auth, 0xfeedbeef) & FHPARM_HASH_MASK;
> +	fhb = &fhcache_hash[hash];
> +
> +	spin_lock(&fhb->pb_lock);
> +	for (fhp = &fhb->pb_head; (fh = *fhp); fhp = &fh->p_next) {
> +		if (fh->p_auth == auth) {
> +			/* Same inode */
> +			if (unlikely(!fh->p_filp)) {
> +				/*
> +				 * Someone is racing in the same code, and
> +				 * this is the first reference to this file.
> +				 */
> +				spin_unlock(&fhb->pb_lock);

The locking seems over-complicated.  But I have to admit, I don't
understand it yet.

> +				return NULL;
> +			}
> +
> +			/*
> +			 * Hold an extra reference to dentry/exp since these
> +			 * are released in fh_put(). 'file' already has an
> +			 * extra hold from the first lookup which was never
> +			 * dropped.

Why not take a reference on the file instead of the dentry?

> +			 */
> +			fh_cache_get(fh->p_filp, fh->p_exp);
> +			goto found;
> +		}
> +
> +		depth++;
> +
> +		if (!ffhp && !fh->p_filp) {
> +			/*
> +			 * This is an unused inode (or a different one), and no
> +			 * entry was found till now.
> +			 */
> +			if (!atomic_read(&fh->p_count)) /* Entry is unused */
> +				ffhp = fhp;
> +		}
> +	}
> +
> +	if (!ffhp) {
> +		spin_unlock(&fhb->pb_lock);
> +		return NULL;
> +	}
> +
> +	depth = nfsdstats.ra_size*11/10;

Help, I'm confused--what's the meaning of this calculation?

--b.

> +	fhp = ffhp;
> +	fh = *ffhp;
> +	fh->p_hindex = hash;
> +	fh->p_auth = auth;
> +
> +found:
> +	if (fhp != &fhb->pb_head) {
> +		*fhp = fh->p_next;
> +		fh->p_next   = fhb->pb_head;
> +		fhb->pb_head = fh;
> +	}
> +
> +	atomic_inc(&fh->p_count);
> +	nfsdstats.ra_depth[depth*10/nfsdstats.ra_size]++;
> +	spin_unlock(&fhb->pb_lock);
> +
> +	return fh;
> +}
> +
>  /*
>   * Grab and keep cached pages associated with a file in the svc_rqst
>   * so that they can be passed to the network sendmsg/sendpage routines
