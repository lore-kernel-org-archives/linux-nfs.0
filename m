From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 19/67] nfs41: introduce nfs4_call_sync
Date: Thu,  2 Apr 2009 16:52:54 +0300
Message-ID: <1238680374-13993-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:27876 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756517AbZDBNxA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:53:00 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Use nfs4_call_sync rather than rpc_call_sync to provide
for a nfs41 sessions-enabled interface for sessions manipulation.

The nfs41 rpc logic uses the rpc_call_prepare method to
recover and create the session, as well as selecting a free slot id
and the rpc_call_done to free the slot and update slot table
related metadata.

In the coming patches we'll add rpc prepare and done routines
for setting up the sequence op and processing the sequence result.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: nfs4_call_sync]
As per 11-14-08 review.
Squash into "nfs41: introduce nfs4_call_sync" and "nfs41: nfs4_setup_sequence"
Define two functions one for v4 and one for v41
add a pointer to struct nfs4_client to the correct one.
Signed-off-by: Andy Adamson <andros@netapp.com>
[added BUG() in _nfs4_call_sync_session if !CONFIG_NFS_V4_1]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: check for session not minorversion]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[group minorversion specific stuff together]
Signed-off-by: Alexandros Batsakis <Alexandros.Batsakis@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Andy Adamson <andros@netapp.com>
[nfs41: fixup nfs4_clear_client_minor_version]
[introduce nfs4_init_client_minor_version() in this patch]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[cleaned-up patch: got rid of nfs_call_sync_t, dprintks, cosmetics, extra server defs]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/client.c           |    5 +++
 fs/nfs/internal.h         |   12 ++++++++
 fs/nfs/nfs4proc.c         |   67 ++++++++++++++++++++++++++++++++-------------
 include/linux/nfs_fs_sb.h |    8 +++++
 4 files changed, 73 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index efbaba3..562f658 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -194,6 +194,8 @@ static void nfs4_clear_client_minor_version(struct nfs_client *clp)
 		nfs4_destroy_session(clp->cl_session);
 		clp->cl_session = NULL;
 	}
+
+	clp->cl_call_sync = _nfs4_call_sync;
 #endif /* CONFIG_NFS_V4_1 */
 }
 
@@ -1073,6 +1075,8 @@ error:
  */
 static int nfs4_init_client_minor_version(struct nfs_client *clp)
 {
+	clp->cl_call_sync = _nfs4_call_sync;
+
 #if defined(CONFIG_NFS_V4_1)
 	if (clp->cl_minorversion) {
 		struct nfs4_session *session = NULL;
@@ -1086,6 +1090,7 @@ static int nfs4_init_client_minor_version(struct nfs_client *clp)
 			return -ENOMEM;
 
 		clp->cl_session = session;
+		clp->cl_call_sync = _nfs4_call_sync_session;
 	}
 #endif /* CONFIG_NFS_V4_1 */
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 7cef45d..8d67c28 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -206,6 +206,18 @@ extern int nfs4_path_walk(struct nfs_server *server,
 			  const char *path);
 #endif
 
+/* nfs4proc.c */
+extern int _nfs4_call_sync(struct nfs_server *server,
+			   struct rpc_message *msg,
+			   struct nfs4_sequence_args *args,
+			   struct nfs4_sequence_res *res,
+			   int cache_reply);
+extern int _nfs4_call_sync_session(struct nfs_server *server,
+				   struct rpc_message *msg,
+				   struct nfs4_sequence_args *args,
+				   struct nfs4_sequence_res *res,
+				   int cache_reply);
+
 /*
  * Determine if sessions are in use.
  */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2fa9442..95c0ace 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -271,6 +271,33 @@ static void renew_lease(const struct nfs_server *server, unsigned long timestamp
 	spin_unlock(&clp->cl_lock);
 }
 
+#if defined(CONFIG_NFS_V4_1)
+
+int _nfs4_call_sync_session(struct nfs_server *server,
+			    struct rpc_message *msg,
+			    struct nfs4_sequence_args *args,
+			    struct nfs4_sequence_res *res,
+			    int cache_reply)
+{
+	/* in preparation for setting up the sequence op */
+	return rpc_call_sync(server->client, msg, 0);
+}
+
+#endif /* CONFIG_NFS_V4_1 */
+
+int _nfs4_call_sync(struct nfs_server *server,
+		    struct rpc_message *msg,
+		    struct nfs4_sequence_args *args,
+		    struct nfs4_sequence_res *res,
+		    int cache_reply)
+{
+	return rpc_call_sync(server->client, msg, 0);
+}
+
+#define nfs4_call_sync(server, msg, args, res, cache_reply) \
+	(server)->nfs_client->cl_call_sync((server), (msg), &(args)->seq_args, \
+			&(res)->seq_res, (cache_reply))
+
 static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo)
 {
 	struct nfs_inode *nfsi = NFS_I(dir);
@@ -1269,7 +1296,7 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 	} else
 		memcpy(&arg.stateid, &zero_stateid, sizeof(arg.stateid));
 
