From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT] Please pull a couple more updates for the NFS client
Date: Thu, 19 Jul 2007 15:27:31 -0400
Message-ID: <1184873251.6649.8.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IBbez-0008JY-AX
	for nfs@lists.sourceforge.net; Thu, 19 Jul 2007 12:27:37 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IBbf2-0007Vm-OO
	for nfs@lists.sourceforge.net; Thu, 19 Jul 2007 12:27:41 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi Linus,

Please pull from the repository at

   git pull git://git.linux-nfs.org/pub/linux/nfs-2.6.git

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/Kconfig                     |    2 +-
 fs/nfs/callback_xdr.c          |   10 +-
 fs/nfs/dir.c                   |    8 +-
 fs/nfs/nfs2xdr.c               |   19 +++-
 fs/nfs/nfs3proc.c              |   60 +++------
 fs/nfs/nfs3xdr.c               |   24 ++++-
 fs/nfs/nfs4_fs.h               |    2 +-
 fs/nfs/nfs4proc.c              |  122 +++++++++----------
 fs/nfs/nfs4xdr.c               |  274 ++++++++++++++++++++++++----------------
 fs/nfs/proc.c                  |   40 ++----
 fs/nfs/super.c                 |    7 +
 fs/nfs/unlink.c                |  195 +++++++++++++----------------
 include/linux/nfs_fs.h         |    4 +-
 include/linux/nfs_xdr.h        |   32 +++---
 include/linux/sunrpc/xdr.h     |   16 +++
 net/sunrpc/auth.c              |   13 +--
 net/sunrpc/auth_gss/auth_gss.c |   21 +---
 17 files changed, 442 insertions(+), 407 deletions(-)

commit 0a87cf128f3d3bc6aa7b1040e73109c974ed875a
Author: Jeff Layton <jlayton@redhat.com>
Date:   Wed Jul 18 11:28:43 2007 -0400

    NFSv4: handle lack of clientaddr in option string
    
    If a NFSv4 mount is attempted  with string based options, and the
    option string doesn't contain a clientaddr= option, the kernel will
    currently oops. Check for this situation and return a proper error.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f9d888fcd9665b863fa042212a3ee7b4c51399f6
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Sun Jul 15 20:14:32 2007 +0300

    NFSv4: debug print ntohl(status) in nfs client callback xdr code
    
    status in nfs client callback xdr code is passed in network order.
    print it in host order for better readability.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e4eff1a622edd6ab7b73acd5d8763aa2fa3fee49
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jul 14 15:39:58 2007 -0400

    SUNRPC: Clean up the sillyrename code
    
    Fix a couple of bugs:
     - Don't rely on the parent dentry still being valid when the call completes.
       Fixes a race with shrink_dcache_for_umount_subtree()
    
     - Don't remove the file if the filehandle has been labelled as stale.
    
    Fix a couple of inefficiencies
     - Remove the global list of sillyrenamed files. Instead we can cache the
       sillyrename information in the dentry->d_fsdata
     - Move common code from unlink_setup/unlink_done into fs/nfs/unlink.c
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4fdc17b2a7f4d9db5b08e0f963d0027f714e4104
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jul 14 15:39:57 2007 -0400

    NFS: Introduce struct nfs_removeargs+nfs_removeres
    
    We need a common structure for setting up an unlink() rpc call in order to
    fix the asynchronous unlink code.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3062c532ad410fe0e8320566fe2879a396be6701
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Jul 14 17:36:45 2007 -0400

    NFS: Use dentry->d_time to store the parent directory verifier.
    
    This will free up the d_fsdata field for other use.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit be879c4e249a8875d7129f3b0c1bb62584dafbd8
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Wed Jul 11 18:39:02 2007 -0400

    SUNRPC: move bkl locking and xdr proc invocation into a common helper
    
    Since every invocation of xdr encode or decode functions takes the BKL now,
    there's a lot of redundant lock_kernel/unlock_kernel pairs that we can pull
    out into a common function.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit e3a535e1739a9da3cc316ccdfe5cd4bf84d745ac
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Jul 19 10:03:38 2007 -0400

    NFSv4: Fix the nfsv4 readlink reply buffer alignment
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit d6ac02dfaa6c423874839fe289c7320624aa9288
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Jul 19 10:03:37 2007 -0400

    NFSv4: Fix the readdir reply buffer alignment
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9104a55dc382c4aae42dff3f54351085cbcb7317
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jul 17 21:52:42 2007 -0400

    NFSv4: More NFSv4 xdr cleanups
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9936781d0147e13cbc6df02f5265e0b9999ce3cf
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jul 17 21:52:41 2007 -0400

    NFSv4: Try to recover from getfh failures in nfs4_xdr_dec_open
    
    Try harder to recover the open state if the server failed to return a
    filehandle.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 56659e9926ef5996398924c799ecac39ca8b6223
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jul 17 21:52:39 2007 -0400

    NFSv4: 'constify' lookup arguments.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 365c8f589afbc27d8cf42d396475017bc1c462fd
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jul 17 21:52:37 2007 -0400

    NFSv4: Don't fail nfs4_xdr_dec_open if decode_restorefh() failed
    
    We can already easily recover from that inside _nfs4_proc_open().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 6f220ed5a84d87645a84ae22105dc565f3f248b5
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jul 17 21:50:45 2007 -0400

    NFSv4: Fix open state recovery
    
    Ensure that opendata->state is always initialised when we do state
    recovery.
    
    Ensure that we set the filehandle in the case where we're doing an
    "OPEN_CLAIM_PREVIOUS" call due to a server reboot.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8cd69e1bc7970bfb032b425043cc0d4e4345c74c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Jul 19 10:03:34 2007 -0400

    NFSD/SUNRPC: Fix the automatic selection of RPCSEC_GSS
    
    Bruce's patch broke the ability to compile RPCSEC_GSS as a module.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/Kconfig b/fs/Kconfig
index 6a64990..58a0650 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1674,7 +1674,7 @@ config NFSD_V3_ACL
 
 config NFSD_V4
 	bool "Provide NFSv4 server support (EXPERIMENTAL)"
-	depends on NFSD_V3 && EXPERIMENTAL
+	depends on NFSD && NFSD_V3 && EXPERIMENTAL
 	select RPCSEC_GSS_KRB5
 	help
 	  If you would like to include the NFSv4 server as well as the NFSv2
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 849a202..058ade7 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -179,7 +179,7 @@ static __be32 decode_getattr_args(struct svc_rqst *rqstp, struct xdr_stream *xdr
 	args->addr = svc_addr_in(rqstp);
 	status = decode_bitmap(xdr, args->bitmap);
 out:
-	dprintk("%s: exit with status = %d\n", __FUNCTION__, status);
+	dprintk("%s: exit with status = %d\n", __FUNCTION__, ntohl(status));
 	return status;
 }
 
@@ -200,7 +200,7 @@ static __be32 decode_recall_args(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 	args->truncate = ntohl(*p);
 	status = decode_fh(xdr, &args->fh);
 out:
-	dprintk("%s: exit with status = %d\n", __FUNCTION__, status);
+	dprintk("%s: exit with status = %d\n", __FUNCTION__, ntohl(status));
 	return status;
 }
 
@@ -349,7 +349,7 @@ static __be32 encode_getattr_res(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 	status = encode_attr_mtime(xdr, res->bitmap, &res->mtime);
 	*savep = htonl((unsigned int)((char *)xdr->p - (char *)(savep+1)));
 out:
-	dprintk("%s: exit with status = %d\n", __FUNCTION__, status);
+	dprintk("%s: exit with status = %d\n", __FUNCTION__, ntohl(status));
 	return status;
 }
 
@@ -392,7 +392,7 @@ static __be32 process_op(struct svc_rqst *rqstp,
 		status = res;
 	if (op->encode_res != NULL && status == 0)
 		status = op->encode_res(rqstp, xdr_out, resp);
-	dprintk("%s: done, status = %d\n", __FUNCTION__, status);
+	dprintk("%s: done, status = %d\n", __FUNCTION__, ntohl(status));
 	return status;
 }
 
@@ -431,7 +431,7 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
 	}
 	*hdr_res.status = status;
 	*hdr_res.nops = htonl(nops);
-	dprintk("%s: done, status = %u\n", __FUNCTION__, status);
+	dprintk("%s: done, status = %u\n", __FUNCTION__, ntohl(status));
 	return rpc_success;
 }
 
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 322141f..ea97408 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -654,7 +654,7 @@ static int nfs_check_verifier(struct inode *dir, struct dentry *dentry)
 
 	if (IS_ROOT(dentry))
 		return 1;
-	verf = (unsigned long)dentry->d_fsdata;
+	verf = dentry->d_time;
 	if (nfs_caches_unstable(dir)
 			|| verf != NFS_I(dir)->cache_change_attribute)
 		return 0;
@@ -663,7 +663,7 @@ static int nfs_check_verifier(struct inode *dir, struct dentry *dentry)
 
 static inline void nfs_set_verifier(struct dentry * dentry, unsigned long verf)
 {
-	dentry->d_fsdata = (void *)verf;
+	dentry->d_time = verf;
 }
 
 static void nfs_refresh_verifier(struct dentry * dentry, unsigned long verf)
@@ -869,7 +869,7 @@ static void nfs_dentry_iput(struct dentry *dentry, struct inode *inode)
 	if (dentry->d_flags & DCACHE_NFSFS_RENAMED) {
 		lock_kernel();
 		drop_nlink(inode);
-		nfs_complete_unlink(dentry);
+		nfs_complete_unlink(dentry, inode);
 		unlock_kernel();
 	}
 	/* When creating a negative dentry, we want to renew d_time */
@@ -1411,7 +1411,7 @@ static int nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 		nfs_renew_times(dentry);
 		nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 		d_move(dentry, sdentry);
