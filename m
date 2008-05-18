From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT] Please pull NFS client bugfixes and cleanups
Date: Sun, 18 May 2008 18:29:46 -0400
Message-ID: <1211149786.18810.13.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6460 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751267AbYERW3w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 18 May 2008 18:29:52 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the "hotfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git hotfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/callback.c         |    2 +-
 fs/nfs/callback_proc.c    |    4 +-
 fs/nfs/callback_xdr.c     |   40 +++++++++---------
 fs/nfs/client.c           |    8 ++--
 fs/nfs/delegation.c       |    4 +-
 fs/nfs/dir.c              |   18 ++++----
 fs/nfs/file.c             |    2 +-
 fs/nfs/inode.c            |   14 +++++--
 fs/nfs/namespace.c        |   11 ++---
 fs/nfs/nfs3proc.c         |    6 +-
 fs/nfs/nfs4_fs.h          |    1 -
 fs/nfs/nfs4namespace.c    |   12 +++---
 fs/nfs/nfs4proc.c         |   38 ++++++++---------
 fs/nfs/nfs4renewd.c       |   10 ++--
 fs/nfs/nfs4state.c        |    8 ++--
 fs/nfs/nfs4xdr.c          |  100 ++++++++++++++++++++++----------------------
 fs/nfs/proc.c             |    8 ++--
 fs/nfs/read.c             |    2 +-
 fs/nfs/super.c            |   12 +++++-
 fs/nfs/write.c            |    2 +-
 net/sunrpc/auth_generic.c |    8 ++--
 21 files changed, 161 insertions(+), 149 deletions(-)

commit b4528762ca92261c6ed3f03e76adeb1dc587aacb
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun May 11 12:18:51 2008 -0700

    SUNRPC: AUTH_SYS "machine creds" shouldn't use negative valued uid/gid
    
    Apparently this causes Solaris 10 servers to refuse our NFSv4 SETCLIENTID
    calls. Fall back to root creds for now, since most servers that care are
    very likely to have root squashing enabled.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 1d2e88e73ee0af52b0ed63b5fb8f42a919a4d9de
Author: Adrian Bunk <bunk@kernel.org>
Date:   Fri May 2 13:42:45 2008 -0700

    nfs: make nfs4_drop_state_owner() static
    
    nfs4_drop_state_owner() can now become static.
    
    Signed-off-by: Adrian Bunk <bunk@kernel.org>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 31f31db1a15671513df9cd9fbe56ef45ee1e9a2a
Author: Jan Blunck <jblunck@suse.de>
Date:   Fri May 2 13:42:45 2008 -0700

    nfs: path_{get,put}() cleanups
    
    Here are some more places where path_{get,put}() can be used instead of
    dput()/mntput() pair.
    
    Signed-off-by: Jan Blunck <jblunck@suse.de>
    Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
    Cc: "J. Bruce Fields" <bfields@fieldses.org>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3110ff8048fb757b36112b044b384aea9c44d6e4
Author: Harvey Harrison <harvey.harrison@gmail.com>
Date:   Fri May 2 13:42:44 2008 -0700

    nfs: replace remaining __FUNCTION__ occurrences
    
    __FUNCTION__ is gcc-specific, use __func__
    
    Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
    Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
    Cc: "J. Bruce Fields" <bfields@fieldses.org>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 46c8ac74250a396aca855e494f49a960797a6b5e
Author: Eric Paris <eparis@redhat.com>
Date:   Fri May 2 13:42:42 2008 -0700

    nfs/lsm: make NFSv4 set LSM mount options
    
    NFSv3 get_sb operations call into the LSM layer to set security options passed
    from userspace.  NFSv4 hooks were not originally added since it was reasonably
    late in the merge window and NFSv3 was the only thing that had regressed (v4
    has never supported any LSM options)
    
    This patch makes NFSv4 call into the LSM to set security options rather than
    just blindly dropping them with no notice to the user as happens today.  This
    patch was tested in a simple NFSv4 environment with the context= option and
    appeared to work as expected.
    
    Signed-off-by: Eric Paris <eparis@redhat.com>
    Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
    Cc: "J. Bruce Fields" <bfields@fieldses.org>
    Cc: Stephen Smalley <sds@tycho.nsa.gov>
    Acked-by: James Morris <jmorris@namei.org>
    Cc: Casey Schaufler <casey@schaufler-ca.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 3a6258e1fb5ff717dcefa04afc35f81aaae3f3e0
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue May 6 13:32:40 2008 -0400

    NFSv4: Check the return value of decode_compound_hdr_arg()
    
    If decode_compound_hdr_arg() returns a resource error, then we cannot
    proceed to process the callback. Return a 'GARBAGE_ARGS' rpc-level error to
    the caller instead.
    If, however, the minor version field is incorrect, then we need to
    propagate the resulting NFS4ERR_MINOR_VERS_MISMATCH error back as the
    compound status field (setting the nops field to 0).
    
    Finally, if encode_compound_hdr_res() returns an error, we need to return
    an RPC_SYSTEM_ERR to the caller.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 38def50fabc479dc96ea6bd2cb2526e0dfc36fa4
Author: Fred Isaman <iisaman@citi.umich.edu>
Date:   Thu May 1 20:03:22 2008 +0300

    nfs: fix race in nfs_dirty_request
    
    When called from nfs_flush_incompatible, the req is not locked, so
    req->wb_page might be set to NULL before it is used by PageWriteback.
    
    Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b0b539739fe9b7d75002412a787cfdf4efddbc33
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon May 5 11:45:41 2008 -0400

    NFS: Ensure that 'noac' and/or 'actimeo=0' turn off attribute caching
    
    Both the 'noac' and 'actimeo=0' mount options should ensure that attributes
    are not cached, however a bug in nfs_attribute_timeout() means that
    currently, the attributes may in fact get cached for up to one jiffy. This
    has been seen to cause corruption in some applications.
    
    The reason for the bug is that the time_in_range() test returns 'true' as
    long as the current time lies between nfsi->read_cache_jiffies and
    nfsi->read_cache_jiffies + nfsi->attrtimeo. In other words, if jiffies
    equals nfsi->read_cache_jiffies, then we still cache the attribute data.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 5606ae3..c1e7c83 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -182,7 +182,7 @@ static int nfs_callback_authenticate(struct svc_rqst *rqstp)
 	if (clp == NULL)
 		return SVC_DROP;
 
-	dprintk("%s: %s NFSv4 callback!\n", __FUNCTION__,
+	dprintk("%s: %s NFSv4 callback!\n", __func__,
 			svc_print_addr(rqstp, buf, sizeof(buf)));
 	nfs_put_client(clp);
 
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 15f7785..f7e83e2 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -57,7 +57,7 @@ out_iput:
 out_putclient:
 	nfs_put_client(clp);
 out:
-	dprintk("%s: exit with status = %d\n", __FUNCTION__, ntohl(res->status));
+	dprintk("%s: exit with status = %d\n", __func__, ntohl(res->status));
 	return res->status;
 }
 
@@ -98,6 +98,6 @@ __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy)
 		nfs_put_client(prev);
 	} while (clp != NULL);
 out:
-	dprintk("%s: exit with status = %d\n", __FUNCTION__, ntohl(res));
+	dprintk("%s: exit with status = %d\n", __func__, ntohl(res));
 	return res;
 }
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 13619d2..dd0ef34 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -141,7 +141,7 @@ static __be32 decode_compound_hdr_arg(struct xdr_stream *xdr, struct cb_compound
 	/* We do not like overly long tags! */
 	if (hdr->taglen > CB_OP_TAGLEN_MAXSZ - 12) {
 		printk("NFSv4 CALLBACK %s: client sent tag of length %u\n",
-				__FUNCTION__, hdr->taglen);
+				__func__, hdr->taglen);
 		return htonl(NFS4ERR_RESOURCE);
 	}
 	p = read_buf(xdr, 12);
