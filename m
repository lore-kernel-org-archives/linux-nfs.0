Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:34364 "EHLO
	mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753105AbbJTReR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Oct 2015 13:34:17 -0400
Received: by qkfm62 with SMTP id m62so10909978qkf.1
        for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2015 10:34:16 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v6 19/19] nfsd: rip out the raparms cache
Date: Tue, 20 Oct 2015 13:33:52 -0400
Message-Id: <1445362432-18869-20-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1445362432-18869-1-git-send-email-jeff.layton@primarydata.com>
References: <1445362432-18869-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Nothing uses it anymore.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/nfssvc.c |  14 +-----
 fs/nfsd/vfs.c    | 147 -------------------------------------------------------
 fs/nfsd/vfs.h    |   6 ---
 3 files changed, 1 insertion(+), 166 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index d816bb3faa6e..d1034d119afb 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -216,18 +216,9 @@ static int nfsd_startup_generic(int nrservs)
 	if (nfsd_users++)
 		return 0;
 
-	/*
-	 * Readahead param cache - will no-op if it already exists.
-	 * (Note therefore results will be suboptimal if number of
-	 * threads is modified after nfsd start.)
-	 */
-	ret = nfsd_racache_init(2*nrservs);
-	if (ret)
-		goto dec_users;
-
 	ret = nfsd_file_cache_init();
 	if (ret)
-		goto out_racache;
+		goto dec_users;
 
 	ret = nfs4_state_start();
 	if (ret)
@@ -236,8 +227,6 @@ static int nfsd_startup_generic(int nrservs)
 
 out_file_cache:
 	nfsd_file_cache_shutdown();
-out_racache:
-	nfsd_racache_shutdown();
 dec_users:
 	nfsd_users--;
 	return ret;
@@ -250,7 +239,6 @@ static void nfsd_shutdown_generic(void)
 
 	nfs4_state_shutdown();
 	nfsd_file_cache_shutdown();
-	nfsd_racache_shutdown();
 }
 
 static bool nfsd_needs_lockd(void)
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 571f1000e670..aafb9b00b767 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -46,34 +46,6 @@
 
 #define NFSDDBG_FACILITY		NFSDDBG_FILEOP
 