-		error = nfs_async_unlink(dentry);
+		error = nfs_async_unlink(dir, dentry);
  		/* If we return 0 we don't unlink */
 	}
 	dput(sdentry);
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 7fcc78f..c5fce75 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -43,6 +43,7 @@
 #define NFS_entry_sz		(NFS_filename_sz+3)
 
 #define NFS_diropargs_sz	(NFS_fhandle_sz+NFS_filename_sz)
+#define NFS_removeargs_sz	(NFS_fhandle_sz+NFS_filename_sz)
 #define NFS_sattrargs_sz	(NFS_fhandle_sz+NFS_sattr_sz)
 #define NFS_readlinkargs_sz	(NFS_fhandle_sz)
 #define NFS_readargs_sz		(NFS_fhandle_sz+3)
@@ -66,7 +67,7 @@
  * Common NFS XDR functions as inlines
  */
 static inline __be32 *
-xdr_encode_fhandle(__be32 *p, struct nfs_fh *fhandle)
+xdr_encode_fhandle(__be32 *p, const struct nfs_fh *fhandle)
 {
 	memcpy(p, fhandle->data, NFS2_FHSIZE);
 	return p + XDR_QUADLEN(NFS2_FHSIZE);
@@ -204,7 +205,7 @@ nfs_xdr_sattrargs(struct rpc_rqst *req, __be32 *p, struct nfs_sattrargs *args)
 
 /*
  * Encode directory ops argument
- * LOOKUP, REMOVE, RMDIR
+ * LOOKUP, RMDIR
  */
 static int
 nfs_xdr_diropargs(struct rpc_rqst *req, __be32 *p, struct nfs_diropargs *args)
@@ -216,6 +217,18 @@ nfs_xdr_diropargs(struct rpc_rqst *req, __be32 *p, struct nfs_diropargs *args)
 }
 
 /*
+ * Encode REMOVE argument
+ */
+static int
+nfs_xdr_removeargs(struct rpc_rqst *req, __be32 *p, const struct nfs_removeargs *args)
+{
+	p = xdr_encode_fhandle(p, args->fh);
+	p = xdr_encode_array(p, args->name.name, args->name.len);
+	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
+	return 0;
+}
+
+/*
  * Arguments to a READ call. Since we read data directly into the page
  * cache, we also set up the reply iovec here so that iov[1] points
  * exactly to the page we want to fetch.
@@ -705,7 +718,7 @@ struct rpc_procinfo	nfs_procedures[] = {
     PROC(READ,		readargs,	readres, 3),
     PROC(WRITE,		writeargs,	writeres, 4),
     PROC(CREATE,	createargs,	diropres, 0),
-    PROC(REMOVE,	diropargs,	stat, 0),
+    PROC(REMOVE,	removeargs,	stat, 0),
     PROC(RENAME,	renameargs,	stat, 0),
     PROC(LINK,		linkargs,	stat, 0),
     PROC(SYMLINK,	symlinkargs,	stat, 0),
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 814d886..c7ca5d7 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -349,62 +349,42 @@ out:
 static int
 nfs3_proc_remove(struct inode *dir, struct qstr *name)
 {
-	struct nfs_fattr	dir_attr;
-	struct nfs3_diropargs	arg = {
-		.fh		= NFS_FH(dir),
-		.name		= name->name,
-		.len		= name->len
+	struct nfs_removeargs arg = {
+		.fh = NFS_FH(dir),
+		.name.len = name->len,
+		.name.name = name->name,
 	};
-	struct rpc_message	msg = {
-		.rpc_proc	= &nfs3_procedures[NFS3PROC_REMOVE],
-		.rpc_argp	= &arg,
-		.rpc_resp	= &dir_attr,
+	struct nfs_removeres res;
+	struct rpc_message msg = {
+		.rpc_proc = &nfs3_procedures[NFS3PROC_REMOVE],
+		.rpc_argp = &arg,
+		.rpc_resp = &res,
 	};
 	int			status;
 
 	dprintk("NFS call  remove %s\n", name->name);
-	nfs_fattr_init(&dir_attr);
+	nfs_fattr_init(&res.dir_attr);
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
-	nfs_post_op_update_inode(dir, &dir_attr);
+	nfs_post_op_update_inode(dir, &res.dir_attr);
 	dprintk("NFS reply remove: %d\n", status);
 	return status;
 }
 
-static int
-nfs3_proc_unlink_setup(struct rpc_message *msg, struct dentry *dir, struct qstr *name)
+static void
+nfs3_proc_unlink_setup(struct rpc_message *msg, struct inode *dir)
 {
-	struct unlinkxdr {
-		struct nfs3_diropargs arg;
-		struct nfs_fattr res;
-	} *ptr;
-
-	ptr = kmalloc(sizeof(*ptr), GFP_KERNEL);
-	if (!ptr)
-		return -ENOMEM;
-	ptr->arg.fh = NFS_FH(dir->d_inode);
-	ptr->arg.name = name->name;
-	ptr->arg.len = name->len;
-	nfs_fattr_init(&ptr->res);
 	msg->rpc_proc = &nfs3_procedures[NFS3PROC_REMOVE];
-	msg->rpc_argp = &ptr->arg;
-	msg->rpc_resp = &ptr->res;
-	return 0;
 }
 
 static int
-nfs3_proc_unlink_done(struct dentry *dir, struct rpc_task *task)
+nfs3_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 {
-	struct rpc_message *msg = &task->tk_msg;
-	struct nfs_fattr	*dir_attr;
-
-	if (nfs3_async_handle_jukebox(task, dir->d_inode))
-		return 1;
-	if (msg->rpc_argp) {
-		dir_attr = (struct nfs_fattr*)msg->rpc_resp;
-		nfs_post_op_update_inode(dir->d_inode, dir_attr);
-		kfree(msg->rpc_argp);
-	}
-	return 0;
+	struct nfs_removeres *res;
+	if (nfs3_async_handle_jukebox(task, dir))
+		return 0;
+	res = task->tk_msg.rpc_resp;
+	nfs_post_op_update_inode(dir, &res->dir_attr);
+	return 1;
 }
 
 static int
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index b4647a2..d9e08f0 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -50,6 +50,7 @@
 
 #define NFS3_sattrargs_sz	(NFS3_fh_sz+NFS3_sattr_sz+3)
 #define NFS3_diropargs_sz	(NFS3_fh_sz+NFS3_filename_sz)
+#define NFS3_removeargs_sz	(NFS3_fh_sz+NFS3_filename_sz)
 #define NFS3_accessargs_sz	(NFS3_fh_sz+1)
 #define NFS3_readlinkargs_sz	(NFS3_fh_sz)
 #define NFS3_readargs_sz	(NFS3_fh_sz+3)
@@ -65,6 +66,7 @@
 
 #define NFS3_attrstat_sz	(1+NFS3_fattr_sz)
 #define NFS3_wccstat_sz		(1+NFS3_wcc_data_sz)
+#define NFS3_removeres_sz	(NFS3_wccstat_sz)
 #define NFS3_lookupres_sz	(1+NFS3_fh_sz+(2 * NFS3_post_op_attr_sz))
 #define NFS3_accessres_sz	(1+NFS3_post_op_attr_sz+1)
 #define NFS3_readlinkres_sz	(1+NFS3_post_op_attr_sz+1)
@@ -106,7 +108,7 @@ static struct {
  * Common NFS XDR functions as inlines
  */
 static inline __be32 *
-xdr_encode_fhandle(__be32 *p, struct nfs_fh *fh)
+xdr_encode_fhandle(__be32 *p, const struct nfs_fh *fh)
 {
 	return xdr_encode_array(p, fh->data, fh->size);
 }
@@ -300,6 +302,18 @@ nfs3_xdr_diropargs(struct rpc_rqst *req, __be32 *p, struct nfs3_diropargs *args)
 }
 
 /*
+ * Encode REMOVE argument
+ */
+static int
+nfs3_xdr_removeargs(struct rpc_rqst *req, __be32 *p, const struct nfs_removeargs *args)
+{
+	p = xdr_encode_fhandle(p, args->fh);
+	p = xdr_encode_array(p, args->name.name, args->name.len);
+	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
+	return 0;
+}
+
+/*
  * Encode access() argument
  */
 static int
@@ -736,6 +750,12 @@ nfs3_xdr_wccstat(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
 	return status;
 }
 
+static int
+nfs3_xdr_removeres(struct rpc_rqst *req, __be32 *p, struct nfs_removeres *res)
+{
+	return nfs3_xdr_wccstat(req, p, &res->dir_attr);
+}
+
 /*
  * Decode LOOKUP reply
  */
@@ -1126,7 +1146,7 @@ struct rpc_procinfo	nfs3_procedures[] = {
   PROC(MKDIR,		mkdirargs,	createres, 0),
   PROC(SYMLINK,		symlinkargs,	createres, 0),
   PROC(MKNOD,		mknodargs,	createres, 0),
-  PROC(REMOVE,		diropargs,	wccstat, 0),
+  PROC(REMOVE,		removeargs,	removeres, 0),
   PROC(RMDIR,		diropargs,	wccstat, 0),
   PROC(RENAME,		renameargs,	renameres, 0),
   PROC(LINK,		linkargs,	linkres, 0),
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 6c028e7..d2802b1 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -182,7 +182,7 @@ extern int nfs4_do_close(struct path *path, struct nfs4_state *state);
 extern struct dentry *nfs4_atomic_open(struct inode *, struct dentry *, struct nameidata *);
 extern int nfs4_open_revalidate(struct inode *, struct dentry *, int, struct nameidata *);
 extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle);