@@ -151,7 +151,7 @@ static __be32 decode_compound_hdr_arg(struct xdr_stream *xdr, struct cb_compound
 	/* Check minor version is zero. */
 	if (minor_version != 0) {
 		printk(KERN_WARNING "%s: NFSv4 server callback with illegal minor version %u!\n",
-				__FUNCTION__, minor_version);
+				__func__, minor_version);
 		return htonl(NFS4ERR_MINOR_VERS_MISMATCH);
 	}
 	hdr->callback_ident = ntohl(*p++);
@@ -179,7 +179,7 @@ static __be32 decode_getattr_args(struct svc_rqst *rqstp, struct xdr_stream *xdr
 	args->addr = svc_addr(rqstp);
 	status = decode_bitmap(xdr, args->bitmap);
 out:
-	dprintk("%s: exit with status = %d\n", __FUNCTION__, ntohl(status));
+	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
 	return status;
 }
 
@@ -200,7 +200,7 @@ static __be32 decode_recall_args(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 	args->truncate = ntohl(*p);
 	status = decode_fh(xdr, &args->fh);
 out:
-	dprintk("%s: exit with status = %d\n", __FUNCTION__, ntohl(status));
+	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
 	return status;
 }
 
@@ -349,7 +349,7 @@ static __be32 encode_getattr_res(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 	status = encode_attr_mtime(xdr, res->bitmap, &res->mtime);
 	*savep = htonl((unsigned int)((char *)xdr->p - (char *)(savep+1)));
 out:
-	dprintk("%s: exit with status = %d\n", __FUNCTION__, ntohl(status));
+	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
 	return status;
 }
 
