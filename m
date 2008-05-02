From: akpm@linux-foundation.org
Subject: [patch 3/5] nfs: replace remaining __FUNCTION__ occurrences
Date: Fri, 02 May 2008 13:42:44 -0700
Message-ID: <200805022042.m42Kgi4g013878@imap1.linux-foundation.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
	akpm@linux-foundation.org, harvey.harrison@gmail.com
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59208 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935891AbYEBUnB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 May 2008 16:43:01 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>

__FUNCTION__ is gcc-specific, use __func__

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/nfs/callback.c      |    2 
 fs/nfs/callback_proc.c |    4 -
 fs/nfs/callback_xdr.c  |   18 +++----
 fs/nfs/client.c        |    8 +--
 fs/nfs/delegation.c    |    4 -
 fs/nfs/dir.c           |   18 +++----
 fs/nfs/file.c          |    2 
 fs/nfs/inode.c         |    4 -
 fs/nfs/namespace.c     |    8 +--
 fs/nfs/nfs3proc.c      |    6 +-
 fs/nfs/nfs4namespace.c |   12 ++--
 fs/nfs/nfs4proc.c      |   32 ++++++------
 fs/nfs/nfs4renewd.c    |   10 +--
 fs/nfs/nfs4state.c     |    6 +-
 fs/nfs/nfs4xdr.c       |  100 +++++++++++++++++++--------------------
 fs/nfs/proc.c          |    8 +--
 fs/nfs/read.c          |    2 
 fs/nfs/super.c         |    2 
 18 files changed, 123 insertions(+), 123 deletions(-)

diff -puN fs/nfs/callback.c~nfs-replace-remaining-__function__-occurrences fs/nfs/callback.c
--- a/fs/nfs/callback.c~nfs-replace-remaining-__function__-occurrences
+++ a/fs/nfs/callback.c
@@ -182,7 +182,7 @@ static int nfs_callback_authenticate(str
 	if (clp == NULL)
 		return SVC_DROP;
 
-	dprintk("%s: %s NFSv4 callback!\n", __FUNCTION__,
+	dprintk("%s: %s NFSv4 callback!\n", __func__,
 			svc_print_addr(rqstp, buf, sizeof(buf)));
 	nfs_put_client(clp);
 
diff -puN fs/nfs/callback_proc.c~nfs-replace-remaining-__function__-occurrences fs/nfs/callback_proc.c
--- a/fs/nfs/callback_proc.c~nfs-replace-remaining-__function__-occurrences
+++ a/fs/nfs/callback_proc.c
@@ -57,7 +57,7 @@ out_iput:
 out_putclient:
 	nfs_put_client(clp);
 out:
-	dprintk("%s: exit with status = %d\n", __FUNCTION__, ntohl(res->status));
+	dprintk("%s: exit with status = %d\n", __func__, ntohl(res->status));
 	return res->status;
 }
 
@@ -98,6 +98,6 @@ __be32 nfs4_callback_recall(struct cb_re
 		nfs_put_client(prev);
 	} while (clp != NULL);
 out:
-	dprintk("%s: exit with status = %d\n", __FUNCTION__, ntohl(res));
+	dprintk("%s: exit with status = %d\n", __func__, ntohl(res));
 	return res;
 }
diff -puN fs/nfs/callback_xdr.c~nfs-replace-remaining-__function__-occurrences fs/nfs/callback_xdr.c
--- a/fs/nfs/callback_xdr.c~nfs-replace-remaining-__function__-occurrences
+++ a/fs/nfs/callback_xdr.c
@@ -141,7 +141,7 @@ static __be32 decode_compound_hdr_arg(st
 	/* We do not like overly long tags! */
 	if (hdr->taglen > CB_OP_TAGLEN_MAXSZ - 12) {
 		printk("NFSv4 CALLBACK %s: client sent tag of length %u\n",
-				__FUNCTION__, hdr->taglen);
+				__func__, hdr->taglen);
 		return htonl(NFS4ERR_RESOURCE);
 	}
 	p = read_buf(xdr, 12);
@@ -151,7 +151,7 @@ static __be32 decode_compound_hdr_arg(st
 	/* Check minor version is zero. */
 	if (minor_version != 0) {
 		printk(KERN_WARNING "%s: NFSv4 server callback with illegal minor version %u!\n",
-				__FUNCTION__, minor_version);
+				__func__, minor_version);
 		return htonl(NFS4ERR_MINOR_VERS_MISMATCH);
 	}
 	hdr->callback_ident = ntohl(*p++);
@@ -179,7 +179,7 @@ static __be32 decode_getattr_args(struct
 	args->addr = svc_addr(rqstp);
 	status = decode_bitmap(xdr, args->bitmap);
 out:
-	dprintk("%s: exit with status = %d\n", __FUNCTION__, ntohl(status));
+	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
 	return status;
 }
 
@@ -200,7 +200,7 @@ static __be32 decode_recall_args(struct 
 	args->truncate = ntohl(*p);
 	status = decode_fh(xdr, &args->fh);
 out:
-	dprintk("%s: exit with status = %d\n", __FUNCTION__, ntohl(status));
+	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
 	return status;
 }
 
@@ -349,7 +349,7 @@ static __be32 encode_getattr_res(struct 
 	status = encode_attr_mtime(xdr, res->bitmap, &res->mtime);
 	*savep = htonl((unsigned int)((char *)xdr->p - (char *)(savep+1)));
 out:
-	dprintk("%s: exit with status = %d\n", __FUNCTION__, ntohl(status));
+	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
 	return status;
 }
 