-extern int nfs4_proc_fs_locations(struct inode *dir, struct qstr *name,
+extern int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 		struct nfs4_fs_locations *fs_locations, struct page *page);
 
 extern struct nfs4_state_recovery_ops nfs4_reboot_recovery_ops;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index fee2da8..6ca2795 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -66,6 +66,8 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 static int nfs4_handle_exception(const struct nfs_server *server, int errorcode, struct nfs4_exception *exception);
 static int nfs4_wait_clnt_recover(struct rpc_clnt *clnt, struct nfs_client *clp);
 static int _nfs4_do_access(struct inode *inode, struct rpc_cred *cred, int openflags);
+static int _nfs4_proc_lookup(struct inode *dir, const struct qstr *name, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
+static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
 
 /* Prevent leaks of NFSv4 errors into userland */
 int nfs4_map_errors(int err)
@@ -552,6 +554,18 @@ static struct nfs_open_context *nfs4_state_find_open_context(struct nfs4_state *
 	return ERR_PTR(-ENOENT);
 }
 
+static struct nfs4_opendata *nfs4_open_recoverdata_alloc(struct nfs_open_context *ctx, struct nfs4_state *state)
+{
+	struct nfs4_opendata *opendata;
+
+	opendata = nfs4_opendata_alloc(&ctx->path, state->owner, 0, NULL);
+	if (opendata == NULL)
+		return ERR_PTR(-ENOMEM);
+	opendata->state = state;
+	atomic_inc(&state->count);
+	return opendata;
+}
+
 static int nfs4_open_recover_helper(struct nfs4_opendata *opendata, mode_t openflags, struct nfs4_state **res)
 {
 	struct nfs4_state *newstate;
@@ -626,12 +640,11 @@ static int _nfs4_do_open_reclaim(struct nfs_open_context *ctx, struct nfs4_state
 	int delegation_type = 0;
 	int status;
 
-	opendata = nfs4_opendata_alloc(&ctx->path, state->owner, 0, NULL);
-	if (opendata == NULL)
-		return -ENOMEM;
+	opendata = nfs4_open_recoverdata_alloc(ctx, state);
+	if (IS_ERR(opendata))
+		return PTR_ERR(opendata);
 	opendata->o_arg.claim = NFS4_OPEN_CLAIM_PREVIOUS;
 	opendata->o_arg.fh = NFS_FH(state->inode);
-	nfs_copy_fh(&opendata->o_res.fh, opendata->o_arg.fh);
 	rcu_read_lock();
 	delegation = rcu_dereference(NFS_I(state->inode)->delegation);
 	if (delegation != NULL && (delegation->flags & NFS_DELEGATION_NEED_RECLAIM) != 0)
@@ -672,13 +685,12 @@ static int nfs4_open_reclaim(struct nfs4_state_owner *sp, struct nfs4_state *sta
 
 static int _nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state *state, const nfs4_stateid *stateid)
 {
-	struct nfs4_state_owner  *sp  = state->owner;
 	struct nfs4_opendata *opendata;
 	int ret;
 
-	opendata = nfs4_opendata_alloc(&ctx->path, sp, 0, NULL);
-	if (opendata == NULL)
-		return -ENOMEM;
+	opendata = nfs4_open_recoverdata_alloc(ctx, state);
+	if (IS_ERR(opendata))
+		return PTR_ERR(opendata);
 	opendata->o_arg.claim = NFS4_OPEN_CLAIM_DELEGATE_CUR;
 	memcpy(opendata->o_arg.u.delegation.data, stateid->data,
 			sizeof(opendata->o_arg.u.delegation.data));
@@ -823,8 +835,10 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 	/* Update sequence id. */
 	data->o_arg.id = sp->so_owner_id.id;
 	data->o_arg.clientid = sp->so_client->cl_clientid;
-	if (data->o_arg.claim == NFS4_OPEN_CLAIM_PREVIOUS)
+	if (data->o_arg.claim == NFS4_OPEN_CLAIM_PREVIOUS) {
 		msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_NOATTR];
+		nfs_copy_fh(&data->o_res.fh, data->o_arg.fh);
+	}
 	data->timestamp = jiffies;
 	rpc_call_setup(task, &msg, 0);
 	return;
@@ -918,6 +932,9 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
 	if (status != 0 || !data->rpc_done)
 		return status;
 
+	if (o_res->fh.size == 0)
+		_nfs4_proc_lookup(dir, o_arg->name, &o_res->fh, o_res->f_attr);
+
 	if (o_arg->open_flags & O_CREAT) {
 		update_changeattr(dir, &o_res->cinfo);
 		nfs_post_op_update_inode(dir, o_res->dir_attr);
@@ -929,7 +946,7 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
 			return status;
 	}
 	if (!(o_res->f_attr->valid & NFS_ATTR_FATTR))
-		return server->nfs_client->rpc_ops->getattr(server, &o_res->fh, o_res->f_attr);
+		_nfs4_proc_getattr(server, &o_res->fh, o_res->f_attr);
 	return 0;
 }
 
@@ -989,9 +1006,9 @@ static int _nfs4_open_expired(struct nfs_open_context *ctx, struct nfs4_state *s
 	struct nfs4_opendata *opendata;
 	int ret;
 
-	opendata = nfs4_opendata_alloc(&ctx->path, state->owner, 0, NULL);
-	if (opendata == NULL)
-		return -ENOMEM;
+	opendata = nfs4_open_recoverdata_alloc(ctx, state);
+	if (IS_ERR(opendata))
+		return PTR_ERR(opendata);
 	ret = nfs4_open_recover(opendata, state);
 	if (ret == -ESTALE) {
 		/* Invalidate the state owner so we don't ever use it again */
@@ -1553,7 +1570,7 @@ static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
  * Note that we'll actually follow the referral later when
  * we detect fsid mismatch in inode revalidation
  */
-static int nfs4_get_referral(struct inode *dir, struct qstr *name, struct nfs_fattr *fattr, struct nfs_fh *fhandle)
+static int nfs4_get_referral(struct inode *dir, const struct qstr *name, struct nfs_fattr *fattr, struct nfs_fh *fhandle)
 {
 	int status = -ENOMEM;
 	struct page *page = NULL;
@@ -1668,8 +1685,8 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 	return status;
 }
 
-static int _nfs4_proc_lookupfh(struct nfs_server *server, struct nfs_fh *dirfh,
-		struct qstr *name, struct nfs_fh *fhandle,
+static int _nfs4_proc_lookupfh(struct nfs_server *server, const struct nfs_fh *dirfh,
+		const struct qstr *name, struct nfs_fh *fhandle,
 		struct nfs_fattr *fattr)
 {
 	int		       status;
@@ -1715,7 +1732,7 @@ static int nfs4_proc_lookupfh(struct nfs_server *server, struct nfs_fh *dirfh,
 	return err;
 }
 
-static int _nfs4_proc_lookup(struct inode *dir, struct qstr *name,
+static int _nfs4_proc_lookup(struct inode *dir, const struct qstr *name,
 		struct nfs_fh *fhandle, struct nfs_fattr *fattr)
 {
 	int status;
@@ -1908,28 +1925,27 @@ out:
 static int _nfs4_proc_remove(struct inode *dir, struct qstr *name)
 {
 	struct nfs_server *server = NFS_SERVER(dir);
-	struct nfs4_remove_arg args = {
+	struct nfs_removeargs args = {
 		.fh = NFS_FH(dir),
-		.name = name,
+		.name.len = name->len,
+		.name.name = name->name,
 		.bitmask = server->attr_bitmask,
 	};
-	struct nfs_fattr dir_attr;
-	struct nfs4_remove_res	res = {
+	struct nfs_removeres res = {
 		.server = server,
-		.dir_attr = &dir_attr,
 	};
 	struct rpc_message msg = {
-		.rpc_proc	= &nfs4_procedures[NFSPROC4_CLNT_REMOVE],
-		.rpc_argp	= &args,
-		.rpc_resp	= &res,
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_REMOVE],
+		.rpc_argp = &args,
+		.rpc_resp = &res,
 	};
 	int			status;
 
-	nfs_fattr_init(res.dir_attr);
+	nfs_fattr_init(&res.dir_attr);
 	status = rpc_call_sync(server->client, &msg, 0);
 	if (status == 0) {
 		update_changeattr(dir, &res.cinfo);
-		nfs_post_op_update_inode(dir, res.dir_attr);
+		nfs_post_op_update_inode(dir, &res.dir_attr);
 	}
 	return status;
 }
@@ -1946,48 +1962,26 @@ static int nfs4_proc_remove(struct inode *dir, struct qstr *name)
 	return err;
 }
 
-struct unlink_desc {
-	struct nfs4_remove_arg	args;
-	struct nfs4_remove_res	res;
-	struct nfs_fattr dir_attr;
-};
-
-static int nfs4_proc_unlink_setup(struct rpc_message *msg, struct dentry *dir,
-		struct qstr *name)
+static void nfs4_proc_unlink_setup(struct rpc_message *msg, struct inode *dir)
 {
-	struct nfs_server *server = NFS_SERVER(dir->d_inode);
-	struct unlink_desc *up;
+	struct nfs_server *server = NFS_SERVER(dir);
+	struct nfs_removeargs *args = msg->rpc_argp;
+	struct nfs_removeres *res = msg->rpc_resp;
 
-	up = kmalloc(sizeof(*up), GFP_KERNEL);
-	if (!up)
-		return -ENOMEM;
-	
-	up->args.fh = NFS_FH(dir->d_inode);
-	up->args.name = name;
-	up->args.bitmask = server->attr_bitmask;
-	up->res.server = server;
-	up->res.dir_attr = &up->dir_attr;
-	
+	args->bitmask = server->attr_bitmask;
+	res->server = server;
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_REMOVE];
-	msg->rpc_argp = &up->args;
-	msg->rpc_resp = &up->res;
-	return 0;
 }
 
-static int nfs4_proc_unlink_done(struct dentry *dir, struct rpc_task *task)
+static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 {
-	struct rpc_message *msg = &task->tk_msg;
-	struct unlink_desc *up;
-	
-	if (msg->rpc_resp != NULL) {
-		up = container_of(msg->rpc_resp, struct unlink_desc, res);
-		update_changeattr(dir->d_inode, &up->res.cinfo);
-		nfs_post_op_update_inode(dir->d_inode, up->res.dir_attr);
-		kfree(up);
-		msg->rpc_resp = NULL;
-		msg->rpc_argp = NULL;
-	}
-	return 0;
+	struct nfs_removeres *res = task->tk_msg.rpc_resp;
+
+	if (nfs4_async_handle_error(task, res->server) == -EAGAIN)
+		return 0;
+	update_changeattr(dir, &res->cinfo);
+	nfs_post_op_update_inode(dir, &res->dir_attr);
+	return 1;
 }
 
 static int _nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
@@ -3672,7 +3666,7 @@ ssize_t nfs4_listxattr(struct dentry *dentry, char *buf, size_t buflen)
 	return len;
 }
 
-int nfs4_proc_fs_locations(struct inode *dir, struct qstr *name,
+int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 		struct nfs4_fs_locations *fs_locations, struct page *page)
 {
 	struct nfs_server *server = NFS_SERVER(dir);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index c087384..badd73b 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -72,10 +72,15 @@ static int nfs4_stat_to_errno(int);
  */
 #define open_owner_id_maxsz	(1 + 4)
 #define lock_owner_id_maxsz	(1 + 4)
+#define decode_lockowner_maxsz	(1 + XDR_QUADLEN(IDMAP_NAMESZ))
 #define compound_encode_hdr_maxsz	(3 + (NFS4_MAXTAGLEN >> 2))
 #define compound_decode_hdr_maxsz	(3 + (NFS4_MAXTAGLEN >> 2))
 #define op_encode_hdr_maxsz	(1)
 #define op_decode_hdr_maxsz	(2)
+#define encode_stateid_maxsz	(XDR_QUADLEN(NFS4_STATEID_SIZE))
+#define decode_stateid_maxsz	(XDR_QUADLEN(NFS4_STATEID_SIZE))
+#define encode_verifier_maxsz	(XDR_QUADLEN(NFS4_VERIFIER_SIZE))
+#define decode_verifier_maxsz	(XDR_QUADLEN(NFS4_VERIFIER_SIZE))
 #define encode_putfh_maxsz	(op_encode_hdr_maxsz + 1 + \
 				(NFS4_FHSIZE >> 2))
 #define decode_putfh_maxsz	(op_decode_hdr_maxsz)
@@ -96,6 +101,11 @@ static int nfs4_stat_to_errno(int);
 #define nfs4_fattr_maxsz	(nfs4_fattr_bitmap_maxsz + \
 				nfs4_fattr_value_maxsz)
 #define decode_getattr_maxsz    (op_decode_hdr_maxsz + nfs4_fattr_maxsz)
+#define encode_attrs_maxsz	(nfs4_fattr_bitmap_maxsz + \
+				 1 + 2 + 1 + \
+				nfs4_owner_maxsz + \
+				nfs4_group_maxsz + \
+				4 + 4)
 #define encode_savefh_maxsz     (op_encode_hdr_maxsz)
 #define decode_savefh_maxsz     (op_decode_hdr_maxsz)
 #define encode_restorefh_maxsz  (op_encode_hdr_maxsz)
@@ -123,7 +133,7 @@ static int nfs4_stat_to_errno(int);
 #define decode_lookup_maxsz	(op_decode_hdr_maxsz)
 #define encode_share_access_maxsz \
 				(2)
-#define encode_createmode_maxsz	(1 + nfs4_fattr_maxsz)
+#define encode_createmode_maxsz	(1 + encode_attrs_maxsz)
 #define encode_opentype_maxsz	(1 + encode_createmode_maxsz)
 #define encode_claim_null_maxsz	(1 + nfs4_name_maxsz)
 #define encode_open_maxsz	(op_encode_hdr_maxsz + \
@@ -132,14 +142,52 @@ static int nfs4_stat_to_errno(int);
 				encode_opentype_maxsz + \
 				encode_claim_null_maxsz)
 #define decode_ace_maxsz	(3 + nfs4_owner_maxsz)
-#define decode_delegation_maxsz	(1 + XDR_QUADLEN(NFS4_STATEID_SIZE) + 1 + \
+#define decode_delegation_maxsz	(1 + decode_stateid_maxsz + 1 + \
 				decode_ace_maxsz)
 #define decode_change_info_maxsz	(5)
 #define decode_open_maxsz	(op_decode_hdr_maxsz + \
-				XDR_QUADLEN(NFS4_STATEID_SIZE) + \
+				decode_stateid_maxsz + \
 				decode_change_info_maxsz + 1 + \
 				nfs4_fattr_bitmap_maxsz + \
 				decode_delegation_maxsz)
+#define encode_open_confirm_maxsz \
+				(op_encode_hdr_maxsz + \
+				 encode_stateid_maxsz + 1)
+#define decode_open_confirm_maxsz \
+				(op_decode_hdr_maxsz + \
+				 decode_stateid_maxsz)
+#define encode_open_downgrade_maxsz \
+				(op_encode_hdr_maxsz + \
+				 encode_stateid_maxsz + 1 + \
+				 encode_share_access_maxsz)
+#define decode_open_downgrade_maxsz \
+				(op_decode_hdr_maxsz + \
+				 decode_stateid_maxsz)
+#define encode_close_maxsz	(op_encode_hdr_maxsz + \
+				 1 + encode_stateid_maxsz)
+#define decode_close_maxsz	(op_decode_hdr_maxsz + \
+				 decode_stateid_maxsz)
+#define encode_setattr_maxsz	(op_encode_hdr_maxsz + \
+				 encode_stateid_maxsz + \
+				 encode_attrs_maxsz)
+#define decode_setattr_maxsz	(op_decode_hdr_maxsz + \
+				 nfs4_fattr_bitmap_maxsz)
+#define encode_read_maxsz	(op_encode_hdr_maxsz + \
+				 encode_stateid_maxsz + 3)
+#define decode_read_maxsz	(op_decode_hdr_maxsz + 2)
+#define encode_readdir_maxsz	(op_encode_hdr_maxsz + \
+				 2 + encode_verifier_maxsz + 5)
+#define decode_readdir_maxsz	(op_decode_hdr_maxsz + \
+				 decode_verifier_maxsz)
+#define encode_readlink_maxsz	(op_encode_hdr_maxsz)
+#define decode_readlink_maxsz	(op_decode_hdr_maxsz + 1)
+#define encode_write_maxsz	(op_encode_hdr_maxsz + \
+				 encode_stateid_maxsz + 4)
+#define decode_write_maxsz	(op_decode_hdr_maxsz + \
+				 2 + decode_verifier_maxsz)
+#define encode_commit_maxsz	(op_encode_hdr_maxsz + 3)
+#define decode_commit_maxsz	(op_decode_hdr_maxsz + \
+				 decode_verifier_maxsz)
 #define encode_remove_maxsz	(op_encode_hdr_maxsz + \
 				nfs4_name_maxsz)
 #define encode_rename_maxsz	(op_encode_hdr_maxsz + \