@@ -363,7 +363,7 @@ static __be32 process_op(struct svc_rqst *rqstp,
 	long maxlen;
 	__be32 res;
 
-	dprintk("%s: start\n", __FUNCTION__);
+	dprintk("%s: start\n", __func__);
 	status = decode_op_hdr(xdr_in, &op_nr);
 	if (likely(status == 0)) {
 		switch (op_nr) {
@@ -392,7 +392,7 @@ static __be32 process_op(struct svc_rqst *rqstp,
 		status = res;
 	if (op->encode_res != NULL && status == 0)
 		status = op->encode_res(rqstp, xdr_out, resp);
-	dprintk("%s: done, status = %d\n", __FUNCTION__, ntohl(status));
+	dprintk("%s: done, status = %d\n", __func__, ntohl(status));
 	return status;
 }
 
@@ -401,37 +401,37 @@ static __be32 process_op(struct svc_rqst *rqstp,
  */
 static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *resp)
 {
-	struct cb_compound_hdr_arg hdr_arg;
-	struct cb_compound_hdr_res hdr_res;
+	struct cb_compound_hdr_arg hdr_arg = { 0 };
+	struct cb_compound_hdr_res hdr_res = { NULL };
 	struct xdr_stream xdr_in, xdr_out;
 	__be32 *p;
 	__be32 status;
-	unsigned int nops = 1;
+	unsigned int nops = 0;
 
-	dprintk("%s: start\n", __FUNCTION__);
+	dprintk("%s: start\n", __func__);
 
 	xdr_init_decode(&xdr_in, &rqstp->rq_arg, rqstp->rq_arg.head[0].iov_base);
 
 	p = (__be32*)((char *)rqstp->rq_res.head[0].iov_base + rqstp->rq_res.head[0].iov_len);
 	xdr_init_encode(&xdr_out, &rqstp->rq_res, p);
 
-	decode_compound_hdr_arg(&xdr_in, &hdr_arg);
+	status = decode_compound_hdr_arg(&xdr_in, &hdr_arg);
+	if (status == __constant_htonl(NFS4ERR_RESOURCE))
+		return rpc_garbage_args;
+
 	hdr_res.taglen = hdr_arg.taglen;
 	hdr_res.tag = hdr_arg.tag;
-	hdr_res.nops = NULL;
-	encode_compound_hdr_res(&xdr_out, &hdr_res);
+	if (encode_compound_hdr_res(&xdr_out, &hdr_res) != 0)
+		return rpc_system_err;
 
-	for (;;) {
+	while (status == 0 && nops != hdr_arg.nops) {
 		status = process_op(rqstp, &xdr_in, argp, &xdr_out, resp);
-		if (status != 0)
-			break;
-		if (nops == hdr_arg.nops)
-			break;
 		nops++;
 	}
+
 	*hdr_res.status = status;
 	*hdr_res.nops = htonl(nops);
-	dprintk("%s: done, status = %u\n", __FUNCTION__, ntohl(status));
+	dprintk("%s: done, status = %u\n", __func__, ntohl(status));
 	return rpc_success;
 }
 
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 89ac5bb..f2a092c 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -488,7 +488,7 @@ static int nfs_create_rpc_client(struct nfs_client *clp,
 	clnt = rpc_create(&args);
 	if (IS_ERR(clnt)) {
 		dprintk("%s: cannot create RPC client. Error = %ld\n",
-				__FUNCTION__, PTR_ERR(clnt));
+				__func__, PTR_ERR(clnt));
 		return PTR_ERR(clnt);
 	}
 
@@ -576,7 +576,7 @@ static int nfs_init_server_rpcclient(struct nfs_server *server,
 
 	server->client = rpc_clone_client(clp->cl_rpcclient);
 	if (IS_ERR(server->client)) {
-		dprintk("%s: couldn't create rpc_client!\n", __FUNCTION__);
+		dprintk("%s: couldn't create rpc_client!\n", __func__);
 		return PTR_ERR(server->client);
 	}
 
@@ -590,7 +590,7 @@ static int nfs_init_server_rpcclient(struct nfs_server *server,
 
 		auth = rpcauth_create(pseudoflavour, server->client);
 		if (IS_ERR(auth)) {
-			dprintk("%s: couldn't create credcache!\n", __FUNCTION__);
+			dprintk("%s: couldn't create credcache!\n", __func__);
 			return PTR_ERR(auth);
 		}
 	}
@@ -985,7 +985,7 @@ static int nfs4_init_client(struct nfs_client *clp,
 	error = nfs_idmap_new(clp);
 	if (error < 0) {
 		dprintk("%s: failed to create idmapper. Error = %d\n",
-			__FUNCTION__, error);
+			__func__, error);
 		goto error;
 	}
 	__set_bit(NFS_CS_IDMAP, &clp->cl_res_state);
diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 00a5e44..cc563cf 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -60,7 +60,7 @@ static int nfs_delegation_claim_locks(struct nfs_open_context *ctx, struct nfs4_
 		switch (status) {
 			default:
 				printk(KERN_ERR "%s: unhandled error %d.\n",
-						__FUNCTION__, status);
+						__func__, status);
 			case -NFS4ERR_EXPIRED:
 				/* kill_proc(fl->fl_pid, SIGLOST, 1); */
 			case -NFS4ERR_STALE_CLIENTID:
@@ -186,7 +186,7 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 		 */
 		dfprintk(FILE, "%s: server %s handed out "
 				"a duplicate delegation!\n",
-				__FUNCTION__, clp->cl_hostname);
+				__func__, clp->cl_hostname);
 		if (delegation->type <= nfsi->delegation->type) {
 			freeme = delegation;
 			delegation = NULL;
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index f288b3e..58d43da 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -180,7 +180,7 @@ int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page *page)
 	int		error;
 
 	dfprintk(DIRCACHE, "NFS: %s: reading cookie %Lu into page %lu\n",
-			__FUNCTION__, (long long)desc->entry->cookie,
+			__func__, (long long)desc->entry->cookie,
 			page->index);
 
  again:
@@ -256,7 +256,7 @@ int find_dirent(nfs_readdir_descriptor_t *desc)
 
 	while((status = dir_decode(desc)) == 0) {
 		dfprintk(DIRCACHE, "NFS: %s: examining cookie %Lu\n",
-				__FUNCTION__, (unsigned long long)entry->cookie);
+				__func__, (unsigned long long)entry->cookie);
 		if (entry->prev_cookie == *desc->dir_cookie)
 			break;
 		if (loop_count++ > 200) {
@@ -315,7 +315,7 @@ int find_dirent_page(nfs_readdir_descriptor_t *desc)
 	int		status;
 
 	dfprintk(DIRCACHE, "NFS: %s: searching page %ld for target %Lu\n",
-			__FUNCTION__, desc->page_index,
+			__func__, desc->page_index,
 			(long long) *desc->dir_cookie);
 
 	/* If we find the page in the page_cache, we cannot be sure
@@ -339,7 +339,7 @@ int find_dirent_page(nfs_readdir_descriptor_t *desc)
 	if (status < 0)
 		dir_page_release(desc);
  out:
-	dfprintk(DIRCACHE, "NFS: %s: returns %d\n", __FUNCTION__, status);
+	dfprintk(DIRCACHE, "NFS: %s: returns %d\n", __func__, status);
 	return status;
 }
 
@@ -380,7 +380,7 @@ int readdir_search_pagecache(nfs_readdir_descriptor_t *desc)
 		}
 	}
 
-	dfprintk(DIRCACHE, "NFS: %s: returns %d\n", __FUNCTION__, res);
+	dfprintk(DIRCACHE, "NFS: %s: returns %d\n", __func__, res);
 	return res;
 }
 
@@ -506,7 +506,7 @@ int uncached_readdir(nfs_readdir_descriptor_t *desc, void *dirent,
 	desc->entry->eof = 0;
  out:
 	dfprintk(DIRCACHE, "NFS: %s: returns %d\n",
-			__FUNCTION__, status);
+			__func__, status);
 	return status;
  out_release:
 	dir_page_release(desc);
@@ -780,7 +780,7 @@ static int nfs_lookup_revalidate(struct dentry * dentry, struct nameidata *nd)
 
 	if (is_bad_inode(inode)) {
 		dfprintk(LOOKUPCACHE, "%s: %s/%s has dud inode\n",
-				__FUNCTION__, dentry->d_parent->d_name.name,
+				__func__, dentry->d_parent->d_name.name,
 				dentry->d_name.name);
 		goto out_bad;
 	}
@@ -808,7 +808,7 @@ static int nfs_lookup_revalidate(struct dentry * dentry, struct nameidata *nd)
 	unlock_kernel();
 	dput(parent);
 	dfprintk(LOOKUPCACHE, "NFS: %s(%s/%s) is valid\n",
-			__FUNCTION__, dentry->d_parent->d_name.name,
+			__func__, dentry->d_parent->d_name.name,
 			dentry->d_name.name);
 	return 1;
 out_zap_parent:
@@ -827,7 +827,7 @@ out_zap_parent:
 	unlock_kernel();
 	dput(parent);
 	dfprintk(LOOKUPCACHE, "NFS: %s(%s/%s) is invalid\n",
-			__FUNCTION__, dentry->d_parent->d_name.name,
+			__func__, dentry->d_parent->d_name.name,
 			dentry->d_name.name);
 	return 0;
 }
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 3536b01..d84a3d8 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -526,7 +526,7 @@ static int do_vfs_lock(struct file *file, struct file_lock *fl)
 	if (res < 0)
 		dprintk(KERN_WARNING "%s: VFS is out of sync with lock manager"
 			" - error %d!\n",
-				__FUNCTION__, res);
+				__func__, res);
 	return res;
 }
 
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 5cb3345..596c5d8 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -541,8 +541,7 @@ static void __put_nfs_open_context(struct nfs_open_context *ctx, int wait)
 	}
 	if (ctx->cred != NULL)
 		put_rpccred(ctx->cred);
-	dput(ctx->path.dentry);
-	mntput(ctx->path.mnt);
+	path_put(&ctx->path);
 	kfree(ctx);
 }
 
@@ -707,6 +706,13 @@ int nfs_attribute_timeout(struct inode *inode)
 
 	if (nfs_have_delegation(inode, FMODE_READ))
 		return 0;
+	/*
+	 * Special case: if the attribute timeout is set to 0, then always
+	 * 		 treat the cache as having expired (unless holding
+	 * 		 a delegation).
+	 */
+	if (nfsi->attrtimeo == 0)
+		return 1;
 	return !time_in_range(jiffies, nfsi->read_cache_jiffies, nfsi->read_cache_jiffies + nfsi->attrtimeo);
 }
 
@@ -995,7 +1001,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	unsigned long now = jiffies;
 
 	dfprintk(VFS, "NFS: %s(%s/%ld ct=%d info=0x%x)\n",
-			__FUNCTION__, inode->i_sb->s_id, inode->i_ino,
+			__func__, inode->i_sb->s_id, inode->i_ino,
 			atomic_read(&inode->i_count), fattr->valid);
 
 	if (nfsi->fileid != fattr->fileid)
@@ -1119,7 +1125,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	 * Big trouble! The inode has become a different object.
 	 */
 	printk(KERN_DEBUG "%s: inode %ld mode changed, %07o to %07o\n",
-			__FUNCTION__, inode->i_ino, inode->i_mode, fattr->mode);
+			__func__, inode->i_ino, inode->i_mode, fattr->mode);
  out_err:
 	/*
 	 * No need to worry about unhashing the dentry, as the
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index af4d0f1..2f285ef 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -106,7 +106,7 @@ static void * nfs_follow_mountpoint(struct dentry *dentry, struct nameidata *nd)
 	dprintk("--> nfs_follow_mountpoint()\n");
 
 	BUG_ON(IS_ROOT(dentry));
-	dprintk("%s: enter\n", __FUNCTION__);
+	dprintk("%s: enter\n", __func__);
 	dput(nd->path.dentry);
 	nd->path.dentry = dget(dentry);
 
@@ -137,13 +137,12 @@ static void * nfs_follow_mountpoint(struct dentry *dentry, struct nameidata *nd)
 			goto out_follow;
 		goto out_err;
 	}
-	mntput(nd->path.mnt);
-	dput(nd->path.dentry);
+	path_put(&nd->path);
 	nd->path.mnt = mnt;
 	nd->path.dentry = dget(mnt->mnt_root);
 	schedule_delayed_work(&nfs_automount_task, nfs_mountpoint_expiry_timeout);
 out:
-	dprintk("%s: done, returned %d\n", __FUNCTION__, err);
+	dprintk("%s: done, returned %d\n", __func__, err);
 
 	dprintk("<-- nfs_follow_mountpoint() = %d\n", err);
 	return ERR_PTR(err);
@@ -230,7 +229,7 @@ static struct vfsmount *nfs_do_submount(const struct vfsmount *mnt_parent,
 
 	dprintk("--> nfs_do_submount()\n");
 
-	dprintk("%s: submounting on %s/%s\n", __FUNCTION__,
+	dprintk("%s: submounting on %s/%s\n", __func__,
 			dentry->d_parent->d_name.name,
 			dentry->d_name.name);
 	if (page == NULL)
@@ -243,7 +242,7 @@ static struct vfsmount *nfs_do_submount(const struct vfsmount *mnt_parent,
 free_page:
 	free_page((unsigned long)page);
 out:
-	dprintk("%s: done\n", __FUNCTION__);
+	dprintk("%s: done\n", __func__);
 
 	dprintk("<-- nfs_do_submount() = %p\n", mnt);
 	return mnt;
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 549dbce..c3523ad 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -63,15 +63,15 @@ do_proc_get_root(struct rpc_clnt *client, struct nfs_fh *fhandle,
 	};
 	int	status;
 
-	dprintk("%s: call  fsinfo\n", __FUNCTION__);
+	dprintk("%s: call  fsinfo\n", __func__);
 	nfs_fattr_init(info->fattr);
 	status = rpc_call_sync(client, &msg, 0);
-	dprintk("%s: reply fsinfo: %d\n", __FUNCTION__, status);
+	dprintk("%s: reply fsinfo: %d\n", __func__, status);
 	if (!(info->fattr->valid & NFS_ATTR_FATTR)) {
 		msg.rpc_proc = &nfs3_procedures[NFS3PROC_GETATTR];
 		msg.rpc_resp = info->fattr;
 		status = rpc_call_sync(client, &msg, 0);
-		dprintk("%s: reply getattr: %d\n", __FUNCTION__, status);
+		dprintk("%s: reply getattr: %d\n", __func__, status);
 	}
 	return status;
 }
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index bd1b9d6..ea79064 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -206,7 +206,6 @@ struct rpc_cred *nfs4_get_renew_cred(struct nfs_client *clp);
 
 extern struct nfs4_state_owner * nfs4_get_state_owner(struct nfs_server *, struct rpc_cred *);
 extern void nfs4_put_state_owner(struct nfs4_state_owner *);
-extern void nfs4_drop_state_owner(struct nfs4_state_owner *);
 extern struct nfs4_state * nfs4_get_open_state(struct inode *, struct nfs4_state_owner *);
 extern void nfs4_put_open_state(struct nfs4_state *);
 extern void nfs4_close_state(struct path *, struct nfs4_state *, mode_t);
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 5f9ba41..b112857 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -86,7 +86,7 @@ static int nfs4_validate_fspath(const struct vfsmount *mnt_parent,
 
 	if (strncmp(path, fs_path, strlen(fs_path)) != 0) {
 		dprintk("%s: path %s does not begin with fsroot %s\n",
-			__FUNCTION__, path, fs_path);
+			__func__, path, fs_path);
 		return -ENOENT;
 	}
 
@@ -134,7 +134,7 @@ static struct vfsmount *nfs_follow_referral(const struct vfsmount *mnt_parent,
 	if (locations == NULL || locations->nlocations <= 0)
 		goto out;
 
-	dprintk("%s: referral at %s/%s\n", __FUNCTION__,
+	dprintk("%s: referral at %s/%s\n", __func__,
 		dentry->d_parent->d_name.name, dentry->d_name.name);
 
 	page = (char *) __get_free_page(GFP_USER);
@@ -204,7 +204,7 @@ static struct vfsmount *nfs_follow_referral(const struct vfsmount *mnt_parent,
 out:
 	free_page((unsigned long) page);
 	free_page((unsigned long) page2);
-	dprintk("%s: done\n", __FUNCTION__);
+	dprintk("%s: done\n", __func__);
 	return mnt;
 }
 
@@ -223,7 +223,7 @@ struct vfsmount *nfs_do_refmount(const struct vfsmount *mnt_parent, struct dentr
 	int err;
 
 	/* BUG_ON(IS_ROOT(dentry)); */
-	dprintk("%s: enter\n", __FUNCTION__);
+	dprintk("%s: enter\n", __func__);
 
 	page = alloc_page(GFP_KERNEL);
 	if (page == NULL)
@@ -238,7 +238,7 @@ struct vfsmount *nfs_do_refmount(const struct vfsmount *mnt_parent, struct dentr
 
 	parent = dget_parent(dentry);
 	dprintk("%s: getting locations for %s/%s\n",
-		__FUNCTION__, parent->d_name.name, dentry->d_name.name);
+		__func__, parent->d_name.name, dentry->d_name.name);
 
 	err = nfs4_proc_fs_locations(parent->d_inode, &dentry->d_name, fs_locations, page);
 	dput(parent);
@@ -252,6 +252,6 @@ out_free:
 	__free_page(page);
 	kfree(fs_locations);
 out:
-	dprintk("%s: done\n", __FUNCTION__);
+	dprintk("%s: done\n", __func__);
 	return mnt;
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index dbc0927..1293e0a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -73,7 +73,7 @@ int nfs4_map_errors(int err)
 {
 	if (err < -1000) {
 		dprintk("%s could not handle NFSv4 error %d\n",
-				__FUNCTION__, -err);
+				__func__, -err);
 		return -EIO;
 	}
 	return err;
@@ -306,8 +306,7 @@ static void nfs4_opendata_free(struct kref *kref)
 		nfs4_put_open_state(p->state);
 	nfs4_put_state_owner(p->owner);
 	dput(p->dir);
-	dput(p->path.dentry);
-	mntput(p->path.mnt);
+	path_put(&p->path);
 	kfree(p);
 }
 
@@ -1210,8 +1209,7 @@ static void nfs4_free_closedata(void *data)
 	nfs4_put_open_state(calldata->state);
 	nfs_free_seqid(calldata->arg.seqid);
 	nfs4_put_state_owner(sp);
-	dput(calldata->path.dentry);
-	mntput(calldata->path.mnt);
+	path_put(&calldata->path);
 	kfree(calldata);
 }
 
@@ -1578,7 +1576,7 @@ static int nfs4_get_referral(struct inode *dir, const struct qstr *name, struct
 		goto out;
 	/* Make sure server returned a different fsid for the referral */
 	if (nfs_fsid_equal(&NFS_SERVER(dir)->fsid, &locations->fattr.fsid)) {
-		dprintk("%s: server did not return a different fsid for a referral at %s\n", __FUNCTION__, name->name);
+		dprintk("%s: server did not return a different fsid for a referral at %s\n", __func__, name->name);
 		status = -EIO;
 		goto out;
 	}
@@ -2211,7 +2209,7 @@ static int _nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 	};
 	int			status;
 
-	dprintk("%s: dentry = %s/%s, cookie = %Lu\n", __FUNCTION__,
+	dprintk("%s: dentry = %s/%s, cookie = %Lu\n", __func__,
 			dentry->d_parent->d_name.name,
 			dentry->d_name.name,
 			(unsigned long long)cookie);
@@ -2223,7 +2221,7 @@ static int _nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 
 	nfs_invalidate_atime(dir);
 
-	dprintk("%s: returns %d\n", __FUNCTION__, status);
+	dprintk("%s: returns %d\n", __func__, status);
 	return status;
 }
 
@@ -3342,7 +3340,7 @@ static void nfs4_lock_prepare(struct rpc_task *task, void *calldata)
 	struct nfs4_lockdata *data = calldata;
 	struct nfs4_state *state = data->lsp->ls_state;
 
-	dprintk("%s: begin!\n", __FUNCTION__);
+	dprintk("%s: begin!\n", __func__);
 	if (nfs_wait_on_sequence(data->arg.lock_seqid, task) != 0)
 		return;
 	/* Do we need to do an open_to_lock_owner? */
@@ -3356,14 +3354,14 @@ static void nfs4_lock_prepare(struct rpc_task *task, void *calldata)
 		data->arg.new_lock_owner = 0;
 	data->timestamp = jiffies;
 	rpc_call_start(task);
-	dprintk("%s: done!, ret = %d\n", __FUNCTION__, data->rpc_status);
+	dprintk("%s: done!, ret = %d\n", __func__, data->rpc_status);
 }
 
 static void nfs4_lock_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_lockdata *data = calldata;
 
-	dprintk("%s: begin!\n", __FUNCTION__);
+	dprintk("%s: begin!\n", __func__);
 
 	data->rpc_status = task->tk_status;
 	if (RPC_ASSASSINATED(task))
@@ -3381,14 +3379,14 @@ static void nfs4_lock_done(struct rpc_task *task, void *calldata)
 		renew_lease(NFS_SERVER(data->ctx->path.dentry->d_inode), data->timestamp);
 	}
 out:
-	dprintk("%s: done, ret = %d!\n", __FUNCTION__, data->rpc_status);
+	dprintk("%s: done, ret = %d!\n", __func__, data->rpc_status);
 }
 
 static void nfs4_lock_release(void *calldata)
 {
 	struct nfs4_lockdata *data = calldata;
 
-	dprintk("%s: begin!\n", __FUNCTION__);
+	dprintk("%s: begin!\n", __func__);
 	nfs_free_seqid(data->arg.open_seqid);
 	if (data->cancelled != 0) {
 		struct rpc_task *task;
@@ -3396,13 +3394,13 @@ static void nfs4_lock_release(void *calldata)
 				data->arg.lock_seqid);
 		if (!IS_ERR(task))
 			rpc_put_task(task);
-		dprintk("%s: cancelling lock!\n", __FUNCTION__);
+		dprintk("%s: cancelling lock!\n", __func__);
 	} else
 		nfs_free_seqid(data->arg.lock_seqid);
 	nfs4_put_lock_state(data->lsp);
 	put_nfs_open_context(data->ctx);
 	kfree(data);
-	dprintk("%s: done!\n", __FUNCTION__);
+	dprintk("%s: done!\n", __func__);
 }
 
 static const struct rpc_call_ops nfs4_lock_ops = {
@@ -3428,7 +3426,7 @@ static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *f
 	};
 	int ret;
 