-	status = rpc_call_sync(server->client, &msg, 0);
+	status = nfs4_call_sync(server, &msg, &arg, &res, 1);
 	if (status == 0 && state != NULL)
 		renew_lease(server, timestamp);
 	return status;
@@ -1595,7 +1622,7 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 	};
 	int status;
 
-	status = rpc_call_sync(server->client, &msg, 0);
+	status = nfs4_call_sync(server, &msg, &args, &res, 0);
 	if (status == 0) {
 		memcpy(server->attr_bitmask, res.attr_bitmask, sizeof(server->attr_bitmask));
 		if (res.attr_bitmask[0] & FATTR4_WORD0_ACL)
@@ -1609,6 +1636,7 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 		server->cache_consistency_bitmask[1] &= FATTR4_WORD1_TIME_METADATA|FATTR4_WORD1_TIME_MODIFY;
 		server->acl_bitmask = res.acl_bitmask;
 	}
+
 	return status;
 }
 
@@ -1641,7 +1669,7 @@ static int _nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
 		.rpc_resp = &res,
 	};
 	nfs_fattr_init(info->fattr);
-	return rpc_call_sync(server->client, &msg, 0);
+	return nfs4_call_sync(server, &msg, &args, &res, 0);
 }
 
 static int nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
@@ -1731,7 +1759,7 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 	};
 	
 	nfs_fattr_init(fattr);
-	return rpc_call_sync(server->client, &msg, 0);
+	return nfs4_call_sync(server, &msg, &args, &res, 0);
 }
 
 static int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr)
@@ -1815,7 +1843,7 @@ static int _nfs4_proc_lookupfh(struct nfs_server *server, const struct nfs_fh *d
 	nfs_fattr_init(fattr);
 
 	dprintk("NFS call  lookupfh %s\n", name->name);
-	status = rpc_call_sync(server->client, &msg, 0);
+	status = nfs4_call_sync(server, &msg, &args, &res, 0);
 	dprintk("NFS reply lookupfh: %d\n", status);
 	return status;
 }
@@ -1901,7 +1929,7 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 			args.access |= NFS4_ACCESS_EXECUTE;
 	}
 	nfs_fattr_init(&fattr);
-	status = rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
+	status = nfs4_call_sync(server, &msg, &args, &res, 0);
 	if (!status) {
 		entry->mask = 0;
 		if (res.access & NFS4_ACCESS_READ)
@@ -1967,7 +1995,7 @@ static int _nfs4_proc_readlink(struct inode *inode, struct page *page,
 		.rpc_resp = &res,
 	};
 
-	return rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
+	return nfs4_call_sync(NFS_SERVER(inode), &msg, &args, &res, 0);
 }
 
 static int nfs4_proc_readlink(struct inode *inode, struct page *page,
@@ -2061,7 +2089,7 @@ static int _nfs4_proc_remove(struct inode *dir, struct qstr *name)
 	int			status;
 
 	nfs_fattr_init(&res.dir_attr);
-	status = rpc_call_sync(server->client, &msg, 0);
+	status = nfs4_call_sync(server, &msg, &args, &res, 1);
 	if (status == 0) {
 		update_changeattr(dir, &res.cinfo);
 		nfs_post_op_update_inode(dir, &res.dir_attr);
@@ -2129,7 +2157,7 @@ static int _nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
 	
 	nfs_fattr_init(res.old_fattr);
 	nfs_fattr_init(res.new_fattr);
-	status = rpc_call_sync(server->client, &msg, 0);
+	status = nfs4_call_sync(server, &msg, &arg, &res, 1);
 
 	if (!status) {
 		update_changeattr(old_dir, &res.old_cinfo);
@@ -2178,7 +2206,7 @@ static int _nfs4_proc_link(struct inode *inode, struct inode *dir, struct qstr *
 
 	nfs_fattr_init(res.fattr);
 	nfs_fattr_init(res.dir_attr);
-	status = rpc_call_sync(server->client, &msg, 0);
+	status = nfs4_call_sync(server, &msg, &arg, &res, 1);
 	if (!status) {
 		update_changeattr(dir, &res.cinfo);
 		nfs_post_op_update_inode(dir, res.dir_attr);
@@ -2239,7 +2267,8 @@ static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
 
 static int nfs4_do_create(struct inode *dir, struct dentry *dentry, struct nfs4_createdata *data)
 {
-	int status = rpc_call_sync(NFS_CLIENT(dir), &data->msg, 0);
+	int status = nfs4_call_sync(NFS_SERVER(dir), &data->msg,
+				    &data->arg, &data->res, 1);
 	if (status == 0) {
 		update_changeattr(dir, &data->res.dir_cinfo);
 		nfs_post_op_update_inode(dir, data->res.dir_fattr);
@@ -2348,7 +2377,7 @@ static int _nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 			(unsigned long long)cookie);
 	nfs4_setup_readdir(cookie, NFS_COOKIEVERF(dir), dentry, &args);
 	res.pgbase = args.pgbase;
-	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
+	status = nfs4_call_sync(NFS_SERVER(dir), &msg, &args, &res, 0);
 	if (status == 0)
 		memcpy(NFS_COOKIEVERF(dir), res.verifier.data, NFS4_VERIFIER_SIZE);
 
@@ -2436,7 +2465,7 @@ static int _nfs4_proc_statfs(struct nfs_server *server, struct nfs_fh *fhandle,
 	};
 
 	nfs_fattr_init(fsstat->fattr);
-	return rpc_call_sync(server->client, &msg, 0);
+	return  nfs4_call_sync(server, &msg, &args, &res, 0);
 }
 
 static int nfs4_proc_statfs(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fsstat *fsstat)
@@ -2467,7 +2496,7 @@ static int _nfs4_do_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle,
 		.rpc_resp = &res,
 	};
 
-	return rpc_call_sync(server->client, &msg, 0);
+	return nfs4_call_sync(server, &msg, &args, &res, 0);
 }
 
 static int nfs4_do_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fsinfo *fsinfo)
@@ -2512,7 +2541,7 @@ static int _nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle
 	}
 
 	nfs_fattr_init(pathconf->fattr);
-	return rpc_call_sync(server->client, &msg, 0);
+	return nfs4_call_sync(server, &msg, &args, &res, 0);
 }
 
 static int nfs4_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