@@ -148,19 +196,44 @@ static int nfs4_stat_to_errno(int);
 #define encode_link_maxsz	(op_encode_hdr_maxsz + \
 				nfs4_name_maxsz)
 #define decode_link_maxsz	(op_decode_hdr_maxsz + 5)
+#define encode_lock_maxsz	(op_encode_hdr_maxsz + \
+				 7 + \
+				 1 + encode_stateid_maxsz + 8)
+#define decode_lock_denied_maxsz \
+				(8 + decode_lockowner_maxsz)
+#define decode_lock_maxsz	(op_decode_hdr_maxsz + \
+				 decode_lock_denied_maxsz)
+#define encode_lockt_maxsz	(op_encode_hdr_maxsz + 12)
+#define decode_lockt_maxsz	(op_decode_hdr_maxsz + \
+				 decode_lock_denied_maxsz)
+#define encode_locku_maxsz	(op_encode_hdr_maxsz + 3 + \
+				 encode_stateid_maxsz + \
+				 4)
+#define decode_locku_maxsz	(op_decode_hdr_maxsz + \
+				 decode_stateid_maxsz)
+#define encode_access_maxsz	(op_encode_hdr_maxsz + 1)
+#define decode_access_maxsz	(op_decode_hdr_maxsz + 2)
 #define encode_symlink_maxsz	(op_encode_hdr_maxsz + \
 				1 + nfs4_name_maxsz + \
 				1 + \
 				nfs4_fattr_maxsz)
 #define decode_symlink_maxsz	(op_decode_hdr_maxsz + 8)
 #define encode_create_maxsz	(op_encode_hdr_maxsz + \
-				2 + nfs4_name_maxsz + \
-				nfs4_fattr_maxsz)
+				1 + 2 + nfs4_name_maxsz + \
+				encode_attrs_maxsz)
 #define decode_create_maxsz	(op_decode_hdr_maxsz + \
 				decode_change_info_maxsz + \
 				nfs4_fattr_bitmap_maxsz)
+#define encode_statfs_maxsz	(encode_getattr_maxsz)
+#define decode_statfs_maxsz	(decode_getattr_maxsz)
 #define encode_delegreturn_maxsz (op_encode_hdr_maxsz + 4)
 #define decode_delegreturn_maxsz (op_decode_hdr_maxsz)
+#define encode_getacl_maxsz	(encode_getattr_maxsz)
+#define decode_getacl_maxsz	(op_decode_hdr_maxsz + \
+				 nfs4_fattr_bitmap_maxsz + 1)
+#define encode_setacl_maxsz	(op_encode_hdr_maxsz + \
+				 encode_stateid_maxsz + 3)
+#define decode_setacl_maxsz	(decode_setattr_maxsz)
 #define encode_fs_locations_maxsz \
 				(encode_getattr_maxsz)
 #define decode_fs_locations_maxsz \