-	dprintk("%s: begin!\n", __FUNCTION__);
+	dprintk("%s: begin!\n", __func__);
 	data = nfs4_alloc_lockdata(fl, nfs_file_open_context(fl->fl_file),
 			fl->fl_u.nfs4_fl.owner);
 	if (data == NULL)
@@ -3451,7 +3449,7 @@ static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *f
 	} else
 		data->cancelled = 1;
 	rpc_put_task(task);
-	dprintk("%s: done, ret = %d!\n", __FUNCTION__, ret);
+	dprintk("%s: done, ret = %d!\n", __func__, ret);
 	return ret;
 }
 
@@ -3527,7 +3525,7 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
 	/* Note: we always want to sleep here! */
 	request->fl_flags = fl_flags | FL_SLEEP;
 	if (do_vfs_lock(request->fl_file, request) < 0)
-		printk(KERN_WARNING "%s: VFS is out of sync with lock manager!\n", __FUNCTION__);
+		printk(KERN_WARNING "%s: VFS is out of sync with lock manager!\n", __func__);
 out_unlock:
 	up_read(&clp->cl_sem);
 out:
@@ -3665,12 +3663,12 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 	};
 	int status;
 
-	dprintk("%s: start\n", __FUNCTION__);
+	dprintk("%s: start\n", __func__);
 	nfs_fattr_init(&fs_locations->fattr);
 	fs_locations->server = server;
 	fs_locations->nlocations = 0;
 	status = rpc_call_sync(server->client, &msg, 0);
-	dprintk("%s: returned status = %d\n", __FUNCTION__, status);
+	dprintk("%s: returned status = %d\n", __func__, status);
 	return status;
 }
 
diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index 5e2e4af..3305acb 100644
--- a/fs/nfs/nfs4renewd.c
+++ b/fs/nfs/nfs4renewd.c
@@ -66,7 +66,7 @@ nfs4_renew_state(struct work_struct *work)
 	unsigned long last, now;
 
 	down_read(&clp->cl_sem);
-	dprintk("%s: start\n", __FUNCTION__);
+	dprintk("%s: start\n", __func__);
 	/* Are there any active superblocks? */
 	if (list_empty(&clp->cl_superblocks))
 		goto out;
@@ -92,17 +92,17 @@ nfs4_renew_state(struct work_struct *work)
 		spin_lock(&clp->cl_lock);
 	} else
 		dprintk("%s: failed to call renewd. Reason: lease not expired \n",
-				__FUNCTION__);
+				__func__);
 	if (timeout < 5 * HZ)    /* safeguard */
 		timeout = 5 * HZ;
 	dprintk("%s: requeueing work. Lease period = %ld\n",
-			__FUNCTION__, (timeout + HZ - 1) / HZ);
+			__func__, (timeout + HZ - 1) / HZ);
 	cancel_delayed_work(&clp->cl_renewd);
 	schedule_delayed_work(&clp->cl_renewd, timeout);
 	spin_unlock(&clp->cl_lock);
 out:
 	up_read(&clp->cl_sem);
-	dprintk("%s: done\n", __FUNCTION__);
+	dprintk("%s: done\n", __func__);
 }
 
 /* Must be called with clp->cl_sem locked for writes */
@@ -117,7 +117,7 @@ nfs4_schedule_state_renewal(struct nfs_client *clp)
 	if (timeout < 5 * HZ)
 		timeout = 5 * HZ;
 	dprintk("%s: requeueing work. Lease period = %ld\n",
-			__FUNCTION__, (timeout + HZ - 1) / HZ);
+			__func__, (timeout + HZ - 1) / HZ);
 	cancel_delayed_work(&clp->cl_renewd);
 	schedule_delayed_work(&clp->cl_renewd, timeout);
 	set_bit(NFS_CS_RENEWD, &clp->cl_res_state);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 46eb624..856a893 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -282,7 +282,7 @@ nfs4_alloc_state_owner(void)
 	return sp;
 }
 
-void
+static void
 nfs4_drop_state_owner(struct nfs4_state_owner *sp)
 {
 	if (!RB_EMPTY_NODE(&sp->so_client_node)) {
@@ -828,7 +828,7 @@ static int nfs4_reclaim_locks(struct nfs4_state_recovery_ops *ops, struct nfs4_s
 		switch (status) {
 			default:
 				printk(KERN_ERR "%s: unhandled error %d. Zeroing state\n",
-						__FUNCTION__, status);
+						__func__, status);
 			case -NFS4ERR_EXPIRED:
 			case -NFS4ERR_NO_GRACE:
 			case -NFS4ERR_RECLAIM_BAD:
@@ -869,14 +869,14 @@ static int nfs4_reclaim_open_state(struct nfs4_state_recovery_ops *ops, struct n
 			list_for_each_entry(lock, &state->lock_states, ls_locks) {
 				if (!(lock->ls_flags & NFS_LOCK_INITIALIZED))
 					printk("%s: Lock reclaim failed!\n",
-							__FUNCTION__);
+							__func__);
 			}
 			continue;
 		}
 		switch (status) {
 			default:
 				printk(KERN_ERR "%s: unhandled error %d. Zeroing state\n",
-						__FUNCTION__, status);
+						__func__, status);
 			case -ENOENT:
 			case -NFS4ERR_RECLAIM_BAD:
 			case -NFS4ERR_RECLAIM_CONFLICT:
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 5a2d649..b916297 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1831,7 +1831,7 @@ static int nfs4_xdr_enc_readdir(struct rpc_rqst *req, __be32 *p, const struct nf
 	xdr_inline_pages(&req->rq_rcv_buf, replen, args->pages,
 			 args->pgbase, args->count);
 	dprintk("%s: inlined page args = (%u, %p, %u, %u)\n",
-			__FUNCTION__, replen, args->pages,
+			__func__, replen, args->pages,
 			args->pgbase, args->count);
 
 out:
@@ -2192,9 +2192,9 @@ out:
 	p = xdr_inline_decode(xdr, nbytes); \
 	if (unlikely(!p)) { \
 		dprintk("nfs: %s: prematurely hit end of receive" \
-				" buffer\n", __FUNCTION__); \
+				" buffer\n", __func__); \
 		dprintk("nfs: %s: xdr->p=%p, bytes=%u, xdr->end=%p\n", \
-				__FUNCTION__, xdr->p, nbytes, xdr->end); \
+				__func__, xdr->p, nbytes, xdr->end); \
 		return -EIO; \
 	} \
 } while (0)
@@ -2306,12 +2306,12 @@ static int decode_attr_type(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *
 		READ_BUF(4);
 		READ32(*type);
 		if (*type < NF4REG || *type > NF4NAMEDATTR) {
-			dprintk("%s: bad type %d\n", __FUNCTION__, *type);
+			dprintk("%s: bad type %d\n", __func__, *type);
 			return -EIO;
 		}
 		bitmap[0] &= ~FATTR4_WORD0_TYPE;
 	}
-	dprintk("%s: type=0%o\n", __FUNCTION__, nfs_type2fmt[*type].nfs2type);
+	dprintk("%s: type=0%o\n", __func__, nfs_type2fmt[*type].nfs2type);
 	return 0;
 }
 
