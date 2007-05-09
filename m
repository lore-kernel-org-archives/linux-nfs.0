From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [GIT] Bugfixes and cleanups for NFS client...
Date: Wed, 09 May 2007 18:07:50 -0400
Message-ID: <1178748470.6760.6.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758847AbXEIWIP@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Hi Linus,

Please pull from the repository at

   git pull git://git.linux-nfs.org/pub/linux/nfs-2.6.git

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/dir.c       |   37 +++++++++++++------------------------
 fs/nfs/getroot.c   |    1 -
 fs/nfs/idmap.c     |    4 ++--
 fs/nfs/inode.c     |    3 ---
 fs/nfs/nfs2xdr.c   |    1 -
 fs/nfs/nfs4xdr.c   |   11 +++++++----
 fs/nfs/pagelist.c  |    7 -------
 net/sunrpc/sched.c |   26 +++++++++++++++++++-------
 8 files changed, 41 insertions(+), 49 deletions(-)

commit 7a13e932281e7042a592f4f14db0b348199e7aac
Author: Jesper Juhl <jesper.juhl@gmail.com>
Date:   Thu Apr 26 00:29:02 2007 -0700

    NFS: Kill the obsolete NFS_PARANOIA
    
    Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
    Acked-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fee7f23feaf0845fdfd47d20cddc75652552fbb8
Author: Milind Arun Choudhary <milindchoudhary@gmail.com>
Date:   Thu Apr 26 00:29:03 2007 -0700

    NFS: use __set_current_state()
    
    use __set_current_state(TASK_*) instead of current->state = TASK_*, in fs/nfs
    
    Signed-off-by: Milind Arun Choudhary <milindchoudhary@gmail.com>
    Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
    Cc: "J. Bruce Fields" <bfields@fieldses.org>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ddce40df6e14dd474bbd9daa006dcc290dea6326
Author: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date:   Wed May 9 08:30:11 2007 +0200

    sunrpc: fix crash in rpc_malloc()
    
    
    While the comment says:
     * To prevent rpciod from hanging, this allocator never sleeps,
     * returning NULL if the request cannot be serviced immediately.
    
    The function does not actually check for NULL pointers being returned.
    
    Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e4cc6ee2e40bdd57990577b7f851fa2ca48edf47
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue May 8 18:23:28 2007 -0400

    NFS: Clean up NFSv4 XDR error message
    
    Make it more useful for debugging purposes.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6ce7dc940701cf3fde3c6e826a696b333092cbb1
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue May 8 18:23:28 2007 -0400

    NFS: NFS client underestimates how large an NFSv4 SETATTR reply can be
    
    The maximum size of an NFSv4 SETATTR compound reply should include the
    GETATTR operation that we send.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit aa3d1faebe6e214cd96be0e587571477ff6fd9fc
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue May 8 18:23:28 2007 -0400

    SUNRPC: Fix pointer arithmetic bug recently introduced in rpc_malloc/free
    
    Use a cleaner method to find the size of an rpc_buffer.  This actually
    works on x86-64!
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e70c490810dc683fad39e57cf00e69d5f120c542
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed May 9 09:00:18 2007 -0400

    NFS: Remove redundant check in nfs_check_verifier()
    
    The check for nfs_attribute_timeout(dir) in nfs_check_verifier is
    redundant: nfs_lookup_revalidate() will already call nfs_revalidate_inode()
    on the parent dir when necessary.
    
    The only case where this is not done is the case of a negative dentry. Fix
    this case by moving up the revalidation code.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e62c2bba1fb7cf068eb78d731da46e4447a9efb1
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed May 9 09:00:17 2007 -0400

    NFS: Fix a jiffie wraparound issue
    
    dentry verifiers are always set to the parent directory's
    cache_change_attribute. There is no reason to be testing for anything other
    than equality when we're trying to find out if the dentry has been checked
    since the last time the directory was modified.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 625d8e5..3df4288 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -38,7 +38,6 @@
 #include "delegation.h"
 #include "iostat.h"
 
-#define NFS_PARANOIA 1
 /* #define NFS_DEBUG_VERBOSE 1 */
 
 static int nfs_opendir(struct inode *, struct file *);
@@ -650,12 +649,15 @@ int nfs_fsync_dir(struct file *filp, struct dentry *dentry, int datasync)
  */
 static int nfs_check_verifier(struct inode *dir, struct dentry *dentry)
 {
+	unsigned long verf;
+
 	if (IS_ROOT(dentry))
 		return 1;
-	if ((NFS_I(dir)->cache_validity & NFS_INO_INVALID_ATTR) != 0
-			|| nfs_attribute_timeout(dir))
+	verf = (unsigned long)dentry->d_fsdata;
+	if (nfs_caches_unstable(dir)
+			|| verf != NFS_I(dir)->cache_change_attribute)
 		return 0;
-	return nfs_verify_change_attribute(dir, (unsigned long)dentry->d_fsdata);
+	return 1;
 }
 
 static inline void nfs_set_verifier(struct dentry * dentry, unsigned long verf)
