From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [RFC] [PATCH v2 1/1]: nfsd: Change caching from ino/dev to
 file-handle
Date: Fri, 20 Feb 2009 15:49:03 -0800
Message-ID: <20090220154903.1e0c6952@tupile.poochiereds.net>
References: <20090124123457.10995.57636.sendpatchset@localhost.localdomain>
	<20090124123511.10995.88449.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:34044 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754095AbZBTXvR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Feb 2009 18:51:17 -0500
In-Reply-To: <20090124123511.10995.88449.sendpatchset-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 24 Jan 2009 18:05:11 +0530
Krishna Kumar <krkumar2@in.ibm.com> wrote:

> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> Implement the file handle caching. List of changes:
> 
> 	1. Remove all implementation and users of readahead, rename RA to FH,
>            parm to cache.
> 	2. Add fields in the fhparms to cache file, svc_export, expiry list
> 	   and expiry time. Modify some other fields (eg p_count is atomic).
> 	3. Implement a daemon to clean up cached FH's.
> 	4. Added four helper functions:
> 		fh_cache_get: Hold a reference to dentry and svc_export.
> 		fh_cache_put: Drop a reference to file, dentry and svc_export.
> 		fh_get_cached_entries: Returns cached file and svc_export.
> 		fh_cache_upd: Cache file and svc_export. Add entry to list for
> 			      daemon to cleanup.
> 	5. nfsd_get_raparms is slightly rewritten (changed to nfsd_get_fhcache).
> 	6. nfsd_read rewritten to use the cache, remove RA from nfsd_vfs_read.
> 	7. File remove operation from the client results in the server checking
> 	   the cache and drops reference immediately (remove operation on the
> 	   server still retains the reference for a short time before the
> 	   daemon frees up the entry).
> 	8. init and shutdown are slightly modified.
> 
> 	(ra_size, ra_depth, nfsd_racache_init and nfsd_racache_shutdown still
> 	   retain the "ra" prefix for now)
> 
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
>  fs/nfsd/vfs.c |  429 +++++++++++++++++++++++++++++++++++++-----------
>  1 file changed, 338 insertions(+), 91 deletions(-)
> 

Hi Krishna. Sorry for the slow response on my part as well. First, some
general comments:

It would be nice to break up this patchset some. It's very hard to
review large-scale changes like this, and this is quite frankly not
code that is often touched by human hands. Being able to do a git
bisect if we run across bugs after these changes would be a very nice
thing. It won't be helpful though unless the changes are in smaller
pieces.