@@ -2327,7 +2327,7 @@ static int decode_attr_change(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t
 		READ64(*change);
 		bitmap[0] &= ~FATTR4_WORD0_CHANGE;
 	}
-	dprintk("%s: change attribute=%Lu\n", __FUNCTION__,
+	dprintk("%s: change attribute=%Lu\n", __func__,
 			(unsigned long long)*change);
 	return 0;
 }
@@ -2344,7 +2344,7 @@ static int decode_attr_size(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t *
 		READ64(*size);
 		bitmap[0] &= ~FATTR4_WORD0_SIZE;
 	}
-	dprintk("%s: file size=%Lu\n", __FUNCTION__, (unsigned long long)*size);
+	dprintk("%s: file size=%Lu\n", __func__, (unsigned long long)*size);
 	return 0;
 }
 
@@ -2360,7 +2360,7 @@ static int decode_attr_link_support(struct xdr_stream *xdr, uint32_t *bitmap, ui
 		READ32(*res);
 		bitmap[0] &= ~FATTR4_WORD0_LINK_SUPPORT;
 	}
-	dprintk("%s: link support=%s\n", __FUNCTION__, *res == 0 ? "false" : "true");
+	dprintk("%s: link support=%s\n", __func__, *res == 0 ? "false" : "true");
 	return 0;
 }
 
@@ -2376,7 +2376,7 @@ static int decode_attr_symlink_support(struct xdr_stream *xdr, uint32_t *bitmap,
 		READ32(*res);
 		bitmap[0] &= ~FATTR4_WORD0_SYMLINK_SUPPORT;
 	}
-	dprintk("%s: symlink support=%s\n", __FUNCTION__, *res == 0 ? "false" : "true");
+	dprintk("%s: symlink support=%s\n", __func__, *res == 0 ? "false" : "true");
 	return 0;
 }
 
@@ -2394,7 +2394,7 @@ static int decode_attr_fsid(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs
 		READ64(fsid->minor);
 		bitmap[0] &= ~FATTR4_WORD0_FSID;
 	}
-	dprintk("%s: fsid=(0x%Lx/0x%Lx)\n", __FUNCTION__,
+	dprintk("%s: fsid=(0x%Lx/0x%Lx)\n", __func__,
 			(unsigned long long)fsid->major,
 			(unsigned long long)fsid->minor);
 	return 0;
@@ -2412,7 +2412,7 @@ static int decode_attr_lease_time(struct xdr_stream *xdr, uint32_t *bitmap, uint
 		READ32(*res);
 		bitmap[0] &= ~FATTR4_WORD0_LEASE_TIME;
 	}
-	dprintk("%s: file size=%u\n", __FUNCTION__, (unsigned int)*res);
+	dprintk("%s: file size=%u\n", __func__, (unsigned int)*res);
 	return 0;
 }
 
@@ -2428,7 +2428,7 @@ static int decode_attr_aclsupport(struct xdr_stream *xdr, uint32_t *bitmap, uint
 		READ32(*res);
 		bitmap[0] &= ~FATTR4_WORD0_ACLSUPPORT;
 	}
-	dprintk("%s: ACLs supported=%u\n", __FUNCTION__, (unsigned int)*res);
+	dprintk("%s: ACLs supported=%u\n", __func__, (unsigned int)*res);
 	return 0;
 }
 
@@ -2444,7 +2444,7 @@ static int decode_attr_fileid(struct xdr_stream *xdr, uint32_t *bitmap, uint64_t
 		READ64(*fileid);
 		bitmap[0] &= ~FATTR4_WORD0_FILEID;
 	}
-	dprintk("%s: fileid=%Lu\n", __FUNCTION__, (unsigned long long)*fileid);
+	dprintk("%s: fileid=%Lu\n", __func__, (unsigned long long)*fileid);
 	return 0;
 }
 
@@ -2460,7 +2460,7 @@ static int decode_attr_mounted_on_fileid(struct xdr_stream *xdr, uint32_t *bitma
 		READ64(*fileid);
 		bitmap[1] &= ~FATTR4_WORD1_MOUNTED_ON_FILEID;
 	}
-	dprintk("%s: fileid=%Lu\n", __FUNCTION__, (unsigned long long)*fileid);
+	dprintk("%s: fileid=%Lu\n", __func__, (unsigned long long)*fileid);
 	return 0;
 }
 
@@ -2477,7 +2477,7 @@ static int decode_attr_files_avail(struct xdr_stream *xdr, uint32_t *bitmap, uin
 		READ64(*res);
 		bitmap[0] &= ~FATTR4_WORD0_FILES_AVAIL;
 	}
-	dprintk("%s: files avail=%Lu\n", __FUNCTION__, (unsigned long long)*res);
+	dprintk("%s: files avail=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
 }
 
@@ -2494,7 +2494,7 @@ static int decode_attr_files_free(struct xdr_stream *xdr, uint32_t *bitmap, uint
 		READ64(*res);
 		bitmap[0] &= ~FATTR4_WORD0_FILES_FREE;
 	}
-	dprintk("%s: files free=%Lu\n", __FUNCTION__, (unsigned long long)*res);
+	dprintk("%s: files free=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
 }
 
@@ -2511,7 +2511,7 @@ static int decode_attr_files_total(struct xdr_stream *xdr, uint32_t *bitmap, uin
 		READ64(*res);
 		bitmap[0] &= ~FATTR4_WORD0_FILES_TOTAL;
 	}
-	dprintk("%s: files total=%Lu\n", __FUNCTION__, (unsigned long long)*res);
+	dprintk("%s: files total=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
 }
 
@@ -2569,7 +2569,7 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 	status = 0;
 	if (unlikely(!(bitmap[0] & FATTR4_WORD0_FS_LOCATIONS)))
 		goto out;
-	dprintk("%s: fsroot ", __FUNCTION__);
+	dprintk("%s: fsroot ", __func__);
 	status = decode_pathname(xdr, &res->fs_path);
 	if (unlikely(status != 0))
 		goto out;
@@ -2586,7 +2586,7 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 		READ32(m);
 
 		loc->nservers = 0;
-		dprintk("%s: servers ", __FUNCTION__);
+		dprintk("%s: servers ", __func__);
 		while (loc->nservers < m) {
 			struct nfs4_string *server = &loc->servers[loc->nservers];
 			status = decode_opaque_inline(xdr, &server->len, &server->data);
@@ -2599,7 +2599,7 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 				unsigned int i;
 				dprintk("%s: using first %u of %u servers "
 					"returned for location %u\n",
-						__FUNCTION__,
+						__func__,
 						NFS4_FS_LOCATION_MAXSERVERS,
 						m, res->nlocations);
 				for (i = loc->nservers; i < m; i++) {
@@ -2618,7 +2618,7 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 			res->nlocations++;
 	}
 out:
-	dprintk("%s: fs_locations done, error = %d\n", __FUNCTION__, status);
+	dprintk("%s: fs_locations done, error = %d\n", __func__, status);
 	return status;
 out_eio:
 	status = -EIO;
@@ -2638,7 +2638,7 @@ static int decode_attr_maxfilesize(struct xdr_stream *xdr, uint32_t *bitmap, uin
 		READ64(*res);
 		bitmap[0] &= ~FATTR4_WORD0_MAXFILESIZE;
 	}
-	dprintk("%s: maxfilesize=%Lu\n", __FUNCTION__, (unsigned long long)*res);
+	dprintk("%s: maxfilesize=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
 }
 
@@ -2655,7 +2655,7 @@ static int decode_attr_maxlink(struct xdr_stream *xdr, uint32_t *bitmap, uint32_
 		READ32(*maxlink);
 		bitmap[0] &= ~FATTR4_WORD0_MAXLINK;
 	}
-	dprintk("%s: maxlink=%u\n", __FUNCTION__, *maxlink);
+	dprintk("%s: maxlink=%u\n", __func__, *maxlink);
 	return status;
 }
 