@@ -665,8 +667,7 @@ static inline void nfs_set_verifier(struct dentry * dentry, unsigned long verf)
 
 static void nfs_refresh_verifier(struct dentry * dentry, unsigned long verf)
 {
-	if (time_after(verf, (unsigned long)dentry->d_fsdata))
-		nfs_set_verifier(dentry, verf);
+	nfs_set_verifier(dentry, verf);
 }
 
 /*
@@ -765,6 +766,10 @@ static int nfs_lookup_revalidate(struct dentry * dentry, struct nameidata *nd)
 	nfs_inc_stats(dir, NFSIOS_DENTRYREVALIDATE);
 	inode = dentry->d_inode;
 
+	/* Revalidate parent directory attribute cache */
+	if (nfs_revalidate_inode(NFS_SERVER(dir), dir) < 0)
+		goto out_zap_parent;
+
 	if (!inode) {
 		if (nfs_neg_need_reval(dir, dentry, nd))
 			goto out_bad;
@@ -778,10 +783,6 @@ static int nfs_lookup_revalidate(struct dentry * dentry, struct nameidata *nd)
 		goto out_bad;
 	}
 
-	/* Revalidate parent directory attribute cache */
-	if (nfs_revalidate_inode(NFS_SERVER(dir), dir) < 0)
-		goto out_zap_parent;
-
 	/* Force a full look up iff the parent directory has changed */
 	if (nfs_check_verifier(dir, dentry)) {
 		if (nfs_lookup_verify_inode(inode, nd))
@@ -1360,11 +1361,6 @@ static int nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 		atomic_read(&dentry->d_count));
 	nfs_inc_stats(dir, NFSIOS_SILLYRENAME);
 
-#ifdef NFS_PARANOIA
-if (!dentry->d_inode)
-printk("NFS: silly-renaming %s/%s, negative dentry??\n",
-dentry->d_parent->d_name.name, dentry->d_name.name);
-#endif
 	/*
 	 * We don't allow a dentry to be silly-renamed twice.
 	 */
@@ -1681,16 +1677,9 @@ static int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 			new_inode = NULL;
 			/* instantiate the replacement target */
 			d_instantiate(new_dentry, NULL);
-		} else if (atomic_read(&new_dentry->d_count) > 1) {
-		/* dentry still busy? */
-#ifdef NFS_PARANOIA
-			printk("nfs_rename: target %s/%s busy, d_count=%d\n",
-			       new_dentry->d_parent->d_name.name,
-			       new_dentry->d_name.name,
-			       atomic_read(&new_dentry->d_count));
-#endif
+		} else if (atomic_read(&new_dentry->d_count) > 1)
+			/* dentry still busy? */
 			goto out;
-		}
 	} else
 		drop_nlink(new_inode);
 
diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
index 2347785..d1cbf0a 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -41,7 +41,6 @@
 #include "internal.h"
 
 #define NFSDBG_FACILITY		NFSDBG_CLIENT
-#define NFS_PARANOIA 1
 
 /*
  * get an NFS2/NFS3 root dentry from the root filehandle
diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 9d4a6b2..d11eb05 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -272,7 +272,7 @@ nfs_idmap_id(struct idmap *idmap, struct idmap_hashtable *h,
 	set_current_state(TASK_UNINTERRUPTIBLE);
 	mutex_unlock(&idmap->idmap_im_lock);
 	schedule();
-	current->state = TASK_RUNNING;
+	__set_current_state(TASK_RUNNING);
 	remove_wait_queue(&idmap->idmap_wq, &wq);
 	mutex_lock(&idmap->idmap_im_lock);
 
@@ -333,7 +333,7 @@ nfs_idmap_name(struct idmap *idmap, struct idmap_hashtable *h,
 	set_current_state(TASK_UNINTERRUPTIBLE);
 	mutex_unlock(&idmap->idmap_im_lock);
 	schedule();
-	current->state = TASK_RUNNING;
+	__set_current_state(TASK_RUNNING);
 	remove_wait_queue(&idmap->idmap_wq, &wq);
 	mutex_lock(&idmap->idmap_im_lock);
 
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 1e9a915..2a3fd95 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -48,7 +48,6 @@
 #include "internal.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
-#define NFS_PARANOIA 1
 
 static void nfs_invalidate_inode(struct inode *);
 static int nfs_update_inode(struct inode *, struct nfs_fattr *);
@@ -1075,10 +1074,8 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	/*
 	 * Big trouble! The inode has become a different object.
 	 */