@@ -169,37 +242,37 @@ static int nfs4_stat_to_errno(int);
 #define NFS4_dec_compound_sz	(1024)  /* XXX: large enough? */
 #define NFS4_enc_read_sz	(compound_encode_hdr_maxsz + \
 				encode_putfh_maxsz + \
-				op_encode_hdr_maxsz + 7)
+				encode_read_maxsz)
 #define NFS4_dec_read_sz	(compound_decode_hdr_maxsz + \
 				decode_putfh_maxsz + \
-				op_decode_hdr_maxsz + 2)
+				decode_read_maxsz)
 #define NFS4_enc_readlink_sz	(compound_encode_hdr_maxsz + \
 				encode_putfh_maxsz + \
-				op_encode_hdr_maxsz)
+				encode_readlink_maxsz)
 #define NFS4_dec_readlink_sz	(compound_decode_hdr_maxsz + \
 				decode_putfh_maxsz + \
-				op_decode_hdr_maxsz)
+				decode_readlink_maxsz)
 #define NFS4_enc_readdir_sz	(compound_encode_hdr_maxsz + \
 				encode_putfh_maxsz + \
-				op_encode_hdr_maxsz + 9)
+				encode_readdir_maxsz)
 #define NFS4_dec_readdir_sz	(compound_decode_hdr_maxsz + \
 				decode_putfh_maxsz + \
-				op_decode_hdr_maxsz + 2)
+				decode_readdir_maxsz)
 #define NFS4_enc_write_sz	(compound_encode_hdr_maxsz + \
 				encode_putfh_maxsz + \
-				op_encode_hdr_maxsz + 8 + \
+				encode_write_maxsz + \
 				encode_getattr_maxsz)
 #define NFS4_dec_write_sz	(compound_decode_hdr_maxsz + \
 				decode_putfh_maxsz + \
-				op_decode_hdr_maxsz + 4 + \
+				decode_write_maxsz + \
 				decode_getattr_maxsz)
 #define NFS4_enc_commit_sz	(compound_encode_hdr_maxsz + \
 				encode_putfh_maxsz + \
-				op_encode_hdr_maxsz + 3 + \
+				encode_commit_maxsz + \
 				encode_getattr_maxsz)
 #define NFS4_dec_commit_sz	(compound_decode_hdr_maxsz + \
 				decode_putfh_maxsz + \
-				op_decode_hdr_maxsz + 2 + \
+				decode_commit_maxsz + \
 				decode_getattr_maxsz)
 #define NFS4_enc_open_sz        (compound_encode_hdr_maxsz + \
 				encode_putfh_maxsz + \
@@ -217,13 +290,14 @@ static int nfs4_stat_to_errno(int);
 				decode_getattr_maxsz + \
 				decode_restorefh_maxsz + \
 				decode_getattr_maxsz)
-#define NFS4_enc_open_confirm_sz      \
-                                (compound_encode_hdr_maxsz + \
-                                encode_putfh_maxsz + \
-                                op_encode_hdr_maxsz + 5)
-#define NFS4_dec_open_confirm_sz        (compound_decode_hdr_maxsz + \
-                                        decode_putfh_maxsz + \
-                                        op_decode_hdr_maxsz + 4)
+#define NFS4_enc_open_confirm_sz \
+				(compound_encode_hdr_maxsz + \
+				 encode_putfh_maxsz + \
+				 encode_open_confirm_maxsz)
+#define NFS4_dec_open_confirm_sz \
+				(compound_decode_hdr_maxsz + \
+				 decode_putfh_maxsz + \
+				 decode_open_confirm_maxsz)
 #define NFS4_enc_open_noattr_sz	(compound_encode_hdr_maxsz + \
 					encode_putfh_maxsz + \
 					encode_open_maxsz + \
@@ -234,31 +308,30 @@ static int nfs4_stat_to_errno(int);
 					decode_getattr_maxsz)
 #define NFS4_enc_open_downgrade_sz \
 				(compound_encode_hdr_maxsz + \
-                                encode_putfh_maxsz + \
-                                op_encode_hdr_maxsz + 7 + \
-				encode_getattr_maxsz)
+				 encode_putfh_maxsz + \
+				 encode_open_downgrade_maxsz + \
+				 encode_getattr_maxsz)
 #define NFS4_dec_open_downgrade_sz \
 				(compound_decode_hdr_maxsz + \
-                                decode_putfh_maxsz + \
-                                op_decode_hdr_maxsz + 4 + \
-				decode_getattr_maxsz)
-#define NFS4_enc_close_sz       (compound_encode_hdr_maxsz + \
-                                encode_putfh_maxsz + \
-                                op_encode_hdr_maxsz + 5 + \
-				encode_getattr_maxsz)
-#define NFS4_dec_close_sz       (compound_decode_hdr_maxsz + \
-                                decode_putfh_maxsz + \
-                                op_decode_hdr_maxsz + 4 + \
-				decode_getattr_maxsz)
-#define NFS4_enc_setattr_sz     (compound_encode_hdr_maxsz + \
-                                encode_putfh_maxsz + \
-                                op_encode_hdr_maxsz + 4 + \
-                                nfs4_fattr_maxsz + \
-                                encode_getattr_maxsz)
-#define NFS4_dec_setattr_sz     (compound_decode_hdr_maxsz + \
-                                decode_putfh_maxsz + \
-                                op_decode_hdr_maxsz + 3 + \
-                                nfs4_fattr_maxsz)
+				 decode_putfh_maxsz + \
+				 decode_open_downgrade_maxsz + \
+				 decode_getattr_maxsz)
+#define NFS4_enc_close_sz	(compound_encode_hdr_maxsz + \
+				 encode_putfh_maxsz + \
+				 encode_close_maxsz + \
+				 encode_getattr_maxsz)
+#define NFS4_dec_close_sz	(compound_decode_hdr_maxsz + \
+				 decode_putfh_maxsz + \
+				 decode_close_maxsz + \
+				 decode_getattr_maxsz)
+#define NFS4_enc_setattr_sz	(compound_encode_hdr_maxsz + \
+				 encode_putfh_maxsz + \
+				 encode_setattr_maxsz + \
+				 encode_getattr_maxsz)
+#define NFS4_dec_setattr_sz	(compound_decode_hdr_maxsz + \
+				 decode_putfh_maxsz + \
+				 decode_setattr_maxsz + \
+				 decode_getattr_maxsz)
 #define NFS4_enc_fsinfo_sz	(compound_encode_hdr_maxsz + \
 				encode_putfh_maxsz + \
 				encode_fsinfo_maxsz)
@@ -285,39 +358,28 @@ static int nfs4_stat_to_errno(int);
 				decode_fsinfo_maxsz)
 #define NFS4_enc_lock_sz        (compound_encode_hdr_maxsz + \
 				encode_putfh_maxsz + \
-				encode_getattr_maxsz + \
-				op_encode_hdr_maxsz + \
-				1 + 1 + 2 + 2 + \
-				1 + 4 + 1 + 2 + \
-				lock_owner_id_maxsz)
+				encode_lock_maxsz)
 #define NFS4_dec_lock_sz        (compound_decode_hdr_maxsz + \
 				decode_putfh_maxsz + \
-				decode_getattr_maxsz + \
-				op_decode_hdr_maxsz + \
-				2 + 2 + 1 + 2 + \
-				lock_owner_id_maxsz)
+				decode_lock_maxsz)
 #define NFS4_enc_lockt_sz       (compound_encode_hdr_maxsz + \
 				encode_putfh_maxsz + \
-				encode_getattr_maxsz + \
-				op_encode_hdr_maxsz + \
-				1 + 2 + 2 + 2 + \
-				lock_owner_id_maxsz)
-#define NFS4_dec_lockt_sz       (NFS4_dec_lock_sz)
+				encode_lockt_maxsz)
+#define NFS4_dec_lockt_sz       (compound_decode_hdr_maxsz + \
+				 decode_putfh_maxsz + \
+				 decode_lockt_maxsz)
 #define NFS4_enc_locku_sz       (compound_encode_hdr_maxsz + \
 				encode_putfh_maxsz + \
-				encode_getattr_maxsz + \
-				op_encode_hdr_maxsz + \
-				1 + 1 + 4 + 2 + 2)
+				encode_locku_maxsz)
 #define NFS4_dec_locku_sz       (compound_decode_hdr_maxsz + \
 				decode_putfh_maxsz + \
-				decode_getattr_maxsz + \
-				op_decode_hdr_maxsz + 4)
+				decode_locku_maxsz)
 #define NFS4_enc_access_sz	(compound_encode_hdr_maxsz + \
 				encode_putfh_maxsz + \
-				op_encode_hdr_maxsz + 1)
+				encode_access_maxsz)
 #define NFS4_dec_access_sz	(compound_decode_hdr_maxsz + \
 				decode_putfh_maxsz + \
-				op_decode_hdr_maxsz + 2)
+				decode_access_maxsz)
 #define NFS4_enc_getattr_sz	(compound_encode_hdr_maxsz + \
 				encode_putfh_maxsz + \
 				encode_getattr_maxsz)
@@ -416,10 +478,10 @@ static int nfs4_stat_to_errno(int);
 				decode_getattr_maxsz)
 #define NFS4_enc_statfs_sz	(compound_encode_hdr_maxsz + \
 				encode_putfh_maxsz + \
-				encode_getattr_maxsz)
+				encode_statfs_maxsz)
 #define NFS4_dec_statfs_sz	(compound_decode_hdr_maxsz + \
 				decode_putfh_maxsz + \
-				op_decode_hdr_maxsz + 12)
+				decode_statfs_maxsz)
 #define NFS4_enc_server_caps_sz (compound_encode_hdr_maxsz + \
 				encode_putfh_maxsz + \
 				encode_getattr_maxsz)