@@ -2672,7 +2672,7 @@ static int decode_attr_maxname(struct xdr_stream *xdr, uint32_t *bitmap, uint32_
 		READ32(*maxname);
 		bitmap[0] &= ~FATTR4_WORD0_MAXNAME;
 	}
-	dprintk("%s: maxname=%u\n", __FUNCTION__, *maxname);
+	dprintk("%s: maxname=%u\n", __func__, *maxname);
 	return status;
 }
 
@@ -2693,7 +2693,7 @@ static int decode_attr_maxread(struct xdr_stream *xdr, uint32_t *bitmap, uint32_
 		*res = (uint32_t)maxread;
 		bitmap[0] &= ~FATTR4_WORD0_MAXREAD;
 	}
-	dprintk("%s: maxread=%lu\n", __FUNCTION__, (unsigned long)*res);
+	dprintk("%s: maxread=%lu\n", __func__, (unsigned long)*res);
 	return status;
 }
 
@@ -2714,7 +2714,7 @@ static int decode_attr_maxwrite(struct xdr_stream *xdr, uint32_t *bitmap, uint32
 		*res = (uint32_t)maxwrite;
 		bitmap[0] &= ~FATTR4_WORD0_MAXWRITE;
 	}
-	dprintk("%s: maxwrite=%lu\n", __FUNCTION__, (unsigned long)*res);
+	dprintk("%s: maxwrite=%lu\n", __func__, (unsigned long)*res);
 	return status;
 }
 
@@ -2731,7 +2731,7 @@ static int decode_attr_mode(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *
 		*mode &= ~S_IFMT;
 		bitmap[1] &= ~FATTR4_WORD1_MODE;
 	}
-	dprintk("%s: file mode=0%o\n", __FUNCTION__, (unsigned int)*mode);
+	dprintk("%s: file mode=0%o\n", __func__, (unsigned int)*mode);
 	return 0;
 }
 
@@ -2747,7 +2747,7 @@ static int decode_attr_nlink(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t
 		READ32(*nlink);
 		bitmap[1] &= ~FATTR4_WORD1_NUMLINKS;
 	}
-	dprintk("%s: nlink=%u\n", __FUNCTION__, (unsigned int)*nlink);
+	dprintk("%s: nlink=%u\n", __func__, (unsigned int)*nlink);
 	return 0;
 }
 
@@ -2766,13 +2766,13 @@ static int decode_attr_owner(struct xdr_stream *xdr, uint32_t *bitmap, struct nf
 		if (len < XDR_MAX_NETOBJ) {
 			if (nfs_map_name_to_uid(clp, (char *)p, len, uid) != 0)
 				dprintk("%s: nfs_map_name_to_uid failed!\n",
-						__FUNCTION__);
+						__func__);
 		} else
 			dprintk("%s: name too long (%u)!\n",
-					__FUNCTION__, len);
+					__func__, len);
 		bitmap[1] &= ~FATTR4_WORD1_OWNER;
 	}
-	dprintk("%s: uid=%d\n", __FUNCTION__, (int)*uid);
+	dprintk("%s: uid=%d\n", __func__, (int)*uid);
 	return 0;
 }
 
@@ -2791,13 +2791,13 @@ static int decode_attr_group(struct xdr_stream *xdr, uint32_t *bitmap, struct nf
 		if (len < XDR_MAX_NETOBJ) {
 			if (nfs_map_group_to_gid(clp, (char *)p, len, gid) != 0)
 				dprintk("%s: nfs_map_group_to_gid failed!\n",
-						__FUNCTION__);
+						__func__);
 		} else
 			dprintk("%s: name too long (%u)!\n",
-					__FUNCTION__, len);
+					__func__, len);
 		bitmap[1] &= ~FATTR4_WORD1_OWNER_GROUP;
 	}
-	dprintk("%s: gid=%d\n", __FUNCTION__, (int)*gid);
+	dprintk("%s: gid=%d\n", __func__, (int)*gid);
 	return 0;
 }
 
@@ -2820,7 +2820,7 @@ static int decode_attr_rdev(struct xdr_stream *xdr, uint32_t *bitmap, dev_t *rde
 			*rdev = tmp;
 		bitmap[1] &= ~ FATTR4_WORD1_RAWDEV;
 	}
-	dprintk("%s: rdev=(0x%x:0x%x)\n", __FUNCTION__, major, minor);
+	dprintk("%s: rdev=(0x%x:0x%x)\n", __func__, major, minor);
 	return 0;
 }
 
@@ -2837,7 +2837,7 @@ static int decode_attr_space_avail(struct xdr_stream *xdr, uint32_t *bitmap, uin
 		READ64(*res);
 		bitmap[1] &= ~FATTR4_WORD1_SPACE_AVAIL;
 	}
-	dprintk("%s: space avail=%Lu\n", __FUNCTION__, (unsigned long long)*res);
+	dprintk("%s: space avail=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
 }
 
@@ -2854,7 +2854,7 @@ static int decode_attr_space_free(struct xdr_stream *xdr, uint32_t *bitmap, uint
 		READ64(*res);
 		bitmap[1] &= ~FATTR4_WORD1_SPACE_FREE;
 	}
-	dprintk("%s: space free=%Lu\n", __FUNCTION__, (unsigned long long)*res);
+	dprintk("%s: space free=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
 }
 
@@ -2871,7 +2871,7 @@ static int decode_attr_space_total(struct xdr_stream *xdr, uint32_t *bitmap, uin
 		READ64(*res);
 		bitmap[1] &= ~FATTR4_WORD1_SPACE_TOTAL;
 	}
-	dprintk("%s: space total=%Lu\n", __FUNCTION__, (unsigned long long)*res);
+	dprintk("%s: space total=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
 }
 
@@ -2887,7 +2887,7 @@ static int decode_attr_space_used(struct xdr_stream *xdr, uint32_t *bitmap, uint
 		READ64(*used);
 		bitmap[1] &= ~FATTR4_WORD1_SPACE_USED;
 	}
-	dprintk("%s: space used=%Lu\n", __FUNCTION__,
+	dprintk("%s: space used=%Lu\n", __func__,
 			(unsigned long long)*used);
 	return 0;
 }
@@ -2918,7 +2918,7 @@ static int decode_attr_time_access(struct xdr_stream *xdr, uint32_t *bitmap, str
 		status = decode_attr_time(xdr, time);
 		bitmap[1] &= ~FATTR4_WORD1_TIME_ACCESS;
 	}
-	dprintk("%s: atime=%ld\n", __FUNCTION__, (long)time->tv_sec);
+	dprintk("%s: atime=%ld\n", __func__, (long)time->tv_sec);
 	return status;
 }
 
@@ -2934,7 +2934,7 @@ static int decode_attr_time_metadata(struct xdr_stream *xdr, uint32_t *bitmap, s
 		status = decode_attr_time(xdr, time);
 		bitmap[1] &= ~FATTR4_WORD1_TIME_METADATA;
 	}
-	dprintk("%s: ctime=%ld\n", __FUNCTION__, (long)time->tv_sec);
+	dprintk("%s: ctime=%ld\n", __func__, (long)time->tv_sec);
 	return status;
 }
 
@@ -2950,7 +2950,7 @@ static int decode_attr_time_modify(struct xdr_stream *xdr, uint32_t *bitmap, str
 		status = decode_attr_time(xdr, time);
 		bitmap[1] &= ~FATTR4_WORD1_TIME_MODIFY;
 	}
-	dprintk("%s: mtime=%ld\n", __FUNCTION__, (long)time->tv_sec);
+	dprintk("%s: mtime=%ld\n", __func__, (long)time->tv_sec);
 	return status;
 }
 