-
-/*
- * This is a cache of readahead params that help us choose the proper
- * readahead strategy. Initially, we set all readahead parameters to 0
- * and let the VFS handle things.
- * If you increase the number of cached files very much, you'll need to
- * add a hash table here.
- */
-struct raparms {
-	struct raparms		*p_next;
-	unsigned int		p_count;
-	ino_t			p_ino;
-	dev_t			p_dev;
-	int			p_set;
-	struct file_ra_state	p_ra;
-	unsigned int		p_hindex;
-};
-
-struct raparm_hbucket {
-	struct raparms		*pb_head;
-	spinlock_t		pb_lock;
-} ____cacheline_aligned_in_smp;
-
-#define RAPARM_HASH_BITS	4
-#define RAPARM_HASH_SIZE	(1<<RAPARM_HASH_BITS)
-#define RAPARM_HASH_MASK	(RAPARM_HASH_SIZE-1)
-static struct raparm_hbucket	raparm_hash[RAPARM_HASH_SIZE];
-
 /* 
  * Called from nfsd_lookup and encode_dirent. Check if we have crossed 
  * a mount point.
@@ -749,65 +721,6 @@ nfsd_open_verified(struct svc_rqst *rqstp, struct svc_fh *fhp, umode_t type,
 	return err;
 }
 
-struct raparms *
-nfsd_init_raparms(struct file *file)
-{
-	struct inode *inode = file_inode(file);
-	dev_t dev = inode->i_sb->s_dev;
-	ino_t ino = inode->i_ino;
-	struct raparms	*ra, **rap, **frap = NULL;
-	int depth = 0;
-	unsigned int hash;
-	struct raparm_hbucket *rab;
-
-	hash = jhash_2words(dev, ino, 0xfeedbeef) & RAPARM_HASH_MASK;
-	rab = &raparm_hash[hash];
-
-	spin_lock(&rab->pb_lock);
-	for (rap = &rab->pb_head; (ra = *rap); rap = &ra->p_next) {
-		if (ra->p_ino == ino && ra->p_dev == dev)
-			goto found;
-		depth++;
-		if (ra->p_count == 0)
-			frap = rap;
-	}
-	depth = nfsdstats.ra_size;
-	if (!frap) {	
-		spin_unlock(&rab->pb_lock);
-		return NULL;
-	}
-	rap = frap;
-	ra = *frap;
-	ra->p_dev = dev;
-	ra->p_ino = ino;
-	ra->p_set = 0;
-	ra->p_hindex = hash;
-found:
-	if (rap != &rab->pb_head) {
-		*rap = ra->p_next;
-		ra->p_next   = rab->pb_head;
-		rab->pb_head = ra;
-	}
-	ra->p_count++;
-	nfsdstats.ra_depth[depth*10/nfsdstats.ra_size]++;
-	spin_unlock(&rab->pb_lock);
-
-	if (ra->p_set)
-		file->f_ra = ra->p_ra;
-	return ra;
-}
-
-void nfsd_put_raparams(struct file *file, struct raparms *ra)
-{
-	struct raparm_hbucket *rab = &raparm_hash[ra->p_hindex];
-
-	spin_lock(&rab->pb_lock);
-	ra->p_ra = file->f_ra;
-	ra->p_set = 1;
-	ra->p_count--;
-	spin_unlock(&rab->pb_lock);
-}
-
 /*
  * Grab and keep cached pages associated with a file in the svc_rqst
  * so that they can be passed to the network sendmsg/sendpage routines
@@ -2017,63 +1930,3 @@ nfsd_permission(struct svc_rqst *rqstp, struct svc_export *exp,
 
 	return err? nfserrno(err) : 0;
 }
-
-void
-nfsd_racache_shutdown(void)
-{
-	struct raparms *raparm, *last_raparm;
-	unsigned int i;
-
-	dprintk("nfsd: freeing readahead buffers.\n");
-
-	for (i = 0; i < RAPARM_HASH_SIZE; i++) {
-		raparm = raparm_hash[i].pb_head;
-		while(raparm) {
-			last_raparm = raparm;
-			raparm = raparm->p_next;
-			kfree(last_raparm);
-		}
-		raparm_hash[i].pb_head = NULL;
-	}
-}
-/*
- * Initialize readahead param cache
- */
-int
-nfsd_racache_init(int cache_size)
-{
-	int	i;
-	int	j = 0;
-	int	nperbucket;
-	struct raparms **raparm = NULL;
-
-
-	if (raparm_hash[0].pb_head)
-		return 0;
-	nperbucket = DIV_ROUND_UP(cache_size, RAPARM_HASH_SIZE);
-	nperbucket = max(2, nperbucket);
-	cache_size = nperbucket * RAPARM_HASH_SIZE;
-
-	dprintk("nfsd: allocating %d readahead buffers.\n", cache_size);
-
-	for (i = 0; i < RAPARM_HASH_SIZE; i++) {
-		spin_lock_init(&raparm_hash[i].pb_lock);
-
-		raparm = &raparm_hash[i].pb_head;
-		for (j = 0; j < nperbucket; j++) {
-			*raparm = kzalloc(sizeof(struct raparms), GFP_KERNEL);
-			if (!*raparm)
-				goto out_nomem;
-			raparm = &(*raparm)->p_next;
-		}
-		*raparm = NULL;
-	}
-
-	nfsdstats.ra_size = cache_size;
-	return 0;
-
-out_nomem:
-	dprintk("nfsd: kmalloc failed, freeing readahead buffers\n");
-	nfsd_racache_shutdown();
-	return -ENOMEM;
-}
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 80692e06302d..1efccde4bf9a 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -39,8 +39,6 @@
 typedef int (*nfsd_filldir_t)(void *, const char *, int, loff_t, u64, unsigned);
 
 /* nfsd/vfs.c */
-int		nfsd_racache_init(int);
-void		nfsd_racache_shutdown(void);
 int		nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
 		                struct svc_export **expp);
 __be32		nfsd_lookup(struct svc_rqst *, struct svc_fh *,
@@ -74,7 +72,6 @@ __be32		nfsd_open(struct svc_rqst *, struct svc_fh *, umode_t,
 				int, struct file **);
 __be32		nfsd_open_verified(struct svc_rqst *, struct svc_fh *, umode_t,
 				int, struct file **);
-struct raparms;
 __be32		nfsd_splice_read(struct svc_rqst *,
 				struct file *, loff_t, unsigned long *);
 __be32		nfsd_readv(struct file *, loff_t, struct kvec *, int,
@@ -107,9 +104,6 @@ __be32		nfsd_statfs(struct svc_rqst *, struct svc_fh *,
 __be32		nfsd_permission(struct svc_rqst *, struct svc_export *,
 				struct dentry *, int);
 
-struct raparms *nfsd_init_raparms(struct file *file);
-void		nfsd_put_raparams(struct file *file, struct raparms *ra);
-
 static inline int fh_want_write(struct svc_fh *fh)
 {
 	int ret = mnt_want_write(fh->fh_export->ex_path.mnt);
-- 
2.4.3