As a general guideline you'll want to try to do the changes in smaller
pieces, but each patch should leave the tree in a working state. It's
hard to be more specific than that without delving more deeply (which I
don't have time to do at the moment).

In your earlier discussion with Bruce, you mentioned trying to
determine when to flush the cache. When the exports table is changed
via exportfs, the exports kernel cache is also flushed. Hooking into
that might be the best thing...

I'd also go ahead and get rid of the ra_ prefixes unless you feel
they're needed. It'd be best to clean this up so that we don't have to
muck around in here later.

More comments below:

> diff -ruNp 2.6.29-rc2.org/fs/nfsd/vfs.c 2.6.29-rc2.new/fs/nfsd/vfs.c
> --- 2.6.29-rc2.org/fs/nfsd/vfs.c	2009-01-22 13:23:18.000000000 +0530
> +++ 2.6.29-rc2.new/fs/nfsd/vfs.c	2009-01-22 13:23:18.000000000 +0530
> @@ -55,38 +55,53 @@
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
> +#define NFSD_CACHE_JIFFIES		100
>  

^^^^
It'd probably be better to express this in terms of HZ so that this is
a fixed amount of time regardless of how the kernel is compiled.

>  /*
> - * This is a cache of readahead params that help us choose the proper
> - * readahead strategy. Initially, we set all readahead parameters to 0
> - * and let the VFS handle things.
> + * This is a cache of file handles to quicken file lookup. This also
> + * helps prevent multiple open/close of a file when a client reads it.
> + *
>   * If you increase the number of cached files very much, you'll need to
>   * add a hash table here.
>   */
> -struct raparms {
> -	struct raparms		*p_next;
> -	unsigned int		p_count;
> -	ino_t			p_ino;
> -	dev_t			p_dev;
> -	int			p_set;
> -	struct file_ra_state	p_ra;
> +struct fhcache {
> +	struct fhcache		*p_next;
> +
> +	/* Hashed on this parameter */
> +	__u32			p_auth;
> +
> +	/* Cached information */
> +	struct file		*p_filp;
> +	struct svc_export	*p_exp;
> +
> +	/* Refcount for overwrite */
> +	atomic_t		p_count;
> +
> +	/* When this entry expires */
> +	unsigned long		p_expires;
> +
> +	/* List of entries linked to 'nfsd_daemon_list' */
> +	struct list_head	p_list;
> +
>  	unsigned int		p_hindex;
>  };
>  
> -struct raparm_hbucket {
> -	struct raparms		*pb_head;
> +struct fhcache_hbucket {
> +	struct fhcache		*pb_head;
>  	spinlock_t		pb_lock;
>  } ____cacheline_aligned_in_smp;
>  
> -#define RAPARM_HASH_BITS	4
> -#define RAPARM_HASH_SIZE	(1<<RAPARM_HASH_BITS)
> -#define RAPARM_HASH_MASK	(RAPARM_HASH_SIZE-1)
> -static struct raparm_hbucket	raparm_hash[RAPARM_HASH_SIZE];
> +#define FHPARM_HASH_BITS	8
> +#define FHPARM_HASH_SIZE	(1<<FHPARM_HASH_BITS)
> +#define FHPARM_HASH_MASK	(FHPARM_HASH_SIZE-1)
> +static struct fhcache_hbucket	fhcache_hash[FHPARM_HASH_SIZE];
>  
>  /* 
>   * Called from nfsd_lookup and encode_dirent. Check if we have crossed 
> @@ -784,51 +799,223 @@ nfsd_sync_dir(struct dentry *dp)
>  	return nfsd_dosync(NULL, dp, dp->d_inode->i_fop);
>  }
>  
> +/* Daemon to handle expired fh cache entries */
> +static struct task_struct	*k_nfsd_task;
> +
> +/* Synchronization for daemon with enqueuer's */
> +static DEFINE_SPINLOCK(k_nfsd_lock);
> +
> +/* List of FH cache entries that has to be cleaned up when they expire */
> +static struct list_head		nfsd_daemon_list;
> +

^^^ some more descriptive variable names would be welcome...

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
>  /*
> - * Obtain the readahead parameters for the file
> - * specified by (dev, ino).
> + * Holds a reference to dentry and svc_export, and caches both. Add fh entry
> + * to list for daemon to cleanup later. Once we add the entry to the list,
> + * we'd rather it expire prematurely rather than updating it on every read.
>   */
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
>  
> -static inline struct raparms *
> -nfsd_get_raparms(dev_t dev, ino_t ino)
> +			spin_lock(&k_nfsd_lock);
> +			list_add_tail(&fh->p_list, &nfsd_daemon_list);
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
>  {
> -	struct raparms	*ra, **rap, **frap = NULL;
> -	int depth = 0;
> -	unsigned int hash;
> -	struct raparm_hbucket *rab;
> +	unsigned long now = jiffies;
> +
> +	spin_lock(&k_nfsd_lock);
> +	while (!list_empty(&nfsd_daemon_list)) {
> +		struct fhcache *fh = list_entry(nfsd_daemon_list.next,
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
>  
> -	hash = jhash_2words(dev, ino, 0xfeedbeef) & RAPARM_HASH_MASK;
> -	rab = &raparm_hash[hash];
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
>  
> -	spin_lock(&rab->pb_lock);
> -	for (rap = &rab->pb_head; (ra = *rap); rap = &ra->p_next) {
> -		if (ra->p_ino == ino && ra->p_dev == dev)
> +		if (kthread_should_stop())
> +			break;
> +
> +		daemon_free_entries();
> +	}
> +	__set_current_state(TASK_RUNNING);
> +
> +	return 0;
> +}
> +

^^^
...I can't say I'm thrilled about adding a kthread for this but don't
have any specific objections. I wonder if it might be better to just
periodically schedule (and reschedule) delayed work to the events queue
whenever a cache entry is touched?

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
> +				return NULL;
> +			}
> +
> +			/*
> +			 * Hold an extra reference to dentry/exp since these
> +			 * are released in fh_put(). 'file' already has an
> +			 * extra hold from the first lookup which was never
> +			 * dropped.
> +			 */
> +			fh_cache_get(fh->p_filp, fh->p_exp);
>  			goto found;
> +		}
> +
>  		depth++;
> -		if (ra->p_count == 0)
> -			frap = rap;
> +
> +		if (!ffhp && !fh->p_filp) {
> +			/*
> +			 * This is an unused inode (or a different one), and no
> +			 * entry was found till now.
> +			 */
> +			if (!atomic_read(&fh->p_count)) /* Entry is unused */
> +				ffhp = fhp;
> +		}
>  	}
> -	depth = nfsdstats.ra_size*11/10;
> -	if (!frap) {	
> -		spin_unlock(&rab->pb_lock);
> +
> +	if (!ffhp) {
> +		spin_unlock(&fhb->pb_lock);
>  		return NULL;
>  	}
> -	rap = frap;
> -	ra = *frap;
> -	ra->p_dev = dev;
> -	ra->p_ino = ino;
> -	ra->p_set = 0;
> -	ra->p_hindex = hash;
> +
> +	depth = nfsdstats.ra_size*11/10;
> +	fhp = ffhp;
> +	fh = *ffhp;
> +	fh->p_hindex = hash;
> +	fh->p_auth = auth;
> +
>  found:
> -	if (rap != &rab->pb_head) {
> -		*rap = ra->p_next;
> -		ra->p_next   = rab->pb_head;
> -		rab->pb_head = ra;
> +	if (fhp != &fhb->pb_head) {
> +		*fhp = fh->p_next;
> +		fh->p_next   = fhb->pb_head;
> +		fhb->pb_head = fh;
>  	}
> -	ra->p_count++;
> +
> +	atomic_inc(&fh->p_count);
>  	nfsdstats.ra_depth[depth*10/nfsdstats.ra_size]++;
> -	spin_unlock(&rab->pb_lock);
> -	return ra;
> +	spin_unlock(&fhb->pb_lock);
> +
> +	return fh;
>  }
>  
>  /*
> @@ -892,7 +1079,6 @@ nfsd_vfs_read(struct svc_rqst *rqstp, st
>                loff_t offset, struct kvec *vec, int vlen, unsigned long *count)
>  {
>  	struct inode *inode;
> -	struct raparms	*ra;
>  	mm_segment_t	oldfs;
>  	__be32		err;
>  	int		host_err;
> @@ -903,11 +1089,6 @@ nfsd_vfs_read(struct svc_rqst *rqstp, st
>  	if (svc_msnfs(fhp) && !lock_may_read(inode, offset, *count))
>  		goto out;
>  
> -	/* Get readahead parameters */
> -	ra = nfsd_get_raparms(inode->i_sb->s_dev, inode->i_ino);
> -
> -	if (ra && ra->p_set)
> -		file->f_ra = ra->p_ra;
>  
>  	if (file->f_op->splice_read && rqstp->rq_splice_ok) {
>  		struct splice_desc sd = {
> @@ -926,16 +1107,6 @@ nfsd_vfs_read(struct svc_rqst *rqstp, st
>  		set_fs(oldfs);
>  	}
>  
> -	/* Write back readahead params */
> -	if (ra) {
> -		struct raparm_hbucket *rab = &raparm_hash[ra->p_hindex];
> -		spin_lock(&rab->pb_lock);
> -		ra->p_ra = file->f_ra;
> -		ra->p_set = 1;
> -		ra->p_count--;
> -		spin_unlock(&rab->pb_lock);
> -	}
> -
>  	if (host_err >= 0) {
>  		nfsdstats.io_read += host_err;
>  		*count = host_err;
> @@ -1078,12 +1249,30 @@ nfsd_read(struct svc_rqst *rqstp, struct
>  			goto out;
>  		err = nfsd_vfs_read(rqstp, fhp, file, offset, vec, vlen, count);
>  	} else {
> -		err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_READ, &file);
> -		if (err)
> -			goto out;
> -		err = nfsd_vfs_read(rqstp, fhp, file, offset, vec, vlen, count);
> -		nfsd_close(file);
> +		struct fhcache	*fh;
> +
> +		/* Check if this fh is cached */
> +		fh = nfsd_get_fhcache(fhp->fh_handle.fh_auth[3]);
> +		if (fh && fh->p_filp) {
> +			/* Got cached values */
> +			file = fh->p_filp;
> +			fhp->fh_dentry = file->f_dentry;
> +			fhp->fh_export = fh->p_exp;
> +			err = fh_verify(rqstp, fhp, S_IFREG, NFSD_MAY_READ);
> +		} else {
> +			/* Nothing in cache */
> +			err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_READ,
> +					&file);
> +		}
> +
> +		if (!err)
> +			err = nfsd_vfs_read(rqstp, fhp, file, offset, vec, vlen,
> +					    count);
> +
> +		/* Update cached values if required, and clean up */
> +		fh_cache_upd(fh, file, fhp->fh_export);
>  	}
> +
>  out:
>  	return err;
>  }
> @@ -1791,6 +1980,39 @@ nfsd_unlink(struct svc_rqst *rqstp, stru
>  		goto out_nfserr;
>  
>  	if (type != S_IFDIR) { /* It's UNLINK */
> +		int i, found = 0;
> +
> +		for (i = 0 ; i < FHPARM_HASH_SIZE && !found; i++) {
> +			struct fhcache_hbucket *fhb = &fhcache_hash[i];
> +			struct fhcache *fh;
> +
> +			spin_lock(&fhb->pb_lock);
> +			for (fh = fhb->pb_head; fh; fh = fh->p_next) {
> +				if (fh->p_filp &&
> +				    fh->p_filp->f_dentry == rdentry) {
> +					/* Found the entry for removed file */
> +					struct file *file;
> +					struct svc_export *exp;
> +
> +					fh_get_cached_entries(fh, &file, &exp);
> +
> +					spin_lock(&k_nfsd_lock);
> +					list_del(&fh->p_list);
> +					spin_unlock(&k_nfsd_lock);
> +
> +					spin_unlock(&fhb->pb_lock);
> +
> +					/* Drop reference to this entry */
> +					fh_cache_put(file, exp);
> +
> +					spin_lock(&fhb->pb_lock);
> +					found = 1;
> +					break;
> +				}
> +			}
> +			spin_unlock(&fhb->pb_lock);
> +		}
> +
>  #ifdef MSNFS
>  		if ((fhp->fh_export->ex_flags & NFSEXP_MSNFS) &&
>  			(atomic_read(&rdentry->d_count) > 1)) {
> @@ -2061,23 +2283,36 @@ nfsd_permission(struct svc_rqst *rqstp, 
>  void
>  nfsd_racache_shutdown(void)
>  {
> -	struct raparms *raparm, *last_raparm;
>  	unsigned int i;
>  
> -	dprintk("nfsd: freeing readahead buffers.\n");
> +	dprintk("nfsd: freeing FH buffers.\n");
>  
> -	for (i = 0; i < RAPARM_HASH_SIZE; i++) {
> -		raparm = raparm_hash[i].pb_head;
> -		while(raparm) {
> -			last_raparm = raparm;
> -			raparm = raparm->p_next;
> -			kfree(last_raparm);
> +	/* Stop the daemon and free the list entries */
> +        kthread_stop(k_nfsd_task);
> +        k_nfsd_task = NULL;
> +
> +	for (i = 0; i < FHPARM_HASH_SIZE; i++) {
> +		struct fhcache *fhcache, *last_fhcache;
> +
> +		fhcache = fhcache_hash[i].pb_head;
> +		while(fhcache) {
> +			last_fhcache = fhcache;
> +			if (fhcache->p_filp) {
> +				struct file *file;
> +				struct svc_export *exp;
> +
> +				fh_get_cached_entries(fhcache, &file, &exp);
> +				list_del(&fhcache->p_list);
> +				fh_cache_put(file, exp);
> +			}
> +			fhcache = fhcache->p_next;
> +			kfree(last_fhcache);
>  		}
> -		raparm_hash[i].pb_head = NULL;
> +		fhcache_hash[i].pb_head = NULL;
>  	}
>  }
>  /*
> - * Initialize readahead param cache
> + * Initialize file handle cache
>   */
>  int
>  nfsd_racache_init(int cache_size)
> @@ -2085,36 +2320,48 @@ nfsd_racache_init(int cache_size)
>  	int	i;
>  	int	j = 0;
>  	int	nperbucket;
> -	struct raparms **raparm = NULL;
> +	struct fhcache **fhcache = NULL;
>  
>  
> -	if (raparm_hash[0].pb_head)
> +	if (fhcache_hash[0].pb_head)
>  		return 0;
> -	nperbucket = DIV_ROUND_UP(cache_size, RAPARM_HASH_SIZE);
> +	nperbucket = DIV_ROUND_UP(cache_size, FHPARM_HASH_SIZE);
>  	if (nperbucket < 2)
>  		nperbucket = 2;
> -	cache_size = nperbucket * RAPARM_HASH_SIZE;
> +	cache_size = nperbucket * FHPARM_HASH_SIZE;
>  
> -	dprintk("nfsd: allocating %d readahead buffers.\n", cache_size);
> +	dprintk("nfsd: allocating %d file handle cache buffers.\n", cache_size);
>  
> -	for (i = 0; i < RAPARM_HASH_SIZE; i++) {
> -		spin_lock_init(&raparm_hash[i].pb_lock);
> +	for (i = 0; i < FHPARM_HASH_SIZE; i++) {
> +		spin_lock_init(&fhcache_hash[i].pb_lock);
>  
> -		raparm = &raparm_hash[i].pb_head;
> +		fhcache = &fhcache_hash[i].pb_head;
>  		for (j = 0; j < nperbucket; j++) {
> -			*raparm = kzalloc(sizeof(struct raparms), GFP_KERNEL);
> -			if (!*raparm)
> +			*fhcache = kzalloc(sizeof(struct fhcache), GFP_KERNEL);
> +			if (!*fhcache) {
> +				dprintk("nfsd: kmalloc failed, freeing file cache buffers\n");
>  				goto out_nomem;
> -			raparm = &(*raparm)->p_next;
> +			}
> +			INIT_LIST_HEAD(&(*fhcache)->p_list);
> +			fhcache = &(*fhcache)->p_next;
>  		}
> -		*raparm = NULL;
> +		*fhcache = NULL;
>  	}
>  
>  	nfsdstats.ra_size = cache_size;
> +
> +	INIT_LIST_HEAD(&nfsd_daemon_list);
> +	k_nfsd_task = kthread_run(k_nfsd_thread, NULL, "nfsd_cacher");
> +
> +	if (IS_ERR(k_nfsd_task)) {
> +		printk(KERN_ERR "%s: unable to create kernel thread: %ld\n",
> +		       __FUNCTION__, PTR_ERR(k_nfsd_task));
> +		goto out_nomem;
> +	}
> +
>  	return 0;
>  
>  out_nomem:
> -	dprintk("nfsd: kmalloc failed, freeing readahead buffers\n");
>  	nfsd_racache_shutdown();
>  	return -ENOMEM;
>  }

-- 
Jeff Layton <jlayton@redhat.com>