-#ifdef NFS_PARANOIA
 	printk(KERN_DEBUG "%s: inode %ld mode changed, %07o to %07o\n",
 			__FUNCTION__, inode->i_ino, inode->i_mode, fattr->mode);
-#endif
  out_err:
 	/*
 	 * No need to worry about unhashing the dentry, as the
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index abd9f8b..cd3ca7b 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -26,7 +26,6 @@
 #include "internal.h"
 
 #define NFSDBG_FACILITY		NFSDBG_XDR
-/* #define NFS_PARANOIA 1 */
 
 /* Mapping from NFS error code to "errno" error code. */
 #define errno_NFSERR_IO		EIO
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index b8c28f2..938f371 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -224,7 +224,8 @@ static int nfs4_stat_to_errno(int);
                                 encode_getattr_maxsz)
 #define NFS4_dec_setattr_sz     (compound_decode_hdr_maxsz + \
                                 decode_putfh_maxsz + \
-                                op_decode_hdr_maxsz + 3)
+                                op_decode_hdr_maxsz + 3 + \
+                                nfs4_fattr_maxsz)
 #define NFS4_enc_fsinfo_sz	(compound_encode_hdr_maxsz + \
 				encode_putfh_maxsz + \
 				encode_fsinfo_maxsz)
@@ -2079,9 +2080,11 @@ out:
 
 #define READ_BUF(nbytes)  do { \
 	p = xdr_inline_decode(xdr, nbytes); \
-	if (!p) { \
-		printk(KERN_WARNING "%s: reply buffer overflowed in line %d.", \
-			       	__FUNCTION__, __LINE__); \
+	if (unlikely(!p)) { \
+		printk(KERN_INFO "%s: prematurely hit end of receive" \
+				" buffer\n", __FUNCTION__); \
+		printk(KERN_INFO "%s: xdr->p=%p, bytes=%u, xdr->end=%p\n", \
+				__FUNCTION__, xdr->p, nbytes, xdr->end); \
 		return -EIO; \
 	} \
 } while (0)
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 3889501..e12054c 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -20,8 +20,6 @@
 
 #include "internal.h"
 
-#define NFS_PARANOIA 1
-
 static struct kmem_cache *nfs_page_cachep;
 
 static inline struct nfs_page *
@@ -167,11 +165,6 @@ nfs_release_request(struct nfs_page *req)
 	if (!atomic_dec_and_test(&req->wb_count))
 		return;
 
-#ifdef NFS_PARANOIA
-	BUG_ON (!list_empty(&req->wb_list));
-	BUG_ON (NFS_WBACK_BUSY(req));
-#endif
-
 	/* Release struct file or cached credential */
 	nfs_clear_request(req);
 	put_nfs_open_context(req->wb_context);
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 9901451..b011eb6 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -736,6 +736,11 @@ static void rpc_async_schedule(struct work_struct *work)
 	__rpc_execute(container_of(work, struct rpc_task, u.tk_work));
 }
 
+struct rpc_buffer {
+	size_t	len;
+	char	data[];
+};
+
 /**
  * rpc_malloc - allocate an RPC buffer
  * @task: RPC task that will use this buffer
@@ -754,18 +759,22 @@ static void rpc_async_schedule(struct work_struct *work)
  */
 void *rpc_malloc(struct rpc_task *task, size_t size)
 {
-	size_t *buf;
+	struct rpc_buffer *buf;
 	gfp_t gfp = RPC_IS_SWAPPER(task) ? GFP_ATOMIC : GFP_NOWAIT;
 
-	size += sizeof(size_t);
+	size += sizeof(struct rpc_buffer);
 	if (size <= RPC_BUFFER_MAXSIZE)
 		buf = mempool_alloc(rpc_buffer_mempool, gfp);
 	else
 		buf = kmalloc(size, gfp);
-	*buf = size;
+
+	if (!buf)
+		return NULL;
+
+	buf->len = size;
 	dprintk("RPC: %5u allocated buffer of size %zu at %p\n",
 			task->tk_pid, size, buf);
-	return ++buf;
+	return &buf->data;
 }
 
 /**
@@ -775,15 +784,18 @@ void *rpc_malloc(struct rpc_task *task, size_t size)
  */
 void rpc_free(void *buffer)
 {
-	size_t size, *buf = buffer;
+	size_t size;
+	struct rpc_buffer *buf;
 
 	if (!buffer)
 		return;
-	size = *buf;
-	buf--;
+
+	buf = container_of(buffer, struct rpc_buffer, data);
+	size = buf->len;
 
 	dprintk("RPC:       freeing buffer of size %zu at %p\n",
 			size, buf);
+
 	if (size <= RPC_BUFFER_MAXSIZE)
 		mempool_free(buf, rpc_buffer_mempool);
 	else