@@ -435,18 +497,16 @@ static int nfs4_stat_to_errno(int);
 				decode_getattr_maxsz)
 #define NFS4_enc_getacl_sz	(compound_encode_hdr_maxsz + \
 				encode_putfh_maxsz + \
-				encode_getattr_maxsz)
+				encode_getacl_maxsz)
 #define NFS4_dec_getacl_sz	(compound_decode_hdr_maxsz + \
 				decode_putfh_maxsz + \
-				op_decode_hdr_maxsz + \
-				nfs4_fattr_bitmap_maxsz + 1)
+				decode_getacl_maxsz)
 #define NFS4_enc_setacl_sz	(compound_encode_hdr_maxsz + \
 				encode_putfh_maxsz + \
-				op_encode_hdr_maxsz + 4 + \
-				nfs4_fattr_bitmap_maxsz + 1)
+				encode_setacl_maxsz)
 #define NFS4_dec_setacl_sz	(compound_decode_hdr_maxsz + \
 				decode_putfh_maxsz + \
-				op_decode_hdr_maxsz + nfs4_fattr_bitmap_maxsz)
+				decode_setacl_maxsz)
 #define NFS4_enc_fs_locations_sz \
 				(compound_encode_hdr_maxsz + \
 				 encode_putfh_maxsz + \
@@ -1108,12 +1168,10 @@ static int encode_read(struct xdr_stream *xdr, const struct nfs_readargs *args)
 
 static int encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg *readdir, struct rpc_rqst *req)
 {
-	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
 	uint32_t attrs[2] = {
 		FATTR4_WORD0_RDATTR_ERROR|FATTR4_WORD0_FILEID,
 		FATTR4_WORD1_MOUNTED_ON_FILEID,
 	};
-	int replen;
 	__be32 *p;
 
 	RESERVE_SPACE(12+NFS4_VERIFIER_SIZE+20);
@@ -1138,37 +1196,16 @@ static int encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg
 			attrs[0] & readdir->bitmask[0],
 			attrs[1] & readdir->bitmask[1]);
 
-	/* set up reply kvec
-	 *    toplevel_status + taglen + rescount + OP_PUTFH + status
-	 *      + OP_READDIR + status + verifer(2)  = 9
-	 */
-	replen = (RPC_REPHDRSIZE + auth->au_rslack + 9) << 2;
-	xdr_inline_pages(&req->rq_rcv_buf, replen, readdir->pages,
-			 readdir->pgbase, readdir->count);
-	dprintk("%s: inlined page args = (%u, %p, %u, %u)\n",
-			__FUNCTION__, replen, readdir->pages,
-			readdir->pgbase, readdir->count);
-
 	return 0;
 }
 
 static int encode_readlink(struct xdr_stream *xdr, const struct nfs4_readlink *readlink, struct rpc_rqst *req)
 {
-	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
-	unsigned int replen;
 	__be32 *p;
 
 	RESERVE_SPACE(4);
 	WRITE32(OP_READLINK);
 
-	/* set up reply kvec
-	 *    toplevel_status + taglen + rescount + OP_PUTFH + status
-	 *      + OP_READLINK + status + string length = 8
-	 */
-	replen = (RPC_REPHDRSIZE + auth->au_rslack + 8) << 2;
-	xdr_inline_pages(&req->rq_rcv_buf, replen, readlink->pages,
-			readlink->pgbase, readlink->pglen);
-	
 	return 0;
 }
 
@@ -1398,7 +1435,7 @@ out:
 /*
  * Encode REMOVE request
  */