@@ -363,7 +363,7 @@ static __be32 process_op(struct svc_rqst
 	long maxlen;
 	__be32 res;
 
-	dprintk("%s: start\n", __FUNCTION__);
+	dprintk("%s: start\n", __func__);
 	status = decode_op_hdr(xdr_in, &op_nr);
 	if (likely(status == 0)) {
 		switch (op_nr) {
@@ -392,7 +392,7 @@ static __be32 process_op(struct svc_rqst
 		status = res;
 	if (op->encode_res != NULL && status == 0)
 		status = op->encode_res(rqstp, xdr_out, resp);
-	dprintk("%s: done, status = %d\n", __FUNCTION__, ntohl(status));
+	dprintk("%s: done, status = %d\n", __func__, ntohl(status));
 	return status;
 }
 
@@ -408,7 +408,7 @@ static __be32 nfs4_callback_compound(str
 	__be32 status;
 	unsigned int nops = 1;
 
-	dprintk("%s: start\n", __FUNCTION__);
+	dprintk("%s: start\n", __func__);
 
 	xdr_init_decode(&xdr_in, &rqstp->rq_arg, rqstp->rq_arg.head[0].iov_base);
 
@@ -431,7 +431,7 @@ static __be32 nfs4_callback_compound(str
 	}
 	*hdr_res.status = status;
 	*hdr_res.nops = htonl(nops);
-	dprintk("%s: done, status = %u\n", __FUNCTION__, ntohl(status));
+	dprintk("%s: done, status = %u\n", __func__, ntohl(status));
 	return rpc_success;
 }
 
diff -puN fs/nfs/client.c~nfs-replace-remaining-__function__-occurrences fs/nfs/client.c
--- a/fs/nfs/client.c~nfs-replace-remaining-__function__-occurrences
+++ a/fs/nfs/client.c
@@ -488,7 +488,7 @@ static int nfs_create_rpc_client(struct 
 	clnt = rpc_create(&args);
 	if (IS_ERR(clnt)) {
 		dprintk("%s: cannot create RPC client. Error = %ld\n",
-				__FUNCTION__, PTR_ERR(clnt));
+				__func__, PTR_ERR(clnt));
 		return PTR_ERR(clnt);
 	}
 
@@ -576,7 +576,7 @@ static int nfs_init_server_rpcclient(str
 
 	server->client = rpc_clone_client(clp->cl_rpcclient);
 	if (IS_ERR(server->client)) {
-		dprintk("%s: couldn't create rpc_client!\n", __FUNCTION__);
+		dprintk("%s: couldn't create rpc_client!\n", __func__);
 		return PTR_ERR(server->client);
 	}
 
@@ -590,7 +590,7 @@ static int nfs_init_server_rpcclient(str
 
 		auth = rpcauth_create(pseudoflavour, server->client);
 		if (IS_ERR(auth)) {
-			dprintk("%s: couldn't create credcache!\n", __FUNCTION__);
+			dprintk("%s: couldn't create credcache!\n", __func__);
 			return PTR_ERR(auth);
 		}
 	}
@@ -985,7 +985,7 @@ static int nfs4_init_client(struct nfs_c
 	error = nfs_idmap_new(clp);
 	if (error < 0) {
 		dprintk("%s: failed to create idmapper. Error = %d\n",
-			__FUNCTION__, error);
+			__func__, error);
 		goto error;
 	}
 	__set_bit(NFS_CS_IDMAP, &clp->cl_res_state);
diff -puN fs/nfs/delegation.c~nfs-replace-remaining-__function__-occurrences fs/nfs/delegation.c
--- a/fs/nfs/delegation.c~nfs-replace-remaining-__function__-occurrences
+++ a/fs/nfs/delegation.c
@@ -60,7 +60,7 @@ static int nfs_delegation_claim_locks(st
 		switch (status) {
 			default:
 				printk(KERN_ERR "%s: unhandled error %d.\n",
-						__FUNCTION__, status);
+						__func__, status);
 			case -NFS4ERR_EXPIRED:
 				/* kill_proc(fl->fl_pid, SIGLOST, 1); */
 			case -NFS4ERR_STALE_CLIENTID:
@@ -186,7 +186,7 @@ int nfs_inode_set_delegation(struct inod
 		 */
 		dfprintk(FILE, "%s: server %s handed out "
 				"a duplicate delegation!\n",
-				__FUNCTION__, clp->cl_hostname);
+				__func__, clp->cl_hostname);
 		if (delegation->type <= nfsi->delegation->type) {
 			freeme = delegation;
 			delegation = NULL;
diff -puN fs/nfs/dir.c~nfs-replace-remaining-__function__-occurrences fs/nfs/dir.c
--- a/fs/nfs/dir.c~nfs-replace-remaining-__function__-occurrences
+++ a/fs/nfs/dir.c
@@ -180,7 +180,7 @@ int nfs_readdir_filler(nfs_readdir_descr
 	int		error;
 
 	dfprintk(DIRCACHE, "NFS: %s: reading cookie %Lu into page %lu\n",
-			__FUNCTION__, (long long)desc->entry->cookie,
+			__func__, (long long)desc->entry->cookie,
 			page->index);
 
  again:
@@ -256,7 +256,7 @@ int find_dirent(nfs_readdir_descriptor_t
 
 	while((status = dir_decode(desc)) == 0) {
 		dfprintk(DIRCACHE, "NFS: %s: examining cookie %Lu\n",
-				__FUNCTION__, (unsigned long long)entry->cookie);
+				__func__, (unsigned long long)entry->cookie);
 		if (entry->prev_cookie == *desc->dir_cookie)
 			break;
 		if (loop_count++ > 200) {
@@ -315,7 +315,7 @@ int find_dirent_page(nfs_readdir_descrip
 	int		status;
 
 	dfprintk(DIRCACHE, "NFS: %s: searching page %ld for target %Lu\n",
-			__FUNCTION__, desc->page_index,
+			__func__, desc->page_index,
 			(long long) *desc->dir_cookie);
 
 	/* If we find the page in the page_cache, we cannot be sure
@@ -339,7 +339,7 @@ int find_dirent_page(nfs_readdir_descrip
 	if (status < 0)
 		dir_page_release(desc);
  out:
-	dfprintk(DIRCACHE, "NFS: %s: returns %d\n", __FUNCTION__, status);
+	dfprintk(DIRCACHE, "NFS: %s: returns %d\n", __func__, status);
 	return status;
 }
 
@@ -380,7 +380,7 @@ int readdir_search_pagecache(nfs_readdir
 		}
 	}
 
-	dfprintk(DIRCACHE, "NFS: %s: returns %d\n", __FUNCTION__, res);
+	dfprintk(DIRCACHE, "NFS: %s: returns %d\n", __func__, res);
 	return res;
 }
 
@@ -506,7 +506,7 @@ int uncached_readdir(nfs_readdir_descrip
 	desc->entry->eof = 0;
  out:
 	dfprintk(DIRCACHE, "NFS: %s: returns %d\n",
-			__FUNCTION__, status);
+			__func__, status);
 	return status;
  out_release:
 	dir_page_release(desc);
@@ -780,7 +780,7 @@ static int nfs_lookup_revalidate(struct 
 
 	if (is_bad_inode(inode)) {
 		dfprintk(LOOKUPCACHE, "%s: %s/%s has dud inode\n",
-				__FUNCTION__, dentry->d_parent->d_name.name,
+				__func__, dentry->d_parent->d_name.name,
 				dentry->d_name.name);
 		goto out_bad;
 	}
@@ -808,7 +808,7 @@ static int nfs_lookup_revalidate(struct 
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
diff -puN fs/nfs/file.c~nfs-replace-remaining-__function__-occurrences fs/nfs/file.c
--- a/fs/nfs/file.c~nfs-replace-remaining-__function__-occurrences
+++ a/fs/nfs/file.c
@@ -526,7 +526,7 @@ static int do_vfs_lock(struct file *file
 	if (res < 0)
 		dprintk(KERN_WARNING "%s: VFS is out of sync with lock manager"
 			" - error %d!\n",
-				__FUNCTION__, res);
+				__func__, res);
 	return res;
 }
 
diff -puN fs/nfs/inode.c~nfs-replace-remaining-__function__-occurrences fs/nfs/inode.c
--- a/fs/nfs/inode.c~nfs-replace-remaining-__function__-occurrences
+++ a/fs/nfs/inode.c
@@ -995,7 +995,7 @@ static int nfs_update_inode(struct inode
 	unsigned long now = jiffies;
 
 	dfprintk(VFS, "NFS: %s(%s/%ld ct=%d info=0x%x)\n",
-			__FUNCTION__, inode->i_sb->s_id, inode->i_ino,
+			__func__, inode->i_sb->s_id, inode->i_ino,
 			atomic_read(&inode->i_count), fattr->valid);
 
 	if (nfsi->fileid != fattr->fileid)
@@ -1119,7 +1119,7 @@ static int nfs_update_inode(struct inode
 	 * Big trouble! The inode has become a different object.
 	 */
 	printk(KERN_DEBUG "%s: inode %ld mode changed, %07o to %07o\n",
-			__FUNCTION__, inode->i_ino, inode->i_mode, fattr->mode);
+			__func__, inode->i_ino, inode->i_mode, fattr->mode);
  out_err:
 	/*
 	 * No need to worry about unhashing the dentry, as the
diff -puN fs/nfs/namespace.c~nfs-replace-remaining-__function__-occurrences fs/nfs/namespace.c
--- a/fs/nfs/namespace.c~nfs-replace-remaining-__function__-occurrences
+++ a/fs/nfs/namespace.c
@@ -106,7 +106,7 @@ static void * nfs_follow_mountpoint(stru
 	dprintk("--> nfs_follow_mountpoint()\n");
 
 	BUG_ON(IS_ROOT(dentry));
-	dprintk("%s: enter\n", __FUNCTION__);
+	dprintk("%s: enter\n", __func__);
 	dput(nd->path.dentry);
 	nd->path.dentry = dget(dentry);
 
@@ -143,7 +143,7 @@ static void * nfs_follow_mountpoint(stru
 	nd->path.dentry = dget(mnt->mnt_root);
 	schedule_delayed_work(&nfs_automount_task, nfs_mountpoint_expiry_timeout);
 out:
-	dprintk("%s: done, returned %d\n", __FUNCTION__, err);
+	dprintk("%s: done, returned %d\n", __func__, err);
 
 	dprintk("<-- nfs_follow_mountpoint() = %d\n", err);
 	return ERR_PTR(err);
@@ -230,7 +230,7 @@ static struct vfsmount *nfs_do_submount(
 
 	dprintk("--> nfs_do_submount()\n");
 
-	dprintk("%s: submounting on %s/%s\n", __FUNCTION__,
+	dprintk("%s: submounting on %s/%s\n", __func__,
 			dentry->d_parent->d_name.name,
 			dentry->d_name.name);
 	if (page == NULL)
@@ -243,7 +243,7 @@ static struct vfsmount *nfs_do_submount(
 free_page:
 	free_page((unsigned long)page);
 out:
-	dprintk("%s: done\n", __FUNCTION__);
+	dprintk("%s: done\n", __func__);
 
 	dprintk("<-- nfs_do_submount() = %p\n", mnt);
 	return mnt;
diff -puN fs/nfs/nfs3proc.c~nfs-replace-remaining-__function__-occurrences fs/nfs/nfs3proc.c
--- a/fs/nfs/nfs3proc.c~nfs-replace-remaining-__function__-occurrences
+++ a/fs/nfs/nfs3proc.c
@@ -63,15 +63,15 @@ do_proc_get_root(struct rpc_clnt *client
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
diff -puN fs/nfs/nfs4namespace.c~nfs-replace-remaining-__function__-occurrences fs/nfs/nfs4namespace.c
--- a/fs/nfs/nfs4namespace.c~nfs-replace-remaining-__function__-occurrences
+++ a/fs/nfs/nfs4namespace.c
@@ -86,7 +86,7 @@ static int nfs4_validate_fspath(const st
 
 	if (strncmp(path, fs_path, strlen(fs_path)) != 0) {
 		dprintk("%s: path %s does not begin with fsroot %s\n",
-			__FUNCTION__, path, fs_path);
+			__func__, path, fs_path);
 		return -ENOENT;
 	}
 
@@ -134,7 +134,7 @@ static struct vfsmount *nfs_follow_refer
 	if (locations == NULL || locations->nlocations <= 0)
 		goto out;
 
-	dprintk("%s: referral at %s/%s\n", __FUNCTION__,
+	dprintk("%s: referral at %s/%s\n", __func__,
 		dentry->d_parent->d_name.name, dentry->d_name.name);
 
 	page = (char *) __get_free_page(GFP_USER);
@@ -204,7 +204,7 @@ static struct vfsmount *nfs_follow_refer
 out:
 	free_page((unsigned long) page);
 	free_page((unsigned long) page2);
-	dprintk("%s: done\n", __FUNCTION__);
+	dprintk("%s: done\n", __func__);
 	return mnt;
 }
 
@@ -223,7 +223,7 @@ struct vfsmount *nfs_do_refmount(const s
 	int err;
 
 	/* BUG_ON(IS_ROOT(dentry)); */
-	dprintk("%s: enter\n", __FUNCTION__);
+	dprintk("%s: enter\n", __func__);
 
 	page = alloc_page(GFP_KERNEL);
 	if (page == NULL)
@@ -238,7 +238,7 @@ struct vfsmount *nfs_do_refmount(const s
 
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
diff -puN fs/nfs/nfs4proc.c~nfs-replace-remaining-__function__-occurrences fs/nfs/nfs4proc.c
--- a/fs/nfs/nfs4proc.c~nfs-replace-remaining-__function__-occurrences
+++ a/fs/nfs/nfs4proc.c
@@ -73,7 +73,7 @@ int nfs4_map_errors(int err)
 {
 	if (err < -1000) {
 		dprintk("%s could not handle NFSv4 error %d\n",
-				__FUNCTION__, -err);
+				__func__, -err);
 		return -EIO;
 	}
 	return err;
@@ -1578,7 +1578,7 @@ static int nfs4_get_referral(struct inod
 		goto out;
 	/* Make sure server returned a different fsid for the referral */
 	if (nfs_fsid_equal(&NFS_SERVER(dir)->fsid, &locations->fattr.fsid)) {
-		dprintk("%s: server did not return a different fsid for a referral at %s\n", __FUNCTION__, name->name);
+		dprintk("%s: server did not return a different fsid for a referral at %s\n", __func__, name->name);
 		status = -EIO;
 		goto out;
 	}
@@ -2211,7 +2211,7 @@ static int _nfs4_proc_readdir(struct den
 	};
 	int			status;
 
-	dprintk("%s: dentry = %s/%s, cookie = %Lu\n", __FUNCTION__,
+	dprintk("%s: dentry = %s/%s, cookie = %Lu\n", __func__,
 			dentry->d_parent->d_name.name,
 			dentry->d_name.name,
 			(unsigned long long)cookie);
@@ -2223,7 +2223,7 @@ static int _nfs4_proc_readdir(struct den
 
 	nfs_invalidate_atime(dir);
 
-	dprintk("%s: returns %d\n", __FUNCTION__, status);
+	dprintk("%s: returns %d\n", __func__, status);
 	return status;
 }
 
@@ -3342,7 +3342,7 @@ static void nfs4_lock_prepare(struct rpc
 	struct nfs4_lockdata *data = calldata;
 	struct nfs4_state *state = data->lsp->ls_state;
 
-	dprintk("%s: begin!\n", __FUNCTION__);
+	dprintk("%s: begin!\n", __func__);
 	if (nfs_wait_on_sequence(data->arg.lock_seqid, task) != 0)
 		return;
 	/* Do we need to do an open_to_lock_owner? */
@@ -3356,14 +3356,14 @@ static void nfs4_lock_prepare(struct rpc
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
@@ -3381,14 +3381,14 @@ static void nfs4_lock_done(struct rpc_ta
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
@@ -3396,13 +3396,13 @@ static void nfs4_lock_release(void *call
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
@@ -3428,7 +3428,7 @@ static int _nfs4_do_setlk(struct nfs4_st
 	};
 	int ret;
 
-	dprintk("%s: begin!\n", __FUNCTION__);
+	dprintk("%s: begin!\n", __func__);
 	data = nfs4_alloc_lockdata(fl, nfs_file_open_context(fl->fl_file),
 			fl->fl_u.nfs4_fl.owner);
 	if (data == NULL)
@@ -3451,7 +3451,7 @@ static int _nfs4_do_setlk(struct nfs4_st
 	} else
 		data->cancelled = 1;
 	rpc_put_task(task);
-	dprintk("%s: done, ret = %d!\n", __FUNCTION__, ret);
+	dprintk("%s: done, ret = %d!\n", __func__, ret);
 	return ret;
 }
 
@@ -3527,7 +3527,7 @@ static int _nfs4_proc_setlk(struct nfs4_
 	/* Note: we always want to sleep here! */
 	request->fl_flags = fl_flags | FL_SLEEP;
 	if (do_vfs_lock(request->fl_file, request) < 0)
-		printk(KERN_WARNING "%s: VFS is out of sync with lock manager!\n", __FUNCTION__);
+		printk(KERN_WARNING "%s: VFS is out of sync with lock manager!\n", __func__);
 out_unlock:
 	up_read(&clp->cl_sem);
 out:
@@ -3665,12 +3665,12 @@ int nfs4_proc_fs_locations(struct inode 
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
 
diff -puN fs/nfs/nfs4renewd.c~nfs-replace-remaining-__function__-occurrences fs/nfs/nfs4renewd.c
--- a/fs/nfs/nfs4renewd.c~nfs-replace-remaining-__function__-occurrences
+++ a/fs/nfs/nfs4renewd.c
@@ -66,7 +66,7 @@ nfs4_renew_state(struct work_struct *wor
 	unsigned long last, now;
 
 	down_read(&clp->cl_sem);
-	dprintk("%s: start\n", __FUNCTION__);
+	dprintk("%s: start\n", __func__);
 	/* Are there any active superblocks? */
 	if (list_empty(&clp->cl_superblocks))
 		goto out;
@@ -92,17 +92,17 @@ nfs4_renew_state(struct work_struct *wor
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
@@ -117,7 +117,7 @@ nfs4_schedule_state_renewal(struct nfs_c
 	if (timeout < 5 * HZ)
 		timeout = 5 * HZ;
 	dprintk("%s: requeueing work. Lease period = %ld\n",
-			__FUNCTION__, (timeout + HZ - 1) / HZ);
+			__func__, (timeout + HZ - 1) / HZ);
 	cancel_delayed_work(&clp->cl_renewd);
 	schedule_delayed_work(&clp->cl_renewd, timeout);
 	set_bit(NFS_CS_RENEWD, &clp->cl_res_state);
diff -puN fs/nfs/nfs4state.c~nfs-replace-remaining-__function__-occurrences fs/nfs/nfs4state.c
--- a/fs/nfs/nfs4state.c~nfs-replace-remaining-__function__-occurrences
+++ a/fs/nfs/nfs4state.c
@@ -828,7 +828,7 @@ static int nfs4_reclaim_locks(struct nfs
 		switch (status) {
 			default:
 				printk(KERN_ERR "%s: unhandled error %d. Zeroing state\n",
-						__FUNCTION__, status);
+						__func__, status);
 			case -NFS4ERR_EXPIRED:
 			case -NFS4ERR_NO_GRACE:
 			case -NFS4ERR_RECLAIM_BAD:
@@ -869,14 +869,14 @@ static int nfs4_reclaim_open_state(struc
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
diff -puN fs/nfs/nfs4xdr.c~nfs-replace-remaining-__function__-occurrences fs/nfs/nfs4xdr.c
--- a/fs/nfs/nfs4xdr.c~nfs-replace-remaining-__function__-occurrences
+++ a/fs/nfs/nfs4xdr.c
@@ -1831,7 +1831,7 @@ static int nfs4_xdr_enc_readdir(struct r
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
@@ -2306,12 +2306,12 @@ static int decode_attr_type(struct xdr_s
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
 
@@ -2327,7 +2327,7 @@ static int decode_attr_change(struct xdr
 		READ64(*change);
 		bitmap[0] &= ~FATTR4_WORD0_CHANGE;
 	}
-	dprintk("%s: change attribute=%Lu\n", __FUNCTION__,
+	dprintk("%s: change attribute=%Lu\n", __func__,
 			(unsigned long long)*change);
 	return 0;
 }
@@ -2344,7 +2344,7 @@ static int decode_attr_size(struct xdr_s
 		READ64(*size);
 		bitmap[0] &= ~FATTR4_WORD0_SIZE;
 	}
-	dprintk("%s: file size=%Lu\n", __FUNCTION__, (unsigned long long)*size);
+	dprintk("%s: file size=%Lu\n", __func__, (unsigned long long)*size);
 	return 0;
 }
 
@@ -2360,7 +2360,7 @@ static int decode_attr_link_support(stru
 		READ32(*res);
 		bitmap[0] &= ~FATTR4_WORD0_LINK_SUPPORT;
 	}
-	dprintk("%s: link support=%s\n", __FUNCTION__, *res == 0 ? "false" : "true");
+	dprintk("%s: link support=%s\n", __func__, *res == 0 ? "false" : "true");
 	return 0;
 }
 
@@ -2376,7 +2376,7 @@ static int decode_attr_symlink_support(s
 		READ32(*res);
 		bitmap[0] &= ~FATTR4_WORD0_SYMLINK_SUPPORT;
 	}
-	dprintk("%s: symlink support=%s\n", __FUNCTION__, *res == 0 ? "false" : "true");
+	dprintk("%s: symlink support=%s\n", __func__, *res == 0 ? "false" : "true");
 	return 0;
 }
 
@@ -2394,7 +2394,7 @@ static int decode_attr_fsid(struct xdr_s
 		READ64(fsid->minor);
 		bitmap[0] &= ~FATTR4_WORD0_FSID;
 	}
-	dprintk("%s: fsid=(0x%Lx/0x%Lx)\n", __FUNCTION__,
+	dprintk("%s: fsid=(0x%Lx/0x%Lx)\n", __func__,
 			(unsigned long long)fsid->major,
 			(unsigned long long)fsid->minor);
 	return 0;
@@ -2412,7 +2412,7 @@ static int decode_attr_lease_time(struct
 		READ32(*res);
 		bitmap[0] &= ~FATTR4_WORD0_LEASE_TIME;
 	}
-	dprintk("%s: file size=%u\n", __FUNCTION__, (unsigned int)*res);
+	dprintk("%s: file size=%u\n", __func__, (unsigned int)*res);
 	return 0;
 }
 
@@ -2428,7 +2428,7 @@ static int decode_attr_aclsupport(struct
 		READ32(*res);
 		bitmap[0] &= ~FATTR4_WORD0_ACLSUPPORT;
 	}
-	dprintk("%s: ACLs supported=%u\n", __FUNCTION__, (unsigned int)*res);
+	dprintk("%s: ACLs supported=%u\n", __func__, (unsigned int)*res);
 	return 0;
 }
 
@@ -2444,7 +2444,7 @@ static int decode_attr_fileid(struct xdr
 		READ64(*fileid);
 		bitmap[0] &= ~FATTR4_WORD0_FILEID;
 	}
-	dprintk("%s: fileid=%Lu\n", __FUNCTION__, (unsigned long long)*fileid);
+	dprintk("%s: fileid=%Lu\n", __func__, (unsigned long long)*fileid);
 	return 0;
 }
 
@@ -2460,7 +2460,7 @@ static int decode_attr_mounted_on_fileid
 		READ64(*fileid);
 		bitmap[1] &= ~FATTR4_WORD1_MOUNTED_ON_FILEID;
 	}
-	dprintk("%s: fileid=%Lu\n", __FUNCTION__, (unsigned long long)*fileid);
+	dprintk("%s: fileid=%Lu\n", __func__, (unsigned long long)*fileid);
 	return 0;
 }
 
@@ -2477,7 +2477,7 @@ static int decode_attr_files_avail(struc
 		READ64(*res);
 		bitmap[0] &= ~FATTR4_WORD0_FILES_AVAIL;
 	}
-	dprintk("%s: files avail=%Lu\n", __FUNCTION__, (unsigned long long)*res);
+	dprintk("%s: files avail=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
 }
 
@@ -2494,7 +2494,7 @@ static int decode_attr_files_free(struct
 		READ64(*res);
 		bitmap[0] &= ~FATTR4_WORD0_FILES_FREE;
 	}
-	dprintk("%s: files free=%Lu\n", __FUNCTION__, (unsigned long long)*res);
+	dprintk("%s: files free=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
 }
 
@@ -2511,7 +2511,7 @@ static int decode_attr_files_total(struc
 		READ64(*res);
 		bitmap[0] &= ~FATTR4_WORD0_FILES_TOTAL;
 	}
-	dprintk("%s: files total=%Lu\n", __FUNCTION__, (unsigned long long)*res);
+	dprintk("%s: files total=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
 }
 
@@ -2569,7 +2569,7 @@ static int decode_attr_fs_locations(stru
 	status = 0;
 	if (unlikely(!(bitmap[0] & FATTR4_WORD0_FS_LOCATIONS)))
 		goto out;
-	dprintk("%s: fsroot ", __FUNCTION__);
+	dprintk("%s: fsroot ", __func__);
 	status = decode_pathname(xdr, &res->fs_path);
 	if (unlikely(status != 0))
 		goto out;
@@ -2586,7 +2586,7 @@ static int decode_attr_fs_locations(stru
 		READ32(m);
 
 		loc->nservers = 0;
-		dprintk("%s: servers ", __FUNCTION__);
+		dprintk("%s: servers ", __func__);
 		while (loc->nservers < m) {
 			struct nfs4_string *server = &loc->servers[loc->nservers];
 			status = decode_opaque_inline(xdr, &server->len, &server->data);
@@ -2599,7 +2599,7 @@ static int decode_attr_fs_locations(stru
 				unsigned int i;
 				dprintk("%s: using first %u of %u servers "
 					"returned for location %u\n",
-						__FUNCTION__,
+						__func__,
 						NFS4_FS_LOCATION_MAXSERVERS,
 						m, res->nlocations);
 				for (i = loc->nservers; i < m; i++) {
@@ -2618,7 +2618,7 @@ static int decode_attr_fs_locations(stru
 			res->nlocations++;
 	}
 out:
-	dprintk("%s: fs_locations done, error = %d\n", __FUNCTION__, status);
+	dprintk("%s: fs_locations done, error = %d\n", __func__, status);
 	return status;
 out_eio:
 	status = -EIO;
@@ -2638,7 +2638,7 @@ static int decode_attr_maxfilesize(struc
 		READ64(*res);
 		bitmap[0] &= ~FATTR4_WORD0_MAXFILESIZE;
 	}
-	dprintk("%s: maxfilesize=%Lu\n", __FUNCTION__, (unsigned long long)*res);
+	dprintk("%s: maxfilesize=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
 }
 
@@ -2655,7 +2655,7 @@ static int decode_attr_maxlink(struct xd
 		READ32(*maxlink);
 		bitmap[0] &= ~FATTR4_WORD0_MAXLINK;
 	}
-	dprintk("%s: maxlink=%u\n", __FUNCTION__, *maxlink);
+	dprintk("%s: maxlink=%u\n", __func__, *maxlink);
 	return status;
 }
 
@@ -2672,7 +2672,7 @@ static int decode_attr_maxname(struct xd
 		READ32(*maxname);
 		bitmap[0] &= ~FATTR4_WORD0_MAXNAME;
 	}
-	dprintk("%s: maxname=%u\n", __FUNCTION__, *maxname);
+	dprintk("%s: maxname=%u\n", __func__, *maxname);
 	return status;
 }
 
@@ -2693,7 +2693,7 @@ static int decode_attr_maxread(struct xd
 		*res = (uint32_t)maxread;
 		bitmap[0] &= ~FATTR4_WORD0_MAXREAD;
 	}
-	dprintk("%s: maxread=%lu\n", __FUNCTION__, (unsigned long)*res);
+	dprintk("%s: maxread=%lu\n", __func__, (unsigned long)*res);
 	return status;
 }
 
@@ -2714,7 +2714,7 @@ static int decode_attr_maxwrite(struct x
 		*res = (uint32_t)maxwrite;
 		bitmap[0] &= ~FATTR4_WORD0_MAXWRITE;
 	}
-	dprintk("%s: maxwrite=%lu\n", __FUNCTION__, (unsigned long)*res);
+	dprintk("%s: maxwrite=%lu\n", __func__, (unsigned long)*res);
 	return status;
 }
 
@@ -2731,7 +2731,7 @@ static int decode_attr_mode(struct xdr_s
 		*mode &= ~S_IFMT;
 		bitmap[1] &= ~FATTR4_WORD1_MODE;
 	}
-	dprintk("%s: file mode=0%o\n", __FUNCTION__, (unsigned int)*mode);
+	dprintk("%s: file mode=0%o\n", __func__, (unsigned int)*mode);
 	return 0;
 }
 
@@ -2747,7 +2747,7 @@ static int decode_attr_nlink(struct xdr_
 		READ32(*nlink);
 		bitmap[1] &= ~FATTR4_WORD1_NUMLINKS;
 	}
-	dprintk("%s: nlink=%u\n", __FUNCTION__, (unsigned int)*nlink);
+	dprintk("%s: nlink=%u\n", __func__, (unsigned int)*nlink);
 	return 0;
 }
 
@@ -2766,13 +2766,13 @@ static int decode_attr_owner(struct xdr_
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
 
@@ -2791,13 +2791,13 @@ static int decode_attr_group(struct xdr_
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
 
@@ -2820,7 +2820,7 @@ static int decode_attr_rdev(struct xdr_s
 			*rdev = tmp;
 		bitmap[1] &= ~ FATTR4_WORD1_RAWDEV;
 	}
-	dprintk("%s: rdev=(0x%x:0x%x)\n", __FUNCTION__, major, minor);
+	dprintk("%s: rdev=(0x%x:0x%x)\n", __func__, major, minor);
 	return 0;
 }
 
@@ -2837,7 +2837,7 @@ static int decode_attr_space_avail(struc
 		READ64(*res);
 		bitmap[1] &= ~FATTR4_WORD1_SPACE_AVAIL;
 	}
-	dprintk("%s: space avail=%Lu\n", __FUNCTION__, (unsigned long long)*res);
+	dprintk("%s: space avail=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
 }
 
@@ -2854,7 +2854,7 @@ static int decode_attr_space_free(struct
 		READ64(*res);
 		bitmap[1] &= ~FATTR4_WORD1_SPACE_FREE;
 	}
-	dprintk("%s: space free=%Lu\n", __FUNCTION__, (unsigned long long)*res);
+	dprintk("%s: space free=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
 }
 
@@ -2871,7 +2871,7 @@ static int decode_attr_space_total(struc
 		READ64(*res);
 		bitmap[1] &= ~FATTR4_WORD1_SPACE_TOTAL;
 	}
-	dprintk("%s: space total=%Lu\n", __FUNCTION__, (unsigned long long)*res);
+	dprintk("%s: space total=%Lu\n", __func__, (unsigned long long)*res);
 	return status;
 }
 
@@ -2887,7 +2887,7 @@ static int decode_attr_space_used(struct
 		READ64(*used);
 		bitmap[1] &= ~FATTR4_WORD1_SPACE_USED;
 	}
-	dprintk("%s: space used=%Lu\n", __FUNCTION__,
+	dprintk("%s: space used=%Lu\n", __func__,
 			(unsigned long long)*used);
 	return 0;
 }
@@ -2918,7 +2918,7 @@ static int decode_attr_time_access(struc
 		status = decode_attr_time(xdr, time);
 		bitmap[1] &= ~FATTR4_WORD1_TIME_ACCESS;
 	}
-	dprintk("%s: atime=%ld\n", __FUNCTION__, (long)time->tv_sec);
+	dprintk("%s: atime=%ld\n", __func__, (long)time->tv_sec);
 	return status;
 }
 
@@ -2934,7 +2934,7 @@ static int decode_attr_time_metadata(str
 		status = decode_attr_time(xdr, time);
 		bitmap[1] &= ~FATTR4_WORD1_TIME_METADATA;
 	}
-	dprintk("%s: ctime=%ld\n", __FUNCTION__, (long)time->tv_sec);
+	dprintk("%s: ctime=%ld\n", __func__, (long)time->tv_sec);
 	return status;
 }
 
@@ -2950,7 +2950,7 @@ static int decode_attr_time_modify(struc
 		status = decode_attr_time(xdr, time);
 		bitmap[1] &= ~FATTR4_WORD1_TIME_MODIFY;
 	}
-	dprintk("%s: mtime=%ld\n", __FUNCTION__, (long)time->tv_sec);
+	dprintk("%s: mtime=%ld\n", __func__, (long)time->tv_sec);
 	return status;
 }
 
@@ -2962,7 +2962,7 @@ static int verify_attr_len(struct xdr_st
 	if (unlikely(attrwords != nwords)) {
 		dprintk("%s: server returned incorrect attribute length: "
 			"%u %c %u\n",
-				__FUNCTION__,
+				__func__,
 				attrwords << 2,
 				(attrwords < nwords) ? '<' : '>',
 				nwords << 2);
@@ -3067,7 +3067,7 @@ static int decode_server_caps(struct xdr
 		goto xdr_error;
 	status = verify_attr_len(xdr, savep, attrlen);
 xdr_error:
-	dprintk("%s: xdr returned %d!\n", __FUNCTION__, -status);
+	dprintk("%s: xdr returned %d!\n", __func__, -status);
 	return status;
 }
 	
@@ -3100,7 +3100,7 @@ static int decode_statfs(struct xdr_stre
 
 	status = verify_attr_len(xdr, savep, attrlen);
 xdr_error:
-	dprintk("%s: xdr returned %d!\n", __FUNCTION__, -status);
+	dprintk("%s: xdr returned %d!\n", __func__, -status);
 	return status;
 }
 
@@ -3125,7 +3125,7 @@ static int decode_pathconf(struct xdr_st
 
 	status = verify_attr_len(xdr, savep, attrlen);
 xdr_error:
-	dprintk("%s: xdr returned %d!\n", __FUNCTION__, -status);
+	dprintk("%s: xdr returned %d!\n", __func__, -status);
 	return status;
 }
 
@@ -3193,7 +3193,7 @@ static int decode_getfattr(struct xdr_st
 	if ((status = verify_attr_len(xdr, savep, attrlen)) == 0)
 		fattr->valid = NFS_ATTR_FATTR | NFS_ATTR_FATTR_V3 | NFS_ATTR_FATTR_V4;
 xdr_error:
-	dprintk("%s: xdr returned %d\n", __FUNCTION__, -status);
+	dprintk("%s: xdr returned %d\n", __func__, -status);
 	return status;
 }
 
@@ -3226,7 +3226,7 @@ static int decode_fsinfo(struct xdr_stre
 
 	status = verify_attr_len(xdr, savep, attrlen);
 xdr_error:
-	dprintk("%s: xdr returned %d!\n", __FUNCTION__, -status);
+	dprintk("%s: xdr returned %d!\n", __func__, -status);
 	return status;
 }
 
@@ -3418,7 +3418,7 @@ static int decode_open(struct xdr_stream
 
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
diff -puN fs/nfs/proc.c~nfs-replace-remaining-__function__-occurrences fs/nfs/proc.c
--- a/fs/nfs/proc.c~nfs-replace-remaining-__function__-occurrences
+++ a/fs/nfs/proc.c
@@ -63,17 +63,17 @@ nfs_proc_get_root(struct nfs_server *ser
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
diff -puN fs/nfs/read.c~nfs-replace-remaining-__function__-occurrences fs/nfs/read.c
--- a/fs/nfs/read.c~nfs-replace-remaining-__function__-occurrences
+++ a/fs/nfs/read.c
@@ -329,7 +329,7 @@ int nfs_readpage_result(struct rpc_task 
 {
 	int status;
 
-	dprintk("NFS: %s: %5u, (status %d)\n", __FUNCTION__, task->tk_pid,
+	dprintk("NFS: %s: %5u, (status %d)\n", __func__, task->tk_pid,
 			task->tk_status);
 
 	status = NFS_PROTO(data->inode)->read_done(task, data);
diff -puN fs/nfs/super.c~nfs-replace-remaining-__function__-occurrences fs/nfs/super.c
--- a/fs/nfs/super.c~nfs-replace-remaining-__function__-occurrences
+++ a/fs/nfs/super.c
@@ -405,7 +405,7 @@ static int nfs_statfs(struct dentry *den
 	return 0;
 
  out_err:
-	dprintk("%s: statfs error = %d\n", __FUNCTION__, -error);
+	dprintk("%s: statfs error = %d\n", __func__, -error);
 	unlock_kernel();
 	return error;
 }
_