@@ -2784,7 +2813,7 @@ static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bu
 		resp_buf = buf;
 		buf_to_pages(buf, buflen, args.acl_pages, &args.acl_pgbase);
 	}
-	ret = rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
+	ret = nfs4_call_sync(NFS_SERVER(inode), &msg, &args, &res, 0);
 	if (ret)
 		goto out_free;
 	if (res.acl_len > args.acl_len)
@@ -2857,7 +2886,7 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
 		return -EOPNOTSUPP;
 	nfs_inode_return_delegation(inode);
 	buf_to_pages(buf, buflen, arg.acl_pages, &arg.acl_pgbase);
-	ret = rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
+	ret = nfs4_call_sync(server, &msg, &arg, &res, 1);
 	nfs_access_zap_cache(inode);
 	nfs_zap_acl_cache(inode);
 	return ret;
@@ -3146,7 +3175,7 @@ static int _nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct file_lock
 		goto out;
 	lsp = request->fl_u.nfs4_fl.owner;
 	arg.lock_owner.id = lsp->ls_id.id;
-	status = rpc_call_sync(server->client, &msg, 0);
+	status = nfs4_call_sync(server, &msg, &arg, &res, 1);
 	switch (status) {
 		case 0:
 			request->fl_type = F_UNLCK;
@@ -3739,7 +3768,7 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 	nfs_fattr_init(&fs_locations->fattr);
 	fs_locations->server = server;
 	fs_locations->nlocations = 0;
-	status = rpc_call_sync(server->client, &msg, 0);
+	status = nfs4_call_sync(server, &msg, &args, &res, 0);
 	nfs_fixup_referral_attributes(&fs_locations->fattr);
 	dprintk("%s: returned status = %d\n", __func__, status);
 	return status;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 283ef0a..d541a49 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -12,6 +12,9 @@
 struct nfs4_session;
 struct nfs_iostats;
 struct nlm_host;
+struct nfs4_sequence_args;
+struct nfs4_sequence_res;
+struct nfs_server;
 
 /*
  * The nfs_client identifies our client state to the server.
@@ -67,6 +70,11 @@ struct nfs_client {
 	char			cl_ipaddr[48];
 	unsigned char		cl_id_uniquifier;
 	u32			cl_minorversion;
+	int		     (* cl_call_sync)(struct nfs_server *server,
+					      struct rpc_message *msg,
+					      struct nfs4_sequence_args *args,
+					      struct nfs4_sequence_res *res,
+					      int cache_reply);
 #endif /* CONFIG_NFS_V4 */
 
 #ifdef CONFIG_NFS_V4_1
-- 
1.6.2.1