-static int nfs4_xdr_enc_remove(struct rpc_rqst *req, __be32 *p, const struct nfs4_remove_arg *args)
+static int nfs4_xdr_enc_remove(struct rpc_rqst *req, __be32 *p, const struct nfs_removeargs *args)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
@@ -1410,7 +1447,7 @@ static int nfs4_xdr_enc_remove(struct rpc_rqst *req, __be32 *p, const struct nfs
 	encode_compound_hdr(&xdr, &hdr);
 	if ((status = encode_putfh(&xdr, args->fh)) != 0)
 		goto out;
-	if ((status = encode_remove(&xdr, args->name)) != 0)
+	if ((status = encode_remove(&xdr, &args->name)) != 0)
 		goto out;
 	status = encode_getfattr(&xdr, args->bitmask);
 out:
@@ -1734,6 +1771,8 @@ static int nfs4_xdr_enc_readlink(struct rpc_rqst *req, __be32 *p, const struct n
 	struct compound_hdr hdr = {
 		.nops = 2,
 	};
+	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
+	unsigned int replen;
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1742,6 +1781,15 @@ static int nfs4_xdr_enc_readlink(struct rpc_rqst *req, __be32 *p, const struct n
 	if(status)
 		goto out;
 	status = encode_readlink(&xdr, args, req);
+
+	/* set up reply kvec
+	 *    toplevel_status + taglen + rescount + OP_PUTFH + status
+	 *      + OP_READLINK + status + string length = 8
+	 */
+	replen = (RPC_REPHDRSIZE + auth->au_rslack + NFS4_dec_readlink_sz) << 2;
+	xdr_inline_pages(&req->rq_rcv_buf, replen, args->pages,
+			args->pgbase, args->pglen);
+
 out:
 	return status;
 }
@@ -1755,6 +1803,8 @@ static int nfs4_xdr_enc_readdir(struct rpc_rqst *req, __be32 *p, const struct nf
 	struct compound_hdr hdr = {
 		.nops = 2,
 	};
+	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
+	int replen;
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -1763,6 +1813,18 @@ static int nfs4_xdr_enc_readdir(struct rpc_rqst *req, __be32 *p, const struct nf
 	if(status)
 		goto out;
 	status = encode_readdir(&xdr, args, req);
+
+	/* set up reply kvec
+	 *    toplevel_status + taglen + rescount + OP_PUTFH + status
+	 *      + OP_READDIR + status + verifer(2)  = 9
+	 */
+	replen = (RPC_REPHDRSIZE + auth->au_rslack + NFS4_dec_readdir_sz) << 2;
+	xdr_inline_pages(&req->rq_rcv_buf, replen, args->pages,
+			 args->pgbase, args->count);
+	dprintk("%s: inlined page args = (%u, %p, %u, %u)\n",
+			__FUNCTION__, replen, args->pages,
+			args->pgbase, args->count);
+
 out:
 	return status;
 }
@@ -3161,11 +3223,12 @@ static int decode_getfh(struct xdr_stream *xdr, struct nfs_fh *fh)
 	uint32_t len;
 	int status;
 
+	/* Zero handle first to allow comparisons */
+	memset(fh, 0, sizeof(*fh));
+
 	status = decode_op_hdr(xdr, OP_GETFH);
 	if (status)
 		return status;
-	/* Zero handle first to allow comparisons */
-	memset(fh, 0, sizeof(*fh));
 
 	READ_BUF(4);
 	READ32(len);
@@ -3772,7 +3835,7 @@ out:
 /*
  * Decode REMOVE response
  */
-static int nfs4_xdr_dec_remove(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_remove_res *res)
+static int nfs4_xdr_dec_remove(struct rpc_rqst *rqstp, __be32 *p, struct nfs_removeres *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
@@ -3785,7 +3848,7 @@ static int nfs4_xdr_dec_remove(struct rpc_rqst *rqstp, __be32 *p, struct nfs4_re
 		goto out;
 	if ((status = decode_remove(&xdr, &res->cinfo)) != 0)
 		goto out;
-	decode_getfattr(&xdr, res->dir_attr, res->server);
+	decode_getfattr(&xdr, &res->dir_attr, res->server);
 out:
 	return status;
 }
@@ -4030,12 +4093,11 @@ static int nfs4_xdr_dec_open(struct rpc_rqst *rqstp, __be32 *p, struct nfs_openr
         status = decode_open(&xdr, res);
         if (status)
                 goto out;
-	status = decode_getfh(&xdr, &res->fh);
-        if (status)
+	if (decode_getfh(&xdr, &res->fh) != 0)
 		goto out;
 	if (decode_getfattr(&xdr, res->f_attr, res->server) != 0)
 		goto out;
-	if ((status = decode_restorefh(&xdr)) != 0)
+	if (decode_restorefh(&xdr) != 0)
 		goto out;
 	decode_getfattr(&xdr, res->dir_attr, res->server);
 out:
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 7be0ee2..845cdde 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -272,14 +272,14 @@ nfs_proc_mknod(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 static int
 nfs_proc_remove(struct inode *dir, struct qstr *name)
 {
-	struct nfs_diropargs	arg = {
-		.fh		= NFS_FH(dir),
-		.name		= name->name,
-		.len		= name->len
+	struct nfs_removeargs arg = {
+		.fh = NFS_FH(dir),
+		.name.len = name->len,
+		.name.name = name->name,
 	};
-	struct rpc_message	msg = { 
-		.rpc_proc	= &nfs_procedures[NFSPROC_REMOVE],
-		.rpc_argp	= &arg,
+	struct rpc_message msg = { 
+		.rpc_proc = &nfs_procedures[NFSPROC_REMOVE],
+		.rpc_argp = &arg,
 	};
 	int			status;
 
@@ -291,32 +291,16 @@ nfs_proc_remove(struct inode *dir, struct qstr *name)
 	return status;
 }
 
-static int
-nfs_proc_unlink_setup(struct rpc_message *msg, struct dentry *dir, struct qstr *name)
+static void
+nfs_proc_unlink_setup(struct rpc_message *msg, struct inode *dir)
 {
-	struct nfs_diropargs	*arg;
-
-	arg = kmalloc(sizeof(*arg), GFP_KERNEL);
-	if (!arg)
-		return -ENOMEM;
-	arg->fh = NFS_FH(dir->d_inode);
-	arg->name = name->name;
-	arg->len = name->len;
 	msg->rpc_proc = &nfs_procedures[NFSPROC_REMOVE];
-	msg->rpc_argp = arg;
-	return 0;
 }
 
-static int
-nfs_proc_unlink_done(struct dentry *dir, struct rpc_task *task)
+static int nfs_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 {
-	struct rpc_message *msg = &task->tk_msg;
-	
-	if (msg->rpc_argp) {
-		nfs_mark_for_revalidate(dir->d_inode);
-		kfree(msg->rpc_argp);
-	}
-	return 0;
+	nfs_mark_for_revalidate(dir);
+	return 1;
 }
 
 static int
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index adffe16..b34b7a7 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1685,6 +1685,9 @@ static int nfs4_validate_mount_data(struct nfs4_mount_data **options,
 
 		dprintk("MNTPATH: %s\n", *mntpath);
 
+		if (args.client_address == NULL)
+			goto out_no_client_address;
+
 		*ip_addr = args.client_address;
 
 		break;
@@ -1705,6 +1708,10 @@ out_inval_auth:
 out_no_address:
 	dfprintk(MOUNT, "NFS4: mount program didn't pass remote address\n");
 	return -EINVAL;
+
+out_no_client_address:
+	dfprintk(MOUNT, "NFS4: mount program didn't pass callback address\n");
+	return -EINVAL;
 }
 
 /*
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 0e28189..045ab80 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -3,7 +3,6 @@
  *
  * nfs sillydelete handling
  *
- * NOTE: we rely on holding the BKL for list manipulation protection.
  */
 
 #include <linux/slab.h>
@@ -15,46 +14,23 @@
 
 
 struct nfs_unlinkdata {
-	struct nfs_unlinkdata	*next;
-	struct dentry	*dir, *dentry;
-	struct qstr	name;
-	struct rpc_task	task;
+	struct nfs_removeargs args;
+	struct nfs_removeres res;
+	struct inode *dir;
 	struct rpc_cred	*cred;
-	unsigned int	count;
 };
 
-static struct nfs_unlinkdata	*nfs_deletes;
-static RPC_WAITQ(nfs_delete_queue, "nfs_delete_queue");
-
-/**
- * nfs_detach_unlinkdata - Remove asynchronous unlink from global list
- * @data: pointer to descriptor
- */
-static inline void
-nfs_detach_unlinkdata(struct nfs_unlinkdata *data)
-{
-	struct nfs_unlinkdata	**q;
-
-	for (q = &nfs_deletes; *q != NULL; q = &((*q)->next)) {
-		if (*q == data) {
-			*q = data->next;
-			break;
-		}
-	}
-}
-
 /**
- * nfs_put_unlinkdata - release data from a sillydelete operation.
+ * nfs_free_unlinkdata - release data from a sillydelete operation.
  * @data: pointer to unlink structure.
  */
 static void
-nfs_put_unlinkdata(struct nfs_unlinkdata *data)
+nfs_free_unlinkdata(struct nfs_unlinkdata *data)
 {
-	if (--data->count == 0) {
-		nfs_detach_unlinkdata(data);
-		kfree(data->name.name);
-		kfree(data);
-	}
+	iput(data->dir);
+	put_rpccred(data->cred);
+	kfree(data->args.name.name);
+	kfree(data);
 }
 
 #define NAME_ALLOC_LEN(len)	((len+16) & ~15)
@@ -63,50 +39,36 @@ nfs_put_unlinkdata(struct nfs_unlinkdata *data)
  * @dentry: pointer to dentry
  * @data: nfs_unlinkdata
  */
-static inline void
-nfs_copy_dname(struct dentry *dentry, struct nfs_unlinkdata *data)
+static int nfs_copy_dname(struct dentry *dentry, struct nfs_unlinkdata *data)
 {
 	char		*str;
 	int		len = dentry->d_name.len;
 
-	str = kmalloc(NAME_ALLOC_LEN(len), GFP_KERNEL);
+	str = kmemdup(dentry->d_name.name, NAME_ALLOC_LEN(len), GFP_KERNEL);
 	if (!str)
-		return;
-	memcpy(str, dentry->d_name.name, len);
-	if (!data->name.len) {
-		data->name.len = len;
-		data->name.name = str;
-	} else
-		kfree(str);
+		return -ENOMEM;
+	data->args.name.len = len;
+	data->args.name.name = str;
+	return 0;
 }
 
 /**
  * nfs_async_unlink_init - Initialize the RPC info
- * @task: rpc_task of the sillydelete
- *
- * We delay initializing RPC info until after the call to dentry_iput()
- * in order to minimize races against rename().
+ * task: rpc_task of the sillydelete
  */
 static void nfs_async_unlink_init(struct rpc_task *task, void *calldata)
 {
-	struct nfs_unlinkdata	*data = calldata;
-	struct dentry		*dir = data->dir;
-	struct rpc_message	msg = {
-		.rpc_cred	= data->cred,
+	struct nfs_unlinkdata *data = calldata;
+	struct inode *dir = data->dir;
+	struct rpc_message msg = {
+		.rpc_argp = &data->args,
+		.rpc_resp = &data->res,
+		.rpc_cred = data->cred,
 	};
-	int			status = -ENOENT;
-
-	if (!data->name.len)
-		goto out_err;
 
-	status = NFS_PROTO(dir->d_inode)->unlink_setup(&msg, dir, &data->name);
-	if (status < 0)
-		goto out_err;
-	nfs_begin_data_update(dir->d_inode);
+	nfs_begin_data_update(dir);
+	NFS_PROTO(dir)->unlink_setup(&msg, dir);
 	rpc_call_setup(task, &msg, 0);
-	return;
- out_err:
-	rpc_exit(task, status);
 }
 
 /**
@@ -117,19 +79,13 @@ static void nfs_async_unlink_init(struct rpc_task *task, void *calldata)
  */
 static void nfs_async_unlink_done(struct rpc_task *task, void *calldata)
 {
-	struct nfs_unlinkdata	*data = calldata;
-	struct dentry		*dir = data->dir;
-	struct inode		*dir_i;
-
-	if (!dir)
-		return;
-	dir_i = dir->d_inode;
-	nfs_end_data_update(dir_i);
-	if (NFS_PROTO(dir_i)->unlink_done(dir, task))
-		return;
-	put_rpccred(data->cred);
-	data->cred = NULL;
-	dput(dir);
+	struct nfs_unlinkdata *data = calldata;
+	struct inode *dir = data->dir;
+
+	if (!NFS_PROTO(dir)->unlink_done(task, dir))
+		rpc_restart_call(task);
+	else
+		nfs_end_data_update(dir);
 }
 
 /**
@@ -142,7 +98,7 @@ static void nfs_async_unlink_done(struct rpc_task *task, void *calldata)
 static void nfs_async_unlink_release(void *calldata)
 {
 	struct nfs_unlinkdata	*data = calldata;
-	nfs_put_unlinkdata(data);
+	nfs_free_unlinkdata(data);
 }
 
 static const struct rpc_call_ops nfs_unlink_ops = {
@@ -151,73 +107,94 @@ static const struct rpc_call_ops nfs_unlink_ops = {
 	.rpc_release = nfs_async_unlink_release,
 };
 
+static int nfs_call_unlink(struct dentry *dentry, struct nfs_unlinkdata *data)
+{
+	struct rpc_task *task;
+	struct dentry *parent;
+	struct inode *dir;
+
+	if (nfs_copy_dname(dentry, data) < 0)
+		goto out_free;
+
+	parent = dget_parent(dentry);
+	if (parent == NULL)
+		goto out_free;
+	dir = igrab(parent->d_inode);
+	dput(parent);
+	if (dir == NULL)
+		goto out_free;
+
+	data->dir = dir;
+	data->args.fh = NFS_FH(dir);
+	nfs_fattr_init(&data->res.dir_attr);
+
+	task = rpc_run_task(NFS_CLIENT(dir), RPC_TASK_ASYNC, &nfs_unlink_ops, data);
+	if (!IS_ERR(task))
+		rpc_put_task(task);
+	return 1;
+out_free:
+	return 0;
+}
+
 /**
  * nfs_async_unlink - asynchronous unlinking of a file
+ * @dir: parent directory of dentry
  * @dentry: dentry to unlink
  */
 int
-nfs_async_unlink(struct dentry *dentry)
+nfs_async_unlink(struct inode *dir, struct dentry *dentry)
 {
-	struct dentry	*dir = dentry->d_parent;
-	struct nfs_unlinkdata	*data;
-	struct rpc_clnt	*clnt = NFS_CLIENT(dir->d_inode);
-	int		status = -ENOMEM;
+	struct nfs_unlinkdata *data;
+	int status = -ENOMEM;
 
 	data = kzalloc(sizeof(*data), GFP_KERNEL);
-	if (!data)
+	if (data == NULL)
 		goto out;
 
-	data->cred = rpcauth_lookupcred(clnt->cl_auth, 0);
+	data->cred = rpcauth_lookupcred(NFS_CLIENT(dir)->cl_auth, 0);
 	if (IS_ERR(data->cred)) {
 		status = PTR_ERR(data->cred);
 		goto out_free;
 	}
-	data->dir = dget(dir);
-	data->dentry = dentry;
-
-	data->next = nfs_deletes;
-	nfs_deletes = data;
-	data->count = 1;
-
-	rpc_init_task(&data->task, clnt, RPC_TASK_ASYNC, &nfs_unlink_ops, data);
 
+	status = -EBUSY;
 	spin_lock(&dentry->d_lock);
+	if (dentry->d_flags & DCACHE_NFSFS_RENAMED)
+		goto out_unlock;
 	dentry->d_flags |= DCACHE_NFSFS_RENAMED;
+	dentry->d_fsdata = data;
 	spin_unlock(&dentry->d_lock);
-
-	rpc_sleep_on(&nfs_delete_queue, &data->task, NULL, NULL);
-	status = 0;
- out:
-	return status;
+	return 0;
+out_unlock:
+	spin_unlock(&dentry->d_lock);
+	put_rpccred(data->cred);
 out_free:
 	kfree(data);
+out:
 	return status;
 }
 
 /**
  * nfs_complete_unlink - Initialize completion of the sillydelete
  * @dentry: dentry to delete
+ * @inode: inode
  *
  * Since we're most likely to be called by dentry_iput(), we
  * only use the dentry to find the sillydelete. We then copy the name
  * into the qstr.
  */
 void
-nfs_complete_unlink(struct dentry *dentry)
+nfs_complete_unlink(struct dentry *dentry, struct inode *inode)
 {
-	struct nfs_unlinkdata	*data;
+	struct nfs_unlinkdata	*data = NULL;
 
-	for(data = nfs_deletes; data != NULL; data = data->next) {
-		if (dentry == data->dentry)
-			break;
-	}
-	if (!data)
-		return;
-	data->count++;
-	nfs_copy_dname(dentry, data);
 	spin_lock(&dentry->d_lock);
-	dentry->d_flags &= ~DCACHE_NFSFS_RENAMED;
+	if (dentry->d_flags & DCACHE_NFSFS_RENAMED) {
+		dentry->d_flags &= ~DCACHE_NFSFS_RENAMED;
+		data = dentry->d_fsdata;
+	}
 	spin_unlock(&dentry->d_lock);
-	rpc_wake_up_task(&data->task);
-	nfs_put_unlinkdata(data);
+
+	if (data != NULL && (NFS_STALE(inode) || !nfs_call_unlink(dentry, data)))
+		nfs_free_unlinkdata(data);
 }
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index c098ae1..9ba4aec 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -407,8 +407,8 @@ extern void nfs_release_automount_timer(void);
 /*
  * linux/fs/nfs/unlink.c
  */
-extern int  nfs_async_unlink(struct dentry *);
-extern void nfs_complete_unlink(struct dentry *);
+extern int  nfs_async_unlink(struct inode *dir, struct dentry *dentry);
+extern void nfs_complete_unlink(struct dentry *dentry, struct inode *);
 
 /*
  * linux/fs/nfs/write.c
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 38d7768..cf74a4d 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -278,6 +278,21 @@ struct nfs_writeres {
 };
 
 /*
+ * Common arguments to the unlink call
+ */
+struct nfs_removeargs {
+	const struct nfs_fh	*fh;
+	struct qstr		name;
+	const u32 *		bitmask;
+};
+
+struct nfs_removeres {
+	const struct nfs_server *server;
+	struct nfs4_change_info	cinfo;
+	struct nfs_fattr	dir_attr;
+};
+
+/*
  * Argument struct for decode_entry function
  */
 struct nfs_entry {
@@ -631,18 +646,6 @@ struct nfs4_readlink {
 	struct page **			pages;   /* zero-copy data */
 };
 
-struct nfs4_remove_arg {
-	const struct nfs_fh *		fh;
-	const struct qstr *		name;
-	const u32 *			bitmask;
-};
-
-struct nfs4_remove_res {
-	const struct nfs_server *	server;
-	struct nfs4_change_info		cinfo;
-	struct nfs_fattr *		dir_attr;
-};
-
 struct nfs4_rename_arg {
 	const struct nfs_fh *		old_dir;
 	const struct nfs_fh *		new_dir;
@@ -788,9 +791,8 @@ struct nfs_rpc_ops {
 	int	(*create)  (struct inode *, struct dentry *,
 			    struct iattr *, int, struct nameidata *);
 	int	(*remove)  (struct inode *, struct qstr *);
-	int	(*unlink_setup)  (struct rpc_message *,
-			    struct dentry *, struct qstr *);
-	int	(*unlink_done) (struct dentry *, struct rpc_task *);
+	void	(*unlink_setup)  (struct rpc_message *, struct inode *dir);
+	int	(*unlink_done) (struct rpc_task *, struct inode *);
 	int	(*rename)  (struct inode *, struct qstr *,
 			    struct inode *, struct qstr *);
 	int	(*link)    (struct inode *, struct inode *, struct qstr *);
diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 9e340fa..c6b53d1 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -12,6 +12,7 @@
 #include <linux/uio.h>
 #include <asm/byteorder.h>
 #include <linux/scatterlist.h>
+#include <linux/smp_lock.h>
 
 /*
  * Buffer adjustment
@@ -36,6 +37,21 @@ struct xdr_netobj {
 typedef int	(*kxdrproc_t)(void *rqstp, __be32 *data, void *obj);
 
 /*
+ * We're still requiring the BKL in the xdr code until it's been
+ * more carefully audited, at which point this wrapper will become
+ * unnecessary.
+ */
+static inline int rpc_call_xdrproc(kxdrproc_t xdrproc, void *rqstp, __be32 *data, void *obj)
+{
+	int ret;
+
+	lock_kernel();
+	ret = xdrproc(rqstp, data, obj);
+	unlock_kernel();
+	return ret;
+}
+
+/*
  * Basic structure for transmission/reception of a client XDR message.
  * Features a header (for a linear buffer containing RPC headers
  * and the data payload for short messages), and then an array of
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 29a8ecc..1ea2755 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -13,7 +13,6 @@
 #include <linux/errno.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/spinlock.h>
-#include <linux/smp_lock.h>
 
 #ifdef RPC_DEBUG
 # define RPCDBG_FACILITY	RPCDBG_AUTH
@@ -476,17 +475,13 @@ rpcauth_wrap_req(struct rpc_task *task, kxdrproc_t encode, void *rqstp,
 		__be32 *data, void *obj)
 {
 	struct rpc_cred *cred = task->tk_msg.rpc_cred;
-	int ret;
 
 	dprintk("RPC: %5u using %s cred %p to wrap rpc data\n",
 			task->tk_pid, cred->cr_ops->cr_name, cred);
 	if (cred->cr_ops->crwrap_req)
 		return cred->cr_ops->crwrap_req(task, encode, rqstp, data, obj);
 	/* By default, we encode the arguments normally. */
-	lock_kernel();
-	ret = encode(rqstp, data, obj);
-	unlock_kernel();
-	return ret;
+	return rpc_call_xdrproc(encode, rqstp, data, obj);
 }
 
 int
@@ -494,7 +489,6 @@ rpcauth_unwrap_resp(struct rpc_task *task, kxdrproc_t decode, void *rqstp,
 		__be32 *data, void *obj)
 {
 	struct rpc_cred *cred = task->tk_msg.rpc_cred;
-	int ret;
 
 	dprintk("RPC: %5u using %s cred %p to unwrap rpc data\n",
 			task->tk_pid, cred->cr_ops->cr_name, cred);
@@ -502,10 +496,7 @@ rpcauth_unwrap_resp(struct rpc_task *task, kxdrproc_t decode, void *rqstp,
 		return cred->cr_ops->crunwrap_resp(task, decode, rqstp,
 						   data, obj);
 	/* By default, we decode the arguments normally. */
-	lock_kernel();
-	ret = decode(rqstp, data, obj);
-	unlock_kernel();
-	return ret;
+	return rpc_call_xdrproc(decode, rqstp, data, obj);
 }
 
 int
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index abfda33..4bbc59c 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -43,7 +43,6 @@
 #include <linux/types.h>
 #include <linux/slab.h>
 #include <linux/sched.h>
-#include <linux/smp_lock.h>
 #include <linux/pagemap.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/auth.h>
@@ -1000,9 +999,7 @@ gss_wrap_req_integ(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
 	offset = (u8 *)p - (u8 *)snd_buf->head[0].iov_base;
 	*p++ = htonl(rqstp->rq_seqno);
 
-	lock_kernel();
-	status = encode(rqstp, p, obj);
-	unlock_kernel();
+	status = rpc_call_xdrproc(encode, rqstp, p, obj);
 	if (status)
 		return status;
 
@@ -1096,9 +1093,7 @@ gss_wrap_req_priv(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
 	offset = (u8 *)p - (u8 *)snd_buf->head[0].iov_base;
 	*p++ = htonl(rqstp->rq_seqno);
 
-	lock_kernel();
-	status = encode(rqstp, p, obj);
-	unlock_kernel();
+	status = rpc_call_xdrproc(encode, rqstp, p, obj);
 	if (status)
 		return status;
 
@@ -1157,16 +1152,12 @@ gss_wrap_req(struct rpc_task *task,
 		/* The spec seems a little ambiguous here, but I think that not
 		 * wrapping context destruction requests makes the most sense.
 		 */
-		lock_kernel();
-		status = encode(rqstp, p, obj);
-		unlock_kernel();
+		status = rpc_call_xdrproc(encode, rqstp, p, obj);
 		goto out;
 	}
 	switch (gss_cred->gc_service) {
 		case RPC_GSS_SVC_NONE:
-			lock_kernel();
-			status = encode(rqstp, p, obj);
-			unlock_kernel();
+			status = rpc_call_xdrproc(encode, rqstp, p, obj);
 			break;
 		case RPC_GSS_SVC_INTEGRITY:
 			status = gss_wrap_req_integ(cred, ctx, encode,
@@ -1282,9 +1273,7 @@ gss_unwrap_resp(struct rpc_task *task,
 	cred->cr_auth->au_rslack = cred->cr_auth->au_verfsize + (p - savedp)
 						+ (savedlen - head->iov_len);
 out_decode:
-	lock_kernel();
-	status = decode(rqstp, p, obj);
-	unlock_kernel();
+	status = rpc_call_xdrproc(decode, rqstp, p, obj);
 out:
 	gss_put_ctx(ctx);
 	dprintk("RPC: %5u gss_unwrap_resp returning %d\n", task->tk_pid,

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