@@ -2962,7 +2962,7 @@ static int verify_attr_len(struct xdr_stream *xdr, __be32 *savep, uint32_t attrl
 	if (unlikely(attrwords != nwords)) {
 		dprintk("%s: server returned incorrect attribute length: "
 			"%u %c %u\n",
-				__FUNCTION__,
+				__func__,
 				attrwords << 2,
 				(attrwords < nwords) ? '<' : '>',
 				nwords << 2);
@@ -3067,7 +3067,7 @@ static int decode_server_caps(struct xdr_stream *xdr, struct nfs4_server_caps_re
 		goto xdr_error;
 	status = verify_attr_len(xdr, savep, attrlen);
 xdr_error:
-	dprintk("%s: xdr returned %d!\n", __FUNCTION__, -status);
+	dprintk("%s: xdr returned %d!\n", __func__, -status);
 	return status;
 }
 	
@@ -3100,7 +3100,7 @@ static int decode_statfs(struct xdr_stream *xdr, struct nfs_fsstat *fsstat)
 
 	status = verify_attr_len(xdr, savep, attrlen);
 xdr_error:
-	dprintk("%s: xdr returned %d!\n", __FUNCTION__, -status);
+	dprintk("%s: xdr returned %d!\n", __func__, -status);
 	return status;
 }
 
@@ -3125,7 +3125,7 @@ static int decode_pathconf(struct xdr_stream *xdr, struct nfs_pathconf *pathconf
 
 	status = verify_attr_len(xdr, savep, attrlen);
 xdr_error:
-	dprintk("%s: xdr returned %d!\n", __FUNCTION__, -status);
+	dprintk("%s: xdr returned %d!\n", __func__, -status);
 	return status;
 }
 
@@ -3193,7 +3193,7 @@ static int decode_getfattr(struct xdr_stream *xdr, struct nfs_fattr *fattr, cons
 	if ((status = verify_attr_len(xdr, savep, attrlen)) == 0)
 		fattr->valid = NFS_ATTR_FATTR | NFS_ATTR_FATTR_V3 | NFS_ATTR_FATTR_V4;
 xdr_error:
-	dprintk("%s: xdr returned %d\n", __FUNCTION__, -status);
+	dprintk("%s: xdr returned %d\n", __func__, -status);
 	return status;
 }
 
@@ -3226,7 +3226,7 @@ static int decode_fsinfo(struct xdr_stream *xdr, struct nfs_fsinfo *fsinfo)
 
 	status = verify_attr_len(xdr, savep, attrlen);
 xdr_error:
-	dprintk("%s: xdr returned %d!\n", __FUNCTION__, -status);
+	dprintk("%s: xdr returned %d!\n", __func__, -status);
 	return status;
 }
 
@@ -3418,7 +3418,7 @@ static int decode_open(struct xdr_stream *xdr, struct nfs_openres *res)
 
 	return decode_delegation(xdr, res);
 xdr_error:
-	dprintk("%s: Bitmap too large! Length = %u\n", __FUNCTION__, bmlen);
+	dprintk("%s: Bitmap too large! Length = %u\n", __func__, bmlen);
 	return -EIO;
 }
 
@@ -3575,7 +3575,7 @@ short_pkt:
 	 * the call was successful, but incomplete. The caller can retry the
 	 * readdir starting at the last cookie.
 	 */
-	dprintk("%s: short packet at entry %d\n", __FUNCTION__, nr);
+	dprintk("%s: short packet at entry %d\n", __func__, nr);
 	entry[0] = entry[1] = 0;
 	if (nr)
 		goto out;
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 5ccf7fa..03599bf 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -63,17 +63,17 @@ nfs_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
 	};
 	int status;
 
-	dprintk("%s: call getattr\n", __FUNCTION__);
+	dprintk("%s: call getattr\n", __func__);
 	nfs_fattr_init(fattr);
 	status = rpc_call_sync(server->nfs_client->cl_rpcclient, &msg, 0);
-	dprintk("%s: reply getattr: %d\n", __FUNCTION__, status);
+	dprintk("%s: reply getattr: %d\n", __func__, status);
 	if (status)
 		return status;
-	dprintk("%s: call statfs\n", __FUNCTION__);
+	dprintk("%s: call statfs\n", __func__);
 	msg.rpc_proc = &nfs_procedures[NFSPROC_STATFS];
 	msg.rpc_resp = &fsinfo;
 	status = rpc_call_sync(server->nfs_client->cl_rpcclient, &msg, 0);
-	dprintk("%s: reply statfs: %d\n", __FUNCTION__, status);
+	dprintk("%s: reply statfs: %d\n", __func__, status);
 	if (status)
 		return status;
 	info->rtmax  = NFS_MAXDATA;
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 16f57e0..40d1798 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -329,7 +329,7 @@ int nfs_readpage_result(struct rpc_task *task, struct nfs_read_data *data)
 {
 	int status;
 
-	dprintk("NFS: %s: %5u, (status %d)\n", __FUNCTION__, task->tk_pid,
+	dprintk("NFS: %s: %5u, (status %d)\n", __func__, task->tk_pid,
 			task->tk_status);
 
 	status = NFS_PROTO(data->inode)->read_done(task, data);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 7226a50..2a4a024 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -405,7 +405,7 @@ static int nfs_statfs(struct dentry *dentry, struct kstatfs *buf)
 	return 0;
 
  out_err:
-	dprintk("%s: statfs error = %d\n", __FUNCTION__, -error);
+	dprintk("%s: statfs error = %d\n", __func__, -error);
 	unlock_kernel();
 	return error;
 }
@@ -2015,6 +2015,10 @@ static int nfs4_get_sb(struct file_system_type *fs_type,
 		goto error_splat_super;
 	}
 
+	error = security_sb_set_mnt_opts(s, &data.lsm_opts);
+	if (error)
+		goto error_splat_root;
+
 	s->s_flags |= MS_ACTIVE;
 	mnt->mnt_sb = s;
 	mnt->mnt_root = mntroot;
@@ -2031,6 +2035,8 @@ out_free:
 	nfs_free_server(server);
 	goto out;
 
+error_splat_root:
+	dput(mntroot);
 error_splat_super:
 	up_write(&s->s_umount);
 	deactivate_super(s);
@@ -2114,6 +2120,8 @@ static int nfs4_xdev_get_sb(struct file_system_type *fs_type, int flags,
 	mnt->mnt_sb = s;
 	mnt->mnt_root = mntroot;
 
+	security_sb_clone_mnt_opts(data->sb, s);
+
 	dprintk("<-- nfs4_xdev_get_sb() = 0\n");
 	return 0;
 
@@ -2197,6 +2205,8 @@ static int nfs4_referral_get_sb(struct file_system_type *fs_type, int flags,
 	mnt->mnt_sb = s;
 	mnt->mnt_root = mntroot;
 
+	security_sb_clone_mnt_opts(data->sb, s);
+
 	dprintk("<-- nfs4_referral_get_sb() = 0\n");
 	return 0;
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 1ade11d..6d8ace3 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -415,7 +415,7 @@ nfs_dirty_request(struct nfs_page *req)
 
 	if (page == NULL || test_bit(PG_NEED_COMMIT, &req->wb_flags))
 		return 0;
-	return !PageWriteback(req->wb_page);
+	return !PageWriteback(page);
 }
 
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index d927d9f..744b79f 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -17,8 +17,8 @@
 # define RPCDBG_FACILITY	RPCDBG_AUTH
 #endif
 
-#define RPC_ANONYMOUS_USERID	((uid_t)-2)
-#define RPC_ANONYMOUS_GROUPID	((gid_t)-2)
+#define RPC_MACHINE_CRED_USERID		((uid_t)0)
+#define RPC_MACHINE_CRED_GROUPID	((gid_t)0)
 
 struct generic_cred {
 	struct rpc_cred gc_base;
@@ -44,8 +44,8 @@ EXPORT_SYMBOL_GPL(rpc_lookup_cred);
 struct rpc_cred *rpc_lookup_machine_cred(void)
 {
 	struct auth_cred acred = {
-		.uid = RPC_ANONYMOUS_USERID,
-		.gid = RPC_ANONYMOUS_GROUPID,
+		.uid = RPC_MACHINE_CRED_USERID,
+		.gid = RPC_MACHINE_CRED_GROUPID,
 		.machine_cred = 1,
 	};
 

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
